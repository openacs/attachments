
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
if {![db_0or1row select_attachment_data {}]} {
    ad_return_complaint "[_ attachments.lt_No_such_attachment_fo]"
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
        set title [db_string select_attachment_title {}]
        ad_returnredirect "download/[ad_urlencode $title]?object_id=$object_id&attachment_id=$attachment_id"
        ad_script_abort
        return
    }
    
    default {
        ad_return_complaint "[_ attachments.lt_dont_know_how_to_deal]"
        return
    }
}
