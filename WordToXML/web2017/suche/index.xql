xquery version "1.0";

import module namespace cs="http://www.bbaw.de/telota/correspSearch" at "lib/correspSearch.xql";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebSearch="http://www.bbaw.de/telota/ediarum/web/search" at "forms.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

(: Parameter :)
let $param_q_title := request:get-parameter("q_title", "")
let $param_q_abstract := request:get-parameter("q_abstract", "")
let $param_q_text := request:get-parameter("q_text", "")
let $param_q_head := request:get-parameter("q_head", "")
let $param_q_note := request:get-parameter("q_note", "")
let $param_q_zb := request:get-parameter("q_zb", "")
let $q_korrespondent := request:get-parameter("korrespondent", "")
let $q_vorlesung := request:get-parameter("vorlesung", "")
let $q_vorlesungstyp := string-join(request:get-parameter("vorlesungstyp", ""), ',')
let $q_tageskalender := request:get-parameter("tageskalender", "")
let $q_tageskalendertyp := request:get-parameter("tageskalendertyp", "")
let $datumUmformatiert := request:get-parameter("datum", "")

(: Parameter für Datumsangaben :)
let $q_startDate := request:get-parameter("startDate", "")
let $q_endDate := request:get-parameter("endDate", "")
let $q_strictDate := request:get-parameter("dateStrict", "")
let $isoStartDate := cs:startOfPeriod(cs:recognizeDate(cs:sanitize($q_startDate)))
let $isoEndDate := cs:endOfPeriod(cs:recognizeDate(cs:sanitize($q_endDate)))

(: Konstanten :)
let $login := edweb:login()
                  
let $header :=  <transferContainer>
                    <h1>Suche in den Texten</h1>
                    <p></p>
                </transferContainer>
                

let $content := <transferContainer>
                  <div class="grid_8">
                    <div class="box whitebox">
                        <div class="boxInner">
                             <h3>Briefe</h3>
                             {edwebSearch:formBriefsuche($param_q_text, $param_q_title, $param_q_abstract, $param_q_note, $q_korrespondent, $isoStartDate, $isoEndDate, $param_q_zb)}    
                        </div>
                    </div>
                    <!-- <div class="box whitebox">
                        <div class="boxInner">
                             <h3>Reisetagebücher</h3>
                             {edwebSearch:formTageskalendersuche($param_q_text, $param_q_note, $q_tageskalender, $q_tageskalendertyp)} 
                        </div>
                    </div> -->
                    </div>
                    <div class="grid_4 box whitebox">
                        <div class="boxInner">
                            <h3>Register durchsuchen</h3>
                            {edwebSearch:formRegistersuche($param_q_text)}                        
                        </div>
                    </div>  
                    <div class="grid_4 box graybox">
                        <div class="boxInner">
                            <h3>Tipps zur Suche in den Texten</h3>
                            <p>Sie können in den Freitextfeldern keinen, einen oder mehrere Suchbegriffe eingeben. 
                            Dabei können Sie verschiedene Zeichen nutzen, um Ihre Suchanfrage flexibler zu gestalten:</p>
                            <ul>
                            <li>* (Stern): Trunkieren</li>
                            <li>~ (Tilde): Unscharfe Suche</li>
                            <li>"" (Anführungszeichen): Genaue Phrase</li>
                        </ul>                        
                        <p>Werden mehrere Felder ausgefüllt, so werden diese Bedingungen bei der Abfrage mit "UND" verknüpft, so dass mehr Angaben
                        das Ergebnis weiter einschränken.</p>
                        <p>Das jeweilige Formular wird Ihnen auch auf der Ergebnisseite angezeigt, so dass Sie ihre Suche ggf. modifizieren können.</p>
                        </div>
                    </div>
                 </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc('../resources/xslt/header.xsl'), ()),
                        transform:transform($content, doc('../resources/xslt/content.xsl'), (<parameters><param name="columns" value="12" /></parameters>))}        
                    </transferContainer>                    

let $output := edweb:transformHTML($xslt_input, 'suche') 

return 
$output