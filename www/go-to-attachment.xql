<?xml version="1.0"?>
<queryset>

<fullquery name="select_url">      
  <querytext>
    select url
    from cr_extlinks
    where extlink_id = :attachment_id
  </querytext>
</fullquery>


  <fullquery name="select_attachment_info">      
    <querytext>
      select r.title,i.name, o.package_id
      from cr_revisions r, cr_items i, acs_objects o
      where i.item_id = :attachment_id 
      and r.revision_id  = i.live_revision
      and i.item_id = o.object_id
    </querytext>
  </fullquery>

</queryset>
