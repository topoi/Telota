xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

declare option exist:serialize "method=html5 media-type=text/html";

(: Für das Login und Logout :)

let $login := edweb:login() 

let $basepath := 'http://telotadev.bbaw.de/mega/' 
let $id := request:get-parameter("id", ())
let $page := 
    if (request:get-parameter("page", ()))
    then ('#'||request:get-parameter("page", ()))
    else ()

let $filepath :=
    if (collection($edweb:data)//tei:TEI[@xml:id=$id])
    then base-uri(root(collection($edweb:data)//tei:TEI[@xml:id=$id]))
    else ()

let $url := 
        if (matches($filepath, 'Briefe'))
        then ($basepath||'briefe/detail.xql?id='||$id||$page)
        else if (matches($filepath, 'Dokumente'))
        then ($basepath||'themen/detail.xql?id='||$id||$page)
        else ($basepath||'index.xql') 

return
response:redirect-to($url)