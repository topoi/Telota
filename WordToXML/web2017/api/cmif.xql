xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $login := edweb:login()

let $useCache := 
    if (doc-available('resources/cached_cmif.xml'))
    then (
        if(current-dateTime() < (xmldb:created(concat($edweb:apiDir, '/resources'), 'cached_cmif.xml') + xs:dayTimeDuration('P1D')))
        then (fn:true())
        else (fn:false())
    )
    else (fn:false())

let $letters :=
    if (not($useCache))
    then (
        for $letter in collection($edweb:dataLetters)//tei:TEI
        return
        transform:transform(
            $letter//tei:creation, 
            doc('resources/correspDesc.xsl'), 
            <parameters>
                <param name="dataRegisterPersons" value="{$edweb:dataRegisterPersons}" />
                <param name="dataRegisterPlaces" value="{$edweb:dataRegisterPlaces}" />
                <param name="permanentURLLetters" value="{$edweb:permanentURLLetters}" />
                <param name="letterID" value="{$letter//tei:titleStmt//tei:idno/text()}" />
            </parameters>)
    ) else ()

return
if ($useCache)
then (doc('resources/cached_cmif.xml'))
else (
    xmldb:store(concat($edweb:apiDir, '/resources'), 'cached_cmif.xml', transform:transform($letters, doc('resources/cmif.xsl'), ())),
    response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/api/cmif.xql'))))
