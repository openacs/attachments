<?xml version="1.0"?>
<queryset>
    <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

    <fullquery name="attachments::get_attachments.select_attachments">
        <querytext>
            select a.item_id,
                   e.label
            from attachments a, cr_extlinks e
            where object_id = :object_id
            and a.item_id = e.extlink_id
            and a.approved_p = 't'
        </querytext>
    </fullquery>
 
    <fullquery name="attachments::get_all_attachments.select_attachments">
        <querytext>
            select item_id,
                   acs_object.name(item_id),
                   approved_p
            from attachments
            where object_id = :object_id
        </querytext>
    </fullquery>
 
</queryset>
