ad_page_contract {
    Add a nonversioned item

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    object_id:integer,notnull
    return_url:notnull
    title:notnull,trim
    description
    url:notnull,trim
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "The specified parent folder is not valid."
	}
    }

} 

# Check for write permission on this folder
ad_require_permission $folder_id write

db_transaction {
    
    # Create and attach the URL
    attachments::attach -object_id $object_id \
        -attachment_id [content_simple::new -url $url -label $title -description $description -parent_id $folder_id]

}

ad_returnredirect "$return_url"
