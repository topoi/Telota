<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:param name="erschlossen"/>
    <xsl:param name="cacheLetterIndex"/>
    <!-- Auswahl ob transkribierter oder erschlossener Brief -->
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$erschlossen='true'">
                <xsl:apply-templates mode="erschlossenerBrief" select="//tei:teiHeader"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="transkribierterBrief" select="//tei:teiHeader"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- HTML für erschlossenen Brief -->
    <xsl:template match="tei:teiHeader" mode="erschlossenerBrief">
        <xsl:choose>
            <xsl:when test="//tei:abstract//text() = ''">
                <div class="grid_11 box whitebox">
                    <div class="boxInner erschlossen summary">
                        <p>
                            <span class="label">Hinweis: </span>
                            <xsl:apply-templates select="//tei:abstract" mode="#current"/>
                        </p>
                    </div>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="grid_11 box whitebox">
                    <div class="boxInner erschlossen summary">
                        <p>
                            <span class="label">Hinweis: </span>
                            <xsl:apply-templates select="//tei:abstract" mode="#current"/>
                        </p>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="//tei:correspDesc/tei:note">
            <div class="grid_11 box whitebox">
                <div class="boxInner erschlossen note">
                    <span class="fussnotenpfeil">&#160;</span>
                    <p>
                        <span class="label">Anmerkung: </span>
                        <xsl:apply-templates select="//tei:correspDesc/tei:note" mode="#current"/>
                    </p>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- HTML für transkribierten Brief -->
    <xsl:template match="tei:teiHeader" mode="transkribierterBrief">
        <div id="meta">
            <div class="visible">
                <h2><i class="fa fa-info-circle" aria-hidden="true"/>
                    Zeugenbeschreibung und Textgeschichte 
                </h2>
            </div>
            <div class="invisible">
                <div id="correspDesc">
                    <xsl:if test="//tei:correspAction[@type='sent']/tei:persName | //tei:correspAction[@type='sent']/tei:orgName">
                        <h3>Absender</h3>
                        <ul>
                            <xsl:for-each select="//tei:correspAction[@type='sent']/tei:persName | //tei:correspAction[@type='sent']/tei:orgName">
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="name() = 'persName'">
                                            <a href="../register/personen/detail.xql?id={./@key}">
                                                <xsl:value-of select="./text()"/>
                                            </a>
                                        </xsl:when>
                                        <xsl:when test="name() = 'orgName'">
                                            <a href="../register/einrichtungen/detail.xql?id={./@key}">
                                                <xsl:value-of select="./text()"/>
                                            </a>
                                        </xsl:when>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <xsl:if test="//tei:correspAction[@type='received']/tei:persName | //tei:correspAction[@type='received']/tei:orgName">
                        <ul>
                            <h3>Empfänger</h3>
                            <xsl:for-each select="//tei:correspAction[@type='received']/tei:persName | //tei:correspAction[@type='received']/tei:orgName">
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="name() = 'persName'">
                                            <a href="../register/personen/detail.xql?id={./@key}">
                                                <xsl:value-of select="./text()"/>
                                            </a>
                                        </xsl:when>
                                        <xsl:when test="name() = 'orgName'">
                                            <a href="../register/einrichtungen/detail.xql?id={./@key}">
                                                <xsl:value-of select="./text()"/>
                                            </a>
                                        </xsl:when>
                                    </xsl:choose>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                </div>
                <xsl:if test="//tei:correspDesc/tei:note//text()">
                    <div id="note">
                        <h3>Anmerkungen zum Brief</h3>
                        <xsl:for-each select="//tei:correspDesc/tei:note">
                            <p>
                                <xsl:apply-templates/>
                            </p>
                        </xsl:for-each>
                    </div>
                </xsl:if>
                <xsl:if test="(//tei:msDesc/tei:physDesc)">
                    <div id="zeugenbeschreibung">
                        <h3>Zeugenbeschreibung</h3>
                        <xsl:for-each select="//tei:physDesc/tei:p">
                            <p>
                                <xsl:apply-templates/>
                            </p>
                        </xsl:for-each>
                    </div>
                </xsl:if>
                <xsl:if test="(//tei:edition[@ana='#firstEdition'])">
                    <p><i>Dieser Brief wird hier erstmals veröffentlicht.</i></p>
                </xsl:if>
                <xsl:if test="(//tei:msIdentifier and //tei:sourceDesc//tei:listWit//tei:witness) or (not(//tei:msIdentifier) and count(//tei:sourceDesc//tei:listWit//tei:witness) &gt; 1)">
                    <h3>Weitere Überlieferung</h3>
                    <xsl:choose>
                        <xsl:when test="count(//tei:sourceDesc//tei:listWit//tei:bibl) &gt; 1">
                            <ul>
                                <xsl:for-each select="//tei:sourceDesc//tei:listWit//tei:bibl">
                                    <li>
                                        <xsl:apply-templates/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="//tei:sourceDesc//tei:listWit//tei:bibl">
                                <p>
                                    <xsl:apply-templates/>
                                </p>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    <!-- Weitere Regeln -->
    <xsl:template match="tei:physDesc//tei:ref | tei:correspDesc/tei:note//tei:ref | tei:profileDesc/tei:abstract//tei:ref" mode="#all">
        <xsl:choose>
            <xsl:when test="@type='tageskalender'">
                <a href="http://telotadev.bbaw.de:9011/exist/rest/db/apps/ediarum/web/tageskalender/detail.xql?datum={@target}">
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="letterID">
                    <xsl:choose>
                        <xsl:when test="matches(@target, '/')">
                            <xsl:value-of select="substring-before(@target, '/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@target"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="letterTitle">
                    <xsl:value-of select="doc($cacheLetterIndex)//entry[@id=$letterID]/text()"/>
                </xsl:variable>
                <a href="detail.xql?id={$letterID}">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="."/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="#all" match="tei:persName">
        <xsl:variable name="id">
            <xsl:value-of select="@key"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@cert='low'">
                <span class="tooltip">
                    <span class="fussnote">
                        <span class="fussnotenpfeil">&#160;</span>
                        <xsl:text>Identifizierung der Person unsicher</xsl:text>
                    </span>
                    <a href="../register/personen/detail.xql?id={$id}">
                        <xsl:apply-templates mode="#current"/>
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <a href="../register/personen/detail.xql?id={$id}">
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template mode="#all" match="tei:placeName">
        <a href="../register/orte/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:rs[@type='person']">
        <a href="../register/personen/detail.xql?id={./@key}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:bibl[@sameAs]">
        <a href="../register/werke/detail.xql?id={./@sameAs}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>
    <xsl:template mode="#all" match="tei:seg">
        <span class="tooltip">
            <span class="fussnote">
                <span class="fussnotenpfeil">&#160;</span>
                <xsl:apply-templates select="tei:note" mode="#current"/>
            </span>
            <xsl:apply-templates select="tei:orig" mode="#current"/>
        </span>
    </xsl:template>
    <xsl:template mode="#all" match="tei:note[not(@resp='Autor')]">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template mode="#all" match="tei:quote">
        <span class="quote">
            <xsl:text>„</xsl:text>
            <xsl:apply-templates mode="#current"/>
            <xsl:text>“</xsl:text>
        </span>
    </xsl:template>
    <xsl:template mode="#all" match="tei:ex">
        <em>
            <xsl:value-of select="."/>
        </em>
    </xsl:template>
</xsl:stylesheet>