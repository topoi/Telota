xquery version "3.0";

module namespace csLink="http://correspSearch.bbaw.de/link";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function csLink:linkedLetters($letter, $allowedRole, $personIndex) {
    let $correspondents := 
        for $key in $letter//tei:correspAction[not(.//@key='prov_d4h_dtz_q5')]/tei:persName[@key]/@key
        return
        collection($personIndex)//tei:person[@xml:id=$key and tei:idno/text()]
       
    let $startDate := xs:date($letter//tei:correspAction/tei:date[1]/(@when|@from|@notBefore)/data(.)) - xs:dayTimeDuration("P60D")
    let $endDate := xs:date($letter//tei:correspAction/tei:date[1]/(@when|@to|@notAfter)/data(.)) + xs:dayTimeDuration("P60D")
    let $mediumDate :=
        if ($letter//tei:correspAction[@type='sent']/tei:date/@when)
        then ($letter//tei:correspAction[@type='sent']/tei:date/@when)
        else (
            xs:date($letter//tei:correspAction/tei:date[1]/(@from|@notBefore)/data(.)) + xs:dayTimeDuration(concat('P', ceiling((xs:date($letter//tei:correspAction/tei:date[1]/(@to|@notAfter)/data(.)) - xs:date($letter//tei:correspAction/tei:date[1]/(@from|@notBefore)/data(.))) div xs:dayTimeDuration('P1D') div 2), 'D'))
        )

    let $role :=
        if ($allowedRole='sender')
        then ('sender')
        else if ($allowedRole='addressee')
        then ('addressee')
        else ('correspondent')
    
    let $queryString := concat($role, '=', $correspondents//tei:idno/text(), '&amp;startdate=', $startDate, '&amp;enddate=', $endDate)
    
    let $letters := 
        transform:transform(
            doc(concat('http://correspsearch.bbaw.de/api/v1/tei-xml.xql?', $queryString)), 
            doc('csapi.xsl'), 
            <parameters>
                <param name="excludeSource" value="FSB" />
                <param name="excludeGND" value="http://d-nb.info/gnd/118554700" />
                <param name="mediumDate" value="{$mediumDate}" />
                <param name="persName" value="{$correspondents//tei:persName/tei:surname/text()}" />
                <param name="queryString" value="{$queryString}" />
            </parameters>
        )

    return
    if ($letters//li)
    then ($letters)
    else ()
};
