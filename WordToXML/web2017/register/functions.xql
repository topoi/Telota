xquery version "3.0";

module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $edwebRegister:section := upper-case(request:get-parameter("section", 'A'));

declare function edwebRegister:sectionNav ($currentName) {
    let $fullRange := 'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z'
    let $currentLetter := 
        if ($currentName!='index')
        then (substring(string-join($currentName), 1, 1))
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
    let $ö := replace($s, 'ö', 'oe')
    let $ä := replace($ö, 'ä', 'ae')
    let $ü := replace($ä, 'ü', 'ue')
    let $e := replace($ü, 'é', 'e')
    let $e2 := replace($e, 'è', 'e')
    return
    $e2
};


declare function local:viewDate($date) {
    if (matches($date/@when, '\d\d\d\d-\d\d-\d\d'))
    then (format-date($date/@when, '[D01].[M01].[Y0001]'))
        else if (matches($date/@from, '\d\d\d\d-\d\d-\d\d') and matches($date/@to, '\d\d\d\d-\d\d-\d\d'))
        then (format-date($date/@from, '[D01].[M01].[Y0001]')||'&#x2013; '||format-date($date/@to, '[D01].[M01].[Y0001]'))
            else if (matches($date/@notBefore, '\d\d\d\d-\d\d-\d\d') and matches($date/@notAfter, '\d\d\d\d-\d\d-\d\d'))
            then ('nach '||format-date($date/@notBefore, '[D01].[M01].[Y0001]')||'&#x2013; vor '||format-date($date/@notAfter, '[D01].[M01].[Y0001]'))
            else ()
};

declare function edwebRegister:viewLetterTable($letters, $title) {
    let $login := edweb:login()
    let $table :=
    <div>
        <h3>{$title}</h3>
        <table class="letters">
            <tr>
                <th>Datum</th>
                <th>Korrespondent</th>
                <th>Ort</th>
            </tr>{
    for $letter in $letters
    let $correspondent := $letter//tei:correspAction/(tei:persName|tei:orgName)[@key!='prov_d4h_dtz_q5']
    let $correspondentName :=
        for $x in $correspondent
        let $type := 
            if ($x/parent::tei:correspAction/@type='sent')
            then ('Von ')
            else ('An ')
        return
            ($type,
            for $y in collection($edweb:dataRegister)//id($x/@key)
            return
            if ($y/tei:orgName[@type='reg'])
            then ($y/tei:orgName[@type='reg']/text(), <br/>)
            else (edweb:persName($y/tei:persName[@type='reg'], 'forename'),<br/>))
    let $place := 
        for $x in $letter//tei:correspAction[@type='sent']/tei:placeName
        return
        (collection($edweb:dataRegister)//id($x/@key)/tei:placeName[@type='reg']/text(),<br/>)
    return
    <tr class="clickable-row" data-href="../../briefe/detail.xql?id={$letter/@xml:id}">
        <td class="date">{local:viewDate($letter//tei:correspAction/tei:date)}</td>
        <td><a href="../../briefe/detail.xql?id={$letter/@xml:id}">{$correspondentName}</a></td>
        <td>{$place}</td>
    </tr>
    }</table></div>
    return
    $table
};

declare function edwebRegister:viewLetterTableIndex($letters, $title) {
    let $login := edweb:login()
    let $table :=
    <div>
        <h3>{$title}</h3>
        <table class="letters">
            <tr>
                <th>Datum</th>
                <th>Korrespondent</th>
            </tr>{
    for $letter in $letters
    let $correspondent := $letter//tei:correspAction/(tei:persName|tei:orgName)
    let $missing_correspondent_received := 
        if (not($letter//tei:correspAction[@type='received']/(tei:persName|tei:orgName)))
        then ('Unbekannt')
        else ()
    let $missing_correspondent_sent := 
        if (not($letter//tei:correspAction[@type='sent']/(tei:persName|tei:orgName)))
        then ('Unbekannt ')
        else ()
    let $correspondentName :=
        for $x in $correspondent
        let $type := 
            if ($x/parent::tei:correspAction/@type='sent')
            then ()
            else (concat($missing_correspondent_sent, ' an '))
        return
            ($type,
            for $y in collection($edweb:dataRegister)//id($x/@key)
            return
            if ($y/tei:orgName[@type='reg'])
            then (<span>{concat($y/tei:orgName[@type='reg']/text(), ' ')}</span>)
            else (<span>{edweb:persName($y/tei:persName[@type='reg'], 'forename')}</span>))
    let $type :=
        if ($letter//tei:profileDesc/tei:abstract)
        then ('conjectured')
        else ()
    let $type_label :=
        if ($type = 'conjectured')
        then (' (nicht überliefert)')
        else ()
    let $place := 
        for $x in $letter//tei:correspAction[@type='sent']/tei:placeName
        return
        (collection($edweb:dataRegister)//id($x/@key)/tei:placeName[@type='reg']/text(),<br/>)
    return
    <tr class="clickable-row {$type}" data-href="../../briefe/detail.xql?id={$letter/@xml:id}">
        <td class="date">{local:viewDate($letter//tei:correspAction/tei:date)}</td>
        <td><a href="../briefe/detail.xql?id={$letter/@xml:id}">{$correspondentName}</a>{$type_label}</td>
    </tr>
    }</table></div>
    return
    $table
};

declare function edwebRegister:altNames($entry) {
    (if ($entry//tei:persName[@type="birth" or @subtype="birthname"]) then (
    element ul {
        attribute class {'altNames'},
        element span {'Geburtsname:&#x2002;'},
        let $count := count($entry//tei:persName[@type="birth" or @subtype="birthname"])
        for $x at $pos in $entry//tei:persName[@type="birth" or @subtype="birthname"]
        let $name := edweb:persName($x, 'forename')
        order by $x/@subtype/data(.), $x/@type/data(.)            
        return
        if ($pos=$count)
        then (element li { $name })
        else (element li { $name||'; ' })  
    }) else (),
    if ($entry//(tei:persName|tei:placeName)[(@type="alt" and not(@subtype='birthname')) or @type="pseudonym"]) then (
    element ul {
        attribute class {'altNames'},
        element span {'Alternative Namen bzw. Schreibungen im edierten Text:&#x2002;'},
        let $count := count($entry//(tei:persName|tei:placeName)[(@type="alt" and not(@subtype='birthname')) or @type="pseudonym"])
        for $x at $pos in $entry//(tei:persName|tei:placeName)[(@type="alt" and not(@subtype='birthname')) or @type="pseudonym"]
        let $name := 
            if ($x[local-name()='persName'])
            then (edweb:persName($x, 'forename'))
            else ($x//text())
        order by $x/@subtype/data(.), $x/@type/data(.)            
        return
        if ($pos=$count)
        then (element li { $name })
        else (element li { $name||'; ' })
    }) else ())
};

(: AVHR :)
declare function edwebRegister:ptr($ptr, $bibl, $megaDigital) {
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
    if ($megaDigital and number(edweb:substring-beforelast($number, '–')) <= number(doc('../resources/MEGA_docs.xml')//band[text()=substring-after($bibl, '/')]/following-sibling::lastPage[1]/text()))
    then (
            element a {
            attribute href {edwebRegister:createMEGAdigitalLink(edweb:substring-beforelast($number, '–'), $bibl)}, $string}
         )
     else ($string)}
            
};

declare function edwebRegister:createMEGAdigitalLink($page, $bibl) {
    let $baseURL := 'http://telota.bbaw.de/mega/#?doc=MEGA_A2_B0'
    let $temp := concat($baseURL, substring-after($bibl, '/'), '-00_ETX.xml&amp;book=', substring-after($bibl, '/'))
    let $temp2 := concat($temp, '&amp;part=0&amp;pageNr=', $page, '&amp;startPage=&amp;endPage=&amp;startLine=&amp;endLine=&amp;startTerm=&amp;endTerm=')
    return $temp2
};

declare function edwebRegister:printReferences($entry, $biblPath) {
let $volumes := "I/1,I/2,I/3,I/5,I/7,I/10,I/11,I/12,I/13,I/14,I/18,I/20,I/21,I/22,I/24,I/25,I/26,I/27,I/29,I/30,I/31,I/32,II/1,II/2,II/3.1,II/3.2,II/3.3,II/3.4,II/3.5,II/3.6,II/4.1,II/4.2,II/4.3,II/5,II/6,II/7,II/8,II/9,II/10,II/11,II/12,II/13,II/14,II/15,III/1,III/2,III/3,III/4,III/5,III/6,III/7,III/8,III/9,III/10,III/11,III/12,III/13,III/30,IV/1,IV/2,IV/3,IV/,IV/4,IV/5,IV/6,IV/7,IV/8,IV/9,IV/12,IV/26,IV/31,IV/32"
let $megaDigital := "II/5,II/11,II/12,II/13,II/15"
return
    (element h3 { 'Nachweise in bereits erschienenen Bänden der MEGA' },
    element div {
        attribute id {"pageReferences"},
        for $vol in tokenize($volumes, ',')
        let $bibl := $vol(:doc($biblPath)//tei:bibl[@xml:id=concat('B', $vol)]:)
        return
        
                if ($entry/(tei:linkGrp|tei:listRef)//@target/substring-before(., '#')=$vol)
                then (
                    if (contains(tokenize($megaDigital, ','), $bibl))
                    then (
                    element h4 {concat($bibl, ' (Textband online verfügbar in MEGAdigital)')}
                    ) else (element h4 { $bibl }),
                    element div {
                        element ul {
                            attribute class {'pageReferences'},
                            for $ptr in $entry/(tei:linkGrp|tei:listRef)/tei:ptr[matches(@target, concat('^', $vol, '#'))]
                            return
                            edwebRegister:ptr($ptr, $bibl, contains(tokenize($megaDigital, ','), $bibl))
                        }
                    }
                ) else ()
    })
};

