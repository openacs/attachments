<?xml version="1.0"?>
<queryset>
<rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="attachments::get_attachments.select_attachments">
<querytext>
select item_id, acs_object.name(item_id) from attachments
where object_id= :object_id
</querytext>
</fullquery>
 
</queryset>
