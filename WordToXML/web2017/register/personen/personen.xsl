<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0">
    <xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN" indent="yes"/>
    <xsl:param name="baseURL"/>
    <xsl:template match="tei:person">
        <h1>
            <xsl:apply-templates select="tei:persName[@type='reg']/tei:surname/text()"/>
            <xsl:if test="tei:persName[@type='reg']/tei:forename">
                <xsl:text>, </xsl:text>
                <xsl:apply-templates select="tei:persName[@type='reg']/tei:forename"/>
            </xsl:if>
        </h1>
        <p>
            <xsl:value-of select="tei:birth"/>–<xsl:value-of select="tei:death"/>
        </p>
    </xsl:template>
    <xsl:template match="tei:note">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="starts-with(@id, '#o')">
                <a href="{$baseURL}/register/orte/detail.xql?id={substring-after(@id, '#')}">
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:when test="starts-with(@id, '#p')">
                <a href="{$baseURL}/register/personen/detail.xql?id={substring-after(@id, '#')}">
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>