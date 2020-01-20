xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";
import module namespace ediarumBeacon="http://www.bbaw.de/telota/ediarum/beacon" at "beacon/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace beacon = "http://purl.org/net/beacon";

declare option exist:serialize "method=html5 media-type=text/html";

declare function local:viewBox($node) {
    if ($node) then (
    <div class="box whitebox">
        <div class="boxInner">
            {$node}
        </div>
    </div>
    ) else ()
};

declare function local:ifEmpty($date) {
    if ($date/normalize-space()='')
    then ('?')
    else ($date/text())
};

let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $p_normid := request:get-parameter("normid", ())

let $personid := 
            if ($p_normid)
            then (collection($edweb:dataRegister)//tei:person[matches(tei:idno, $p_normid)]/@xml:id/data(.))
            else ($p_id)
            
let $redirect := 
        if ($personid='')
        then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/register/personen/index.xql'))))
        else ()            

let $person := collection($edweb:dataRegister)//tei:person[@xml:id=concat($personid, '')]

let $description := 
    local:viewBox((
    for $x in $person//tei:note
    return
    transform:transform($x, doc('../register.xsl'), <parameters><param name="baseURL" value="{$edweb:baseURL}" /></parameters>),
    if (edwebRegister:altNames($person)//li) then (edwebRegister:altNames($person)) else ()
    ))

let $lettersWrittenBy := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspAction//tei:persName/@key=$personid]
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        'Korrespondenz')
    

let $lettersMentionPerson := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspDesc and ((tei:text|.//tei:abstract)//tei:rs[@key=$personid and not(ancestor::tei:note[parent::tei:seg])] or (tei:text|.//tei:abstract)//tei:persName[@key=$personid  and not(ancestor::tei:note[parent::tei:seg])] or tei:text//tei:index[substring(@corresp, 2)=$personid])]
        order by edweb:defaultOrderBy($brief)
        return
        $brief
    , 'Erwähnungen in Briefen')
    
let $lettersCommentsMentionPerson := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspDesc and (.//tei:seg/tei:note//tei:rs[@key=$personid] or .//tei:seg/tei:note//tei:persName[@key=$personid] or .//tei:correspDesc/tei:note//tei:persName[@key=$personid])]
        order by edweb:defaultOrderBy($brief)
        return
        $brief
    , 'Erwähnungen in Erläuterungen')

let $lettersZbMentionPerson := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:physDesc//tei:persName/@key=$personid]
        order by edweb:defaultOrderBy($brief)
        return
        $brief
    , 'Erwähnungen in Zeugenbeschreibungen')

let $works := 
     <div>
     <h3>Erwähnte Werke dieser Person</h3>
     <ul>
        {for $werk in doc($edweb:dataRegisterWorks)//tei:bibl[.//tei:persName[@key=$personid]]
        return
            <li><a href="../werke/detail.xql?id={$werk/@xml:id}">{$werk//tei:title/text()}</a></li>
        }
     </ul></div>


(: ############ WEITEREFÜHRENDE LINKS ################## :)
let $beaconLinks :=
    <div class="box whitebox">
        <div class="boxInner hinweise">
            <h3>Links zu externen Websites</h3>
                {if ($person/tei:idno[@type='uri'][1]/text())
                then (ediarumBeacon:beaconLinks($person/tei:idno[@type='uri'][1]/text()))
                else ()
                }
        </div>
    </div>


(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($person/tei:persName[@type='reg'][1]/tei:surname/text())}
        </div>
        <h1>{edweb:persName($person/tei:persName[@type='reg'], 'forename')}</h1>
        {if (not($person/@role='mythological' or $person/@role='fictional')) then 
        (<p>{if ($person/tei:floruit) then (concat('Wirkungszeit: ', $person/tei:floruit/text())) else concat(local:ifEmpty($person/tei:birth[1]), '–', local:ifEmpty($person/tei:death[1]))}</p>) else ()}
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11">
            {if ($description) then ($description) else ()}
            {local:viewBox((
             if ($lettersWrittenBy//td) then ($lettersWrittenBy) else (),
             if ($lettersMentionPerson//td) then ($lettersMentionPerson) else (),
             if ($lettersCommentsMentionPerson//td) then ($lettersCommentsMentionPerson) else (),
             if ($lettersZbMentionPerson//td) then ($lettersZbMentionPerson) else (),
             if ($works/ul/li) then ($works) else (),
             if ($person/tei:linkGrp) then (edwebRegister:printReferences($person, $person/tei:linkGrp)) else(),
             if (edwebRegister:printReferences($person, concat($edweb:data, '/Register/Personen/'))//person[@id=$p_id]/tei:linkGrp) then (edwebRegister:printReferences($person, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()))}
            
        </div>
        <div class="grid_5">
            {if ($beaconLinks//li) then ($beaconLinks) else ()}
        </div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output