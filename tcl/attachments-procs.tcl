#  Copyright (C) 2001, 2002 OpenForce, Inc.
#
#  this is free software; you can redistribute it and/or modify it under the
#  terms of the GNU General Public License as published by the Free Software
#  Foundation; either version 2 of the License, or (at your option) any later
#  version.
#
#  this is distributed in the hope that it will be useful, but WITHOUT ANY
#  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#  details.
#

ad_library {
    Attachments

    @author Arjun Sanyal (arjun@openforce.net)
    @version $Id$
}

namespace eval attachments {

    ad_proc -public root_folder_p {
        {-package_id:required}
    } {
        Returns 1 if the package_id has an fs_folder mapped to it
    } {
        return [db_string root_folder_p_select {} -default 0]
    }

    ad_proc -public get_root_folder {
        {-package_id ""}
    } {
    } {
        if {[empty_string_p $package_id]} {
            # Get the package ID from the parent URL
            array set parent_node [site_node::get_parent -node_id [ad_conn node_id]]
            set package_id $parent_node(object_id)
        }

        return [db_string get_root_folder_select {} -default {}]
    }

    ad_proc -public root_folder_map_p {
        {-package_id:required}
    } {
        Returns 1 if the package_id has an fs_folder mapped to it
    } {
        # this is a duplicate (Ben)
        return [root_folder_p -package_id $package_id]
    }

    ad_proc -public map_root_folder {
        {-package_id:required}
        {-folder_id:required}
    } {
    } {
        db_dml map_root_folder_insert {}
    }

    ad_proc -public unmap_root_folder {
        {-package_id:required}
        {-folder_id:required}
    } {
    } {
        db_dml unmap_root_folder_delete {}
    }

    ad_proc -public attach {
        {-object_id:required}
        {-attachment_id:required}
    } {
        perform the attachment
    } {
        db_dml insert_attachment {}
    }

    ad_proc -public unattach {
        {-object_id:required}
        {-attachment_id:required}
    } {
        undo the attachment
    } {
        db_dml delete_attachment {}
    }

    ad_proc -public get_package_key {} {
        return attachments
    }

    ad_proc -public get_url {
    } {
        return [parameter::get  \
            -package_id [apm_package_id_from_key [get_package_key]] \
            -parameter RelativeUrl
        ]
    }

    ad_proc -public add_attachment_url {
        {-folder_id ""}
        {-package_id ""}
        {-object_id:required}
        {-return_url ""}
        {-pretty_name ""}
    } {
        return "[attachments::get_url]/attach?pretty_object_name=[ns_urlencode $pretty_name]&folder_id=$folder_id&object_id=$object_id&return_url=[ns_urlencode $return_url]"
    }

    ad_proc -public goto_attachment_url {
        {-package_id ""}
        {-object_id:required}
        {-attachment_id:required}
    } {
        return "[attachments::get_url]/go-to-attachment?object_id=$object_id&attachment_id=$attachment_id"
    }

    ad_proc -public graphic_url {
        {-package_id ""}
    } {
        return "<img valign=bottom src=\"[attachments::get_url]/graphics/file.gif\">"
    }

    ad_proc -public get_attachments {
        {-object_id:required}
    } {
        returns a list of attachment ids and names
    } {
        set lst [db_list_of_lists select_attachments {}]
        set lst_with_urls [list]

        foreach el $lst {
            set append_lst [list [goto_attachment_url -object_id $object_id -attachment_id [lindex $el 0]]]
            lappend lst_with_urls [concat $el $append_lst]
        }

        return $lst_with_urls
    }

    ad_proc -public context_bar {
        {-folder_id:required}
        {-final ""}
        {-extra_vars ""}
    } {
        set root_folder_id [attachments::get_root_folder]

        set cbar_list [fs_context_bar_list -extra_vars $extra_vars -folder_url "attach" -file_url "attach" -root_folder_id $root_folder_id -final $final $folder_id]

        set cbar_html "<a href=\"attach?${extra_vars}&folder_id=$root_folder_id\">Top</a> &gt; "
        
        foreach el $cbar_list {
            if {[llength $el] < 2} {
                append cbar_html "$el"
            } else {
                append cbar_html "<a href=\"[lindex $el 0]\">[lindex $el 1]</a> &gt; "
            }
        }

        return $cbar_html
    }
    
}
