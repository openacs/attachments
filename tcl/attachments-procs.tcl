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
        {-package_id:required}
    } {
    } {
        return [db_1row get_root_folder_select {}]
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
    
}
