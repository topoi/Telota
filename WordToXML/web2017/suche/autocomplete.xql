xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace json="http://www.json.org"; 

declare option exist:serialize "method=json media-type=text/javascript";

let $login := edweb:login()

let $p_register := request:get-parameter("register", "personen")
let $searchTerms := tokenize(request:get-parameter("term", ""), '\s')
    

let $lucenequery := 
    <query><bool>
       {for $term in $searchTerms
        return
        <wildcard occur="must">*{lower-case($term)}*</wildcard>}
    </bool></query>

let $abfrage := 
    if ($p_register='personen')
    then (collection($edweb:dataRegister)//tei:person[ft:query(.//tei:persName, $lucenequery)])
    else (
        if ($p_register='orte')
        then (collection($edweb:dataRegister)//tei:place[ft:query(./tei:placeName, $lucenequery)])
        else (
            if ($p_register='werke')
            then (doc($edweb:dataRegisterWorks)//tei:bibl[ft:query(., $lucenequery)])
            else (
                if ($p_register='orgs')
                then (collection($edweb:dataRegister)//tei:org[ft:query(., $lucenequery)])
                else (
                    if ($p_register='sachen')
                    then (collection($edweb:dataRegister)//tei:item[ft:query(./tei:label, $lucenequery)])
                    else ()
                )
            )
        )
    )

let $ergebnis := 
    for $x in $abfrage
    let $label :=
        if ($p_register='personen')
        then (
            if ($x//tei:persName[@type='alt'])
            then (
                for $y in $x//tei:persName
                return
                if ($y[@type='alt'])                        
                then (concat('(', edweb:persName($y, 'surname'), ')'))
                else (edweb:persName($y, 'surname'))
            ) 
            else (edweb:persName($x//tei:persName, 'surname')))
        else (
            if ($p_register='orte')
            then (
                if ($x/tei:placeName[@type='alt'])
                then (
                    for $y in $x/tei:placeName
                    return
                    if ($y[@type='alt'])                        
                    then (concat('(', $y/text(), ')'))
                    else ($y/text())
                ) 
                else (string-join($x/tei:placeName/text())))
            else (
                if ($p_register='werke')
                then (concat(string-join($x//tei:author/tei:surname/text()), ', ', string-join($x//tei:title/text())))
                else (
                    if ($p_register='orgs')
                    then (
                        if ($x/tei:orgName[@type='alt'])
                        then (
                            for $y in $x/tei:orgName
                            return
                            if ($y[@type='alt'])                        
                            then (concat('(', $y/text(), ')'))
                            else ($y/text())
                        ) 
                        else (string-join($x/tei:orgName/text())))
                    else (
                        if ($p_register='sachen')
                        then (
                        if ($x/tei:label[@type='alt'])
                        then (
                            for $y in $x/tei:label
                            return
                            if ($y[@type='alt'])                        
                            then (concat('(', $y/text(), ')'))
                            else ($y/text())
                        ) 
                        else (string-join($x/tei:label/text())))
                    else ())
                )
            )
        )       
    return
    <json:value json:array="true" value="{$x/@xml:id}" label="{$label}"></json:value>

return
<select>
    {$ergebnis}
</select>