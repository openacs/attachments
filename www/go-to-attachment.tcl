
ad_page_contract {
    Go to an attachment
    
    @author Ben Adida (ben@openforce)
} {
    {object_id:integer,notnull}
    {attachment_id:integer,notnull}
}

# We check permissions on the object
permission::require_permission -object_id $object_id -privilege read

# Get information about attachment
if {![db_0or1row select_attachment_data {}]} {
    ad_return_complaint "No such attachment for this object"
    return
}

switch $object_type {
    fs_url {
        set url [db_string select_url {}]
        ad_returnredirect $url
        ad_script_abort
        return
    }

    content_item {
        ad_returnredirect "download/$object_id?object_id=$object_id&attachment_id=$attachment_id"
        ad_script_abort
        return
    }
    
    default {
        ad_return_complaint "don't know how to deal with this attachment type"
        return
    }
}
