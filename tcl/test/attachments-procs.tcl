ad_library {
    Automated tests.

    @author Héctor Romojaro <hector.romojaro@gmail.com>
    @creation-date 18 February 2021
    @cvs-id $Id$
}

aa_register_case -procs {
    attachments::get_all_attachments
    attachments::get_attachments
    attachments::attach
    attachments::unattach
    attachments::toggle_approved
} -cats {
    api
} attachments_basic_api {
    Test attachments basic api.
} {
    aa_run_with_teardown -rollback -test_code {
        #
        # Create test objects
        #
        set object_id       [package_instantiate_object acs_object]
        set attachment1_id  [package_instantiate_object acs_object]
        set attachment2_id  [package_instantiate_object acs_object]
        set attachment_ids  [lsort [list $attachment1_id $attachment2_id]]
        #
        # Check that there are no attachments in new object
        #
        aa_equals "Check for attachments on new object" \
            [attachments::get_all_attachments -object_id $object_id] ""
        #
        # Check attachments in object
        #
        attachments::attach \
            -object_id $object_id \
            -attachment_id $attachment1_id \
            -approved_p f
        attachments::attach \
            -object_id $object_id \
            -attachment_id $attachment2_id \
            -approved_p f
        set attachment_list [attachments::get_all_attachments \
                                -object_id $object_id]
        set attachment_list_ids [lsort [lmap x $attachment_list {lindex $x 0}]]
        aa_equals "Check for new attachments object" \
           "$attachment_list_ids" "$attachment_ids"
        #
        # Check for approved/not approved attachments
        #
        attachments::toggle_approved \
            -object_id $object_id \
            -item_id $attachment1_id
        set approved_attachments_list [attachments::get_attachments \
                                        -object_id $object_id]
        set approved_attachments_ids [lsort \
            [lmap x $approved_attachments_list {lindex $x 0}]]
        aa_equals "Check for approved attachments after toggle" \
           "$attachment1_id" "$approved_attachments_ids"
        attachments::toggle_approved \
            -object_id $object_id \
            -item_id $attachment1_id
        aa_equals "Check for approved attachments after toggle (1)" \
            "[attachments::get_attachments -object_id $object_id]" ""
        aa_equals "Check for approved attachments after toggle (2)" \
            [attachments::get_all_attachments \
                -object_id $object_id \
                -approved_only] ""
        #
        # Check that there are no attachments after unattaching
        #
        attachments::unattach \
            -object_id $object_id \
            -attachment_id $attachment1_id
        attachments::unattach \
            -object_id $object_id \
            -attachment_id $attachment2_id
        aa_equals "Check for attachments after unattaching" \
            [attachments::get_all_attachments -object_id $object_id] ""
    }
}

aa_register_case -procs {
    content::item::get_descendants
    attachments::get_root_folder
} -cats {
    api
    production_safe
} attachments_package_key {
    Test attachments::get_package_key.
} {
    aa_equals "Package_key" [attachments::get_package_key] "attachments"
}

aa_register_case -procs {
    attachments::get_title
    acs_object_type
    content::extlink::is_extlink
    content::extlink::name
    content::item::is_subclass
    content::revision::get_title
    acs_object::get_element
} -cats {
    api smoke production_safe
} attachments_name_api {
    Test attachments name api.
} {
    foreach attachment_id [db_list get_attachments {
        select item_id from attachments fetch first 10 rows only
    }] {
        #
        # Try our best to get the 'title', depending on the object type
        #
        set title ""
        set object_type [acs_object_type $attachment_id]
        if {[content::extlink::is_extlink -item_id $attachment_id]} {
            #
            # URL
            #
            set title [content::extlink::name -item_id $attachment_id]
        } elseif {[content::item::is_subclass \
                       -object_type $object_type \
                       -supertype "content_item"]} {
            #
            # Content item, or subtype
            #
            set title [content::item::get_title -item_id $attachment_id]
        } elseif {[content::item::is_subclass \
                       -object_type $object_type  \
                       -supertype "content_revision"]} {
            #
            # Content revision, or subtype
            #
            set title [content::revision::get_title -revision_id $attachment_id]
        } else {
            #
            # Let's try the 'title' column on 'acs_objects'
            #
            set title [acs_object::get_element \
                           -object_id $attachment_id \
                           -element "title"]
        }
        #
        # If everything fails, set the 'attachment_id' as title
        #
        if {$title eq ""} {
            set title $attachment_id
        }

        aa_equals "Name for attachment '$attachment_id' is expected" \
            $title [attachments::get_title -attachment_id $attachment_id]
    }
}

aa_register_case -procs {
    attachments::get_url
    attachments::get_attachments_url
    attachments::add_attachment_url
    attachments::detach_url
    attachments::goto_attachment_url
    attachments::graphic_url
    attachments::context_bar
    attachments::get_root_folder
    fs_context_bar_list
} -cats {
    api smoke production_safe
} attachments_url_api {
    Test attachments URL api.
} {
    set system_url [acs::test::url]


    aa_section "Attachments URL"

    set attachments_url [attachments::get_attachments_url]
    aa_false "'$attachments_url' is a local URL" [util::external_url_p $attachments_url]
    aa_true "'$attachments_url' is a valid URL" [util_url_valid_p -relative $attachments_url]
    aa_true "'$system_url/$attachments_url' is a valid URL" \
        [util_url_valid_p $system_url/$attachments_url]


    aa_section "Add Attachment URL"

    set add_attachment_url [attachments::add_attachment_url \
                                -folder_id 1234 \
                                -package_id 5678 \
                                -object_id 91011 \
                                -return_url a&b \
                                -pretty_name c&d \
                               ]
    aa_false "'$add_attachment_url' is a local URL" [util::external_url_p $add_attachment_url]
    aa_true "'$add_attachment_url' is a valid URL" [util_url_valid_p -relative $add_attachment_url]
    aa_true "'$add_attachment_url' starts by '$attachments_url'" \
        [regexp ^/?${attachments_url}.*$ $add_attachment_url]
    aa_true "'$add_attachment_url' contains '1234'" {
        [string first 1234 $add_attachment_url] >= 0
    }
    #
    # TODO: this fails because package_id is not used into the
    # API. This should be fixed somehow.
    #
    # aa_true "'$add_attachment_url' contains '5678'" {
    #     [string first 5678 $add_attachment_url] >= 0
    # }
    aa_true "'$add_attachment_url' contains '91011'" {
        [string first 91011 $add_attachment_url] >= 0
    }
    aa_true "'$add_attachment_url' contains '[ns_urlencode a&b]'" {
        [string first [ns_urlencode a&b] $add_attachment_url] >= 0
    }
    aa_true "'$add_attachment_url' contains '[ns_urlencode c&d]'" {
        [string first [ns_urlencode c&d] $add_attachment_url] >= 0
    }


    aa_section "Remove Attachment URL"

    set detach_url [attachments::detach_url \
                        -package_id 1234 \
                        -object_id 5678 \
                        -attachment_id 91011 \
                        -return_url c&d]
    aa_false "'$detach_url' is a local URL" [util::external_url_p $detach_url]
    aa_true "'$detach_url' is a valid URL" [util_url_valid_p -relative $detach_url]
    aa_true "'$detach_url' starts by '$attachments_url'" \
        [regexp ^/?${attachments_url}.*$ $detach_url]
    #
    # TODO: this fails because package_id is not used into the
    # API. This should be fixed somehow.
    #
    # aa_true "'$detach_url' contains '1234'" {
    #     [string first 1234 $detach_url] >= 0
    # }
    aa_true "'$detach_url' contains '5678'" {
        [string first 5678 $detach_url] >= 0
    }
    aa_true "'$detach_url' contains '91011'" {
        [string first 91011 $detach_url] >= 0
    }
    aa_true "'$detach_url' contains '[ns_urlencode c&d]'" {
        [string first [ns_urlencode c&d] $detach_url] >= 0
    }


    aa_section "Go to Attachment URL"

    set go_to_attachment_url [attachments::goto_attachment_url \
                                  -package_id 1234 \
                                  -object_id 5678 \
                                  -attachment_id 91011]
    aa_false "'$go_to_attachment_url' is a local URL" [util::external_url_p $go_to_attachment_url]
    aa_true "'$go_to_attachment_url' is a valid URL" [util_url_valid_p -relative $go_to_attachment_url]
    aa_true "'$go_to_attachment_url' starts by '$attachments_url'" \
        [regexp ^/?${attachments_url}.*$ $go_to_attachment_url]
    #
    # TODO: this fails because package_id is not used into the
    # API. This should be fixed somehow.
    #
    # aa_true "'$go_to_attachment_url' contains '1234'" {
    #     [string first 1234 $go_to_attachment_url] >= 0
    # }
    aa_true "'$go_to_attachment_url' contains '5678'" {
        [string first 5678 $go_to_attachment_url] >= 0
    }
    aa_true "'$go_to_attachment_url' contains '91011'" {
        [string first 91011 $go_to_attachment_url] >= 0
    }


    aa_section "Graphics URL"

    set graphic_html [attachments::graphic_url]
    aa_true "Tag contains '[attachments::get_url]'" {
        [string first [attachments::get_url] $graphic_html] >= 0
    }
    aa_true "The graphics are in HTML form" [regexp -nocase {^<img.*$} $graphic_html]


    aa_section "Attachment Context-Bar"

    set root_folder_id [attachments::get_root_folder]
    set folder_id [db_string get_any_attachment_folder {
        select coalesce(max(f.folder_id), :root_folder_id)
        from cr_folders f, cr_items i
        where f.folder_id = i.item_id
          and i.parent_id = :root_folder_id
    } -default ""]
    set extra_vars {a 1 b 2 c 3}
    set cbar_list [fs_context_bar_list \
                       -extra_vars $extra_vars \
                       -folder_url "attach" \
                       -file_url "attach" \
                       -root_folder_id $root_folder_id \
                       -final t $folder_id]

    attachments::context_bar \
        -folder_id $folder_id \
        -extra_vars $extra_vars \
        -final t \
        -multirow attachments_test_multirow

    aa_true "Multirow 'attachments_test_multirow' was created" \
        [template::multirow exists attachments_test_multirow]
    aa_equals "Multirow length is expected" \
        [template::multirow size attachments_test_multirow] \
        [expr {[llength $cbar_list] + 1}]
}

aa_register_case -procs {
    attachments::map_root_folder
    attachments::unmap_root_folder
    attachments::root_folder_p
} -cats {
    api smoke production_safe
} attachments_map_folder {
    Test attachments::map_root_folder api.
} {
    aa_run_with_teardown -rollback -test_code {
        set package_id [db_string get_a_package {
            select max(package_id) from apm_packages p
            where not exists (select 1 from attachments_fs_root_folder_map
                              where package_id = p.package_id)
        } -default ""]
        set folder_id [db_string get_a_folder {
            select max(folder_id) from fs_root_folders f
            where not exists (select 1 from attachments_fs_root_folder_map
                              where folder_id = f.folder_id)
        } -default ""]
        if { $package_id ne "" && $folder_id ne "" } {

            aa_false "Package does not refer to a root_folder" \
                [attachments::root_folder_p -package_id $package_id]

            aa_log "Mapping package '$package_id' to folder '$folder_id'"
            attachments::map_root_folder \
                -package_id $package_id \
                -folder_id $folder_id

            aa_true "Package now refers to a root_folder" \
                [attachments::root_folder_p -package_id $package_id]

            aa_true "A mapping was inserted" [db_0or1row check {
                select 1 from attachments_fs_root_folder_map
                where package_id = :package_id and folder_id = :folder_id
            }]

            aa_log "Remove the mapping"
            attachments::unmap_root_folder \
                -package_id $package_id \
                -folder_id $folder_id

            aa_false "Package does not refer to a root_folder anymore" \
                [attachments::root_folder_p -package_id $package_id]
        } else {
            aa_log "Cannot test mapping, not package or root folders to choose."
        }
    }
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
