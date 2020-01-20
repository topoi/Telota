<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.bbaw.de/telota/correspSearch" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="cs xs tei" version="2.0">
    <xsl:param name="excludeSource"/>
    <xsl:param name="excludeGND"/>
    <xsl:param name="mediumDate"/>
    <xsl:param name="queryString"/>
    <xsl:param name="persName"/>
    <xsl:variable name="language">de</xsl:variable>
    <xsl:function name="cs:formatDate">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="$language='de'">
                <xsl:value-of select="replace($date, '(\d\d\d\d)-(\d\d)-(\d\d)', '$3.$2.$1')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="replace($date, '(\d\d\d\d)-(\d\d)-(\d\d)', '$3/$2/$1')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template match="/">
        <div xmlns="http://www.w3.org/1999/xhtml" id="linkedLetters">
            <div class="visible">
                <span class="label">Briefnetz erkunden <i class="fa fa-share-alt">&#160;</i>
                </span>
            </div>
            <div class="invisible">
                <span class="arrow">&#160;</span>
                <p>Briefe von oder an <xsl:value-of select="$persName"/> im selben Zeitraum in anderen Editionen:</p>
                <ul>
                    <xsl:variable name="closestPrevDate" as="node()*">
                        <xsl:apply-templates select="//tei:correspDesc[(xs:date($mediumDate) &gt; xs:date(./tei:correspAction/tei:date/@when)) and not(.//tei:persName/@ref=$excludeGND)]">
                            <xsl:sort select="tei:correspAction/tei:date/@when" data-type="text"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:variable name="closestNextDate" as="node()*">
                        <xsl:apply-templates select="//tei:correspDesc[(xs:date(./tei:correspAction/tei:date/@when) &gt;= xs:date($mediumDate)) and not(.//tei:persName/@ref=$excludeGND)]">
                            <xsl:sort select="tei:correspAction/tei:date/@when" data-type="text"/>
                        </xsl:apply-templates>
                    </xsl:variable>
                    <xsl:copy-of select="$closestPrevDate[last()]"/>
                    <xsl:copy-of select="$closestNextDate[1]"/>
                    <xsl:if test="count(//tei:correspDesc) &gt; 2">
                        <li>
                            <a href="http://correspSearch.bbaw.de/search.xql?{$queryString}&amp;l=de" target="_blank">Alle Nachweise in correspSearch ansehen</a>
                        </li>
                    </xsl:if>
                </ul>
                <p class="hint">Diese Verknüpfungen werden automatisiert bereitgestellt über <a href="http://correspSearch.bbaw.de/index.xql?l=de" target="_blank">correspSearch</a>.</p>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:correspDesc[substring-after(@cs:source, '#')=$excludeSource]"/>
    <xsl:template match="tei:correspDesc">
        <xsl:variable name="source">
            <xsl:value-of select="substring-after(@cs:source, '#')"/>
        </xsl:variable>
        <li>
            <xsl:choose>
                <xsl:when test="@ref">
                    <a href="{@ref}" target="_blank">
                        <xsl:call-template name="title"/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="title"/>
                    <!--<text>. In: </text>
                    <xsl:value-of select="./ancestor-or-self::tei:TEI//tei:bibl[@xml:id=$source]"/>-->
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    <xsl:template name="title">
        Von <xsl:value-of select="tei:correspAction[@type='sent']/tei:persName/text()"/> 
        an <xsl:value-of select="tei:correspAction[@type='received']/tei:persName/text()"/>
        <xsl:if test="tei:correspAction[@type='sent']/tei:placeName/text()">
            <text>, </text>
            <xsl:value-of select="tei:correspAction[@type='sent']/tei:placeName/text()"/>
        </xsl:if>
        <xsl:if test="tei:correspAction/tei:date">
            <text>, </text>
            <xsl:apply-templates select="tei:correspAction/tei:date"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:date">
        <xsl:choose>
            <xsl:when test="@when">
                <xsl:value-of select="cs:formatDate(@when)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>