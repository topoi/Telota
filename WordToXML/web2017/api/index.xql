xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

(: Konstanten :)
let $login := edweb:login()                 
let $header :=  <transferContainer>
                    <h1>API</h1>
                    <p>Schnittstellen für externe Webangebote</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_8 box whitebox">
                            <div class="boxInner">
                             <h3>CMIF-Schnittstelle</h3>
                             <p>Über diese Schnittstelle können die Metadaten aller in dieser Edition vorhandenen Briefe im <a href="http://correspsearch.bbaw.de/index.xql?id=participate_cmi-format&amp;l=de">Correspondence Metadata Interchange (CMI) Format</a> abgeurfen werden.  
                             Absender und Empfänger werden hauptsächlich mit Hilfe der <a href="http://www.dnb.de/DE/Standardisierung/GND/gnd_node.html">ID der Gemeinsamen Normdatei (GND)</a> der Deutschen Nationalbibliothek identifiziert, seltener mit Hilfe der
                             Virtual International Authority File. 
                             </p>
                             <p>URL: <a href="{$edweb:baseURL}/api/cmif.xql">{$edweb:baseURL}/api/cmif.xql</a></p>
                            </div>
                    </div>
                    <div class="grid_8 box whitebox">
                            <div class="boxInner">
                             <h3>BEACON-Dateien</h3>
                             <p>Die in unserem Datenbestand vorhandenen und mit der <a href="http://www.dnb.de/DE/Standardisierung/GND/gnd_node.html">GND</a>-Nummer ausgezeichneten Personen können als Liste im <a href="https://de.wikipedia.org/wiki/Wikipedia:BEACON">BEACON-Format</a> abgerufen werden.
                             Es ist dabei möglich, die Liste auf Personen zu beschränkgen, die im Brieftext erwähnt werden oder die Korrespondenzpartner sind. 
                             </p>
                             <ul>
                                <li><a href="{$edweb:baseURL}/api/beacon.xql">BEACON-Datei aller Datensätze im Personenregister</a></li>
                                <li><a href="{$edweb:baseURL}/api/beacon.xql?type=correspondents">BEACON-Datei aller Korrespondenzpartner</a></li>
                                <li><a href="{$edweb:baseURL}/api/beacon.xql?type=personMentioned">BEACON-Datei aller in der Korrespondenz erwähnten Personen</a></li>
                             </ul>
                             <table>
                                <tr>
                                    <th>Parameter</th>
                                    <th>Beschreibung</th>
                                </tr>
                                <tr>
                                    <td><span class="code">type</span></td>
                                    <td>
                                        Mögliche Werte: <br/>
                                        <span class="code">[nicht gesetzt]</span>: alle Datensätze im Personenregister
                                        <span class="code">correspondents</span>: alle Korrespondenzpartner
                                        <span class="code">personMentioned</span>: alle in Briefen erwähnten Personen
                                        Der Parameter ist standardmäßig nicht gesetzt.
                                    </td>
                                </tr>
                                <tr>
                                    <td><span class="code">authority</span></td>
                                    <td>
                                        Alle Personen (eingeschränkt ggf. durch <span class="code">type</span>) mit einer Norm-ID einer bestimmten
                                        Norm-Datei. Mögliche Werte: <br/> 
                                        <span class="code">gnd</span>: Gemeinsame Normdatei der Deutschennationalbiblitothek
                                        <span class="code">viaf</span>: Virtual International Authority File
                                        Der Parameter ist standardmäßig auf "{$edweb:defaultAuthority}" gesetzt.
                                    </td>
                                </tr>
                             </table>
                            </div>
                    </div>
                    <div class="grid_4">
                        
                    </div>
                 </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc($edweb:htmlHeader), ()),
                        transform:transform($content, doc($edweb:htmlContent), (<parameters><param name="columns" value="12" /></parameters>))}        
                    </transferContainer>                    

let $output := edweb:transformHTML($xslt_input, 'empty')

return 
$output