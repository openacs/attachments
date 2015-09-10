ad_page_contract {
    Add a nonversioned item

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:naturalnum,notnull
    object_id:naturalnum,notnull
    return_url:notnull
    title:notnull,trim
    description
    url:notnull,trim
} -validate {
    valid_folder -requires {folder_id:integer} {
	if {![fs_folder_p $folder_id]} {
	    ad_complain "[_ attachments.lt_The_specified_parent_]"
	}
    }

} 

# Check for write permission on this folder
permission::require_permission -object_id $folder_id -privilege write

db_transaction {

    # Create the URL (for now)
    set url_id [content::extlink::new -url $url -label $title -description $description -parent_id $folder_id]

    # Attach the URL
    attachments::attach -object_id $object_id -attachment_id $url_id

}

ad_returnredirect "$return_url"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
