<master>
<property name="title">Add Attachment Folder Link </property>

<h3>Add folder Link</h3>

<if @root_folder_id@ eq 0>
  No file-storage folders found to link to. Would you like to create one?
  <form method=get action=new-root-folder-map-2>
    <input type=hidden name=package_id value=@package_id@>
    <input type=hidden name=referer value=@referer@>
    <input type=submit value="Yes">
  </form>

  <form method=get action=redirect>
    <input type=hidden name=referer value=@referer@>
    <input type=submit value="No">
  </form>

</if>
<else>
  Found file-storage folder XXX folder_name XXX ... would you like to link to it?
</else>
