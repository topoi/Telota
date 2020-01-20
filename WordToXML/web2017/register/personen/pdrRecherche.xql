xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare option exist:serialize "method=html5 media-type=text/html";

let $login := xmldb:login('/db/', 'bot3', 'pTz48KkWjETZngdbMdz8')

let $personid := request:get-parameter("id",0)
let $person := doc("/db/data/Register/personen.xml")//person[@id=concat($personid, '')]

let $params := <parameters><param name="name" value="{concat($person/vorname/text(), ' ', $person/name/text())}"/></parameters>
let $lebensdaten := substring(substring-after($person/lebensdaten, '('), 1,4)
let $abfrageURL := concat('http://pdrprod.bbaw.de/concord/1-4/?n=', lower-case($person/name), '&amp;on=', lower-case($person/vorname), '&amp;ya=', $lebensdaten)
let $pdrAbfrage := doc($abfrageURL)

let $inhalt := transform:transform($pdrAbfrage, doc('pdrergebnis.xsl'), $params)


(: ########### HTML-Ausgabe ########### :)
let $header :=  <transferContainer>
                    <h1>Recherche nach Identifikationsnummern <br/>für {$person/name/text(), if ($person/vorname) then(concat(', ', string-join($person/vorname/text()))) else ()}</h1>
                    <p>{replace($person/lebensdaten/text(), '\(|\)|,', '')}</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_11 box whitebox">
                                    <div class="boxInner">
                                        {$inhalt}
                                    </div>
                                </div>
                                <div class="grid_5 box graybox">
                                    <div class="boxInner hinweise">
                                        <h3>Hinweise</h3>
                                        <p>Für diese Recherche wird der <a href="http://pdrdev.bbaw.de/concord/1-4/">Person Concordancer 1.4 </a>
                                        des Personendaten-Repositoriums der BBAW benutzt.
                                        </p>
                                        <p>Es wurde folgende Abfrage gestellt: <a href="{$abfrageURL}">{$abfrageURL}</a></p>
                                    </div>
                                </div>
                 </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc('../../resources/xslt/header.xsl'), ()),
                        transform:transform($content, doc('../../resources/xslt/content.xsl'), ())}        
                    </transferContainer>

let $output := transform:transform($xslt_input, doc('../../resources/xslt/html.xsl'), (<parameters><param name="currentSection" value="register" /><param name="currentPage" value="pdrRecherche" /></parameters>))

return
$output