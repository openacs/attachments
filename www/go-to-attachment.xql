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


  <fullquery name="select_attachment_title">      
    <querytext>
      select r.title 
      from cr_revisions r, cr_items i 
      where i.item_id = :attachment_id 
      and r.revision_id  = i.live_revision
    </querytext>
  </fullquery>
 
</queryset>
