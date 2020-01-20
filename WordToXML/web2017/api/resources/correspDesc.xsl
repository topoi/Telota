<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:param name="dataRegisterPersons"/>
    <xsl:param name="dataRegisterPlaces"/>
    <xsl:param name="permanentURLLetters"/>
    <xsl:param name="letterID"/>
    <xsl:template match="/">
        <correspDesc ref="{concat($permanentURLLetters, $letterID)}">
            <xsl:call-template name="correspActionSent"/>
            <xsl:call-template name="correspActionReceived"/>
        </correspDesc>
    </xsl:template>
    <xsl:template name="correspActionSent">
        <correspAction type="sent">
            <xsl:apply-templates select="tei:creation/tei:persName[@type='absender']"/>
            <xsl:apply-templates select="tei:creation/tei:placeName[@type='schreibort']"/>
            <xsl:apply-templates select="tei:creation/tei:date"/>
        </correspAction>
    </xsl:template>
    <xsl:template name="correspActionReceived">
        <correspAction type="received">
            <xsl:apply-templates select="tei:creation/tei:persName[@type='empfänger']"/>
        </correspAction>
    </xsl:template>
    <xsl:template match="tei:persName">
        <xsl:variable name="id">
            <xsl:value-of select="@key/data(.)"/>
        </xsl:variable>
        <xsl:variable name="normid">
            <xsl:value-of select="doc($dataRegisterPersons)//person[@id=$id]/@normid"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$normid!=''">
                <persName ref="{$normid}">
                    <xsl:value-of select="./text()"/>
                </persName>
            </xsl:when>
            <xsl:otherwise>
                <persName>
                    <xsl:value-of select="./text()"/>
                </persName>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:placeName">
        <xsl:variable name="id">
            <xsl:value-of select="./@key"/>
        </xsl:variable>
        <xsl:variable name="normid">
            <xsl:value-of select="doc($dataRegisterPlaces)//ort[@id=$id]/@normid"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$normid!=''">
                <placeName ref="{$normid}">
                    <xsl:value-of select="./text()"/>
                </placeName>
            </xsl:when>
            <xsl:otherwise>
                <placeName>
                    <xsl:value-of select="./text()"/>
                </placeName>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:date">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>