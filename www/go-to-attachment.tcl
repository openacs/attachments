ad_page_contract {
    Go to an attachment

    @author Ben Adida (ben@openforce.net)
} {
    {object_id:naturalnum,notnull}
    {attachment_id:naturalnum,notnull}
}
#
# We check permissions on the object
#
permission::require_permission -object_id $object_id -privilege read
#
# Get information about the attachment, and act depending on type
#
set object_type [acs_object_type $attachment_id]
if {$object_type eq ""} {
    #
    # No object type
    #
    ad_return_complaint 1 [_ attachments.lt_No_such_attachment_fo]
    return
} elseif {[content::extlink::is_extlink -item_id $attachment_id]} {
    #
    # URL
    #
    ad_returnredirect [db_string select_url {}]
    ad_script_abort
    return
} elseif {[content::item::is_subclass \
                -object_type $object_type \
                -supertype "content_item"]} {
    #
    # Content item, or subtype
    #
    db_1row select_attachment_info {}
    if {[parameter::get -package_id $package_id -parameter BehaveLikeFilesystemP -default 0]} {
        set filename $title
    } else {
        set filename $name
    }
} elseif {[content::item::is_subclass \
                -object_type $object_type \
                -supertype "content_revision"]} {
    #
    # Content revision, or subtype
    #
    db_1row select_attachment_info_specific_revision {}
    set filename $title
} else {
    #
    # Not a known object type, just give up
    #
    ad_return_complaint 1 [_ attachments.lt_dont_know_how_to_deal [list content_type $content_type]]
    return
}
#
# Test if the filename contains the extension, otherwise append it
# This usually happens if you just rename the title (displayed filename) but
# forget to append the extension to it.
#
#file extension return "." extension without "."
set file_extension_aux  [concat .$file_extension]
set extension           [file extension $filename]
if {$extension ne $file_extension_aux} {
    append filename ".${file_extension}"
}
#
# Redirect finally
#
ad_returnredirect "download/[ad_urlencode $filename]?object_id=$object_id&attachment_id=$attachment_id"
ad_script_abort
return

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
