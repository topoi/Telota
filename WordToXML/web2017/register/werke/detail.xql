xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html5 media-type=text/html";

declare function local:zoteroLink($id) {
    if (matches($id, 'zotero-'))
    then (concat(
        'http://www.zotero.org/groups/',
        substring-after(edweb:substring-beforelast($id, '-'), '-'),
        '/items/itemKey/',
        edweb:substring-afterlast($id, '-')
    ))
    else ()
};

declare function local:viewBox($node) {
    if ($node) then (
    <div class="box whitebox">
        <div class="boxInner">
            {$node}
        </div>
    </div>
    ) else ()
};

let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $werk := collection($edweb:dataRegister)//tei:bibl[@xml:id=concat($p_id, '')]

let $redirect :=
         if (not($werk))
        then (
            if (matches($p_id, 'zotero'))
            then (response:redirect-to(xs:anyURI('http://www.zotero.org/groups/604880/items/itemKey/'||edweb:substring-afterlast($p_id, '-'))))
            else (response:redirect-to(xs:anyURI('index.xql'))))
        else ()

let $description := 
    local:viewBox((
    for $x in $werk//tei:note
    return
    transform:transform($x, doc('../register.xsl'), <parameters><param name="baseURL" value="{$edweb:baseURL}" /></parameters>)
    ))


let $lettersMentionPubl := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[tei:text//tei:bibl[@sameAs=$p_id] or .//tei:abstract//tei:bibl[@sameAs=$p_id] or .//tei:correspDesc/tei:note//tei:bibl[@sameAs=$p_id] or tei:text//tei:index[substring(@corresp, 2)=$p_id]]
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        'Erwähnungen in Briefen')
        
let $roles :=
map { 
        "music" := "Musik",
        "composition" := "Komposition",
        "arrangement" := "Bearbeitung",
        "libretto" := "Libretto",
        "text" := "Text",
        "translation" := "Übersetzung"
    }    
    
(: ########### HTML-Ausgabe ########### :)
let $header :=  <transferContainer>
                    <div id="subnavbar">
                        {edwebRegister:sectionNav($werk//tei:title/text())}
                    </div>
                    <h1>{$werk/tei:title/text(), if ($werk/tei:date) then (concat(' (', replace($werk/tei:date/text(), '\(|\)', ''), ') ')) else ()}</h1>
                    <p>{if ($werk/tei:author) then (
                        for $x in $werk/tei:author
                        let $role :=
                            if ($x/@role)
                            then (' ('||map:get($roles, $x/@role)||') ')
                            else ()
                        return
                        (edweb:persName($x/tei:persName, 'forename'),$role,<br/>)) 
                        else ()}</p>
                </transferContainer>
                

let $content := <transferContainer>
                    <div class="grid_11 box whitebox">
                         {if ($description) then ($description) else ()}
                         {local:viewBox(if ($lettersMentionPubl//td) then ($lettersMentionPubl) else ())}
                    </div>
                    <div class="grid_5"></div>
                 </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output