<master>
<property name="title">Attach a File to @pretty_object_name@</property>
<property name="context">@context@</property>

You are attaching a document to @pretty_object_name@.

<p>

<small>
To attach a file already in a folder, open the folder by clicking the
folder's name, then click the &quot;[ Choose ]&quot; link next to the file. To
upload a new file into a folder, open the folder by clicking the
folder's name, then click the appropriate  &quot;Attach a new: File | URL&quot;
link
</small>

<p>
@fs_context_bar_html@
<p>
Attach a <b>new</b>:  &nbsp;&nbsp;     <a href="file-add?folder_id=@folder_id@&@passthrough_vars@">File</a>
      &nbsp;&nbsp;|&nbsp;&nbsp;
      <a href="simple-add?folder_id=@folder_id@&@passthrough_vars@">URL</a>
<p>
<if @contents:rowcount@ gt 0>
  <table width="85%" cellpadding="5" cellspacing="0" class="table-display">
    <tr class="table-header">
      <td>&nbsp;</td>
      <td>Name</td>
      <td>Action</td>
      <td>Size</td>
      <td>Type</td>
      <td>Last Modified</td>
    </tr>
<multiple name="contents">
<if @contents.rownum@ odd>
    <tr class="oddrow">
</if>
<else>
    <tr class="evenrow">
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
        @contents.content_size@ item<if @contents.content_size@ ne 1>s</if>
      </td>
      <td>@contents.type@</td>
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
<a href="attach-2?item_id=@contents.object_id@&@passthrough_vars@">Choose</a>
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
<a href="attach-2?item_id=@contents.object_id@&@passthrough_vars@">Choose</a>
        ]</small>
      </td>
      <td>@contents.content_size@ byte<if @contents.content_size@ ne 1>s</if></td>
      <td>@contents.type@</td>
      <td>@contents.last_modified@</td>
</else>
</else>
    </tr>
</multiple>
  </table>
</if>
<else>
  <p><blockquote><i>Folder @folder_name@ is empty</i></blockquote></p>
</else>
