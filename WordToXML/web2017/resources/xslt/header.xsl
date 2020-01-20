<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="columns"/>
    <xsl:output method="html" media-type="text/html" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <xsl:template match="/">
        <div xmlns="http://www.w3.org/1999/xhtml" class="outerLayer" id="header">
            <header class="container_16">
                <xsl:choose>
                    <xsl:when test="$columns='16'">
                        <div class="grid_16">
                            <xsl:copy-of select="transferContainer/child::*"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="grid_16">
                            <xsl:copy-of select="transferContainer/child::*"/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </header>
        </div>
    </xsl:template>
</xsl:stylesheet>