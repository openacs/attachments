ad_page_contract {

    UI to display, upload and delete attachments on an item and insert
    them into the opener page.

    Meant to be integrated by richtext editors via plugins.

} {
    object_id:object_id,optional
    {page:naturalnum,optional}
    {search_string ""}
}

set title [_ attachments.Attachments]

if {![info exists object_id]} {
    #
    # Without an object this page behaves as a trivial webservice to
    # retrieve localized information and other stuff relevant to this
    # plugin. In this case, we use it for the title.
    #
    package require json::write
    set title [::json::write string $title]
    ns_return 200 application/json [subst -nocommands {{"title": $title}}]
    ad_script_abort
}

set doc(title) $title

::permission::require_permission \
    -object_id $object_id \
    -privilege read

ad_form -name attachment_search -export {object_id page syearch_string} -has_submit 1 -form {
    {search_string:text,optional
        {label {}}
        {html {placeholder "[_ 	acs-kernel.common_Search]"}}
        {value $search_string}
    }
} -on_submit {}

#
# Focus and place the cursor at the end of the search string
#
::template::add_body_handler -event load -script {
    const search = document.querySelector('#attachment_search [name="search_string"]');
    const value = search.value;
    search.addEventListener('focus', function () {
        search.value = '';
        search.value = value;
    });
    search.focus();
}

ad_form -name upload_form \
    -export {object_id page syearch_string} \
    -html {enctype multipart/form-data} \
    -mode edit \
    -form {
        {upload:file(file),optional
            {label "[_ acs-templating.HTMLArea_SelectFileUploadTitle]"}
        }
    } -on_submit {
        set d [::attachments::richtext::file_attach \
                   -object_id   $object_id \
                   -import_file [ns_queryget upload.tmpfile] \
                   -mime_type   [ns_queryget upload.content-type] \
                   -title       [ns_queryget upload] \
                   -user_id     [ad_conn user_id] \
                   -peeraddr    [ad_conn peeraddr] \
                   -package_id  [ad_conn package_id] \
                   -privilege   write]
        if {![dict get $d success]} {
            ::template::element::set_error upload_form upload [dict get $d errMsg]
            break
        }
    }

::template::list::create \
    -page_size 10 \
    -page_groupsize 10 \
    -page_flush_p true \
    -page_query {
       select a.item_id
       from attachments a, cr_revisions r, cr_items i
       where a.object_id = :object_id
         and a.item_id = r.item_id
         and i.live_revision = r.revision_id
        and (:search_string is null or r.title ilike '%' || :search_string || '%')
       order by r.title asc
    } \
    -name attachments \
    -multirow attachments \
    -key related_object_id \
    -elements {
        select {
            display_template {
               <button
                  title="#attachments.Choose#"
                  class="btn btn-outline-secondary selectable"
                  data-name="@attachments.name@"
                  >&#129052;</button>
            }
        }
        title {
            label "#acs-kernel.common_Title#"
        }
        mime_type {
            label "#acs-kernel.common_Type#"
        }
        src {
            display_template {
                <div class="attachment"
                     data-name="@attachments.name@"
                     data-src="@attachments.src@"
                     data-title="@attachments.title@"
                     data-mime-type="@attachments.mime_type@">
                </div>
            }
        }
        delete {
            link_url_col delete_url
            display_template {
                <adp:icon name="trash">
            }
        }
    } -filters {object_id {}}

set return_url [export_vars -base [ad_conn url] {object_id page search_string}]

db_multirow -extend { src delete_url } attachments get_attachments [subst {
    select i.name,
           r.title,
           r.mime_type,
           r.item_id as attachment_id
    from cr_revisions r, cr_items i
    where i.live_revision = r.revision_id
    [::template::list::page_where_clause -name attachments -key r.item_id -and]
    order by r.title asc
}] {
    set src /file/${attachment_id}
    set delete_url [export_vars -base file-delete {attachment_id return_url}]
}

::template::add_body_handler -event load -script {
    function returnContent(content) {
        window.parent.postMessage({
            plugin: 'oacsAttachments',
            action: 'insertContent',
            content: content
        });
    }

    function renderAttachment(attachment) {
        const mimeType = attachment.getAttribute('data-mime-type');
        const src      = attachment.getAttribute('data-src');
        const title    = attachment.getAttribute('data-title');

        let rendered;

        const mediaType = mimeType.split('/')[0];
        switch (mediaType) {
        case 'image':
            rendered = `<img src="${src}" alt="${title}"/>`;
            break;
        case 'video':
            rendered = `<video src="${src}" controls>${title}</video>`;
            break;
        case 'audio':
            rendered = `<audio src="${src}" controls>${title}</audio>`;
            break;
        default:
            rendered = `<a href="${src}" title="${title}" target="_blank">${title}</a>`;
        }
        return rendered;
    }

    for (const attachment of document.querySelectorAll('.attachment')) {
        const rendered = renderAttachment(attachment);
        attachment.innerHTML = rendered;
    }

    for (const link of document.querySelectorAll('.selectable')) {
        const name = link.getAttribute('data-name');
        const attachment = document.querySelector(`.attachment[data-name='${name}']`);
        link.addEventListener('click', function (event) {
            event.preventDefault();
            returnContent(attachment.innerHTML);
        });
    }
}


#
# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
