ad_page_contract {
    script to recieve the new file and insert it into the database

    @author Kevin Scaldeferri (kevin@arsdigita.com)
    @creation-date 6 Nov 2000
    @cvs-id $Id$
} {
    folder_id:integer,notnull
    upload_file:notnull,trim
    upload_file.tmpfile:tmpfile
    object_id:integer,notnull
    return_url:notnull
    title:notnull,trim
    description
} -validate {
    valid_folder -requires {folder_id:integer} {
	if ![fs_folder_p $folder_id] {
	    ad_complain "[_ attachments.lt_The_specified_parent_]"
	}
    }

    max_size -requires {upload_file} {
	set n_bytes [file size ${upload_file.tmpfile}]
	set max_bytes [ad_parameter "MaximumFileSize"]
	if { $n_bytes > $max_bytes } {
            # Max number of bytes is used in the error message
            set max_number_of_bytes [util_commify_number $max_bytes]
	    ad_complain "[_ attachments.lt_Your_file_is_larger_t]"
	}
    }
} 

# Check for write permission on this folder
ad_require_permission $folder_id write

# Get the filename part of the upload file
if ![regexp {[^//\\]+$} $upload_file filename] {
    # no match
    set filename $upload_file
}

# Get the user
set user_id [ad_conn user_id]

# Get the ip
set creation_ip [ad_conn peeraddr]

set mime_type [cr_filename_to_mime_type -create $upload_file]

# Get the storage type
set indb_p [ad_parameter "StoreFilesInDatabaseP" -package_id [ad_conn package_id]]

db_transaction {

    # create the new item
    if {$indb_p} {

	set file_id [db_exec_plsql new_lob_file "
	begin
    		:1 := file_storage.new_file (
        		title => :title,
        		folder_id => :folder_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip,
		        indb_p => 't'
   			);

        end;"]

	set version_id [db_exec_plsql new_version "
	begin
    		:1 := file_storage.new_version (
        		filename => :filename,
        		description => :description,
        		mime_type => :mime_type,
        		item_id => :file_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip
    			);
        end;"]

	db_dml lob_content "
	update cr_revisions
	set    content = empty_lob()
	where  revision_id = :version_id
	returning content into :1" -blob_files [list ${upload_file.tmpfile}]


	# Unfortunately, we can only calculate the file size after the lob is uploaded 
	db_dml lob_size "
	update cr_revisions
 	set content_length = dbms_lob.getlength(content) 
	where revision_id = :version_id"

    } else {

	set file_id [db_exec_plsql new_fs_file "
	begin
    		:1 := file_storage.new_file (
        		title => :title,
        		folder_id => :folder_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip,
		        indb_p => 'f'
   			);
	end;"]


	set version_id [db_exec_plsql new_version "
	begin

    		:1 := file_storage.new_version (
        		filename => :filename,
        		description => :description,
        		mime_type => :mime_type,
        		item_id => :file_id,
        		creation_user => :user_id,
        		creation_ip => :creation_ip
    			);

        end;"]

	set tmp_filename [cr_create_content_file $file_id $version_id ${upload_file.tmpfile}]
	set tmp_size [cr_file_size $tmp_filename]

	db_dml fs_content_size "
	update cr_revisions
	set content = '$tmp_filename',
            content_length = $tmp_size
	where  revision_id = :version_id"

    }

    # attach the file_id
    attachments::attach -object_id $object_id -attachment_id $file_id

} on_error {

    # most likely a duplicate name or a double click

    set folder_url index?folder_id?$folder_id
    ad_return_complaint 1 "[_ attachments.lt_You_probably_clicked_]"

       ad_script_abort
}


ad_returnredirect $return_url
