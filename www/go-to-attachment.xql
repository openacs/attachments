<?xml version="1.0"?>
<queryset>

<fullquery name="select_url">      
  <querytext>
    select url
    from cr_extlinks
    where extlink_id = :attachment_id
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
