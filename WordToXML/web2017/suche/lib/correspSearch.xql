xquery version "3.0";

(:  ################### CORRESPSEARCH ########################### :)

module namespace cs="http://www.bbaw.de/telota/correspSearch";

declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace ct = "http://wiki.tei-c.org/index.php/SIG:Correspondence/task-force-correspDesc";
declare namespace pdrws = "http://pdr.bbaw.de/namespaces/pdrws/";

(: PATHS :)
declare variable $cs:dbBasePath := doc('../config.xml')//config/dbbasepath;
declare variable $cs:beacons := concat($cs:dbBasePath, '/data');
declare variable $cs:beaconIndex := concat($cs:dbBasePath, '/config.xml');
declare variable $cs:indexes := concat($cs:dbBasePath, '/core/indexes');
declare variable $cs:indexPersons := concat($cs:dbBasePath, '/core/indexes/persNames.xml');
declare variable $cs:indexPlaces := concat($cs:dbBasePath, '/core/indexes/placeNames.xml');
declare variable $cs:schema := concat($cs:dbBasePath, '/api/correspDesc-cif.rng');

declare variable $cs:logDir := concat($cs:dbBasePath, '/core/logs');
declare variable $cs:errorLog := concat($cs:logDir, '/errorLog.xml');
declare variable $cs:log := concat($cs:logDir, '/log.xml');
declare variable $cs:statistics := concat($cs:logDir, '/statistics.xml');
declare variable $cs:listApikeys := concat($cs:dbBasePath, '/config.xml');

declare variable $cs:baseURL := doc(concat($cs:dbBasePath, '/config.xml'))//web/baseurl;

(: LOGIN :)
declare function cs:login(){
    (:let $username := doc(concat($cs:dbBasePath, '/config.xml'))//config/dblogin/username
    let $password := doc(concat($cs:dbBasePath, '/config.xml'))//config/dblogin/password:)
    let $login := xmldb:login('/db/', 'admin', 'Perigord1607Beynac')
    return ()
};

(: ################ SECURITY FUNCTIOONS ############ :)

declare function cs:sanitize($text as xs:string) {
    replace(replace(replace($text, '&amp;', '&amp;amp;'), '''', '&amp;apos;'), '"', '&amp;quot;')
};

(: ################ DATE FUNCTIONS ################# :)

declare function cs:recognizeDate($date as xs:string) {
    let $dateAsText := iri-to-uri($date)
    let $isoDate :=
        if ($dateAsText)
        then (
            if (matches($dateAsText, '\d\d\d\d-\d\d-\d\d')) 
            then ($dateAsText) 
            else (httpclient:get(xs:anyURI(concat('https://pdrprod.bbaw.de/pdrws/dates?output=xml&amp;lang=en&amp;text=', $dateAsText)), true(), (<headers></headers>))//pdrws:isodate/@when)) 
        else ()
    return
    $isoDate
};

declare function cs:recognizeDate($date as xs:string, $language as xs:string) {
    let $setLanguage := 
        if ($language='de')
        then ('de')
        else ('en')
    let $dateAsText := iri-to-uri($date)
    let $isoDate :=
        if ($dateAsText)
        then (
            if (matches($dateAsText, '\d\d\d\d-\d\d-\d\d')) 
            then ($dateAsText) 
            else (httpclient:get(xs:anyURI(concat('https://pdrprod.bbaw.de/pdrws/dates?output=xml&amp;lang=', $setLanguage, '&amp;text=', $dateAsText)), true(), (<headers></headers>))//pdrws:isodate/@when)) 
        else ()
    return
    $isoDate
};

declare function cs:cleanDate($date) {
    let $normalizedDate := normalize-space($date)
    let $cleanDate :=
        if (matches($normalizedDate, '^\d\d\d\d(-\d\d)?(-\d\d)?$'))
        then ($normalizedDate)
        else (
            if (matches($normalizedDate, '/'))
            then (substring-before($normalizedDate, '/'))
            else ()
        )
    return
    $cleanDate
};

(:  Setzt für Datumsangaben, die nur Jahr oder nur Jahr und Monat enthalten, 
    das Datum auf den Beginn bzw. den Ende des Monats bzw. Jahres :)

declare function cs:startOfPeriod($date) {
    let $date := cs:cleanDate($date)
    let $proofedDate := 
        if (matches($date, '\d\d\d\d$'))
        then (concat($date, '-01-01'))
        else (
            if (matches($date, '\d\d\d\d-\d\d$'))
            then (
                if (matches($date, '\d\d\d\d-\d\d$'))
                then (concat($date, '-01'))
                else ()
            ) else ($date)
        )
    return
    $proofedDate
};

declare function cs:endOfPeriod($date) {
    let $date := cs:cleanDate($date)
    let $proofedDate := 
        if (matches($date, '\d\d\d\d$'))
        then (concat($date, '-12-31'))
        else (
            if (matches($date, '\d\d\d\d-\d\d$'))
            then (
                if (matches($date, '\d\d\d\d-02$'))
                then (concat($date, '-29'))
                else (
                    if (matches($date, '\d\d\d\d-(01|03|05|07|08|10|12)$'))
                    then (concat($date, '-31'))
                    else (concat($date, '-30'))
                )
            ) else ($date)
        )
    return
    $proofedDate
};

(: ###### PARAMETERS ####### :)
declare variable $cs:p_cmiFile := cs:sanitize(request:get-parameter('cmiFile', ''));

declare variable $cs:p_startdate := cs:sanitize(request:get-parameter('startdate', ''));
declare variable $cs:p_enddate := cs:sanitize(request:get-parameter('enddate', ''));

declare variable $cs:p_place := cs:sanitize(request:get-parameter('place', ''));
declare variable $cs:p_placeSender := cs:sanitize(request:get-parameter('placeSender', ''));
declare variable $cs:p_placeAddressee := cs:sanitize(request:get-parameter('placeAddressee', ''));

declare variable $cs:p_available := cs:sanitize(request:get-parameter('available', ''));
declare variable $cs:p_strictDate := cs:sanitize(request:get-parameter('strictDate', 'false'));

declare variable $cs:p_language := cs:sanitize(request:get-parameter('l', 'en'));

(: ########## ISODATES ########### :)
declare variable $cs:isoStartdate := cs:startOfPeriod(cs:recognizeDate(cs:sanitize($cs:p_startdate), $cs:p_language));
declare variable $cs:isoEnddate := cs:endOfPeriod(cs:recognizeDate(cs:sanitize($cs:p_enddate), $cs:p_language));
   
(: ####### QUERY CONDITIONS ###### :)

(: CORRESPONDENTS :)

declare function local:setQueryCorrespondentNode($role){
    (: this function convert the correspondent type (see below) in the right xpath expression :)
    let $node :=
        if ($role='sender')
        then ('./tei:correspAction[@type="sent"]/(tei:persName|tei:orgName)/@ref')
        else (
            if ($role='addressee')
            then ('./tei:correspAction[@type="received"]/(tei:persName|tei:orgName)/@ref')
            else ('.//@ref')
        )
    return
    $node
};

declare variable $cs:allCorrespondents :=
        (: collect all CorrespondentIDs from URL and set type (sender/addressee) :)
        <ul>
            {for $id in tokenize(request:get-query-string(), '&amp;')
            return
            if (matches($id, 'correspondent=|sender=|addressee='))
            then (<li type="{substring-before(cs:sanitize($id), '=')}">{xmldb:decode-uri(xs:anyURI(substring-after(cs:sanitize($id), '=')))}</li>)
            else ()
            }
        </ul>
;

declare variable $cs:idQuery :=
    <ul>{
        (: get other IDs for each correspondent IDs from person index :)
        for $id in $cs:allCorrespondents//li[not(./text()='all' or ./text()='')]
        let $specifiedID :=
            if (matches($id, 'http://d-nb.info/gnd/'))
            then (concat('@gnd="', $id, '"'))
            else (
                if (matches($id, 'http://viaf.org/viaf/'))
                then (concat('@viaf="', $id, '"'))
                else (
                     if (matches($id, 'http://catalogue.bnf.fr/ark:/12148/'))
                    then (concat('@bnf="', $id, '"'))
                    else (
                        if (matches($id, 'http://lccn.loc.gov/'))
                        then (concat('@lc="', $id, '"'))
                        else (
                            if (matches($id, 'http://id.ndl.go.jp/auth/ndlna/'))
                            then (concat('@ndl="', $id, '"'))
                            else ()
                        )
                    )
                )
            )
        return
        (: return lucene query expression :)
        <query cs:type="{$id/@type/data(.)}">
            <bool>
                {for $id in util:eval(concat("doc($cs:indexPersons)//persName[", $specifiedID, "]/(@gnd|@viaf|@bnf|@lc|@ndl)[.!='']"))
                return
                <term>{$id/data(.)}</term>}
            </bool>
        </query>
    }</ul>;

declare variable $cs:searchQueryCorrespondent :=
    (: returns the correct condition for the search query to filter by correspondents :)
    if ($cs:allCorrespondents//li='all' and $cs:allCorrespondents//li/@type='sender')
    then ('[./tei:correspAction[@type="sent"]/(tei:persName|tei:orgName)]')
    else (
        if ($cs:allCorrespondents//li='all' and $cs:allCorrespondents//li/@type='addressee')
        then ('[./tei:correspAction[@type="received"]/(tei:persName|tei:orgName)]') 
        else (
            if ($cs:allCorrespondents//li='all')
            then ()
            else (
                if ($cs:idQuery//query)
                then (
                    if (count($cs:idQuery//query) > 1)
                    then (
                        for $x at $pos in $cs:idQuery//query
                        return
                        if ($pos=1)
                        then (concat('[ft:query(', local:setQueryCorrespondentNode($x/@cs:type),', $cs:idQuery//query[', $pos, '])'))
                        else (concat(' and ft:query(', local:setQueryCorrespondentNode($x/@cs:type),',  $cs:idQuery//query[', $pos, '])]'))
                    ) else (
                        concat('[ft:query(', local:setQueryCorrespondentNode($cs:idQuery//query/@cs:type), ', $cs:idQuery//query)]')
                    )
                )
                else ()
            )
        )
    );

(: PLACE :)
declare variable $cs:placeID :=
    (: returns the lucene query expression for the place :)
    if ($cs:p_placeSender)
    then (<query><term>{$cs:p_placeSender}</term></query>)
    else (
        if ($cs:p_placeAddressee)
        then (<query><term>{$cs:p_placeAddressee}</term></query>)
        else (
            if ($cs:p_place)
            then (<query><term>{$cs:p_place}</term></query>)
            else ()
        )
);

declare variable $cs:searchQueryPlace :=
    if ($cs:p_placeSender)
    then ('[ft:query(./tei:correspAction[@type="sent"]//@ref, $cs:placeID)]')
    else (
        if ($cs:p_placeAddressee)
        then ('[ft:query(./tei:correspAction[@type="received"]//@ref, $cs:placeID)]')
        else (
            if ($cs:p_place)
            then ('[ft:query(.//@ref, $cs:placeID)]')
            else ()
        )
    );

(: DATE :)
declare variable $cs:searchQueryDate :=
    if ($cs:isoStartdate and $cs:isoEnddate)
    then (
        if ($cs:p_strictDate='true')
        then ('[(./tei:correspAction[@type="sent"]/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) >= $cs:isoStartdate) and (./tei:correspAction[@type="sent"]/tei:date/(@when|@to|@notAfter)/cs:endOfPeriod(.) <= $cs:isoEnddate)]')
        (: "cross over" query, thx to Martin Fechner :)
        else ('[(./tei:correspAction[@type="sent"]/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) <= $cs:isoEnddate) and (./tei:correspAction[@type="sent"]/tei:date/(@when|@to|@notAfter)/cs:endOfPeriod(.) >= $cs:isoStartdate)]'))
    else (
        if ($cs:isoStartdate)
        then ('[(./tei:correspAction[@type="sent"]/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) >= $cs:isoStartdate) or (./tei:correspAction[@type="sent"]/tei:date/(@to|@notAfter)/cs:endOfPeriod(.) >= $cs:isoStartdate)]')
        else (
            if ($cs:isoEnddate)
            then ('[(./tei:correspAction[@type="sent"]/tei:date/(@when|@from|@notBefore)/cs:startOfPeriod(.) <= $cs:isoEnddate) or (./tei:correspAction[@type="sent"]/tei:date/(@to|@notAfter)/cs:endOfPeriod(.) >= $cs:isoStartdate)]')
            else ()
        )
    );

(: AVAILABILITY :)
declare variable $cs:onlyOnlineAvailable :=
    if ($cs:p_available='online')
    then ("[matches(./@ref, 'https?://')]")
    else (
        if ($cs:p_available='print')
        then ("[not(matches(./@ref, 'https?://'))]")
        else ()
    );    
    

(: CMI FILE :)
declare variable $cs:cmiFile :=
    if ($cs:p_cmiFile)
    then ("[matches(ancestor-or-self::tei:TEI//tei:idno, $cs:p_cmiFile)]")
    else ();

(: ALLOWED QUERY :)
declare variable $cs:allowedQuery :=
    (: prevents that the search query is executed if ther is no Correspondent ID (or the value "all" ist set) :)
    if (matches($cs:allCorrespondents/li, '^http://d-nb.info/gnd/|^http://viaf.org/viaf/|^http://catalogue.bnf.fr/ark:/12148/|^http://lccn.loc.gov/|^http://id.ndl.go.jp/auth/ndlna/|^all$'))
    then (true())
    else (false());
    
(: COMPLETE SEARCH QUERY EXPRESSION :)
declare variable $cs:completeSearchQuery := 
    if ($cs:allowedQuery)
    then (concat('collection($cs:beacons)//tei:correspDesc', $cs:cmiFile, string-join($cs:searchQueryCorrespondent), $cs:searchQueryPlace, $cs:searchQueryDate, $cs:onlyOnlineAvailable))
    else ();