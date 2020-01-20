xquery version "3.0";

module namespace edweb="http://www.bbaw.de/telota/ediarum/web";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $edweb:config := doc('config.xml');

(: Interne oder externe Umgebung: ja/nein :)
declare variable $edweb:intern :=
    if ($edweb:config//intern/text()='yes')
    then (true())
    else (false());

(: BaseURL der Website :)
declare variable $edweb:baseURL := 
    if ($edweb:intern) 
    then ($edweb:config//web/baseurl[@type='intern']/text())
    else ($edweb:config//web/baseurl[@type='public']/text());

(: Verzeichnispfade :)
declare variable $edweb:data := $edweb:config//directory[@type='data']/text();
declare variable $edweb:dataLetters := concat($edweb:data, '/Briefe');
declare variable $edweb:dataDiaries := concat($edweb:data, '/Tageskalender');
declare variable $edweb:dataLectures := concat($edweb:data, '/Vorlesungen');
declare variable $edweb:dataExcerpts := concat($edweb:data, '/Exzerpte');
declare variable $edweb:dataRegister := concat($edweb:data, '/Register');
declare variable $edweb:dataRegisterPersons := concat($edweb:dataRegister, '/Personen.xml');
declare variable $edweb:dataRegisterWorks := concat($edweb:dataRegister, '/Werke.xml');
declare variable $edweb:dataRegisterPlaces := concat($edweb:dataRegister, '/Orte.xml');
declare variable $edweb:dataRegisterOrgs := concat($edweb:dataRegister, '/Firmen_Institutionen.xml');

(: Web :)
declare variable $edweb:webDir := $edweb:config//directory[@type='web'];
declare variable $edweb:apiDir := concat($edweb:webDir, '/api');
declare variable $edweb:html := concat($edweb:webDir, '/resources/xslt/html.xsl');
declare variable $edweb:htmlHeader := concat($edweb:webDir, '/resources/xslt/header.xsl');
declare variable $edweb:htmlContent := concat($edweb:webDir, '/resources/xslt/content.xsl');

(: Caches :)
declare variable $edweb:cacheLetterIndex := concat($edweb:webDir, '/briefe/resources/letterIndex.xml');

(: CMIF :)
declare variable $edweb:permanentURLLetters := concat($edweb:baseURL, '/brief/id/'); 
declare variable $edweb:cmifCache := $edweb:config//api/cmif/cacheduration/text(); (: xs:dayTimeDuration :)

(: BEACONS :)
(: Used Authority Controlled Files :)
declare variable $edweb:authorities :=
    map:new(
       for $authority in $edweb:config//authorities/authority 
       return
           map:entry($authority/@name/data(.), $authority/@prefix/data(.))
    );
declare variable $edweb:defaultAuthority := $edweb:config//authority[@default='true']/@name/data(.);
declare variable $edweb:beaconDir := concat($edweb:webDir, '/register/personen/beacon');

declare variable $edweb:beacons := $edweb:config//beacons; 
    
(: Globale URL Parameter :)
declare variable $edweb:p_view := request:get-parameter("view", "k");

(: Zentrales Login für alle Skripte :)
declare function edweb:login(){
    xmldb:login($edweb:data, 'admin', 'al06hi27')
};

declare function edweb:defaultOrderBy($brief){ 
                if ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date/@when) 
                then ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date[1]/@when)
                else ( 
                    if ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date/@from) 
                    then ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date[1]/@from)
                    else if ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date/@notBefore)
                        then ($brief//(tei:creation|tei:correspAction[@type='sent'])/tei:date[1]/@notBefore)
                        else ($brief/@xml:id)
                )
};

declare function edweb:transformHTML($input, $currentSection) {
    transform:transform(
        $input, 
        doc($edweb:html), 
        <parameters>
            <param name="currentSection" value="{$currentSection}" />
            <param name="baseURL" value="{$edweb:baseURL}" />
        </parameters>
    )
};

declare function edweb:transformHTML($header, $content, $currentSection) {
    transform:transform(
        <transferContainer>
            {transform:transform($header, doc($edweb:htmlHeader), ()),
            transform:transform($content, doc($edweb:htmlContent), ())}        
        </transferContainer>, 
        doc($edweb:html), 
        <parameters>
            <param name="currentSection" value="{$currentSection}" />
            <param name="baseURL" value="{$edweb:baseURL}" />
        </parameters>
    )
};


declare function edweb:pagination($p_limit, $p_offset, $resultCount, $showCount) {
    
    let $numberOfPages := xs:int(ceiling($resultCount div $p_limit))
    let $URLqueryString := replace(request:get-query-string(), '&amp;offset=\d\d?\d?\d?', '')
    
    let $showCount := 
        if ($showCount='yes')
        then (true())
        else (false())
    
    let $labels :=
        map { 
            "noResult" := 1,
            "of" := 2
        }
        
    let $pageSelectBox :=
        element select {
            attribute onchange { 'location = this.options[this.selectedIndex].value;'},
            if ($numberOfPages = 1)
            then (attribute disabled {'disabled'} )
            else (),
            for $x in (1 to $numberOfPages)
            return
            if ($x = ceiling($p_offset div $p_limit))
            then (element option { attribute selected { '' }, attribute value { concat('?', $URLqueryString, '&amp;offset=', ((($x - 1) * $p_limit) + 1)) }, $x })
            else (element option { attribute value { concat('?', $URLqueryString, '&amp;offset=', ((($x - 1) * $p_limit) + 1)) }, $x })
        }

    let $pagination :=
        element span {
            attribute class { 'pageBrowser' },
            if ($pageSelectBox//option[@selected]/preceding-sibling::option)
            then (
                element a { attribute href { $pageSelectBox//option[@selected]/preceding-sibling::option[last()]/@value }, <i class="fa fa-angle-double-left"><span class="hidden">first</span></i> },
                element a { attribute href { $pageSelectBox//option[@selected]/preceding-sibling::option[1]/@value }, <i class="fa fa-angle-left"><span class="hidden">prev</span></i> }
            )
            else (
                <i class="fa fa-angle-double-left"><span class="hidden">first</span></i>,
                <i class="fa fa-angle-left"><span class="hidden">prev</span></i>
            ),
            $pageSelectBox,
            if ($pageSelectBox//option[@selected]/following-sibling::option)
            then (
                element a { attribute href { $pageSelectBox//option[@selected]/following-sibling::option[1]/@value }, <i class="fa fa-angle-right"><span class="hidden">next</span></i> },
                element a { attribute href { $pageSelectBox//option[@selected]/following-sibling::option[last()]/@value }, <i class="fa fa-angle-double-right"><span class="hidden">last</span></i> })
            else (
                <i class="fa fa-angle-right"><span class="hidden">next</span></i>,
                <i class="fa fa-angle-double-right"><span class="hidden">last</span></i>
            )
        }
    
    let $resultCounter :=
        if ($showCount)
        then (
            if ($resultCount = 0)
                then ($labels('noResult'))
                else (
                    if ($resultCount <= $p_limit)
                    then (element span { attribute class {'resultcount'}, concat($resultCount, ' Treffer') })
                    else (
                        if ($pagination//select/option[position()=last()]/@selected)
                        then (element span { attribute class {'resultcount'}, concat('Treffer ', $p_offset, '-', $resultCount, ' von ', $resultCount) } )
                        else (element span { attribute class {'resultcount'}, concat('Treffer ', $p_offset, '-', ($p_offset + $p_limit - 1), ' von ', $resultCount)} )
                    )
                )
         ) else ()
    
    return
    element div {
        attribute class {'pageNav'},
        $resultCounter,
        $pagination
    }
};

declare function edweb:letterTitle($titleStmt) {
    let $idno :=
        if ($titleStmt//tei:idno/text())
        then (<span class="idno">{concat($titleStmt//tei:idno/text(), '. ')}</span>)
        else ()
    return
    concat($idno, string-join($titleStmt/tei:title/text()))
};

declare function edweb:persName($persName, $rendFirst) {
    if ($persName/tei:name) 
    then ($persName/tei:name/text())
    else (
        if ($rendFirst='surname')
        then (
            if ($persName/tei:forename/text())
            then (concat($persName/tei:surname/text(), ', ', $persName/tei:forename/text()))
            else ($persName/tei:surname/text()))
        else (
            if ($persName/tei:forename/text())
            then (concat($persName/tei:forename/text()[1], ' ', $persName/tei:surname/text()[1]))
            else ($persName/tei:surname/text())
        )
    )
};

declare function edweb:seperator($input, $seperator) {
    if ($input)
    then (concat($seperator, ' ', string-join($input)))
    else ()
};

declare function edweb:substring-afterlast($string as xs:string, $cut as xs:string){
  if (matches($string, $cut))
    then edweb:substring-afterlast(substring-after($string,$cut),$cut)
  else $string
};

declare function edweb:substring-beforelast($string as xs:string, $cut as xs:string){
  if (matches($string, $cut))
    then substring($string,1,string-length($string)-string-length(edweb:substring-afterlast($string,$cut))-string-length($cut))
  else $string
};

