<?xml version="1.0"?>
<queryset>

<fullquery name="select_attachment_data">      
<querytext>
select 
object_type
from attachments, acs_objects
where
attachments.object_id = :object_id and
attachments.item_id = :attachment_id and
attachments.item_id = acs_objects.object_id
</querytext>
</fullquery>

<fullquery name="select_url">      
<querytext>
select 
url
from fs_urls
where
url_id = :attachment_id
</querytext>
</fullquery>

 
</queryset>
