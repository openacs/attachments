ad_page_contract {

    @author yon@openforce.net
    @creation-date 2002-08-29
    @cvs-id $Id$

} -query {
    {object_id:naturalnum,notnull}
    {item_id:naturalnum,notnull}
    {approved_p ""}
    {return_url:notnull}
}

attachments::toggle_approved -object_id $object_id -item_id $item_id -approved_p $approved_p

ad_returnredirect $return_url
