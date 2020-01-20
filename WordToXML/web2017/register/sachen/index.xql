xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace beacon = "http://purl.org/net/beacon";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $listOrgs := <ul>{
    for $name in collection($edweb:dataRegister)//tei:label
    order by edwebRegister:orderLabel($name)
    return
    <li><a href="detail.xql?id={$name/ancestor::tei:item/@xml:id}">
        {if ($name[@type='alt']) then (concat($name, ' &#x2192; ', $name/ancestor::tei:org/tei:label[@type='reg']/text())) else ($name)}
        </a></li>}
    </ul>
    
    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  <transferContainer>
                    <h1>Register der Themen</h1>
                    <p>{count($listOrgs/li)} Themen</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_11 box whitebox">
                                    <div class="boxInner">
                                        {$listOrgs}
                                    </div>
                                </div>
                                <div class="grid_5">
                                </div>
                 </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return
$output


