xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $header :=  <transferContainer>
                    <h1>MEGAdigital</h1>
                    <p>Online-Angebot der historisch-kritischen Gesamtausgabe von Karl Marx und Friedrich Engels</p>
                </transferContainer>

let $content := <transferContainer>
                    <div class="grid_4 row1">
                        <h3>Über diese Edition</h3>
                        <p>Die Marx-Engels-Gesamtausgabe (MEGA) präsentiert die Veröffentlichungen, Manuskripte und den Briefwechsel von Marx und Engels in vier Abteilungen. In der <a href="http://mega.bbaw.de/struktur/abteilung_ii" title="Überblick über die II. Abteilung der MEGA">II. Abteilung „‚Das Kapital‘ und Vorarbeiten“</a> werden alle Textfassungen des ökonomischen Hauptwerkes von Marx publiziert, darunter auch bislang unveröffentlichte Manuskripte. In der digitalen Ausgabe der <abbr title="Marx-Engels-Gesamtausgabe">MEGA</abbr> werden die <a href="http://telota.bbaw.de/mega/" title="Online verfügbare Inhalte der II. Abteilung">edierten Texte dieser II. Abteilung und Teile der Editorischen Apparate</a> im Internet präsentiert. Ab dem Jahrgang 1866 werden die <a href="briefe/index.xql" title="Übersicht aller online verfügbaren Briefe">Briefe von und an Marx und Engels</a> ebenfalls digital dargeboten. Dies gilt auch für einen Großteil der <a href="exzerpte/index.xql">Exzerpte und Notizen</a>. Darüber hinaus werden zu ausgewählten Themen digitale Projekte aus dem Korpus der Gesamtausgabe auf dieser Plattform zugänglich gemacht werden. Alle weiteren Texte und Apparate finden sich in der <a href="http://mega.bbaw.de/struktur">Druckausgabe</a> der <abbr title="Marx-Engels-Gesamtausgabe">MEGA</abbr>.</p>
                        <p><a href="about/text.xql?id=aufbau_edition">Mehr zu dieser Edition</a></p>
                    </div>
                    <div class="grid_5 row1 toc">
                    <h3>Online verfügbare Inhalte</h3>
                    <h4 id="kapital-heading"><a href="http://telota.bbaw.de/mega/" title="Online verfügbare Inhalte der II. Abteilung">„Das Kapital“ und Vorarbeiten</a></h4>
                    <h4><a href="briefe/index.xql" title="Übersicht aller online verfügbaren Briefe">Briefwechsel insgesamt</a></h4>
                    <ul>
                        <li><a href="briefe/index.xql?jahr=1866" title="Briefe des Jahres 1866">1866</a>&#160;<a href="about/text.xql?id=mega_bht_sdh_yy" title="Einführung zum Briefjahrgang 1866" style="line-height: 1.1em;"><i class="fa fa-info-circle" aria-hidden="true"></i></a></li>
                    </ul>
                    <h4><a href="exzerpte/index.xql" title="Exzerpte und Notizen">Exzerpte und Notizen</a></h4>
                    <ul>
                        <li><a href="exzerpte/index.xql?heft=krisenhefte">Krisenhefte 1857/58</a> (digitale Ausgabe in Vorbereitung)</li>
                    </ul>
                    <h4>Weitere Materialien und Texte</h4>
                        <ul>
                            <li><a href="https://edoc.bbaw.de/solrsearch/index/search/searchtype/simple/start/0/rows/10/query/marx+feuerbach/sortfield/score/sortorder/desc/author_facetfq/Karl+Marx" title="Die Feuerbach-Thesen auf dem edoc-Server der BBAW">Feuerbach-Thesen</a></li>
                            <li><a href="http://www.deutschestextarchiv.de/nrhz" title="Die „Neue Rheinische Zeitung“ im Deutschen Textarchiv">Vollständige Leseausgabe „Neue Rheinische Zeitung“</a></li>
                        </ul>
                    </div>
                    <div class="grid_3 row1" id="search">
                        <h3>Suche</h3>
                        <form action="suche/ergebnis.xql" accept-charset="utf-8">
                            <label for="suchbegriff">Suchbegriff </label>
                            <input id="searchstring" name="q_text" placeholder="Suchbegriff hier eingeben"/>
                            <label for="typ">Dokumenttyp</label>
                            <select name="doctype" size="1">
                                <option value="briefe">Briefe</option>
                            </select>
                            <button type="submit" class="submit" value="Absenden">
                                Suchen
                            </button>
                        </form>
                        <p><a href="suche/index.xql">[Erweiterte Suche]</a></p>
                        <!-- <span class="icon-question-sign help">
                            <span class="helpcontent">
                                Sie können verschiedene Zeichen in Ihrer Suchabfrage nutzen:
                                <ul>
                                    <li>* (Stern): Trunkieren</li>
                                    <li>~ (Tilde): Unscharfe Suche</li>
                                    <li>"" (Anführungszeichen): Genaue Phrase</li>
                                </ul>
                            </span>
                        </span> -->
                    </div>
                    <!-- <div class="grid_12">
                        <h3>Titelbild:</h3>
                        <p>Gebrüder Henschel, mimische Darstellung von Iffland. Gouache, z.T. gefirnisst, auf Bristolkarton. Durchmesser der Medaillons: je 3,5 cm; Blattgröße: 23 x 18 cm. Deutsches Literaturarchiv Marbach.</p>
                        <p>Iffland als Wilhelm Tell in Wilhelm Tell von F. v. Schiller, als Richter Dupperich in Die Quälgeister, oder viel Lärm um Nichts von Shakespeare, als Martin Luther in Die Weihe der Kraft von Z. Werner, als Richter Dupperich in Die Quälgeister, oder viel Lärm um Nichts von Shakespeare.</p>
                    </div> -->
                 </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc($edweb:htmlHeader), (<parameters><param name="columns" value="16" /></parameters>)),
                        transform:transform($content, doc($edweb:htmlContent), (<parameters><param name="columns" value="12" /></parameters>))}        
                    </transferContainer>

let $output := edweb:transformHTML($xslt_input, 'startseite') 


return 
$output