ad_library {
    Automated tests.

    @author Héctor Romojaro <hector.romojaro@gmail.com>
    @creation-date 18 February 2021
    @cvs-id $Id$
}

aa_register_case -procs {
    attachments::get_all_attachments
    attachments::get_attachments
    attachments::attach
    attachments::unattach
    attachments::toggle_approved
} -cats {
    api
} attachments_basic_api {
    Test attachments basic api.
} {
    aa_run_with_teardown -rollback -test_code {
        #
        # Create test objects
        #
        set object_id       [package_instantiate_object acs_object]
        set attachment1_id  [package_instantiate_object acs_object]
        set attachment2_id  [package_instantiate_object acs_object]
        set attachment_ids  [lsort [list $attachment1_id $attachment2_id]]
        #
        # Check that there are no attachments in new object
        #
        aa_equals "Check for attachments on new object" \
            [attachments::get_all_attachments -object_id $object_id] ""
        #
        # Check attachments in object
        #
        attachments::attach \
            -object_id $object_id \
            -attachment_id $attachment1_id \
            -approved_p f
        attachments::attach \
            -object_id $object_id \
            -attachment_id $attachment2_id \
            -approved_p f
        set attachment_list [attachments::get_all_attachments \
                                -object_id $object_id]
        set attachment_list_ids [lsort [lmap x $attachment_list {lindex $x 0}]]
        aa_equals "Check for new attachments object" \
           "$attachment_list_ids" "$attachment_ids"
        #
        # Check for approved/not approved attachments
        #
        attachments::toggle_approved \
            -object_id $object_id \
            -item_id $attachment1_id
        set approved_attachments_list [attachments::get_attachments \
                                        -object_id $object_id]
        set approved_attachments_ids [lsort \
            [lmap x $approved_attachments_list {lindex $x 0}]]
        aa_equals "Check for approved attachments after toggle" \
           "$attachment1_id" "$approved_attachments_ids"
        attachments::toggle_approved \
            -object_id $object_id \
            -item_id $attachment1_id
        aa_equals "Check for approved attachments after toggle (1)" \
            "[attachments::get_attachments -object_id $object_id]" ""
        aa_equals "Check for approved attachments after toggle (2)" \
            [attachments::get_all_attachments \
                -object_id $object_id \
                -approved_only] ""
        #
        # Check that there are no attachments after unattaching
        #
        attachments::unattach \
            -object_id $object_id \
            -attachment_id $attachment1_id
        attachments::unattach \
            -object_id $object_id \
            -attachment_id $attachment2_id
        aa_equals "Check for attachments after unattaching" \
            [attachments::get_all_attachments -object_id $object_id] ""
    }
}

aa_register_case -procs {
    attachments::get_package_key
} -cats {
    api
    production_safe
} attachments_package_key {
    Test attachments::get_package_key.
} {
    aa_equals "Package_key" [attachments::get_package_key] "attachments"
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
