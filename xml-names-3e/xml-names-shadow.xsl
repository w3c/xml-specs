<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns="http://www.w3.org/1999/xhtml">

<!-- Make sure even stuff we add gets diff-handled properly -->
<xsl:import href="xmlspec.xsl"/>

<xsl:variable name="additional.css">
.RFC2119 {
  text-transform: lowercase;
  font-style: italic;
}
<xsl:if test="$show.diff.markup != '0'">
<xsl:text>
div.diff-add  { background-color: #FFFF99; }
div.diff-del  { text-decoration: line-through; }
div.diff-chg  { background-color: #99FF99; }
div.diff-off  {  }

span.diff-add { background-color: #FFFF99; }
span.diff-del { text-decoration: line-through; }
span.diff-chg { background-color: #99FF99; }
span.diff-off {  }

td.diff-add   { background-color: #FFFF99; }
td.diff-del   { text-decoration: line-through }
td.diff-chg   { background-color: #99FF99; }
td.diff-off   {  }
</xsl:text>
</xsl:if>
</xsl:variable>

<xsl:template match="emph[@role='rfc2119']">
 <em class="RFC2119">
  <xsl:if test=". != 'EMPHASIZED'">
   <xsl:attribute name="title">
    <xsl:value-of select="."/>
    <xsl:text> in RFC 2119 context</xsl:text>
   </xsl:attribute>
  </xsl:if>
  <xsl:apply-templates/>
 </em>
</xsl:template>

<!-- prod: a formal grammar production -->
<!-- if not in a prodgroup, needs a <tbody> -->
<!-- has a weird content model; makes a table but there are no
     explicit rules; many different things can start a new row -->
<!-- process the first child in each row, and it will process the
     others -->
<xsl:template match="prod">
  <tbody>
    <xsl:apply-templates select="lhs |
              rhs[preceding-sibling::*[1][name()!='lhs']] |
              com[preceding-sibling::*[1][name()!='rhs']] |
              constraint[preceding-sibling::*[1][name()!='rhs']] |
              vc[preceding-sibling::*[1][name()!='rhs']] |
              nsc[preceding-sibling::*[1][name()!='rhs']] |
              wfc[preceding-sibling::*[1][name()!='rhs']]"/>
  </tbody>
</xsl:template>

<xsl:template match="prodgroup/prod">
  <xsl:apply-templates select="lhs |
            rhs[preceding-sibling::*[1][name()!='lhs']] |
            com[preceding-sibling::*[1][name()!='rhs']] |
            constraint[preceding-sibling::*[1][name()!='rhs']] |
            vc[preceding-sibling::*[1][name()!='rhs']] |
            nsc[preceding-sibling::*[1][name()!='rhs']] |
            wfc[preceding-sibling::*[1][name()!='rhs']]"/>
</xsl:template>

<!-- rhs: right-hand side of a formal production -->
<!-- make a table cell; if it's not the first after an LHS, make a
     new row, too -->
<xsl:template match="rhs">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[1][name()='lhs']">
      <td>
        <xsl:if test="ancestor-or-self::*/@diff and $show.diff.markup='1'">
          <xsl:attribute name="class">
            <xsl:text>diff-</xsl:text>
            <xsl:value-of select="ancestor-or-self::*/@diff"/>
          </xsl:attribute>
        </xsl:if>
        <code><xsl:apply-templates/></code>
      </td>
      <xsl:apply-templates select="following-sibling::*[1][name()='com' or
                                        name()='nsc' or
                                        name()='constraint' or
                                        name()='vc' or
                                        name()='wfc']"/>
    </xsl:when>
    <xsl:otherwise>
      <tr valign="baseline">
        <td/><td/><td/>
        <td>
          <xsl:if test="ancestor-or-self::*/@diff and $show.diff.markup='1'">
            <xsl:attribute name="class">
              <xsl:text>diff-</xsl:text>
              <xsl:value-of select="ancestor-or-self::*/@diff"/>
            </xsl:attribute>
          </xsl:if>
          <code><xsl:apply-templates/></code>
        </td>
        <xsl:apply-templates select="following-sibling::*[1][name()='com' or
                                          name()='nsc' or
                                          name()='constraint' or
                                          name()='vc' or
                                          name()='wfc']"/>
      </tr>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- nsc: namespace check reference in a formal production -->
<xsl:template match="nsc">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[1][name()='rhs']">
      <td>
        <xsl:if test="@diff and $show.diff.markup='1'">
          <xsl:attribute name="class">
            <xsl:text>diff-</xsl:text>
            <xsl:value-of select="@diff"/>
          </xsl:attribute>
        </xsl:if>
        <a>
          <xsl:attribute name="href">
            <xsl:call-template name="href.target">
              <xsl:with-param name="target" select="key('ids', @def)"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:text>[NSC: </xsl:text>
          <xsl:apply-templates select="key('ids', @def)/head" mode="text"/>
          <xsl:text>]</xsl:text>
        </a>
      </td>
    </xsl:when>
    <xsl:otherwise>
      <tr valign="baseline">
        <td/><td/><td/><td/>
        <td>
          <xsl:if test="@diff and $show.diff.markup='1'">
            <xsl:attribute name="class">
      	<xsl:text>diff-</xsl:text>
      	<xsl:value-of select="@diff"/>
            </xsl:attribute>
          </xsl:if>
          <a>
            <xsl:attribute name="href">
              <xsl:call-template name="href.target">
                <xsl:with-param name="target" select="key('ids', @def)"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:text>[NSC: </xsl:text>
            <xsl:apply-templates select="key('ids', @def)/head" mode="text"/>
            <xsl:text>]</xsl:text>
          </a>
        </td>
      </tr>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="nscnote/head">
  <p class="prefix">
    <xsl:if test="../@id">
      <a name="{../@id}" id="{../@id}"/>
    </xsl:if>
    <b><xsl:text>Namespace constraint: </xsl:text><xsl:apply-templates/></b>
  </p>
</xsl:template>

<!-- nscnote: namespace check note after formal production -->
<xsl:template match="nscnote">
  <div class="constraint">
    <xsl:apply-templates/>
  </div>
</xsl:template>

<!-- 1.1 role for author -->
  <xsl:template match="author">
    <dd>
      <xsl:apply-templates/>
      <xsl:if test="@role = '1.1'">
	<xsl:text> - Version 1.1</xsl:text>
      </xsl:if>
    </dd>
  </xsl:template>
</xsl:stylesheet>
