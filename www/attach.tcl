ad_page_contract {

    Attach something to an object

    @author arjun@openforce.net
    @author ben@openforce
    @cvs-id $Id$

} -query {
    {object_id:notnull}
    {folder_id ""}
    {pretty_object_name ""}
    {return_url:notnull}
}

set user_id [ad_conn user_id]

# We require the write permission on an object
permission::require_permission -object_id $object_id -privilege write

# Give the object a nasty name if it doesn't have a pretty name
if {[empty_string_p $pretty_object_name]} {
    set pretty_object_name "[_ attachments.Object] #$object_id"
}

# Load up file storage information
if {[empty_string_p $folder_id]} {
    set folder_id [dotlrn_fs::get_user_shared_folder -user_id $user_id]
} 

# sanity check
if {[empty_string_p $folder_id]} {
    ad_return_complaint 1 "[_ attachments.lt_Error_empty_folder_id]"
    ad_script_abort
}

set write_permission_p \
        [permission::permission_p -object_id $folder_id -privilege write]

# Check permission
permission::require_permission -object_id $folder_id -privilege read

# Size of contents
set n_contents [fs::get_folder_contents_count -folder_id $folder_id -user_id $user_id]

# Folder name
set folder_name [lang::util::localize [fs::get_object_name -object_id $folder_id]]

# Folder contents
db_multirow -unclobber contents select_folder_contents {} {
    set name [lang::util::localize $name]
}

set passthrough_vars "object_id=$object_id&return_url=[ns_urlencode $return_url]&pretty_object_name=[ns_urlencode $pretty_object_name]"

set fs_context_bar_html [attachments::context_bar -extra_vars $passthrough_vars -folder_id $folder_id]

set context "[_ attachments.Attach]"

