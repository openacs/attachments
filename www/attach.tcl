
ad_page_contract {

    Attach something to an object

    @author arjun@openforce.net,ben@openforce
    @version $Id$

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
    set pretty_object_name "Object #$object_id"
}

# Load up file storage information

if {[empty_string_p $folder_id]} {
    set folder_id [attachments::get_root_folder]
}

# Check permission
permission::require_permission -object_id $folder_id -privilege read

# Size of contents
set n_contents [fs::get_folder_contents_count -folder_id $folder_id -user_id $user_id]

# Folder name
set folder_name [fs::get_object_name -object_id $folder_id]

# Folder contents
set rows [fs::get_folder_contents \
    -folder_id $folder_id \
    -user_id $user_id]

template::util::list_of_ns_sets_to_multirow -rows $rows -var_name "contents"

set fs_context_bar [fs_context_bar_list -root_folder_id [attachments::get_root_folder] -final "Attach" $folder_id]

set passthrough_vars "object_id=$object_id&return_url=[ns_urlencode $return_url]&pretty_object_name=[ns_urlencode $pretty_object_name]"

ad_return_template
