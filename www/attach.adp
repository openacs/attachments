<master>
<property name="title">#attachments.lt_Attach_a_File_to_pret#</property>
<property name="context">@context;noquote@</property>

#attachments.lt_You_are_attaching_a_d#

<p>

<small>
#attachments.lt_To_attach_a_file_alre#
</small>

<p>
@fs_context_bar_html;noquote@
<p>
<if @write_permission_p@ eq 1>
#attachments.attach_new#  &nbsp;&nbsp;     <a href="file-add?folder_id=@folder_id@&@passthrough_vars@">#attachments.File#</a>
      &nbsp;&nbsp;|&nbsp;&nbsp;
      <a href="simple-add?folder_id=@folder_id@&@passthrough_vars@">#attachments.URL#</a>
</if>
<p>
<if @contents:rowcount@ gt 0>
  <table width="85%" cellpadding="5" cellspacing="0" class="table-display">
    <tr class="table-header">
      <td>&nbsp;</td>
      <td>#attachments.Name#</td>
      <td>#attachments.Action#</td>
      <td>#attachments.Size#</td>
      <td>#attachments.Type#</td>
      <td>#attachments.Last_Modified#</td>
    </tr>
<multiple name="contents">
<if @contents.rownum@ odd>
    <tr class="odd">
</if>
<else>
    <tr class="even">
</else>
    <tr>
<if @contents.type@ eq "folder">
      <td><img src="graphics/folder.gif"></td>
      <td>
        <a href="attach?folder_id=@contents.object_id@&@passthrough_vars@">@contents.name@</a>
<if @contents.new_p@ and @contents.content_size@ gt 0>(&nbsp;new&nbsp;)</if>
      </td>
      <td>&nbsp;</td>
      <td>
        #attachments.lt_contentscontent_size_#<if @contents.content_size@ ne 1>s</if>
      </td>
      <td>#file-storage.folder_type_pretty_name#</td>
      <td>@contents.last_modified@</td>
</if>
<else>
<if @contents.type@ eq "url">
      <td><img src="graphics/file.gif"></td>
      <td>
      @contents.name@
<if @contents.new_p@>(&nbsp;new&nbsp;)</if>
      </td>
      <td>
        <small>[
<a href="attach-2?item_id=@contents.object_id@&@passthrough_vars@">#attachments.Choose#</a>
          ]</small>
      </td>
      <td>&nbsp;</td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</if>
<else>
      <td><img src="graphics/file.gif"></td>
      <td>
        @contents.name@
<if @contents.new_p@>
        (&nbsp;new&nbsp;)
</if>
      </td>
      <td>
        <small>[
<a href="attach-2?item_id=@contents.object_id@&@passthrough_vars@">#attachments.Choose#</a>
        ]</small>
      </td>
      <td>#attachments.lt_contentscontent_size__1#<if @contents.content_size@ ne 1>s</if></td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</else>
</else>
    </tr>
</multiple>
  </table>
</if>
<else>
  <p><blockquote><i>#attachments.lt_Folder_folder_name_is#</i></blockquote></p>
</else>

