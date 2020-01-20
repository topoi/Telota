xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "resources/functions.xql";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare option exist:serialize "method=html media-type=text/html";

let $login := edweb:login()

(: Parameter aus URL übernehmen :)
let $p_id := request:get-parameter("id", ())
let $p_filepath := substring-after(request:get-parameter("file", ""), 'webdav')

let $doc :=
    if ($p_id)
    then collection('/db/projects/mega/data/Briefe')//tei:TEI[@xml:id=$p_id] 
    else doc($p_filepath)//tei:TEI

(: Parameter für alle Transformationen :)
let $params := 
    <parameters>
        <param name="id" value="{$p_id}"/>
        <param name="view" value="k" />
        <param name="print" value="yes" />
        <param name="cacheLetterIndex" value="{$edweb:cacheLetterIndex}" />
    </parameters>

let $document := transform:transform($doc, doc("resources/xslt/content-grid.xsl"), $params)

let $att_place_values :=
    map{
        "superlinear" := "Über der Zeile ergänzt",
        "sublinear" := "Unter der Zeile ergänzt",
        "intralinear" := "Innerhalb der Zeile ergänzt",
        "across" := "Über den ursprünglichen Text geschrieben",
        "left" := "Am linken Rand ergänzt",
        "right" := "Am rechten Rand ergänzt",
        "mTop" := "Am unteren Rand ergänzt",
        "mBottom" := "Am unteren Rand ergänzt"
    }

return
<html>
    <head>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="resources/css/transkription.css" type="text/css"/>
        <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" href="resources/css/print.css" type="text/css"/>
    </head>
    <body>
        <h1>{$doc//tei:teiHeader//tei:titleStmt/tei:title/text()}</h1>
        <p id="nachweis">
            {if ($doc//tei:msDesc//tei:idno/text()!='') then (
                concat("H: ", $doc//tei:msDesc/tei:msIdentifier/tei:institution,
                edweb:seperator($doc//tei:msDesc/tei:msIdentifier/tei:repository/text(), ', '),
                edweb:seperator($doc//tei:msDesc/tei:msIdentifier/tei:collection/text(), ', '),
                edweb:seperator($doc//tei:msDesc/tei:msIdentifier/tei:idno/tei:idno[not(@type='kalliope')]/text(), ','))
            ) else (
                concat("D: ", $doc//tei:witness[position()=last()]/tei:bibl/text())
            )}
        </p>
        {if ($doc//tei:physDesc)
        then (<p>{$doc//tei:physDesc/tei:p}</p>)
        else (),
        if ($doc//tei:witness)
        then (
            element ul {
            element h4 {'Textzeugen'}, 
            for $wit in $doc//tei:listWit/tei:witness
            return
            <li>{$wit//text()}</li>
        }) else ()}
        
        {$document}
        <div id="comments">
            <h3>Kommentar</h3>
            <ul>
            {for $comment at $pos in $doc//tei:text//tei:seg/tei:note
             let $note := transform:transform($comment, doc("resources/xslt/transcription.xsl"), $params)
             return
             <li><a name="fnote{$pos}">[{$pos}] </a>{$note}</li>}
             </ul>
        </div>
        {if ($edweb:p_view='k') then (
        <div id="critical">
            <h3>Kritischer Apparat</h3>
            <ul>
            {for $add at $pos in $doc//tei:add
             let $label := 
                if ($add/@place!='' and $att_place_values($add/@place))
                then $att_place_values($add/@place)
                else  if ($add/@place!='') 
                      then $add/@place/data(.)
                      else ('[Keine Angabe]')
             return
             <li><a name="cnote{$pos}"/>{$label}</li>}
             </ul>
        </div>) else ()}
    </body>
</html>