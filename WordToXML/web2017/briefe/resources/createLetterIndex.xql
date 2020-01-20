xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $list :=
    <list>
    {for $x in collection($edweb:dataLetters)//tei:TEI
    return
        <entry id="{$x/@xml:id}">{$x//tei:titleStmt//text()}</entry>}
    </list>
    
return
xmldb:store(concat($edweb:webDir, '/briefe/resources'), 'letterIndex.xml', $list)