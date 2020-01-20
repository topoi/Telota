xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $header :=  <transferContainer>
                    <div>
                         <div>
                             <h1>Impressum</h1>
                         </div>
                     </div>
                </transferContainer>

let $content := <transferContainer>
                    <div class="grid_11 box whitebox impressum">
                        <div class="boxInner">
                            <h4>Herausgeber</h4>
                            <p> Berlin-Brandenburgische Akademie der Wissenschaften<br/>
                                Jägerstraße 22/23<br/> 10117 Berlin </p>
                            <h4>Vertreter</h4>
                            <p> Prof. Dr. Dr. h. c. mult. Martin Grötschel<br/> Tel.: +49 30 20370-0,
                                E-Mail: bbaw@bbaw.de </p>
                            <h4>Rechtsform</h4>
                            <p> Rechtsfähige Körperschaft öffentlichen Rechts </p>
                            <h4>Umsatzsteuer-Identifikationsnummer</h4>
                            <p> DE 167 449 058 (gemäß §27 a
                                Umsatzsteuergesetz) </p>
                            <h4>Technische Realisierung</h4>
                            <p>
                                <a href="http://www.bbaw.de/telota">TELOTA</a> (Berlin-Brandenburgische Akademie der Wissenschaften)<br/>
                                <a href="mailto:telota@bbaw.de">telota@bbaw.de</a></p>
                            <h4>Benutzte Software</h4>
                            <ul>
                                <li>
                                    <a href="http://www.bbaw.de/telota/software/ediarum">ediarum</a>
                                </li>
                                <li>
                                    <a href="http://www.exist.org">exist-db</a>
                                </li>
                            </ul>
                            <h4>Urheberrecht</h4>
                            <p>Die BBAW ist bestrebt, in allen Publikationen die Urheberrechte der verwendeten Grafiken, Tondokumente, Video-Sequenzen und Texte zu beachten, von ihm selbst erstellte Grafiken, Tondokumente, Video-Sequenzen und Texte zu nutzen oder auf lizenzfreie Grafiken, Tondokumente, Video-Sequenzen und Texte zurückzugreifen.</p>
                            <p>Alle innerhalb des Internet-Angebotes genannten und gegebenenfalls durch Dritte geschützten Marken- und Warenzeichen unterliegen uneingeschränkt den Bestimmungen des jeweils gültigen Kennzeichenrechts und den Besitzrechten der jeweiligen eingetragenen Eigentümer.</p>
                            <p>Allein aufgrund der bloßen Nennung ist nicht der Schluß zu ziehen, daß Markenzeichen nicht durch Rechte Dritter geschützt sind.</p>
                            <p>Das Copyright für veröffentlichte, vom Autor selbst erstellte Objekte bleibt allein beim Autor der Seiten.</p>
                            <p>Eine Vervielfältigung oder Verwendung solcher Grafiken, Tondokumente, Video-Sequenzen und Texte in anderen elektronischen oder gedruckten Publikationen ist ohne ausdrückliche Zustimmung des Autors nicht gestattet, wenn es den zulässigen Umfang überschreitet oder den zulässigen Zweck nicht erfüllt.</p>
                            <h4>Hinweise zum Datenschutz</h4>
                            <p>Diese Website benutzt Piwik, eine Open-Source-Software zur statistischen
                                Auswertung der Besucherzugriffe. Piwik verwendet sog. “Cookies”,
                                Textdateien, die auf Ihrem Computer gespeichert werden und die eine Analyse
                                der Benutzung der Website durch Sie ermöglichen. Die durch den Cookie
                                erzeugten Informationen über Ihre Benutzung dieses Internetangebotes werden
                                auf einem Server der Berlin-Brandenburgischen Akademie der Wissenschaften in
                                Deutschland gespeichert. Die IP-Adresse wird sofort nach der Verarbeitung
                                und vor deren Speicherung anonymisiert.</p>
                            <iframe frameborder="no" width="600px" height="200px" src="https://telotadev.bbaw.de/stat/index.php?module=CoreAdminHome&amp;action=optOut&amp;language=de">&#160;</iframe>
                        </div>
                    </div>
                 </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc($edweb:htmlHeader), (<parameters><param name="columns" value="16" /></parameters>)),
                        transform:transform($content, doc($edweb:htmlContent), (<parameters><param name="columns" value="16" /></parameters>))}        
                    </transferContainer>

let $output := edweb:transformHTML($xslt_input, 'impressum') 


return 
$output