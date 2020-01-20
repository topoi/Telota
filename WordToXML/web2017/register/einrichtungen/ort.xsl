<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN" indent="yes"/>
    <xsl:template match="/">
        <h2>
            <xsl:value-of select="//ortsname"/>
        </h2>
        <xsl:if test="//zugehörigkeit">
            <p>
                <xsl:value-of select="//zugehörigkeit"/>
            </p>
        </xsl:if>
        <p>
            <xsl:value-of select="//beschreibung"/>
        </p>
    </xsl:template>
</xsl:stylesheet>