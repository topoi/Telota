xquery version "1.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=html5 media-type=text/html";

(: Für das Login und Logout :)

let $login := xmldb:login('/db/', 'web_AvH', 'MVLOFEKdHzmPDsDNBknQ')

let $filepath := substring-after(request:get-parameter("file", ""), 'webdav')

let $id := doc($filepath)//tei:TEI/@xml:id
let $url := if ($filepath) 
            then concat('http://telotadev.bbaw.de:9200/exist/rest/db/web_AvH/briefe/detail.xql?id=', $id)
            else 'http://telotadev.bbaw.de:9200/exist/rest/db/web_AvH/briefe/index.xql'

return
response:redirect-to($url)
