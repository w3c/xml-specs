<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">


<!-- make sure we get an encoding decl! -->
<xsl:output method="xml" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" indent="no" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
<!--<xsl:import href="http://www.w3.org/2002/xmlspec/html/1.3/xmlspec.xsl"/>-->
<xsl:include href="diffspec.xsl"/>

 <xsl:template match="/">
  <!-- Allow mixed @num and not -->
    <xsl:apply-templates/>
  </xsl:template>
 <xsl:template mode="number-simple" match="prod">
    <!-- Using @num and auto-numbered productions is forbidden. -->
    <xsl:choose>
      <xsl:when test="@num">
        <xsl:value-of select="@num"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:variable name="set1" select="preceding::prod[not(@diff='add')]"/>
       <xsl:choose>
        <xsl:when test="$set1[@num]">
         <xsl:variable name="fence" select="$set1[@num][position()=last()]"/>
         <xsl:variable name="preNum" select="count($set1[@num])"/>
         <!--<xsl:message><xsl:value-of select="$fence/@num"/>|<xsl:value-of select="count($set1)"/>|<xsl:value-of select="$preNum"/>|<xsl:value-of select="count($set1[count(preceding::prod/@num)=$preNum]) + 1"/></xsl:message>-->
         <xsl:value-of select="$fence/@num + count($set1[count(preceding::prod/@num)=$preNum]) + 1"/>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="count($set1)+1"/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
