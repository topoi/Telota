xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace csLink="http://correspSearch.bbaw.de/link" at "resources/csapi/functions.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html media-type=text/html";

declare function local:linkToSibling($type as xs:string, $view as xs:string, $id) {
    if ($id)
    then (
        <li>
            <a class="{$type}" href="{ concat('detail.xql?id=', $id, '&amp;view=', $view) }">
                <span> {
                    if ($type='prev') then ('Vorheriger Brief')
                    else if ($type='next') then ('Nächster Brief')
                    else ()}
                </span>
            </a>
        </li>
    ) else ()
};

let $login := edweb:login()

(: Parameter aus URL übernehmen :)
let $p_id := request:get-parameter("id", ())
let $p_year := request:get-parameter("jahr", ())
let $p_searchTerms := request:get-parameter("searchTerms", ())

(: Pfad das aktuellen Briefs :)
let $letter := 
        if ($p_searchTerms)
        then (: XXX hier OR-Case für Highlighting in Zeugenbeschreibung einbinden :)
            (if (collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)]) 
            then (kwic:expand(collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')][ft:query(.//tei:text, $p_searchTerms, <options><leading-wildcard>yes</leading-wildcard></options>)]))
            else (collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')]))
        else (collection($edweb:dataLetters)//tei:TEI[@xml:id=concat($p_id, '')])

(: Ist der Brief eine Beilage? :)
let $beilage :=
    if ($letter//tei:correspDesc/tei:note/tei:ref[@type='attachedTo'])
    then (<p id="beilage-info">(Beilage zu: <a href="detail.xql?id={$letter//tei:correspDesc/tei:note/tei:ref/@target}">{$letter//tei:correspDesc/tei:note/tei:ref[@type='attachedTo']}</a>.)</p>)
    else ()

(: Erschlossener Brief? :)
let $conjectured := $letter[.//tei:abstract]

(: Aktuellen Jahrgang auslesen :)
let $person := $letter//tei:correspAction[not(.//@key='prov_d4h_dtz_q5')]/tei:persName/@key

let $currentYear := 
    if ($letter//tei:correspAction[@type='sent']/tei:date/@when) 
    then ($letter//tei:correspAction[@type='sent']/tei:date/@when/substring(., 1,4))
        else if ($letter//tei:correspAction[@type='sent']/tei:date/@from)
        then ($letter//tei:correspAction[@type='sent']/tei:date/@from/substring(., 1,4))
            else if ($letter//tei:correspAction[@type='sent']/tei:date/@notBefore)
            then ($letter//tei:correspAction[@type='sent']/tei:date/@notBefore/substring(., 1,4))
            else ()

(: Nächste und vorangehende Briefe :)
let $lettersListAbsolute := 
    element root {
        for $letter in collection($edweb:dataLetters)//tei:TEI[@telota:doctype='letter mega' and not(.//tei:correspDesc/tei:note/tei:ref[@type='attachedTo'])]
        order by edweb:defaultOrderBy($letter)
        return
        $letter
    }

let $nextLetter := $lettersListAbsolute/tei:TEI[@xml:id=$p_id]/following-sibling::tei:TEI[1]/@xml:id/data(.)
let $prevLetter := $lettersListAbsolute/tei:TEI[@xml:id=$p_id]/preceding-sibling::tei:TEI[1]/@xml:id/data(.)

let $lettersListCorrespondence :=
    element root {
        for $letter in $lettersListAbsolute//tei:TEI[.//tei:correspAction/tei:persName[@key=$person]]
        order by edweb:defaultOrderBy($letter)
        return
        $letter
    }               

let $nextLetterInCorresp := $lettersListCorrespondence/tei:TEI[@xml:id=$p_id]/following-sibling::tei:TEI[1]/@xml:id/data(.)
let $prevLetterInCorresp := $lettersListCorrespondence/tei:TEI[@xml:id=$p_id]/preceding-sibling::tei:TEI[1]/@xml:id/data(.)  

(: Parameter für alle Transformationen :)
let $params := 
    <parameters>
        <param name="jahr" value="{$p_year}"/>
        <param name="id" value="{$p_id}"/>
        <param name="view" value="{$edweb:p_view}" />
        <param name="cacheLetterIndex" value="{$edweb:cacheLetterIndex}" />
        {if ($conjectured)
        then (<param name="erschlossen" value="true" />)
        else (<param name="erschlossen" value="false" />)
        }
    </parameters>

(: Metaangaben ("Weitere Angaben") nur platzieren, wenn Brief transkribiert vorliegt :) 
let $meta := 
    if ($conjectured)
    then ()
    else (transform:transform($letter, doc("resources/letterHeader.xsl"), $params))

(:let $facsimile :=
    let $akte := substring-before($letter//tei:facsimile/tei:graphic/@url, '_')
    let $seite := replace(edweb:substring-afterlast($letter//tei:facsimile/tei:graphic/@url, '_'), '^0+', '')
    return
    if ($letter//tei:facsimile/tei:graphic[@url])
    then (<a href="http://content.landesarchiv-berlin.de/iffland/akte_{$akte}/teil_1/#p=6"></a>)
    else ():)

(: Nachweis, d.h. Archiv und Signatur :)
let $nachweis :=
    if (not($letter//tei:msDesc//tei:idno[@type="shelfmark"]/text()))
    then (
        <p id="nachweis">Nicht überlieferter Brief</p>
    )
    else (
        <p id="nachweis">
           {if ($letter//tei:sourceDesc/tei:msDesc[@rend='manuscript'])
            then ('H: ')
            else if ($letter//tei:sourceDesc/tei:msDesc[@rend='copy'])
            then ('h: ')
            else ()}
            {concat($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:institution,
            edweb:seperator($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:repository/text(), ', '),
            edweb:seperator($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:collection/text(), ', '),
            edweb:seperator($letter//tei:sourceDesc/tei:msDesc/tei:msIdentifier//tei:idno[not(@type='uri')]/text(), ','))}
        </p> 
    )

(: Rendern der Transkription bzw. (wenn nur erschlossen) der Anmerkung zum Brief und ggf. Zusammenfassung :)
let $letterText :=
    if ($conjectured)
    then (transform:transform($letter, doc("resources/letterHeader.xsl"), $params))
    else (transform:transform($letter, doc("resources/letterText.xsl"), $params))

let $yearLinks :=
    if (not($beilage))
    then (<ul>
                {local:linkToSibling('prev', $edweb:p_view, $prevLetter)}
                <li><a class="index" href="index.xql?jahr={$currentYear}&amp;view={$edweb:p_view}">Briefe im Jahr {$currentYear}</a></li>
                {local:linkToSibling('next', $edweb:p_view, $nextLetter)}
            </ul>)
    else ()

let $letterTitle:=
    if ($edweb:intern)
    then (edweb:letterTitle($letter//tei:titleStmt))
    else ($letter//tei:titleStmt/tei:title/text())

(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {$yearLinks}
            <ul>
            <!--{local:linkToSibling('prev', $edweb:p_view, $prevLetterInCorresp)}-->
            <li><a class="index" href="index.xql?person={$person[1]}&amp;view={$edweb:p_view}">Briefwechsel ingesamt mit {edweb:persName(collection($edweb:dataRegister)//tei:person[@xml:id=$person][1]/tei:persName[not(./@type='alt')], 'forename')}</a></li>
            <!--{local:linkToSibling('next', $edweb:p_view, $nextLetterInCorresp)}-->
            </ul>

        </div>
        <h1>{$letterTitle}</h1>
        {$nachweis}
        {$beilage}
        {$meta}
        <!-- {csLink:linkedLetters($letter, 'correspondent', $edweb:dataRegister)} -->
        <ul id="viewSwitch">
           {if ($conjectured)
            then ()
            else (
                if ($edweb:p_view='k')
                then (<li class="current"><a href="detail.xql?id={$p_id}&amp;view=k">Kritischer Text</a></li>)
                else (<li><a href="detail.xql?id={$p_id}&amp;view=k">Kritischer Text</a></li>),
                if ($edweb:p_view='l')
                then (<li class="current"><a href="detail.xql?id={$p_id}&amp;view=l">Lesetext</a></li>)
                else (<li><a href="detail.xql?id={$p_id}&amp;view=l">Lesetext</a></li>)
            )}
        </ul>
    </transferContainer>

let $content := 
    if (not($beilage))
    then (<transferContainer>
        {if ($letterText!='') then $letterText
        else
            if ($conjectured) 
            then ()
            else (<div class="notfound"><p>Fehler!<br/>Es wurde kein entsprechendes Dokument in der Datenbank gefunden.</p></div>)}
        <ul xmlns="http://www.w3.org/1999/xhtml"id="browselinks">
        {local:linkToSibling('prev', $edweb:p_view, $prevLetter),
         local:linkToSibling('next', $edweb:p_view, $nextLetter)} 
        </ul>
    </transferContainer>)
    else (<transferContainer>
        {if ($letterText!='') then $letterText
        else
            if ($conjectured) 
            then ()
            else (<div class="notfound"><p>Fehler!<br/>Es wurde kein entsprechendes Dokument in der Datenbank gefunden.</p></div>)}
    </transferContainer>)
    
let $xslt_input :=  
    <transferContainer>
        {transform:transform($header, doc($edweb:htmlHeader), ()),
        transform:transform($content, doc($edweb:htmlContent), (<parameters><param name="columns" value="16" /></parameters>))}        
    </transferContainer>


let $output := 
    transform:transform(
        $xslt_input, 
        doc($edweb:html), 
        <parameters>
            <param name="currentSection" value="briefe" />
            <param name="searchTerms" value="{$p_searchTerms}" />
            <param name="baseURL" value="{$edweb:baseURL}" />
        </parameters>)

return 
$output