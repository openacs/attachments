<?xml version="1.0"?>
<queryset>

<fullquery name="attachments::root_folder_p.root_folder_p_select">
<querytext>
select 1 from attachments_folder_map
where package_id = :package_id
</querytext>
</fullquery>

<fullquery name="attachments::get_root_folder.get_root_folder_select">
<querytext>
select folder_id from attachments_folder_map
where package_id = :package_id
</querytext>
</fullquery>

<fullquery name="attachments::map_root_folder.map_root_folder_insert">
<querytext>
insert into attachments_folder_map 
(package_id, folder_id)
values
(:package_id, :folder_id)
</querytext>
</fullquery>

<fullquery name="attachments::unmap_root_folder.unmap_root_folder_delete">
<querytext>
delete from attachments_folder_map where
package_id = :package_id and
folder_id = :folder_id
</querytext>
</fullquery>
 
</queryset>
