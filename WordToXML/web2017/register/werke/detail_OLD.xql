xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $werk := doc($edweb:dataRegisterWorks)//tei:bibl[@xml:id=concat($p_id, '')]

let $redirect := 
        if (not($werk))
        then (response:redirect-to(xs:anyURI('index.xql')))
        else ()


let $lettersMentionPubl := 
    <div><h3>Erwähnungen in Briefen</h3><ul>
        {for $brief in collection($edweb:dataLetters)//tei:TEI[tei:text//tei:bibl[@sameAs=$p_id] or .//tei:abstract//tei:bibl[@sameAs=$p_id] or tei:text//tei:index[substring(@corresp, 2)=$p_id]]
        order by edweb:defaultOrderBy($brief)
        return
            <li><a href="../../briefe/detail.xql?id={$brief/@xml:id}">{$brief//tei:titleStmt/tei:title//text()}</a></li>
        }
    </ul></div>

let $roles :=
map { 
        "music" := "Musik",
        "composition" := "Komposition",
        "arrangement" := "Bearbeitung",
        "libretto" := "Libretto",
        "text" := "Text",
        "translation" := "Übersetzung"
    }    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  <transferContainer>
                    <div id="subnavbar">
                        {edwebRegister:sectionNav($werk//tei:title/text())}
                    </div>
                    <h1>{$werk/tei:title/text(), if ($werk/tei:date) then (concat(' (', replace($werk/tei:date/text(), '\(|\)', ''), ') ')) else ()}</h1>
                    <p>{if ($werk/tei:author) then (
                        for $x in $werk/tei:author
                        let $role :=
                            if ($x/@role)
                            then (' ('||map:get($roles, $x/@role)||') ')
                            else ()
                        return
                        (edweb:persName($x/tei:persName, 'forename'),$role,<br/>)) 
                        else ()}</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_11 box whitebox">
                        <div class="boxInner">
                            {if ($lettersMentionPubl/ul/li) then ($lettersMentionPubl) else ()
                            }
                        </div>
                    </div>
                    <div class="grid_5"></div>
                 </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output