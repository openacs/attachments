ad_page_contract {
    Delete a richtext attachment.
} {
    attachment_id:object_id
    return_url:localurl
}

::permission::require_permission \
    -object_id $attachment_id \
    -privilege delete

content::item::delete -item_id $attachment_id

ad_returnredirect $return_url
ad_script_abort
