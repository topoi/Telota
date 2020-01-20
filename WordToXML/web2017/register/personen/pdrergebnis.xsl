<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:param name="name"/>
    <xsl:template match="request"/>
    <xsl:template match="results">
        <div>
            <h3>Suchergebnisse</h3>
            <xsl:apply-templates select="match"/>
        </div>
    </xsl:template>
    <xsl:template match="match">
        <div class="match">
            <div class="score_wrap">
                <div class="score" style="width: {@optimal};">
                    <xsl:value-of select="@optimal"/>
                </div>
            </div>
            <h3>
                <xsl:value-of select="person/name"/>
            </h3>
            <div class="matchcontent">
                <ul>
                    <li>*<xsl:value-of select="person/dateOfBirth"/>
                        <xsl:if test="person/placeOfBirth/text()"> in <xsl:value-of select="person/placeOfBirth"/>
                        </xsl:if> | †<xsl:value-of select="person/dateOfDeath"/>
                        <xsl:if test="person/placeOfDeath/text()"> in <xsl:value-of select="person/placeOfDeath"/>
                        </xsl:if>
                    </li>
                    <li>
                        <xsl:if test="person/description">
                            <xsl:value-of select="person/description"/>
                        </xsl:if>
                    </li>
                    <xsl:if test="person/reference/text()">
                        <li>Weitere Informationen: <ul>
                                <xsl:for-each select="person/reference">
                                    <li>
                                        <a href="{@url}">
                                            <xsl:value-of select="@provider"/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </li>
                    </xsl:if>
                    <li>Identifikationsnummern:<ul>
                            <xsl:for-each select="identifiers/personId">
                                <li>
                                    <xsl:value-of select="@provider"/>: <a href="{@url}">
                                        <xsl:value-of select="."/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>