<master>
<property name="title">#attachments.lt_Upload_New_Attachment#</property>
<property name="context">@context@</property>

#attachments.You_are_attaching_a# <b>#attachments.new#</b> #attachments.lt_document_to_pretty_ob#<p>

<form enctype=multipart/form-data method=POST action="file-add-2">
<input type=hidden name="folder_id" value="@folder_id@">
<input type=hidden name="object_id" value="@object_id@">
<input type=hidden name="return_url" value="@return_url@">

<table border=0>

<tr>
<td align=right>#attachments.Version_filename_# </td>
<td><input type=file name=upload_file size=20></tr>
</tr>

<tr>
<td>&nbsp;</td>
<td><font size=-1>#attachments.lt_Use_the_Browse_button# </font></td>
</tr>

<tr>
<td>&nbsp;</td>
<td>&nbsp;</td>
</tr>

<tr>
<td align=right> #attachments.Title# </td>
  <if @lock_title_p@ eq 0>
    <td><input size=30 name=title value=@title@></td>
  </if>
  <else>
      <input type=hidden name=title value=@title@>
      <td>@title@</td>
  </else>
</tr>

<tr>
<td valign=top align=right> #attachments.Description# </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=physical></textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="Upload">
</td>
</tr>

</table>
</form>

