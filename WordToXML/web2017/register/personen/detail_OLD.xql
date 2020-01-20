xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";
import module namespace ediarumBeacon="http://www.bbaw.de/telota/ediarum/beacon" at "beacon/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace beacon = "http://purl.org/net/beacon";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $p_normid := request:get-parameter("normid", ())

let $personid := 
            if ($p_normid)
            then (collection($edweb:dataRegister)//tei:person[@normid=$p_normid]/@xml:id/data(.))
            else ($p_id)
            
let $redirect := 
        if ($personid='')
        then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/register/personen/index.xql'))))
        else ()            

let $person := collection($edweb:dataRegister)//tei:person[@xml:id=concat($personid, '')]

let $description := 
    for $x in $person//tei:note
    return
    transform:transform($x, doc('personen.xsl'), <parameters><param name="baseURL" value="{$edweb:baseURL}" /></parameters>)

let $lettersWrittenBy := 
    <div><h3>Korrespondenz</h3><ul>
        {for $brief in collection($edweb:dataLetters)//tei:TEI[tei:teiHeader/tei:profileDesc/tei:correspDesc//tei:persName[@key=$personid]]
        order by edweb:defaultOrderBy($brief)
        return
            if ($brief/tei:text//tei:p//text())
            then (<li><a href="../../briefe/detail.xql?id={$brief/@xml:id}">{$brief//tei:titleStmt/tei:title//text()}</a></li>)
            else (<li class="erschlossen"><a href="../../briefe/detail.xql?id={$brief/@xml:id}"><span>&#xf069; </span>{$brief//tei:titleStmt/tei:title//text()}</a></li>)
        }
    </ul></div>

let $lettersMentionPerson := 
    <div><h3>Erwähnungen in Briefen</h3><ul>
        {for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:abstract//tei:persName[@key=$personid] or .//tei:rs[@key=$personid] or tei:text//tei:persName[@key=$personid] or tei:text//tei:index[substring(@corresp, 2)=$personid]]
        order by edweb:defaultOrderBy($brief)
        return
            <li><a href="../../briefe/detail.xql?id={$brief/@xml:id}">{$brief//tei:titleStmt/tei:title//text()}</a></li>
        }
    </ul></div>

let $works := 
     <div><h3>Publikationen im Werkregister</h3><ul>
        {for $werk in doc($edweb:dataRegisterWorks)//tei:bibl[.//tei:persName[@key=$personid]]
        return
            <li><a href="../werke/detail.xql?id={$werk/@xml:id}">{$werk//tei:title/text()}</a></li>
        }
     </ul></div>

(: ############ WEITEREFÜHRENDE LINKS ################## :)



(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($person/tei:persName[@type='reg'][1]/tei:surname/text())}
        </div>
        {transform:transform($person, doc('personen.xsl'), ())}
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11 box whitebox">
            <div class="boxInner">
                {if ($description) then ($description) else ()}
                {if ($lettersWrittenBy/ul/li) then ($lettersWrittenBy) else ()}
                {if ($lettersMentionPerson/ul/li) then ($lettersMentionPerson) else ()}
                {if ($works/ul/li) then ($works) else ()}
                {if (edwebRegister:printReferences($person, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($person, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
            </div>
        </div>
        <div class="grid_5 box whitebox">
            <div class="boxInner hinweise">
                <h3>Links zu externen Websites</h3>
                {if ($person/tei:idno/text())
                then (ediarumBeacon:beaconLinks($person/tei:idno/text()))
                else (<a class="personconcordancer" href="http://telotadev.bbaw.de:9011/exist/rest/db/apps/ediarum/web/register/personen/pdrRecherche.xql?id={$personid}">Allgemeine Identifikationsnummern für diese Person finden</a>)
                }
            </div>
        </div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output