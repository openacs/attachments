ad_library {

    Utilities to attach files to an object in the context of richtext
    editors.

    @author Gustaf Neumann, Antonio Pisano.
    @creation-date 15 Aug 2017

}

namespace eval attachments::richtext {

    ad_proc -public file_attach {
        -import_file
        -title
        -mime_type
        -object_id
        {-privilege read}
        -user_id
        -peeraddr
        -package_id
    } {

        Insert the provided file to the content repository as a
        new item and attach it to the specified object_id via
        the attachment API. This makes sure that the file will be
        deleted from the content repository, when the provided
        object_id is deleted.

        The user must have at least "read" privileges on the object,
        but other stronger privileges can be supplied via parameter.

    } {
        permission::require_permission \
            -party_id $user_id \
            -object_id $object_id \
            -privilege $privilege

        set success 1

        #
        # Create a new item
        #
        set name $object_id-[clock clicks -microseconds]
        if {![info exists title]} {
            set title $name
        }
       set item_id [::content::item::new \
                         -name            $name \
                         -parent_id       [require_root_folder] \
                         -title           $title \
                         -context_id      $object_id \
                         -creation_user   $user_id \
                         -creation_ip     $peeraddr \
                         -storage_type    "file" \
                         -package_id      $package_id \
                         -tmp_filename    $import_file \
                         -is_live         t]

        #
        # Attach the file to the object via the attachments API
        #
        attachments::attach \
            -object_id $object_id \
            -attachment_id $item_id

        return [list \
                    success $success \
                    name $name \
                    item_id $item_id
                   ]
    }

    ad_proc -private require_root_folder {
        {-parent_id -100}
        {-name attachments}
    } {

        Helper function to find the root folder for ckfinder
        attachments.

    } {
        set root_folder_id [content::item::get_id \
                                -root_folder_id $parent_id \
                                -item_path $name]
        if {$root_folder_id eq ""} {
            set root_folder_id [content::item::new \
                                    -name $name \
                                    -parent_id $parent_id]
        }
        return $root_folder_id
    }


}

#
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
