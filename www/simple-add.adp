<master>
<property name="title">#attachments.Attach_URL#</property>
<property name="context">@context;noquote@</property>

<p>
#attachments.you_are_attaching_url_to_object#
</p>

<form method=POST action="simple-add-2">
<input type=hidden name="folder_id" value="@folder_id@">
<input type=hidden name="type" value="@type@">
<input type=hidden name="object_id" value="@object_id@">
<input type=hidden name="return_url" value="@return_url@">

<table border=0>

<tr>
<td align=right> #attachments.Title# </td>
  <if @lock_title_p@ eq 0>
    <td><input size=30 name=title value=@title@></td>
  </if>
  <else>
     <td>@title@</td>
     <input type=hidden name=title value=@title@>
  </else>
</tr>

<tr>
<td align=right> #attachments.URL_1# </td>
<td><input size=50 name=url value="http://"></td>
</tr>

<tr>
<td valign=top align=right> #attachments.Description# </td>
<td colspan=2><textarea rows=5 cols=50 name=description wrap=soft></textarea></td>
</tr>

<tr>
<td></td>
<td><input type=submit value="Create">
</td>
</tr>

</table>
</form>

