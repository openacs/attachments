ad_page_contract {
    page to add a new file to the system

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:naturalnum,notnull
    object_id:naturalnum,notnull
    return_url:notnull
    pretty_object_name:notnull
    {title ""}
    {lock_title_p:boolean 0}
} -validate {
    valid_folder -requires {folder_id:integer} {
	if {![fs_folder_p $folder_id]} {
	    ad_complain "[_ attachments.lt_The_specified_parent_]"
	}
    }
} -properties {
    folder_id:onevalue
    context:onevalue
    title:onevalue
    lock_title_p:onevalue
}

# check for write permission on the folder

permission::require_permission -object_id $folder_id -privilege write

# set templating datasources

set context [_ attachments.Add_File]
#set fs_context [fs_context_bar_list -final "[_ attachments.Add_File]" $folder_id]

# Should probably generate the item_id and version_id now for
# double-click protection

# if title isn't passed in ignore lock_title_p
if {$title eq ""} {
    set lock_title_p 0
}


# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
