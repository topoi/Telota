xquery version "3.0"; 

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html media-type=text/html";

let $login := edweb:login()

(: Parameter aus URL übernehmen :)
let $p_id := request:get-parameter("id", ())
let $p_searchTerms := request:get-parameter("searchTerms", ())

(: Pfad das aktuellen Briefs :)
let $letter := 
        if ($p_searchTerms)
        then 
            (if (collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)])
            then (kwic:expand(collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)]))
            else (collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')]))
        else (collection($edweb:data)//tei:TEI[@xml:id=concat($p_id, '')])
        
(: Parameter für alle Transformationen :)
let $params := 
    <parameters>
        <param name="id" value="{$p_id}"/>
        <param name="view" value="c" />
        <param name="filename" value="none" />
        <param name="cacheLetterIndex" value="{$edweb:cacheLetterIndex}" />
    </parameters>

let $authorInfo := 
    ()
    (:if (count($letter//tei:author) = 0)
    then ()
    else
    <div class="grid_11 authorInfo">
    {if (count($letter//tei:author) > 1)
    then (<h2>Über die AutorInnen</h2>)
    else (<h2>Über den/die AutorIn</h2>)}
    {for $author in $letter//tei:author
    return
    <div>
        <a name="authorInfo">&#160;</a>
        <h3>{$author/tei:persName/text()}</h3>
        <p class="orgName">{$author/tei:affiliation/text()}</p>
        <p class="mail"><a href="mailto:{$author/tei:email/text()}">{$author/tei:email}</a></p>
        <p class="note">{transform:transform($author/tei:note, doc('../resources/xslt/transcription.xsl'), $params)}</p>
     </div>}
    </div>:)

(: Rendern der Transkription bzw. (wenn nur erschlossen) der Anmerkung zum Brief und ggf. Zusammenfassung :)
let $letterText := transform:transform($letter, doc("../resources/xslt/content-grid.xsl"), $params)
let $subnav :=
    if ($letter/@type = 'year_intro')
    then ()
    else (
    <!--<div id="subnavbar">
        <ul>
            {if ($p_id='aufbau_edition') 
            then (<li><a href="text.xql?id=aufbau_edition" class="current">Aufbau der Edition</a></li>)
            else (<li><a href="text.xql?id=aufbau_edition">Aufbau der Edition</a></li>),
            if ($p_id='archiv') 
            then (<li><a href="text.xql?id=archiv" class="current">Ifflands Archiv</a></li>)
            else (<li><a href="text.xql?id=weitere_gliederung1">Weitere Gliederung 1</a></li>),
            if ($p_id='nationaltheater') 
            then (<li><a href="text.xql?id=nationaltheater" class="current">Nationaltheater</a></li>)
            else (<li><a href="text.xql?id=weitere_gliederung2">Weitere Gliederung 2</a></li>)}
        </ul>
    </div>-->)

let $year_link := 
    concat('../briefe/index.xql?jahr=', $letter/@subtype)

let $toc :=
    if ($p_id='zeuske')
    then (
        <div class="grid_11">
        <ul class="toc">
        <h3>Inhaltsverzeichnis</h3>
        {for $head at $pos in $letter//tei:text//tei:head
        return
        <li><a href="#section{$pos}">{$head//text()}</a></li>}
        </ul></div>
    ) else ()

(: ########### HTML-Ausgabe ########### :)
let $header := 
    <transferContainer>
        {$subnav}
        <h1>{$letter//tei:titleStmt/tei:title[not(@type='sub')]/text()}</h1>
        <ul class="author">
            {for $author in $letter//tei:author
            return
            <li>{$author/tei:persName/text()}</li>}
        </ul>
    </transferContainer>

let $content := 
    <transferContainer>
        {if ($letter/@type = 'year_intro') then (<p class="yearLink"><a href="{$year_link}"><i class="fa fa-files-o" aria-hidden="true">&#160;</i>Alle Briefe dies Jahrgangs anzeigen</a></p>) else ()}
        {if ($letterText!='') then ($toc, $letterText, $authorInfo)
        else (<div class="notfound"><p>Fehler!<br/>Es wurde kein entsprechendes Dokument in der Datenbank gefunden.</p></div>)}
    </transferContainer>

let $xslt_input :=  
    <transferContainer>
        {transform:transform($header, doc($edweb:htmlHeader), ()),
        transform:transform($content, doc($edweb:htmlContent), (<parameters><param name="columns" value="16" /><param name="class" value="about_page" /></parameters>))}        
    </transferContainer>


let $output := 
    transform:transform(
        $xslt_input, 
        doc($edweb:html), 
        <parameters>
            <param name="currentSection" value="commentary" />
            <param name="searchTerms" value="{$p_searchTerms}" />
            <param name="baseURL" value="{$edweb:baseURL}" />
        </parameters>)

return 
$output