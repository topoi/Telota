xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace schema = "http://schema.org/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare option exist:serialize "method=html5 media-type=text/html";


let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $org := collection($edweb:dataRegister)//tei:item[@xml:id=concat($p_id, '')]

let $redirect := 
        if (not($org))
        then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/register/sachen/index.xql'))))
        else ()

let $lettersMentionKeyword := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:profileDesc/tei:textClass/tei:keywords/tei:term/@key=$p_id]
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        'Korrespondenz zum Thema')    

         
(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($org/tei:label[@type='reg']/text())}
        </div>
        <h1>{$org/tei:label[@type='reg']/text()}</h1>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11 box whitebox">
                        <div class="boxInner">
                            <p>{transform:transform($org/tei:desc, doc('../register.xsl'), ())}</p>
                            {if ($lettersMentionKeyword//td) then ($lettersMentionKeyword) else ()}
                        </div>
                    </div> 
                    <div class="grid_5">

                    </div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output