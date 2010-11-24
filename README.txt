There does not appear to be an extension point for the ToC, therefore we work around it.

One way is to declare a custom transtype, however that would require 2 build steps.

In this 'plugin' we supply:
    1. Custom xsl file for the Toc
    2. Ant build file override the 'dita.out.map.xhtml.toc' build target.

By adding this as a plugin (e.g. drop the folder into the dita-ot/plugins folder) and running the integrator,
you should get a <import file="plugins/net.ipov.dita.xhtml.toc/build_toc.xml"></import>  statement added
to your dita-ot/build.xml file.  Currently, the location of the imports means it will override the built in
'dita.out.map.xhtml.toc' build target, however if this changes it may become necessary to take more invasive steps.
Anyone have any "inside" knowledge on this they want to share on this?  If so, please let me know.


Due to the way that the current DITA-OT processing works it would be pretty difficult to assign a meaningful @id
to the output ToC, therefore we will rely on JS using the HTML to do any reverse highlight updates.