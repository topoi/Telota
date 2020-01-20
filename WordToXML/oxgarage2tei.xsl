<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei" version="2.0">

    <xsl:output method="xml" indent="no"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:body">
        <body>
            <div type="writingAct">
                <xsl:apply-templates/>
            </div>
        </body>
    </xsl:template>
    
    <xsl:template match="tei:editionStmt/tei:edition/tei:date"/>

    <xsl:template match="tei:p[@rend = 'MBDatumszeile']">
        <dateline sameAs="MBDatumszeile">
            <xsl:apply-templates/>
        </dateline>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend = 'MBAnrede']">
        <salute sameAs="MBAnrede">
            <xsl:apply-templates/>
        </salute>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend = 'MBTextohneEinzug'] | tei:p[@rend = 'MBTextmitEinzug'] | tei:p[@rend = 'MBAdresse']">
        <p sameAs="{@rend}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend = 'MBRedKopf']/tei:index"></xsl:template>
    
    <xsl:template match="tei:p[@rend = 'MBKolumTitel'] | tei:p[@rend = 'MBRedKopf']"></xsl:template>
    
    <xsl:template match="tei:p[@rend= 'MBUnterschrift']">
        <closer sameAs="{@rend}">
            <xsl:apply-templates/>
        </closer>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend= 'MBNachschrift']">
        <postscript>
            <p>
                <xsl:apply-templates/>
            </p>
        </postscript>
    </xsl:template>
    
    <xsl:template match="tei:encodingDesc">
        <encodingDesc>
            <xsl:copy-of select="//tei:p[@rend = 'MBKolumTitel']"></xsl:copy-of>
            <xsl:copy-of select="//tei:p[@rend = 'MBRedKopf']"></xsl:copy-of>
            <xsl:apply-templates/>
        </encodingDesc>
    </xsl:template>

    <xsl:template match="tei:hi[@rend= 'italic']">
        <hi rendition="#u">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend= 'bold']">
        <xsl:processing-instruction name="oxy_custom_start">
            type="oxy_content_highlight" color="255,255,0"
        </xsl:processing-instruction>
        <xsl:apply-templates/>
        <xsl:processing-instruction name="oxy_custom_end"/>
    </xsl:template>
    
    <xsl:template match="tei:hi[@rend= 'superscript']">
        <hi rendition="#sup">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>
    
    <xsl:template match="tei:anchor">
        <anchor xml:id="{generate-id()}"/>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>



</xsl:stylesheet>
