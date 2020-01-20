xquery version "1.0" encoding "UTF-8";

import module namespace cs="http://www.bbaw.de/telota/correspSearch" at "../resources/correspSearch.xql";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebSearch="http://www.bbaw.de/telota/ediarum/web/search" at "forms.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace telota = "http://www.telota.de";
declare namespace pdrws = "http://pdr.bbaw.de/namespaces/pdrws/";

declare option exist:serialize "method=html5 media-type=text/html";

declare function local:buildQuery($suchbegriff) {
(: String mit Suchbegriffen wird nach Phrase (d.h. Anführungszeichen) durchsucht und ggf. aufgetrennt :)
let $suchphrase := if (contains($suchbegriff, '"'))
                   then (
                        <query>
                            <phrase occur="must">{substring-before(substring-after($suchbegriff, '"'), '"')}</phrase>
                            <bool>{substring-before($suchbegriff, '"')}{substring-after(substring-after($suchbegriff, '"'), '"')}</bool>
                        </query>
                   )
                   else (<query>
                            <bool>{$suchbegriff}</bool>
                        </query>),
                   
(: Abfrage wird zusammengestellt: Phrase wird übernommen, weitere einzelne Wörter nach Fuzzy, Wildcard und Term sortiert :)
$suchabfrage := <query>
                        <bool>{$suchphrase//phrase}{
                        for $x in tokenize($suchphrase//bool, ' ')[not(contains(., '~'))]
                        return 
                                if (contains($x, '*'))
                                then (<wildcard occur="must">{$x}</wildcard>)
                                else (<term occur="must">{$x}</term>)
                        }{                               
                        for $y in tokenize($suchphrase//bool, ' ')[contains(., '~')]
                        return
                            <fuzzy occur="must">{replace($y, '~', '')}</fuzzy>
                        }</bool></query>
return 
($suchabfrage)
};

let $login := edweb:login()

(: ################### GET-PARAMETER ###################### :)
(: Dokumentart: Briefe, Tageskalender oder Vorlesungen :)
let $param_doctype := request:get-parameter("doctype", "")

(: Parameter, die später durch local:buildQuery() geschickt werden :)
let $param_q_title := request:get-parameter("q_title", "")
let $param_q_abstract := request:get-parameter("q_abstract", "")
let $param_q_text := request:get-parameter("q_text", "")
let $param_q_head := request:get-parameter("q_head", "")
let $param_q_note := request:get-parameter("q_note", "")
let $param_q_zb := request:get-parameter("q_zb", "")

(: Parameter, die *nicht* durch local:buildQuery() geschickt werden :)
let $q_korrespondent := request:get-parameter("korrespondent", "")
let $q_vorlesung := request:get-parameter("vorlesung", "")
let $q_vorlesungstyp := string-join(request:get-parameter("vorlesungstyp", ""), ',')
let $q_tageskalender := request:get-parameter("tageskalender", "")
let $q_tageskalendertyp := request:get-parameter("tageskalendertyp", "")

(: Parameter für Datumsangaben :)
let $q_startDate := request:get-parameter("startDate", "")
let $q_endDate := request:get-parameter("endDate", "")
let $q_strictDate := request:get-parameter("dateStrict", "")
let $isoStartDate := cs:startOfPeriod(cs:recognizeDate(cs:sanitize($q_startDate)))
let $isoEndDate := cs:endOfPeriod(cs:recognizeDate(cs:sanitize($q_endDate)))

(: ################### COLLECTION AUSWÄHLEN ###################### :)
let $collection := 
        if ($param_doctype='briefe') then collection($edweb:data)
        else (
            if ($param_doctype='vorlesungen' and $q_vorlesung) then collection(concat($edweb:dataLectures, '/', $q_vorlesung))
            else (
                if ($param_doctype='vorlesungen') then collection($edweb:dataLectures)
                else (
                    if ($param_doctype='tageskalender') then collection($edweb:dataDiaries)
                    else (collection($edweb:data))
                )
            )
        )


(: ################### QUERIS IN XML ZUSAMMENBAUEN ###################### :)
(: Suchbegriffe durch oben definierte Funktion buildQuery schicken und damit den zweiten Parameter für ft:query bereitstellen :)
let $q_title := if ($param_q_title) then local:buildQuery($param_q_title) else ()
let $q_abstract := if ($param_q_abstract) then local:buildQuery($param_q_abstract) else ()
let $q_text := if ($param_q_text) then local:buildQuery($param_q_text) else ()
let $q_head := if ($param_q_head) then local:buildQuery($param_q_head) else ()
let $q_note := if ($param_q_note) then local:buildQuery($param_q_note) else ()
let $q_zb := if ($param_q_zb) then local:buildQuery($param_q_zb) else ()

(: Suchbegriffe zusammen stellen für die Weitergabe an die jeweilige detai.xql als URL-Parameter zum Hervorheben :)
let $tokenizedSearchTerms := <ul>
    {$param_q_title, $param_q_text, $param_q_head, $param_q_note, $param_q_zb
    }</ul>

(: ################### EINZELNE BEDINGUNGEN ZUSAMMENBAUEN ###################### :)
(: Eigentliche Abfrage im ausgewählten Lucene-Index bzw. andere Bedingungen (z.B. Vorlesungstyp) zusammenbauen :)    
let $query_title := if ($q_title) then ('[ft:query(.//tei:titleStmt, $q_title)]') else ()
let $query_abstract := if ($q_abstract) then ('[ft:query(.//tei:abstract, $q_abstract)]') else ()
let $query_text :=  if ($q_text and $param_doctype!='tageskalender') 
                    then ('[ft:query(.//tei:text, $q_text)]')
                    else (
                        if ($q_text)                    
                        then ('[ft:query(.//tei:div, $q_text)]')
                        else ()
                    )
let $query_head := if ($q_head) then ('[ft:query(.//tei:head, $q_head)]') else ()
let $query_note := if ($q_note) then ('[ft:query(.//tei:seg/tei:note, $q_note)]') else ()
let $query_zb := if ($q_zb) then ('[ft:query(.//tei:physDesc, $q_zb)]') else ()

let $query_date :=
    if ($isoStartDate and $isoEndDate)
    then (
        if ($q_strictDate='true')
        then ('[(.//tei:correspAction/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) >= $isoStartDate) and (.//tei:correspAction/tei:date/(@when|@to|@notAfter)/cs:endOfPeriod(.) <= $isoEndDate)]')
        (: "cross over" query, thx to Martin Fechner :)
        else ('[(.//tei:correspAction/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) <= $isoEndDate) and (.//tei:correspAction/tei:date/(@when|@to|@notAfter)/cs:endOfPeriod(.) >= $isoStartDate)]'))
    else (
        if ($isoStartDate)
        then ('[(.//tei:correspAction/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) >= $isoStartDate) or (.//tei:correspAction/tei:date/(@to|@notAfter)/cs:endOfPeriod(.) >= $isoStartDate)]')
        else (
            if ($isoEndDate)
            then ('[(.//tei:correspAction/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) <= $isoEndDate) or (.//tei:correspAction/tei:date/(@to|@notAfter)/cs:endOfPeriod(.) >= $isoStartDate)]')
            else ()
        )
    )

let $query_korrespondent := if ($q_korrespondent) then ('[.//tei:correspDesc/tei:correspAction/tei:persName/@key=$q_korrespondent]') else ()
(: Die Suche kann auf einen oder mehrere Vorlesungstypen eingeschränkt werden, daher die aufwendigere Konstruktion :)
let $query_vorlesungstyp := 
                    if ($q_vorlesungstyp) 
                    then (
                        concat('[.//tei:msDesc/@rend[',
                            string-join(
                            for $typ at $pos in tokenize($q_vorlesungstyp, ',')
                            return
                            if ($pos=1)
                            then (concat('contains(., "', $typ, '")'))
                            else (concat(' or contains(., "', $typ, '")'))
                            ),
                        ']]')
                    ) 
                    else () 

(: ################### KOMPLETTE ABFRAGE ZUSAMMENBAUEN ###################### :)
let $completeQuery :=
                    if ($param_doctype='tageskalender' and $q_tageskalender and $q_tageskalendertyp='kalender')
                    then (concat('$collection//tei:TEI[@xml:id=$q_tageskalender]//tei:div[@type="tag"]', $query_text, $query_note))
                    else (
                        if ($param_doctype='tageskalender' and $q_tageskalender and $q_tageskalendertyp='anhang')
                        then (concat('$collection//tei:TEI[@xml:id=$q_tageskalender]//tei:back', $query_text, $query_note))
                        else (
                            if ($param_doctype='tageskalender' and $q_tageskalendertyp='kalender')
                            then (concat('$collection//tei:div[@type="tag"]', $query_text, $query_note))
                            else (
                                if ($param_doctype='tageskalender' and $q_tageskalendertyp='anhang')
                                then (concat('$collection//tei:back', $query_text, $query_note))
                                else (
                                    if ($param_doctype='tageskalender' and $q_tageskalender)
                                    then (concat('$collection//tei:TEI[@xml:id=$q_tageskalender]//(tei:div[@type="tag"]|tei:back)', $query_text, $query_note))
                                    else (
                                        if ($param_doctype='tageskalender')
                                        then (concat('$collection//(tei:div[@type="tag"]|tei:back)', $query_text, $query_note))
                                        else (concat('$collection//tei:TEI', $query_title, $query_abstract, $query_text, $query_head, $query_note, $query_vorlesungstyp, $query_korrespondent, $query_date, $query_zb))               
                                    )
                                )
                            )
                        )
                    )

(: ################### SUCHE ###################### :)                    
let $results := if ($completeQuery!='$collection//tei:TEI') 
                then (
                    for $hit in (util:eval($completeQuery))
                    let $hit_filepath := base-uri($hit)
                    let $hit_id := doc($hit_filepath)//tei:TEI/@xml:id/data(.)
                    let $hit_link :=
                                if ($param_doctype='tageskalender' and $hit[self::tei:back])
                                then (concat('../', $param_doctype,'/detail.xql?id=', $hit_id, '&amp;range=13', '&amp;searchTerms=', $tokenizedSearchTerms))
                                else (
                                    if ($param_doctype='tageskalender')
                                    then (concat('../', $param_doctype,'/detail.xql?id=', $hit_id, '&amp;datum=', $hit//tei:date/@when/data(.) ,'&amp;searchTerms=', $tokenizedSearchTerms))
                                    else (concat('../', $param_doctype,'/detail.xql?id=', $hit_id, '&amp;searchTerms=', $tokenizedSearchTerms))
                                )
                    let $hit_title := 
                                if ($param_doctype='tageskalender' and $hit[self::tei:back])
                                then (concat(doc($hit_filepath)//tei:TEI//tei:titleStmt/tei:title/text(), ' &#8211; Anhang'))
                                else (
                                    if ($param_doctype='tageskalender')
                                    then (concat('Tageskalender ', format-date(xs:date($hit//tei:date/@when/data(.)), '[Y] &#8211; [D].[M].')))
                                    else (doc($hit_filepath)/tei:TEI//tei:titleStmt/tei:title/text())
                                )
                    let $hit_summarize_width := if ($param_doctype='vorlesungen') then ('300') else ('100')
                    order by 
                        if ($param_doctype='tageskalender') 
                        then ($hit//tei:date/@when/data(.)) 
                        else (
                            if ($param_doctype='briefe')
                            then ($hit//tei:date/(@when(:|@from|@notBefore:))/data(.))[1]
                            else ()
                        )
                    return 
                    <div class="box whitebox">
                        <div class="boxInner">
                        <h3><a class="doclink" href="{$hit_link}">{$hit_title}</a></h3>
                        {if ($q_text|$q_head|$q_note|$q_zb) 
                        then (kwic:summarize($hit, <config width="{$hit_summarize_width}" />))
                        else (substring(string-join($hit//tei:body/tei:div[1]/tei:p/text()), 1, 200))
                        }
                        </div>
                    </div>
                ) else ()

(: Zählung, wieviele Dokumente gefunden wurden :)
let $resultsCount := 
                if (count($results) = 0)
                then (<p>Es wurden keine Dokumente gefunden</p>)
                else (
                    if (count($results) = 1)
                    then (<p>Es wurde 1 Dokument gefunden</p>)
                    else (<p>Es wurden {count($results)} Dokumente gefunden</p>)
                )

(: Inhaltszusammenstellung abhängig von gefundenen Ergbnissen :)
let $header :=   <transferContainer>{
                        <div>
                            <h1>Suchergebnis</h1>
                            <p>{$resultsCount}</p>
                        </div>
                 }</transferContainer>   

(: Zusammenbau der verschiedenen Inhaltsteile :)
let $content :=  <transferContainer>
                        <div class="grid_10">
                                {if (count($results) = 0)
                                then (<div class="whitebox box">
                                        <div class="boxInner">
                                            <p>Es wurden keine Dokumente gefunden. Im Formularfeld rechts können Sie Ihre Suchanfrage modifizieren oder eine neue starten.</p>
                                        </div>
                                    </div>)
                                else ($results)}
                         </div>
                         <div class="grid_6 box graybox">
                            <div class="boxInner">
                                <h3>{concat(upper-case(substring($param_doctype, 1, 1)), substring($param_doctype, 2))}</h3>
                               <p>Sie haben mit folgender Anfrage im Datenbestand gesucht:</p>
                                {if ($param_doctype='briefe')
                                then (edwebSearch:formBriefsuche($param_q_text, $param_q_title, $param_q_abstract, $param_q_note, $q_korrespondent, $isoStartDate, $isoEndDate, $param_q_zb))
                                else (
                                    if ($param_doctype='tageskalender')
                                    then (edwebSearch:formTageskalendersuche($param_q_text, $param_q_note, $q_tageskalender, $q_tageskalendertyp))
                                    else (
                                        if ($param_doctype='vorlesungen')
                                        then (edwebSearch:formVorlesungssuche($param_q_head, $param_q_text, $param_q_note, $q_vorlesung, $q_vorlesungstyp))
                                        else ()
                                    )
                                )}
                            </div>
                        </div>
                    </transferContainer>

let $xslt_input :=  <transferContainer>
                        {transform:transform($header, doc('../resources/xslt/header.xsl'), (<parameters><param name="columns" value="16" /></parameters>)),
                        transform:transform($content, doc('../resources/xslt/content.xsl'), (<parameters><param name="columns" value="16" /></parameters>))}        
                    </transferContainer>


(: Transformation durch allgemeines Seitentemplate :)
let $output := edweb:transformHTML($xslt_input, 'suche')

return 
$output