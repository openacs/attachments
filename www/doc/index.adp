
<property name="context">{/doc/attachments/ {Attachments}} {}</property>
<property name="doc(title)"></property>
<master>
<style>
div.sect2 > div.itemizedlist > ul.itemizedlist > li.listitem {margin-top: 16px;}
div.sect3 > div.itemizedlist > ul.itemizedlist > li.listitem {margin-top: 6px;}
</style>              
<h1><a id="id.toc" name="id.toc">Contents</a></h1>
<dl><dd>
<a href="#id.s1">1 Attachments</a><dl>
<dd>
<a href="#id.s1.1">1.1 Basics</a><dl>
<dd><a href="#id.s1.1.1">1.1.1 What does attachments do?</a></dd><dd><a href="#id.s1.1.2">1.1.2 At a high-level, how does
attachments work?</a></dd>
</dl>
</dd><dd>
<a href="#id.s1.2">1.2 Using attachments</a><dl>
<dd><a href="#id.s1.2.1">1.2.1 Mount attachments under your
package</a></dd><dd><a href="#id.s1.2.2">1.2.2 Map a file-storage root folder to
your package instance</a></dd><dd>
<a href="#id.s1.2.3">1.2.3 Attaching files to your objects</a><dl>
<dd><a href="#id.s1.2.3.1">1.2.3.1 Have your package check if
attachments is mounted properly</a></dd><dd><a href="#id.s1.2.3.2">1.2.3.2 Get the attachment Url</a></dd>
</dl>
</dd><dd><a href="#id.s1.2.4">1.2.4 Viewing attached files</a></dd>
</dl>
</dd>
</dl>
</dd></dl>
<hr>
<h1>1 Attachments</h1>
<h2>
<a id="id.s1.1" name="id.s1.1">1.1</a> Basics</h2>
<h3>
<a id="id.s1.1.1" name="id.s1.1.1">1.1.1</a> What does
attachments do?</h3>
<p>
<tt>attachments</tt> is a service package that allows you to
attach one or more file-storage files to any <tt>acs_object</tt>.
<tt>attachments</tt> is mounted below a package that uses it, and
the application provides links into the attachments package&#39;s
UI.</p>
<h3>
<a id="id.s1.1.2" name="id.s1.1.2">1.1.2</a> At a high-level,
how does attachments work?</h3>
<p>Before you can use the attachments package, each instance of
your package must be mapped to a <tt>file-storage root
folder</tt>.</p>
<p>The root folder is a "super folder" for all the files
in that specific instance of file-storage, and it is created
automatically when the file-storage package is instantiated.</p>
<p>When a user wants to make an attachment to an object in your
package, she is shown the contents of the file-storage root folder
mapped to your package instance. The user is also given the option
to upload a new file into file-storage to attach.</p>
<h2>
<a id="id.s1.2" name="id.s1.2">1.2</a> Using attachments</h2>
<h3>
<a id="id.s1.2.1" name="id.s1.2.1">1.2.1</a> Mount attachments
under your package</h3>
<p>The first step is to mount the attachments package
<strong>under</strong> your package. In the <tt>site-map</tt>, you
should create a new site-node (sub-folder) under your package
called "attach".</p>
<p>"attach" is the standard URL. However, this URL can be
changed on a site-wide basis by changing the
"RelativeUrl" parameter of <strong>any</strong> of the
attachments packages (this works since there&#39;s only one
instance of attachments in the entire system. The same instance is
just re-mounted)</p>
<h3>
<a id="id.s1.2.2" name="id.s1.2.2">1.2.2</a> Map a file-storage
root folder to your package instance</h3>
<p>First, you must select a file-storage instance that will provide
the files you can attach. If you do not already have an instance of
file-storage that you want to use for your package instance, you
must create one using the site-map.</p>
<p>Once you have a file-storage instance you wish to use, you must
map the root folder of that file-storage instance with the
package_id of the instance of your package.</p>
<p>Two utility procs to help you do this:</p>
<p>
<tt>fs::get_root_folder</tt> and
<tt>attachments::map_root_folder</tt>
</p>
<h3>
<a id="id.s1.2.3" name="id.s1.2.3">1.2.3</a> Attaching files to
your objects</h3>
<h4>
<a id="id.s1.2.3.1" name="id.s1.2.3.1">1.2.3.1</a> Have your
package check if attachments is mounted properly</h4>
<p>Most likely, you want your package to work even if the
attachments package is not installed on the system or if
attachments is not properly mounted. To do this, add the following
proc to your package&#39;s API and wrap all calls to the
attachments package with it:</p>
<div class="box" style="border: 2px solid; width: 100%"><pre>    ad_proc -private attachments_enabled_p {} {
        set package_id [site_node_apm_integration::child_package_exists_p \
            -package_key attachments
        ]
    }</pre></div>
<h4>
<a id="id.s1.2.3.2" name="id.s1.2.3.2">1.2.3.2</a> Get the
attachment Url</h4>
<p>When you want to set up the link that the user can click on to
attach something to an object, use the
attachments::add_attachment_url proc, which will return the correct
Url into the attachments package mounted under your package.</p>
<div class="box" style="border: 2px solid; width: 100%"><pre>    if {$attachments_enabled_p} {
        if {$attach_p} {
            set redirect_url [attachments::add_attachment_url \
                                  -object_id $message_id \
                                  -return_url $redirect_url \
                                  -pretty_name "$subject"]
        }
    }</pre></div>
<p>forums redirects the user to the redirect_url, if the user chose
to add an attachment to their posting.</p>
<h3>
<a id="id.s1.2.4" name="id.s1.2.4">1.2.4</a> Viewing attached
files</h3>
<p>You can use the "attachments::get_attachments" proc to
see the list of attachments to a given object.</p>
<h2>Release Notes</h2>
<p>Please file bugs in the <a href="http://openacs.org/bugtracker/openacs/">Bug Tracker</a>.</p>
