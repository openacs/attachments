<?xml version="1.0"?>
<queryset>

<fullquery name="select_url">      
  <querytext>
    select url
    from cr_extlinks
    where extlink_id = :attachment_id
  </querytext>
</fullquery>


  <fullquery name="select_attachment">      
    <querytext>
      select r.title, m.file_extension, r.mime_type
      from cr_revisions r, cr_items i, cr_mime_types m 
      where i.item_id = :attachment_id 
      and r.revision_id  = i.live_revision
      and r.mime_type = m.mime_type
    </querytext>
  </fullquery>
 
</queryset>
