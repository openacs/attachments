<?xml version="1.0"?>
<queryset>
<rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="attachments::get_attachments.select_attachments">
<querytext>
select item_id, acs_object__name(item_id) from attachments
where object_id= :object_id
</querytext>
</fullquery>
 
</queryset>
