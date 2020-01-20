xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $p_year := request:get-parameter("jahr", ())
let $p_person := request:get-parameter("person", ())
let $p_file := request:get-parameter("akte", ())
let $p_heft := request:get-parameter("heft", ())
let $p_limit := xs:int(request:get-parameter("limit", '20'))
let $p_offset := xs:int(request:get-parameter("offset", '1'))


let $currentCollection :=
                    if ($p_year and $p_person) 
                     then collection($edweb:dataExcerpts)//tei:TEI[ft:query(.//tei:correspAction/tei:persName/@key, $p_person) and ft:query(.//tei:correspAction/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>)]
                        else if ($p_person) 
                        then collection($edweb:dataExcerpts)//tei:TEI[ft:query(.//tei:correspAction/tei:persName/@key, $p_person)]
                             else if ($p_year) 
                             then collection($edweb:dataExcerpts)//tei:TEI[ft:query(.//(tei:correspAction|tei:creation)/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>)] 
                                else (collection($edweb:dataExcerpts)//tei:TEI)

let $correspondents :=
    if ($p_year)
    then (collection($edweb:dataExcerpts)//tei:TEI[.//tei:correspAction/tei:persName and ft:query(.//tei:correspAction/tei:date/(@when|@from|@to|@notBefore|@notAfter), <query><wildcard>{$p_year}*</wildcard></query>)]//tei:correspAction/tei:persName/@key/data(.))
    else (collection($edweb:dataExcerpts)//tei:TEI[.//tei:correspAction/tei:persName]//tei:correspAction/tei:persName/@key/data(.))        

let $sortedResult :=
    element list {
        for $x in $currentCollection
        order by edweb:defaultOrderBy($x)
        return
        $x 
    }

let $resultCount := count($sortedResult//tei:TEI)
    
let $lettersList := 
    for $x in subsequence($sortedResult//tei:TEI, $p_offset, $p_limit)
    return
        <div class="box whitebox">
            <div class="boxInner index">
            <a href="detail.xql?id={$x/@xml:id}&amp;view={$edweb:p_view}">
                <h2>{edweb:letterTitle($x//tei:titleStmt)}</h2>
                {if ($x//tei:body//text() or $x//tei:abstract//text())
                then (
                    if ($x//tei:abstract//text())
                    then (<p class="summary">{transform:transform($x//tei:abstract, doc('../resources/xslt/transcr-teaser.xsl'), ())}</p>)
                    else (<p>{substring(transform:transform($x//tei:body/tei:div[1]//tei:p, doc('../resources/xslt/transcr-teaser.xsl'), ()), 1, 300)} [...]</p>))
                else ()}
            </a>
            </div>
        </div>
        (:
        element div {
            attribute class {'box', 'whitebox'},
                element div {
                    attribute class {'boxInner', 'index'},
                    edwebRegister:viewLetterTable(
        for $brief in subsequence($sortedResult//tei:TEI, $p_offset, $p_limit) 
        order by edweb:defaultOrderBy($brief)
        return
        $brief
    , '')
            }
        }
        :)
     
let $filterYearsQuery :=
    if ($p_person and $p_year)
    then ('distinct-values(collection($edweb:dataExcerpts)//tei:correspDesc[.//@key=$p_person]//tei:date/(@when|@from|@notBefore)/substring(., 1, 4))')
    else ('distinct-values(collection($edweb:dataExcerpts)//tei:correspDesc//tei:date/(@when|@from|@notBefore)/substring(., 1, 4))')

let $filterYears := 
    <div class="box graybox filter jahre"><div class="boxInner"><h3>Nach Chronologie filtern</h3><ul id="filter_jahre">
    {   for $year in util:eval($filterYearsQuery)
        order by $year
        return
        if ($year=$p_year)
        then (<li class="current"><a href="index.xql?person={$p_person}">{$year}</a></li>)
        else (<li><a href="index.xql?jahr={$year}&amp;person={$p_person}">{$year}</a></li>)}
     </ul><hr class="clear" /></div></div>     

let $filterSubjects :=
    <div class="box graybox filter themen"><div class="boxInner"><h3>Nach Themen filtern</h3><ul id="filter_themen"> 
    </ul></div></div>

let $filterPersons := 
    <div class="box graybox filter personen"><div class="boxInner"><h3>Nach Personen filtern</h3><ul id="filter_personen"> 
    {
       for $person in collection($edweb:dataRegister)//tei:person[@xml:id/data(.)=$correspondents and @xml:id/data(.)!='prov_uhm_svf_ks']
       let $name := edweb:persName($person/tei:persName[@type='reg'], 'surname'),
           $id := $person/@xml:id/data(.)
       order by $name
       return 
          if ($id=$p_person) 
          then (<li class="current"><a href="index.xql?jahr={$p_year}&amp;akte={$p_file}">{$name}</a></li>)
          else (<li><a href="index.xql?person={$id}&amp;jahr={$p_year}&amp;akte={$p_file}">{$name}</a></li>)
    }
    </ul></div></div>

let $h1 := 
    if ($p_year) 
    then (<h1>Exzerpte und Notizen des Jahres {$p_year}</h1>)
            else if ($p_heft = 'krisenhefte') then
                (<h1> „Krisenhefte“ 1857/58</h1>)
    else (<h1>Exzerpte und Notizen</h1>)


let $year_information_title :=
    if ($p_year)
    then (doc(concat($edweb:dataExcerpts, '/', $p_year, '_information.xml'))//tei:titleStmt/tei:title/text())
    else ('Missing')

let $year_information_text :=
    if ($p_year)
    then (doc(concat($edweb:dataExcerpts, '/', $p_year, '_information.xml'))//tei:hi[@ana='short']/text())
    else ('Missing')

let $year_information_contact_name :=
    if ($p_year)
    then (doc(concat($edweb:dataExcerpts, '/', $p_year, '_information.xml'))//tei:hi[@ana='contact']/text())
    else()

let $year_information_contact_email :=
    if ($p_year)
    then (doc(concat($edweb:dataExcerpts, '/', $p_year, '_information.xml'))//tei:hi[@ana='email']/text())
    else()

let $xslt_input :=  <transferContainer>
                        <div class="outerLayer" id="header">
                            <header class="container_16">
                                <div class="grid_15">
                                    {$h1}
                                </div>
                            </header>
                        </div>
                        <div class="outerLayer" id="content">
                            <div class="container_16">
                                {
                                if ($p_year and not($p_person))
                                    then (
                                    <div class="grid_16" id="year_information">
                                    <div class="box whitebox">
                                            <div class="boxInner">
                                                <h2>{$year_information_title}</h2>
                                                <p>{$year_information_text}&#160;<a href="#" title="Weiterlesen">mehr…</a></p>
                                                <p>AnsprechpartnerIn: <a href="mailto:{$year_information_contact_email}" title="E-Mail">{$year_information_contact_name}&#160;<i class="fa fa-envelope-o" aria-hidden="true"></i></a></p>
                                            </div>
                                        </div>
                                    </div>
                                    )
                                    else if ($p_heft = 'krisenhefte') then (
                                        <div class="grid_16 general-publication-information">
                                            <div class="box whitebox">
                                                <div class="boxInner">
                                                    <p><b>Karl Marx: Exzerpte, Zeitungsausschnitte und Notizen zur Weltwirtschaftskrise (Krisenhefte). November 1857 bis Februar 1858. Bearb. von Kenji Mori, Rolf Hecker, Izumi Omura und Atsushi Tamaoka unter Mitwirkung von Fritz Fiehler und Timm Graßmann. Berlin 2017.</b></p>
                                                    <p>Der Band enthält die drei bislang unveröffentlichten „Krisenhefte“ von Marx mit Exzerpten, Zeitungsausschnitten und Notizen, die 1857/1858 während der ersten Weltwirtschaftskrise entstanden sind. Die Materialsammlung dokumentiert Marx’ empirische Untersuchung dieser Krise, die er mit der Zusammenstellung und Systematisierung von Artikeln, Angaben und Kommentaren aus führenden Zeitungen wie „The Times“, „The Morning Star“, „The Standard“, „The Manchester Guardian“ und „The Economist“ durchführte. In den Auszügen werden Wirtschafts- und Finanzfragen in den europäischen Ländern sowie den USA, China, Indien, Ägypten, Australien und Brasilien behandelt, der Finanz- und Warenmarkt untersucht, sowie Daten zu Konkursen, Arbeitslosigkeit, Kurzarbeit, Lohnentwicklung und Arbeitskämpfen festgehalten. Die Krisenhefte stehen in engem Zusammenhang mit Marx’ „Grundrissen der Kritik der politischen Ökonomie“, seinen Artikeln für die „New-York Tribune“ und Debatten mit Engels, in denen allesamt die Krise 1857/58 analysiert wird.</p>
                                                </div>
                                            </div>
                                        </div>
                                        )
                                        else (
                                        <div class="grid_16 general-publication-information">
                                            <div class="box whitebox">
                                                <div class="boxInner">
                                                    <p>Die digitale Ausgabe der Exzerpte und Notizen von Karl Marx und Friedrich Engels beginnt mit den ökonomischen <a href="index.xql?heft=krisenhefte">Krisenheften von 1857/58 (MEGA IV/14)</a>. Die Exzerpthefte und Notizbücher des Frühwerks, die Londoner Hefte, die agrarökonomischen, geologischen und chemischen Exzerpte sind oder werden in <a href="http://mega.bbaw.de/struktur/abteilung_iv">Buchform</a> publiziert, ebenso ein annotiertes Verzeichnis des ermittelten Bestandes der Bibliotheken von Karl Marx und Friedrich Engels. Die digitalen Exzerpte und Notizen können nach verschiedenen Kriterien abgerufen werden:</p>
                                                    <ul>
                                                        <li>Nach den jeweiligen Kontexten der Exzerpthefte oder Notizbücher, in denen sie niedergeschrieben wurden</li>
                                                        <li>Chronologisch</li>
                                                        <li>Thematisch</li>
                                                        <li>Nach Autoren oder Werken</li>
                                                    </ul>
                                                    <p>Knappe Annotationen zu in den Briefen direkt oder indirekt erwähnten Personen sowie literarische und mythologische Gestalten können über das <a href="../register/personen/index.xql">Register der Namen</a>, erwähnte Unternehmen über das <a href="../register/einrichtungen/index.xql">Register der Firmen</a> ermittelt werden. Von den Korrespondenten benutzte und erwähnte Quellen sind im <a href="../register/werke/index.xql">Register Literatur</a> recherchierbar.</p>
                                                    <p>Die digitale Ausgabe ist in Vorbereitung.</p>
                                                </div>
                                            </div>
                                        </div>
                                        )
                                      }
                                <div class="grid_11">
                                    {if ($lettersList) 
                                    then (edweb:pagination($p_limit, $p_offset, $resultCount, 'yes'), $lettersList, edweb:pagination($p_limit, $p_offset, $resultCount, 'no'))
                                    else (<div class="notfound"><p>Für diese Auswahl konnten keine Exzerpte oder andere Materialien in der Datenbank gefunden werden.</p></div>)}
                                </div>
                                <div class="grid_5">
                                    {$filterYears}
                                    {$filterSubjects}
                                    {$filterPersons}
                                </div>
                           </div>
                        </div>
                    </transferContainer>

let $output := transform:transform(
                $xslt_input, 
                doc($edweb:html), 
                <parameters>
                    <param name="currentSection" value="exzerpte" />
                    <param name="pageTitle" value="{$h1/h1/text()}" />
                    <param name="baseURL" value="{$edweb:baseURL}" />
                </parameters>)

return 
$output