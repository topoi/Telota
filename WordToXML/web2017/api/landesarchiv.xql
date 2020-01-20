xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=text media-type=text/plain omit-xml-declaration=yes";

let $login := edweb:login()
let $p_beacon := request:get-parameter('beacon', 'no')
let $p_file := request:get-parameter('akte', ())
let $p_page := request:get-parameter('seite', ())


let $searchString :=  $p_file||'_\d\d_'||$p_page

let $docID := collection($edweb:data)//tei:TEI[matches(.//tei:facsimile/tei:graphic/@url, $searchString)]/@xml:id  
 
return
if ($p_beacon='yes') then 
    for $fac in collection($edweb:data)//tei:TEI//tei:facsimile/tei:graphic/@url
    order by normalize-space($fac)
    return
        for $token in tokenize($fac, ';|,|:')
        order by normalize-space($token)
        return
        normalize-space($token)||'&#xa;'    
else (
if ($docID!='')
then (response:redirect-to(xs:anyURI($edweb:baseURL||'/briefe/detail.xql?id='||$docID)))
else ('Nicht gefunden')
)