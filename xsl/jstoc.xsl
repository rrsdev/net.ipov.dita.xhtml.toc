<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:saxon="http://icl.com/saxon"
    xmlns:xt="http://www.jclark.com/xt"
    xmlns:java="org.dita.dost.util.StringUtils"
    extension-element-prefixes="saxon xt"
    exclude-result-prefixes="java">

   <!-- If we are in the ./plugins dir, then the path to the base file should be, once we import it, then we can set out properties. -->
   <xsl:import href="../../../xsl/map2xhtmtoc.xsl"/>

   <xsl:output method="text" media-type="text/plain" encoding="UTF-8" indent="no" />

   <!-- TODO: Generate the following dynamically, either in XSL or in ANT -->
   <xsl:param name="YEAR" select="'2010'"/>

   <!-- Used to assign a prefix to the CSS class elements. -->
   <xsl:param name="xtoc-css-prefix" select="'toc'"/>

   <xsl:param name="xtoc-dita-prefix" select="'dita'"/>

   <!-- Include the map title as a heading in the document? -->
   <xsl:param name="xtoc-include-map-title" select="'yes'"/>

   <!-- used to 'define' a newline? -->
   <xsl:variable name="newline">
       <xsl:text>&#xa;</xsl:text>
   </xsl:variable>

   <xsl:variable name="quotation">
       <xsl:text>&#xa;</xsl:text>
   </xsl:variable>

   <xsl:template match="/">
       <xsl:apply-templates/>
   </xsl:template>

   <xsl:template match="/*[contains(@class, ' map/map ')]">
  <xsl:param name="pathFromMaplist"/>
  <xsl:if test=".//*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
  {
    <xsl:call-template name="commonProperties">
          <xsl:with-param name="nodeClass" select="'map/map'"></xsl:with-param>
       </xsl:call-template>
    <xsl:if test="'yes' = $xtoc-include-map-title">
        "title": "<xsl:value-of select="title/text()"/>"
    </xsl:if>
    "children":[<xsl:value-of select="$newline"/>
      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
      </xsl:apply-templates>
      <xsl:value-of select="$newline"/>
      <!-- append and ending so we don't have a trailing comma -->
      {
        "eol":"true"
      }
      <xsl:value-of select="$newline"/>
    ]
  }<xsl:value-of select="$newline"/>
  </xsl:if>
</xsl:template>

<!-- *********************************************************************************
     Output each topic as an <li> with an A-link. Each item takes 2 values:
     - A title. If a navtitle is specified on <topicref>, use that.
       Otherwise try to open the file and retrieve the title. First look for a navigation title in the topic,
       followed by the main topic title. Last, try to use <linktext> specified in the map.
       Failing that, use *** and issue a message.
     - An HREF is optional. If none is specified, this will generate a wrapper.
       Include the HREF if specified.
     - Ignore if TOC=no.

     If this topicref has any child topicref's that will be part of the navigation,
     output a <ul> around them and process the contents.
     ********************************************************************************* -->
<xsl:template match="*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
  <xsl:param name="pathFromMaplist"/>
  <xsl:variable name="title">
    <xsl:call-template name="navtitle"/>
  </xsl:variable>
  {
    <xsl:call-template name="commonProperties">
       <xsl:with-param name="nodeClass" select="'map/topicref'"></xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="$title and $title!=''">
        "title":"<xsl:value-of select="$title"/>",
        <xsl:if test="@href and not(@href='')">
            "href":"<xsl:choose>
                  <!-- What if targeting a nested topic? Need to keep the ID? -->
                  <!-- edited by william on 2009-08-06 for bug:2832696 start -->
                  <xsl:when test="contains(@copy-to, $DITAEXT) and not(contains(@chunk, 'to-content')) and
                    (not(@format) or @format = 'dita' or @format='ditamap' ) ">
                           <!-- edited by william on 2009-08-06 for bug:2832696 end -->
                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                    <!-- added by William on 2009-11-26 for bug:1628937 start-->
                    <xsl:value-of select="java:getFileName(@copy-to,$DITAEXT)"/>
                    <!-- added by William on 2009-11-26 for bug:1628937 end-->
                    <xsl:value-of select="$OUTEXT"/>
                    <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
                      <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                    </xsl:if>
                  </xsl:when>
                  <!-- edited by william on 2009-08-06 for bug:2832696 start -->
                  <xsl:when test="contains(@href,$DITAEXT) and (not(@format) or @format = 'dita' or @format='ditamap')">
                  <!-- edited by william on 2009-08-06 for bug:2832696 end -->
                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                    <!-- added by William on 2009-11-26 for bug:1628937 start-->
                    <!--xsl:value-of select="substring-before(@href,$DITAEXT)"/-->
                    <xsl:value-of select="java:getFileName(@href,$DITAEXT)"/>
                    <!-- added by William on 2009-11-26 for bug:1628937 end-->
                    <xsl:value-of select="$OUTEXT"/>
                    <xsl:if test="contains(@href, '#')">
                      <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>  <!-- If non-DITA, keep the href as-is -->
                    <xsl:if test="not(@scope='external')"><xsl:value-of select="$pathFromMaplist"/></xsl:if>
                    <xsl:value-of select="@href"/>
                  </xsl:otherwise>
                </xsl:choose>",
            "scope":"<xsl:value-of select="@scope"/>",
            "type":"<xsl:value-of select="@type"/>",
        </xsl:if>

        <!-- If there are any children that should be in the TOC, process them -->
        <xsl:if test="descendant::*[contains(@class, ' map/topicref ')][not(contains(@toc,'no'))][not(@processing-role='resource-only')]">
          <xsl:value-of select="$newline"/>
            "children":[
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
              <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
            </xsl:apply-templates>
            <xsl:value-of select="$newline"/>
            <!-- append and ending so we don't have a trailing comma -->
            {
            "eol":"true"
            }
            <xsl:value-of select="$newline"/>
            ]
        </xsl:if>
      <xsl:value-of select="$newline"/>
      </xsl:when>
      <xsl:otherwise>
	      "title":"null",
          "children":[
		      <!-- if it is an empty topicref -->
		      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
		        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
		      </xsl:apply-templates>
		      <xsl:value-of select="$newline"/>
	          <!-- append and ending so we don't have a trailing comma -->
	          {
	            "eol":"true"
	          }
	          <xsl:value-of select="$newline"/>
	      ]
      </xsl:otherwise>
    </xsl:choose>
     },
</xsl:template>

<xsl:template name="commonProperties">
    <xsl:param name="nodeClass"></xsl:param>
    <xsl:text></xsl:text>
    "nodeClass": "<xsl:value-of select="$nodeClass"/>",
    "nodeName": "<xsl:value-of select="name(.)"/>",
    "nodeClassFull": "<xsl:value-of select="@class"/>",
     <xsl:choose>
       <xsl:when test="@id">"id":"<xsl:value-of select="@id"/>",</xsl:when>
       <xsl:otherwise>"id":"<xsl:value-of select="generate-id(.)"/>",</xsl:otherwise>
     </xsl:choose>
</xsl:template>

</xsl:stylesheet>