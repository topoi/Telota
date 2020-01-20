<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:param name="currentSection"/>
    <xsl:param name="currentPage"/>
    <xsl:param name="pageTitle"/>
    <xsl:param name="searchTerms"/>
    <xsl:param name="baseURL"/>
    <xsl:output method="html" media-type="text/html" omit-xml-declaration="yes" encoding="UTF-8" indent="yes"/>
    <xsl:variable name="titleAddOn">
        <xsl:if test="$pageTitle">
            <xsl:text> - </xsl:text>
            <xsl:value-of select="$pageTitle"/>
        </xsl:if>
    </xsl:variable>
    <xsl:template match="/">
        <html>
            <head>
                <title>Alexander von Humboldt auf Reisen <xsl:value-of select="$titleAddOn"/>
                </title>
                <link rel="icon" href="{$baseURL}/resources/images/favicon.png" type="image/png"/>
                <xsl:call-template name="css"/>
                <xsl:call-template name="js"/>
            </head>
            <body>
                <div class="outerLayer" id="navbar">
                    <div class="container_16">
                        <div class="grid_7">
                            <a id="homelink" href="{$baseURL}/index.xql">
                                <h1>Alexander von Humboldt auf Reisen</h1>
                            </a>
                            <img id="beta" src="{$baseURL}/resources/images/beta.png"/>
                        </div>
                        <div class="grid_9">
                            <nav>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'reisetagebuecher|commentary')">
                                        <a class="current" href="{$baseURL}/reisetagebuecher/index.xql">Reisetagebücher</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/reisetagebuecher/index.xql">Reisetagebücher</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'themen')">
                                        <a class="current" href="{$baseURL}/themen/index.xql">Themen</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/themen/index.xql">Themen</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'briefe')">
                                        <a class="current" href="{$baseURL}/briefe/index.xql">Briefe</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/briefe/index.xql">Briefe</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'register')">
                                        <a class="current" href="{$baseURL}/register/index.xql">Register</a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a href="{$baseURL}/register/index.xql">Register</a>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="matches($currentSection, 'suche')">
                                        <a class="search current" href="{$baseURL}/suche/index.xql">
                                            <span>Suche</span>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a class="search" href="{$baseURL}/suche/index.xql">
                                            <span>Suche</span>
                                        </a>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </nav>
                        </div>
                    </div>
                </div>
                <xsl:copy-of select="transferContainer/child::*"/>
                <div class="outerLayer" id="footer">
                    <footer class="container_16">
                        <div class="grid_3">
                            <ul>
                                <h3>Über das Vorhaben</h3>
                                <li>
                                    <a href="http://www.bbaw.de/forschung/avh-r/projektdarstellung">Vorhaben</a>
                                </li>
                                <li>
                                    <a href="http://www.bbaw.de/forschung/avh-r/mitarbeiter">Mitarbeiter</a>
                                </li>
                                <li>
                                    <a href="{$baseURL}/impressum.xql">Impressum</a>
                                </li>
                                <li>
                                    <a href="{$baseURL}/api/index.xql">Schnittstellen</a>
                                </li>
                            </ul>
                        </div>
                        <div class="grid_5">
                            <a href="https://creativecommons.org/licenses/by-sa/4.0/">
                                <img src="{$baseURL}/resources/images/cc-by-sa.png" width="110"/>
                            </a>
                            <p>
                                <br/>Alle Texte dieser Website können – soweit nicht anders vermerkt – unter den Bedingungen der <a href="https://creativecommons.org/licenses/by-sa/4.0/">Creative Commons-Lizenz CC-BY-SA 4.0</a> nachgenutzt werden.</p>
                        </div>
                        <div class="grid_4">
                            <h3>Träger des Forschungsvorhabens</h3>
                            <p class="italic">
                                »Alexander von Humboldt auf Reisen – Wissenschaft aus der Bewegung« ist ein Vorhaben der Berlin-Brandenburgischen Akademie der Wissenschaften</p>
                        </div>
                        <div class="grid_4">
                            <a href="http://www.bbaw.de">
                                <img src="{$baseURL}/resources/images/bbaw_logo.png" title="Berlin-Brandeburgische Akademie der Wissenschaften" alt="Das Logo der Berlin-Brandenburgischen Akademie der Wissenschaften zeigt den Schriftzug neben einem Adler vor einem Sternenhimmel"/>
                            </a>
                        </div>
                    </footer>
                </div>
                <xsl:if test="$currentSection!='startseite'">
                    <script type="text/javascript">
                        $(document).ready(function() {
                        /*
                        var defaults = {
                        containerID: 'toTop', // fading element id
                        containerHoverID: 'toTopHover', // fading element hover id
                        scrollSpeed: 1200,
                        easingType: 'linear' 
                        };
                        */
                        
                        $().UItoTop({ easingType: 'easeOutQuart' });
                        
                        });
                    </script>
                </xsl:if>
                <xsl:if test="$currentSection='reisetagebuecher' or $currentSection='briefe'">
                    <script type="text/javascript">
                    $(document).ready(function(){
                    
                        var options = {  
                        preloadImages: false,  
                        zoomWidth: 450,  
                        zoomHeight: 350,  
                        xOffset:10,
                        position:'left',
                        title: false
                        };
                        
                        $('.faksimile').jqzoom(options);
                    });
                </script>
                </xsl:if>
                <script type="text/javascript">
                    $('.tooltip').not('.add').not('.measure').mouseover(function(){
                    
                        //If this item is already selected, forget about it.
                        if ($(this).hasClass('active')) return;
                    
                        //Find the currently selected item, and remove the style class
                        $('.active').removeClass('active');

                        //Add the style class to this item
                        $(this).addClass('active');
                    });
                    $('.close').click(function(){
                        $(".active").removeClass('active');
                    });
                </script>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="css">
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/reset.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/960.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/main.css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/font-awesome.css"/>
        <xsl:if test="$currentSection='startseite'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/startseite.css"/>
        </xsl:if>
        <xsl:if test="$currentSection='briefe' or $currentSection='reisetagebuecher' or $currentSection='themen' or $currentSection='commentary' or $currentSection='vorlesungen'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="../resources/css/transkription.css" type="text/css"/>
        </xsl:if>
        <xsl:if test="$currentSection='reisetagebuecher' or $currentSection='briefe'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$baseURL}/resources/css/jqzoom.css"/>
        </xsl:if>
<!--        <xsl:if test="$currentSection='reisetagebuecher' or $currentSection='suche'">
            <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="../resources/css/kalendae.css" type="text/css" charset="utf-8"/>
        </xsl:if>
-->
        <xsl:if test="$currentSection='suche'">
            <link rel="stylesheet" href="../resources/css/suche.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentPage='pdrRecherche'">
            <link rel="stylesheet" href="{$baseURL}/resources/css/pdrRecherche.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <xsl:if test="$currentSection='commentary'">
            <link rel="stylesheet" href="../resources/css/commentary.css" type="text/css" charset="utf-8"/>
        </xsl:if>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" media="screen,projection" href="../resources/css/ui.totop.css"/>
    </xsl:template>
    <xsl:template name="js">
        <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery-1.7.2.min.js" type="text/javascript">&#160;</script>
        <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery-ui-1.10.3.custom.js" type="text/javascript">&#160;</script>
        <xsl:if test="$currentSection!='startseite'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jquery.ui.totop.js" type="text/javascript">&#160;</script>
        </xsl:if>
        <xsl:if test="$currentSection='reisetagebuecher' or $currentSection='briefe'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="{$baseURL}/resources/js/jqzoom2016.js" type="text/javascript" charset="utf-8">&#160;</script>
        </xsl:if>
<!--        <xsl:if test="$currentSection='reisetagebuecher' or $currentSection='suche'">
            <script xmlns="http://www.w3.org/1999/xhtml" src="http://telotadev.bbaw.de/schleiermacher/website/js/kalendae.min.js" type="text/javascript" charset="utf-8"/>
        </xsl:if>
-->
        <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.css"/>
        <script src="http://cdn.leafletjs.com/leaflet/v0.7.7/leaflet.js">&#160;</script>
        <script src="{$baseURL}/resources/js/jquery.collapser.min.js">&#160;</script>
        <script src="{$baseURL}/resources/js/jquery.truncate.js">&#160;</script>
        <script>
            $(function() {
            $( ".accordion" ).accordion({
                heightStyle: "content",
            });
            });
        </script>
        <xsl:if test="$currentSection='briefe' or $currentSection='themen'">
            <script>
                $(document).ready(function(){
                $('.introInner').collapser({
                mode: 'words',
                truncate: 60,
                showText: '[Mehr]',
                hideText: '[Weniger]'
                });
                });
            </script>
        </xsl:if>
        <script>
            $(document).ready(function(){
                $('.collapsedNote').collapser({
                mode: 'block',
                target: 'next',
                effect: 'slide'
                });
            });
            <!--$(document).ready(function() {
            $(".truncate").dotdotdot({
            ellipsis: '(...)',
            wrap: 'letter',
            height: '30' 
            });
            });-->
            $(document).ready(function(){
            $('.truncate').each(function(){
                $(this).truncate({
                length: '80',
                ellipsis: ' <a href="#endnote' + this.id + '">(...)</a>',
                words: true,
                keepFirstWord: true
                });
                });
            });
        </script>
    </xsl:template>
</xsl:stylesheet>