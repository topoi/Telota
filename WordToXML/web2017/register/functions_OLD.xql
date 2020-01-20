xquery version "3.0";

module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $edwebRegister:section := upper-case(request:get-parameter("section", 'A'));

declare function edwebRegister:sectionNav ($currentName) {
    let $fullRange := 'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z'
    let $currentLetter := 
        if ($currentName!='index')
        then (substring($currentName, 1, 1))
        else ($edwebRegister:section)
    
    let $nav :=
    <ul>
        { for $letter in tokenize($fullRange, ',')
        return
            <li> 
            { if ($letter=$currentLetter) then (<a class="current" href="index.xql?section={$letter}">{$letter}</a>) 
            else (<a href="index.xql?section={$letter}">{$letter}</a>) }
            </li> 
        }
    </ul>
    return
    $nav
};

declare function edwebRegister:orderLabel($label) {
    let $normalized := normalize-space($label)
    let $s := replace($normalized, 'š', 's')
    return
    $s
};

declare function local:viewDate($date) {
    if ($date/@when)
    then (format-date($date/@when, '[D01].[M01].[Y0001]'))
        else if ($date/@from and $date/@to)
        then (format-date($date/@from, '[D01].[M01].[Y0001]')||'&#x2013; '||format-date($date/@to, '[D01].[M01].[Y0001]'))
            else if ($date/@notBefore and $date/@notAfter)
            then ('nach '||format-date($date/@notBefore, '[D01].[M01].[Y0001]')||'&#x2013; vor '||format-date($date/@notAfter, '[D01].[M01].[Y0001]'))
            else ()
};

declare function edwebRegister:viewLetterTable($letters, $title) {
    <div>
        <h3>{$title}</h3>
        <table class="letters">
            <tr>
                <th>No.</th>
                <th>Datum</th>
                <th>Korrespondent</th>
                <th>Ort</th>
            </tr>{
    for $letter in $letters
    let $correspondent := $letter//tei:creation/tei:persName[@key!='p1914']
    let $correspondentName :=
        for $x in $correspondent
        return
            for $y in doc($edweb:dataRegisterPersons)//person[ft:query(@id, $x/@key)]
            return
            edweb:persName($y, 'forename')
    let $place := 
        for $x in $letter//tei:creation/tei:placeName
        return
        doc($edweb:dataRegisterPlaces)//ort[ft:query(@id, $x/@key)]
    let $conjectured :=
        if (not($letter//tei:text//text()))
        then (' conjectured')
        else ()
    return
    <tr class="clickable-row{$conjectured}" data-href="../../briefe/detail.xql?id={$letter/@xml:id}">
        <td class="idno"><a class="{$conjectured}" href="../../briefe/detail.xql?id={$letter/@xml:id}">{$letter//tei:title/tei:idno/text()}</a></td>
        <td class="date">{local:viewDate($letter//tei:date)}</td>
        <td>{
            if ($correspondent/@type='absender')
            then ('Von '||string-join($correspondentName))
            else ('An '||string-join($correspondentName))
        }</td>
        <td>{$place/ortsname}</td>
    </tr>
    }</table></div>
};

(: AVHR :)
declare function edwebRegister:ptr($ptr) {
    let $number := 
        if ($ptr/@subtype="comment")
        then (concat("[", substring-after($ptr/@target, '#'), "]"))
        else (substring-after($ptr/@target, '#'))
    let $string :=
        if ($ptr[@type='letter'])
        then (concat('Nr. ', $number))
            else if ($ptr[@type='document'])
            then (concat('Dok. ', $number))
            else if ($ptr[@type='page'])
            then (concat('S. ', $number))
            else ($number)
    return
    element li {
    if ($ptr/@subtyp="sentFrom")
    then (
            attribute class {'bold'},
            $string
         )
     else ($string)}        
            
};

declare function edwebRegister:printReferences($entry, $biblPath) {
let $volumes := "02,04,05,06,07,0910,12,14,16,19,22,25,26,27,29,30,32,33,34,35,37,41,42,43"
return
    (element h3 { 'Nachweise in gedruckten Editionen' },
    element div {
        attribute id {"pageReferences"},
        attribute class { "accordion" },
        for $vol in tokenize($volumes, ',')
        let $bibl := doc($biblPath)//tei:bibl[@xml:id=concat('B', $vol)]
        return
        
                if ($entry/(tei:linkGrp|tei:listRef)//@target/substring-before(., '#')=$vol)
                then (
                    element h4 { $bibl/@n/data(.) },
                    element div {
                        element p { $bibl/text() },
                        element ul {
                            attribute class {'pageReferences'},
                            for $ptr in $entry/(tei:linkGrp|tei:listRef)/tei:ptr[matches(@target, concat($vol, '#'))]
                            return
                            edwebRegister:ptr($ptr)
                        }
                    }
                ) else ()
    })
};
