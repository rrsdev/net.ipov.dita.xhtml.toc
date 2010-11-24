<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:saxon="http://icl.com/saxon"
    xmlns:xt="http://www.jclark.com/xt"
    xmlns:java="org.dita.dost.util.StringUtils"
    extension-element-prefixes="saxon xt"
    exclude-result-prefixes="java">

    <!--  Find and override the XSL template for the toc-body and LI -->

    <!-- If we are in the ./plugins dir, then the path to the base file should be, once we import it, then we can set out properties. -->
    <xsl:import href="../../../xsl/map2xhtmtoc.xsl"/>

    <!-- TODO: Generate the following dynamically, either in XSL or in ANT -->
    <xsl:param name="YEAR" select="'2010'"/>

    <!-- Used to assign a prefix to the CSS class elements. -->
    <xsl:param name="xtoc-css-prefix" select="'toc'"/>

    <!-- Include the map title as a heading in the document? -->
    <xsl:param name="xtoc-include-map-title" select="'yes'"/>

    <!-- used to 'define' a newline? -->
    <xsl:variable name="newline">
        <xsl:text>&#xa;</xsl:text>
    </xsl:variable>

    <!-- Can't link to commonltr.css or commonrtl.css because we don't know what language the map is in.
	<xsl:template name="generateCssLinks">
	  <xsl:variable name="urltest">
	    <xsl:call-template name="url-string">
	      <xsl:with-param name="urltext">
	        <xsl:value-of select="concat($CSSPATH,$CSS)"/>
	      </xsl:with-param>
	    </xsl:call-template>
	  </xsl:variable>
	  <xsl:if test="string-length($CSS)>0">
		  <xsl:choose>
		    <xsl:when test="$urltest='url'">
		      <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}" />
		    </xsl:when>
		    <xsl:otherwise>
		      <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}" />
		    </xsl:otherwise>
		  </xsl:choose><xsl:value-of select="$newline"/>
	  </xsl:if>
	  <xsl:if test="string-length($CSS)>0">
	  </xsl:if>
	</xsl:template> -->

    <xsl:template match="/*[contains(@class, ' map/map ')]">
	  <xsl:param name="pathFromMaplist"/>
	  <xsl:if test=".//*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
	    <xsl:if test="'yes' = $xtoc-include-map-title">
		    <h3>
		       <xsl:attribute name="class"><xsl:value-of select="$xtoc-css-prefix"/>-heading</xsl:attribute>
	           <xsl:value-of select="title/text()"/>
		    </h3>
	    </xsl:if>
	    <ul class="toc"><xsl:value-of select="$newline"/>

	      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
	        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
	      </xsl:apply-templates>
	    </ul><xsl:value-of select="$newline"/>
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
	  <xsl:choose>
	    <xsl:when test="$title and $title!=''">
	      <li>
	        <xsl:attribute name="id">li-<xsl:value-of select="generate-id(.)"/></xsl:attribute>
	        <xsl:attribute name="class">
	           <xsl:choose>
	               <xsl:when test="position() = 1"><xsl:value-of select="$xtoc-css-prefix"/>-first <xsl:value-of select="$xtoc-css-prefix"/>-topic</xsl:when>
	               <xsl:when test="position() = last()"><xsl:value-of select="$xtoc-css-prefix"/>-last <xsl:value-of select="$xtoc-css-prefix"/>-topic</xsl:when>
	               <xsl:otherwise><xsl:value-of select="$xtoc-css-prefix"/>-topic</xsl:otherwise>
	           </xsl:choose>
	        </xsl:attribute>
	        <xsl:choose>
	          <!-- If there is a reference to a DITA or HTML file, and it is not external: -->
	          <xsl:when test="@href and not(@href='')">
	            <xsl:element name="a">
	              <xsl:attribute name="class"><xsl:value-of select="$xtoc-css-prefix"/>-topic-link</xsl:attribute>
	              <xsl:attribute name="href">
	                <xsl:choose>        <!-- What if targeting a nested topic? Need to keep the ID? -->
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
	                </xsl:choose>
	              </xsl:attribute>
	              <xsl:if test="@scope='external' or @type='external' or ((@format='PDF' or @format='pdf') and not(@scope='local'))">
	                <xsl:attribute name="target">_blank</xsl:attribute>
	              </xsl:if>
	              <xsl:value-of select="$title"/>
	            </xsl:element>
	          </xsl:when>

	          <xsl:otherwise>
	            <span>
	               <xsl:attribute name="class"><xsl:value-of select="$xtoc-css-prefix"/>-topic-title</xsl:attribute>
	               <xsl:value-of select="$title"/>
	            </span>
	          </xsl:otherwise>
	        </xsl:choose>

	        <!-- If there are any children that should be in the TOC, process them -->
	        <xsl:if test="descendant::*[contains(@class, ' map/topicref ')][not(contains(@toc,'no'))][not(@processing-role='resource-only')]">
	          <xsl:value-of select="$newline"/><ul><xsl:value-of select="$newline"/>
	            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
	              <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
	            </xsl:apply-templates>
	          </ul><xsl:value-of select="$newline"/>
	        </xsl:if>
	      </li><xsl:value-of select="$newline"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <!-- if it is an empty topicref -->
	      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
	        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
	      </xsl:apply-templates>
	    </xsl:otherwise>
	  </xsl:choose>

	</xsl:template>

</xsl:stylesheet>