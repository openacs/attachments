
ad_page_contract {
    Go to an attachment
    
    @author Ben Adida (ben@openforce.net)
} {
    {object_id:integer,notnull}
    {attachment_id:integer,notnull}
}

# We check permissions on the object
permission::require_permission -object_id $object_id -privilege read

# Get information about attachment
set content_type [item::get_type $attachment_id]
if { [string length $content_type] == 0 } {
    ad_return_complaint 1 "No such attachment for this object"
    return
}

switch $content_type {
    content_extlink {
        ad_returnredirect [db_string select_url {}]
        ad_script_abort
        return
    }

    file_storage_object {
        set title [db_string select_attachment_title {}]
        ad_returnredirect "download/[ad_urlencode $title]?object_id=$object_id&attachment_id=$attachment_id"
        ad_script_abort
        return
    }
    
    default {
        ad_return_complaint 1 "don't know how to deal with attachment type $content_type"
        return
    }
}
