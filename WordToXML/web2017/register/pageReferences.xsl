<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="/">
        <xsl:variable name="keys">
            <xsl:for-each select="substring-before(.//@target, '#')"/>
        </xsl:variable>
        <ul>
            <xsl:for-each select="$keys">
                <xsl:value-of select="$keys"/>
            </xsl:for-each>
        </ul>
    </xsl:template>
</xsl:stylesheet>