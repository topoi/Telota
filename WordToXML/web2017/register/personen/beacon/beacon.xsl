<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="url"/>
    <xsl:param name="urlname"/>
    <xsl:param name="group"/>
    <xsl:param name="position"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <xsl:variable name="beacon" select="unparsed-text($url)"/>
        <xsl:variable name="text" select="$beacon"/>
        <xsl:variable name="target" select="substring-before(substring-after($beacon, '#TARGET: '), '&#xA;')"/>
        <xsl:variable name="feed" select="substring-before(substring-after($beacon, '#FEED: '), '&#xA;')"/>
        <xsl:variable name="contact" select="substring-before(substring-after($beacon, '#CONTACT: '), '&#xA;')"/>
        <xsl:variable name="institution" select="substring-before(substring-after($beacon, '#INSTITUTION: '), '&#xA;')"/>
        <xsl:variable name="description" select="substring-before(substring-after($beacon, '#DESCRIPTION: '), '&#xA;')"/>
        <xsl:variable name="timestamp" select="substring-before(substring-after($beacon, '#TIMESTAMP: '), '&#xA;')"/>
        <beacon xmlns="http://purl.org/net/beacon" prefix="http://d-nb.info/gnd/" target="{$target}" feed="{$feed}" contact="{$contact}" institution="{$institution}" description="{$description}" timestamp="{$timestamp}" name="{$urlname}" group="{$group}" position="{$position}">
            <xsl:for-each select="tokenize($text, '\r?\n')">
                <xsl:choose>
                    <xsl:when test="matches(., '#')"/>
                    <xsl:otherwise>
                        <link source="{replace(., '\|\d\d?', '')}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </beacon>
    </xsl:template>
</xsl:stylesheet>