<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN" indent="yes"/>
    <xsl:template match="/">
        <h2>
            <xsl:value-of select="//titel"/>
        </h2>
        <xsl:for-each select="//autor">
            <p>
                <a href="personen.xql?id={substring(@id, 2)}">
                    <xsl:value-of select="//autor"/>
                </a>
            </p>
        </xsl:for-each>
        <xsl:if test="//beschreibung">
            <p>
                <xsl:value-of select="//beschreibung"/>
            </p>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>