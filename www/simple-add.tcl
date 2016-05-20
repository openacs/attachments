ad_page_contract {
    page to add a new nonversioned object to the system

    @author Ben Adida (ben@openforce.net)
    @author arjun (arjun@openforce.net)
    @creation-date 01 April 2002
    @cvs-id $Id$
} {
    folder_id:naturalnum,notnull
    object_id:naturalnum,notnull
    return_url:localurl,notnull
    pretty_object_name:notnull
    {type "fs_url"}
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
}

# check for write permission on the folder

permission::require_permission -object_id $folder_id -privilege write

# set templating datasources

set pretty_name "URL"
if {$pretty_name eq ""} {
    return -code error "[_ attachments.No_such_type]"
}

set context [_ attachments.Add_pretty_name [list pretty_name $pretty_name]]
#set context [fs_context_bar_list -final [_ attachments.Add_pretty_name [list pretty_name $pretty_name]] $folder_id]

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
