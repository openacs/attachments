ad_page_contract {

    Attaches something to an object

    @author Arjun Sanyal (arjun@openforce.net), Ben Adida
    @version $Id$

} -query {
    {object_id:notnull}
    {item_id:notnull}
    {return_url:notnull}
}

# Perms
permission::require_permission -object_id $object_id -privilege write

# Perform the attachment
attachments::attach -object_id $object_id -attachment_id $item_id

ad_returnredirect $return_url

