xquery version "1.0";

(: hier weitermaachen :)

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebSearch="http://www.bbaw.de/telota/ediarum/web/search" at "forms.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace functx = "http://www.functx.com"; 
declare option exist:serialize "method=html5 media-type=text/html";

declare function functx:contains-case-insensitive  
  ( $arg as xs:string? ,
    $substring as xs:string )  as xs:boolean? {
       
   contains(upper-case($arg), upper-case($substring))
 } ;


let $login := edweb:login()

(: Parameter aus URL übernehmen :)
let $param_q_text := request:get-parameter("q_text", "")
let $typ := request:get-parameter("typ", "")

let $suchergebnisPersonen := if ($typ='1') then
                                <ul><h3>Treffer im Personenregister</h3>
                                { for $item in collection($edweb:dataRegister)//tei:person[functx:contains-case-insensitive(., $param_q_text)]
                                let $name := edweb:persName($item/tei:persName[@type='reg'], 'surname')
                                order by $name
                                return
                                    <li><a href="../register/personen/detail.xql?id={$item/@xml:id}">{$name}</a></li>
                                }
                                </ul>
                            else ()
                            
                    
let $suchergebnisOrte := if ($typ='2') then
                                <ul><h3>Treffer im Ortsregister</h3>
                                { for $item in collection($edweb:dataRegister)//tei:place[functx:contains-case-insensitive(., $param_q_text)]
                                let $name := $item/tei:placeName[@type='reg']/text()
                                order by $name
                                return
                                    <li><a href="../register/orte/detail.xql?id={$item/@xml:id}">{$name}</a></li>
                                }
                                </ul>
                             else ()
                                
                    
let $suchergebnisWerke := if ($typ='3') then 
                                <ul><h3>Treffer im Register der Einrichtungen</h3>
                                { for $item in collection($edweb:dataRegister)//tei:org[functx:contains-case-insensitive(., $param_q_text)]
                                let $name := $item/tei:orgName[@type='reg']/text()
                                order by $name
                                return
                                    <li><a href="../register/einrichtungen/detail.xql?id={$item/@xml:id}">{$name}</a></li>
                                }
                                </ul>
                           else ()                            


let $header :=   <transferContainer>{
                        <div>
                            <h1>Ergebnis der Registersuche</h1>
                            <p></p>
                        </div>
                 }</transferContainer>   

let $content :=  <transferContainer>
                        <div class="grid_10 whitebox box">
                            <div class="boxInner">
                            {$suchergebnisPersonen}
                            {$suchergebnisOrte}
                            {$suchergebnisWerke}
                            </div>
                        </div>
                        <div class="grid_6 box graybox">
                            <div class="boxInner">
                                <h3>Register</h3>
                                <p>Sie haben mit folgender Anfrage im Datenbestand gesucht:</p>
                                {edwebSearch:formRegistersuche($param_q_text)}                        
                            </div>
                        </div>
                    </transferContainer>


let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc('../resources/xslt/header.xsl'), (<parameters><param name="columns" value="16" /></parameters>)),
                        transform:transform($content, doc('../resources/xslt/content.xsl'), (<parameters><param name="columns" value="16" /></parameters>))}        
                    </transferContainer>

let $output := transform:transform($xslt_input, doc('../resources/xslt/html.xsl'), (<parameters><param name="currentSection" value="suche" /><param name="baseURL" value="{$edweb:baseURL}"/></parameters>))


return
$output