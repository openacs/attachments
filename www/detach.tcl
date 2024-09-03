# packages/attachments/www/detach.tcl

ad_page_contract {

    detaches an attached item from an object

    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2006-07-13
    @cvs-id $Id$
} {
    object_id:naturalnum,notnull
    attachment_id:naturalnum,notnull
    {return_url:localurl ""}
} -properties {
} -validate {
} -errors {
}

set user_id [auth::require_login]
#
# Require write permission on the object to remove its attachments
#
permission::require_permission -object_id $object_id -privilege write
#
# Message keys
#
set object_name     [acs_object_name $object_id]
set attachment_name [attachments::get_title -attachment_id $attachment_id]
set title           "[_ attachments.Detach_file_from]"
set context         "[_ attachments.Detach]"
#
# Is the attachment attached to other objects?
#
set attached_to_other_objects_p [db_string attached_to_others {
    select case when exists (
         select *
           from attachments
          where item_id = :attachment_id
            and object_id <> :object_id
    ) then 1 else 0 end;
}]
#
# Is the attachment inside the file storage?
#
set is_in_file_storage_p [db_string is_in_fs_files {
    select case when exists (
         select *
           from fs_files
          where file_id = :attachment_id
    ) then 1 else 0 end;
}]
#
# Define form elements
#
set form_elements {
    {inform:text(inform) {label {}} {value "[_ attachments.Are_you_sure_detach]"}}
    {attachment_name:text(inform) {label "[_ attachments.Attachment]"}}
    {object_name:text(inform) {label "[_ attachments.on_Object]"}}
}
if {$is_in_file_storage_p} {
    if {$attached_to_other_objects_p} {
        append form_elements {
            {count_info:text(inform) {label {}} {value "[_ attachments.Only_detach]"}}
            {detach:text(submit) {label "[_ attachments.Detach]"}}
        }
    } else {
        append form_elements {
            {count_info:text(inform) {label {}} {value "[_ attachments.Can_delete]"}}
            {detach:text(submit) {label "[_ attachments.Detach]"}}
            {delete_button:text(submit) {label "[_ attachments.delete_from_fs]"}}
        }
    }
} else {
    append form_elements {
        {detach:text(submit) {label "[_ attachments.Detach]"}}
    }
}
#
# Declare form
#
ad_form \
    -name detach \
    -export { object_id attachment_id return_url } \
    -form $form_elements \
    -cancel_url $return_url \
    -on_request {} \
    -on_submit {
        attachments::unattach -object_id $object_id -attachment_id $attachment_id
        if {[info exists delete_button]
            && $delete_button ne ""
            && !$attached_to_other_objects_p
            && $is_in_file_storage_p
        } {
           fs::delete_file -item_id $attachment_id
        }
    } -after_submit {
        ad_returnredirect $return_url
        ad_script_abort
    }

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
