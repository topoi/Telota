xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login :=edweb:login()

let $werkliste := <ul>{
    for $werk in doc($edweb:dataRegisterWorks)//tei:bibl[starts-with(normalize-space(./tei:title), $edwebRegister:section)]
    let $place := if ($werk//tei:placeName[@role='venue']) then (<span class="venue"> <i class="fa fa-map-marker venue" aria-hidden="true">&#160;{$werk//tei:placeName[@role='venue']/text()}</i></span>) else ()
    order by edwebRegister:orderLabel($werk/tei:title)
    return
    <li><a href="detail.xql?id={$werk/@xml:id}">
        {$werk//tei:title/text()}
        </a>{$place}</li>}
    </ul>
    
    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav('index')}
        </div>
        <h1>Register der Literatur - {$edwebRegister:section}</h1>
        <p>{count($werkliste/li)} Werke</p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11 box whitebox">
                        <div class="boxInner">
                            {$werkliste}
                        </div>
                    </div>
                    <div class="grid_5">
                    </div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return
$output


