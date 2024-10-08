#
#  This is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  This is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

ad_library {
    Attachments

    @author Arjun Sanyal (arjun@openforce.net)
    @cvs-id $Id$
}

namespace eval attachments {

    ad_proc -public root_folder_p {
        {-package_id:required}
    } {
        @return 1 if the package_id has an fs_folder mapped to it
    } {
        return [db_string root_folder_p_select {} -default 0]
    }

    ad_proc -public get_root_folder {
        {-package_id ""}
    } {
        @param package_id when omitted, will default to the package
                          mounted on the current node's parent.
        @return the attachment root folder id for the package.
    } {
        if {$package_id eq ""} {
            # Get the package ID from the parent URL
            array set parent_node [site_node::get_parent -node_id [ad_conn node_id]]
            set package_id $parent_node(object_id)
        }

        return [db_string get_root_folder_select {} -default {}]
    }

    ad_proc -deprecated root_folder_map_p {
        {-package_id:required}
    } {
        @return 1 if the package_id has an fs_folder mapped to it

        @see attachments::root_folder_p
    } {
        # this is a duplicate (Ben)
        return [root_folder_p -package_id $package_id]
    }

    ad_proc -public map_root_folder {
        {-package_id:required}
        {-folder_id:required}
    } {
        Designate a folder as the attachment root folder for a
        package.
    } {
        db_dml map_root_folder_insert {}
    }

    ad_proc -public unmap_root_folder {
        {-package_id:required}
        {-folder_id:required}
    } {
        Designate a folder as the attachment root folder for a
        package.
    } {
        db_dml unmap_root_folder_delete {}
    }

    ad_proc -public attach {
        {-object_id:required}
        {-attachment_id:required}
        {-approved_p t}
    } {
        perform the attachment
    } {
        db_dml insert_attachment {}
    }

    ad_proc -public unattach {
        {-object_id:required}
        {-attachment_id:required}
    } {
        undo the attachment
    } {
        db_dml delete_attachment {}
    }

    ad_proc -public toggle_approved {
        {-object_id:required}
        {-item_id:required}
        {-approved_p ""}
    } {
        toggle approved_p for attachment
    } {
        db_dml toggle_approved_p {}
    }

    ad_proc -public get_package_key {} {
        @return the package key (attachments)
    } {
        return attachments
    }

    ad_proc -public get_url {} {
        @return the value of the RelativeUrl package parameter
    } {
        return [parameter::get  \
            -package_id [apm_package_id_from_key [get_package_key]] \
            -parameter RelativeUrl
        ]
    }

    ad_proc -private get_attachments_url {
        {-base_url ""}
    } {

        As 'attachments::get_url' returns the value of the attachments package
        'RelativeUrl' parameter, which can change at any time, it could happen
        that previously mounted attachments have a different url and are not
        found anymore.

        We try our best here to find a mounted attachments package under
        'base_url' to mitigate this, probably flawed, package logic.

        In the future, probably a better method should be used for URL resolving
        that is not so broken.

        The whole thing is even more weird, as the attachments package is
        currently a singleton that auto-mounts on /attachments, so i am tempted
        to replace this whole thing with just that, but anyway...

        @param base_url The base URL where to look for the attachments package.

        @return The attachments package URL under 'base_url', or "" if none is
                found.

        @see attachments::get_url

    } {
        if {![ns_conn isconnected]} {
            return "${base_url}[attachments::get_url]"
        } else {
            #
            # Get some context
            #
            set url             "[ad_conn package_url]${base_url}"
            set relative_url    "${url}[attachments::get_url]"
            #
            # Is this URL an attachments package? Otherwise try to find one...
            #
            set package_key [dict get [site_node::get_from_url -url "$relative_url"] package_key]
            if {$package_key eq "attachments"} {
                return $relative_url
            } else {
                set url_node_id [site_node::get_node_id -url $url]
                return [site_node::get_children \
                            -package_key "attachments" \
                            -element "url" \
                            -node_id $url_node_id]
            }
        }
    }

    ad_proc -public add_attachment_url {
        {-folder_id ""}
        {-package_id ""}
        {-object_id:required}
        {-return_url ""}
        {-pretty_name ""}
    } {
        @return the url that can be used to attach something to an object
    } {
        return "[get_attachments_url]/attach?pretty_object_name=[ns_urlencode $pretty_name]&folder_id=$folder_id&object_id=$object_id&return_url=[ns_urlencode $return_url]"
    }

    ad_proc -public goto_attachment_url {
        {-package_id ""}
        {-object_id:required}
        {-attachment_id:required}
        {-base_url ""}
    } {
        @return the url to go to an attachment
    } {
        return "[get_attachments_url -base_url ${base_url}]/go-to-attachment?object_id=$object_id&attachment_id=$attachment_id"
    }

    ad_proc -public detach_url {
        {-package_id ""}
        {-object_id:required}
        {-attachment_id:required}
        {-base_url ""}
        {-return_url ""}
    } {
        @return the url to detach an attached item from an object
    } {
        return "[get_attachments_url -base_url ${base_url}]/detach?object_id=$object_id&attachment_id=$attachment_id&return_url=[ad_urlencode $return_url]"
    }

    ad_proc -public graphic_url {
        {-package_id ""}
    } {
        @return the attachment icon
    } {
        return "<img valign=bottom src=\"[attachments::get_url]/graphics/file.gif\">"
    }

    ad_proc -public get_attachments {
        {-object_id:required}
        {-base_url ""}
        {-return_url ""}
    } {
        @return a list of attachment ids and names which are approved:
        {item_id name url detach_url}
    } {
        return [get_all_attachments \
                    -object_id $object_id \
                    -base_url $base_url \
                    -return_url $return_url \
                    -approved_only -add_detach_url]
    }

    ad_proc -public get_title {
        {-attachment_id:required}
    } {
        @param attachment_id ID of the attachment (item_id)
        @return The title of the attachment (string)
    } {
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
                        -object_type $object_type \
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

        return $title
    }

    ad_proc -public get_all_attachments {
        {-object_id:required}
        {-base_url ""}
        {-return_url ""}
        -approved_only:boolean
        -add_detach_url:boolean
    } {
        @return a list representing attachments and their UI URLs.

        @param object_id object to check for attachments.
        @param base_url URL path that will be prepended to generated URLs.
        @param return_url only meaningful if we are also generating
                          detach_url, is the location we will return
                          to after detaching.
        @param approved_only flag deciding if we want to return only
                             attachments that have been approved. All
                             attachments will be returned when this is
                             not specified.
        @param add_detach_url flag deciding whether we want to
                              generate also detach_url in the result.

        @return list of lists in the format {item_id name url} or
                {item_id name url detach_url} when
                <code>add_detach_url</code> is specified.
    } {
        set lst_with_urls [list]

        foreach item_id [db_list_of_lists select_attachments {
            select item_id from attachments
             where object_id = :object_id
               and (not :approved_only_p or approved_p)}] {
            #
            # Set the attachment 'label'
            #
            set label [attachments::get_title -attachment_id $item_id]
            #
            # Set the attachment URL
            #
            set url [goto_attachment_url \
                         -object_id     $object_id \
                         -attachment_id $item_id \
                         -base_url      $base_url]
            set element [list $item_id $label $url]
            if {$add_detach_url_p} {
                lappend element [detach_url \
                                     -object_id     $object_id \
                                     -attachment_id $item_id \
                                     -base_url      $base_url \
                                     -return_url    $return_url]
            }
            lappend lst_with_urls $element
        }

        return $lst_with_urls
    }

    ad_proc -public context_bar {
        {-folder_id:required}
        {-final ""}
        {-extra_vars ""}
        {-multirow "fs_context"}
    } {
        Create a multirow with cols (url title) for the file-storage bar
        starting at folder_id
    } {

        set root_folder_id [attachments::get_root_folder]

        set cbar_list [fs_context_bar_list -extra_vars $extra_vars -folder_url "attach" -file_url "attach" -root_folder_id $root_folder_id -final $final $folder_id]

        template::multirow create $multirow url label

        if { $root_folder_id ne "" && $cbar_list ne "" } {
            template::multirow append $multirow "attach?${extra_vars}&folder_id=$root_folder_id" [_ attachments.Top]
            foreach elm $cbar_list {
                if { [llength elm] > 1 } {
                    template::multirow append $multirow [lindex $elm 0] [lindex $elm 1]
                } else {
                    template::multirow append $multirow "" $elm
                }
            }
        } else {
            template::multirow append $multirow "" [_ attachments.Top]
        }
    }

}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
