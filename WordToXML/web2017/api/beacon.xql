xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

let $login := edweb:login()
let $p_type := request:get-parameter("type", "all")
let $p_authority := request:get-parameter("authority", $edweb:defaultAuthority)

let $correspondents := collection($edweb:dataLetters)//tei:creation/tei:persName/@key/data(.)
let $personsMentioned := collection($edweb:dataLetters)//tei:text//tei:persName/@key/data(.)

let $authorityPrefix := 
    if (map:contains($edweb:authorities, $p_authority))
    then ($edweb:authorities($p_authority))
    else (false())

let $normid :=
    if ($p_type='correspondents')
    then (
        for $normid in doc($edweb:dataRegisterPersons)//person[@normid and contains(@normid, $authorityPrefix) and contains($correspondents, @id)]/@normid
        return
        concat(substring-after($normid, $authorityPrefix), ',')
    )
    else (
        if ($p_type='personsMentioned')
        then (
            for $normid in doc($edweb:dataRegisterPersons)//person[@normid and matches(@normid, $authorityPrefix) and contains($personsMentioned, @id)]/@normid
            return
            concat(substring-after($normid, $authorityPrefix), ',')    
        )
        else (
            for $normid in doc($edweb:dataRegisterPersons)//person[matches(@normid, $authorityPrefix)]/@normid
            return
            concat(substring-after($normid, $authorityPrefix), ',')
        )
    )

let $description := 
    if ($p_type='correspondents')
    then ('Alle Korrespondenzpartner Schleiermachers, von denen ein oder mehrere Brief(e) in der Datenbank enthalten sind')
    else (
        if ($p_type='personsMentioned')
        then ('Alle in den Manuskripten erwähnten und mit Norm-ID versehenen Personen')
        else ('Alle mit Norm-ID versehenen Datensätze im Personenregister')
    )

let $timestamp := xmldb:last-modified($edweb:dataRegister, substring-after($edweb:dataRegisterPersons, concat($edweb:dataRegister, '/')))

let $replaceWhitspace := replace(string-join($normid), ' ', ',')
let $makeLinebreaks := replace($replaceWhitspace, ',', '&#xa;')

let $metadata := 
<p>
#FORMAT: BEACON
#PREFIX: {$authorityPrefix}
#TARGET: {$edweb:baseURL}/register/personen/detail.xql?normid={$authorityPrefix}{{ID}}
#FEED: {$edweb:baseURL}/register/personen/beacon.xql?type={$p_type}&amp;authority={$p_authority}
#CONTACT: dumont@bbaw.de
#INSTITUTION: Berlin-Brandenburgische Akademie der Wissenschaften
#NAME: Akademienvorhaben "Schleiermacher in Berlin 1808-1834. Briefwechsel, Tageskalender, Vorlesungen"
#DESCRIPTION: {$description} 
#TIMESTAMP: {$timestamp} &#xa;
</p>

let $output := <p>{$metadata, $makeLinebreaks}</p> 

return
if ($authorityPrefix)
then ($output)
else ()