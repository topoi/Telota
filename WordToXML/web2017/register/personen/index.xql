xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $listPersons := <ul>{
    for $persName in collection($edweb:dataRegister)//tei:person/tei:persName[starts-with(normalize-space(string-join(.//text())), $edwebRegister:section)]
    let $surname :=
        if ($persName/tei:surname)
        then (normalize-space($persName/tei:surname/text()))
        else (normalize-space(string-join($persName/tei:name/text(), '')))
    let $forename := normalize-space($persName/tei:forename/text()[1])
    order by edwebRegister:orderLabel($surname)
    return
    <li><a href="detail.xql?id={$persName/ancestor::tei:person/@xml:id}">
        { if ($persName[@type='alt'])
        then concat($surname, ' &#x2192; ', $persName/ancestor::tei:person/tei:persName[@type='reg']/tei:surname, edweb:seperator($persName/ancestor::tei:person/tei:persName[@type='reg']/tei:forename,  ','))
        else (concat($surname, edweb:seperator($forename, ',')))}</a></li>
    } </ul>
    
    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  <transferContainer>
                    <div id="subnavbar">
                        {edwebRegister:sectionNav('index')}
                    </div>
                    <h1>Register der Namen - {$edwebRegister:section}</h1>
                    <p>{count($listPersons/li)} Personen</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_11 box whitebox">
                                    <div class="boxInner">
                                        {$listPersons}
                                    </div>
                                </div>
                                <div class="grid_5">
                                </div>
                 </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return
$output


