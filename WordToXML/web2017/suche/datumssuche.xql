xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";
import module namespace edwebSearch="http://www.bbaw.de/telota/ediarum/web/search" at "forms.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace pdrws = "http://pdr.bbaw.de/namespaces/pdrws/";

declare option exist:serialize "method=html5 media-type=text/html";

let $login := edweb:login()

let $p_date := iri-to-uri(request:get-parameter("datum", ()))

let $isodate := httpclient:get(xs:anyURI(concat('https://pdrprod.bbaw.de/pdrws/dates?output=xml&amp;lang=de&amp;text=', $p_date)), true(), (<headers><header name="Authorization" value="Basic cGRyd3MtdXNlcjpwZHJyZHA="/></headers>))//pdrws:isodate/@when 
let $date := if (matches($isodate, '\d\d\d\d-\d\d-\d\d')) 
              then (xs:date($isodate))
              else (xs:date('2012-01-01'))

let $prevWeek := xs:string($date - xs:dayTimeDuration("P7D"))
let $nextWeek := xs:string($date + xs:dayTimeDuration("P7D"))
              
let $letters := 
    <div class="box whitebox"><div class="boxInner"><h2>Briefe in diesem Zeitraum</h2><ul>
        { for $item in collection($edweb:dataLetters)//tei:TEI[tei:teiHeader//tei:date[@when le $nextWeek and @when ge $prevWeek]]
            order by $item//tei:creation/tei:date/@when
          return
            <li><a href="../briefe/detail.xql?id={$item/@xml:id}">{$item//tei:titleStmt/tei:title/text()}</a></li>
        }
    </ul></div></div>
                
let $diaries := 
    <div class="box whitebox">
        <div class="boxInner">
            <h2>Einträge im Tageskalender</h2>               
            { for $item in collection($edweb:dataDiaries)//tei:TEI[.//tei:p/tei:date[@when le $nextWeek and @when ge $prevWeek]]
             order by $item//tei:creation/tei:date/@from
             return
        <div>
        <h3><a href="../tageskalender/detail.xql?id={$item/@xml:id}">{$item//tei:titleStmt/tei:title/text()}</a></h3>
        <ul class="tageskalendereintraege">
            { for $x in $item/tei:text//tei:p[tei:date[@when le $nextWeek and @when ge $prevWeek]]
            return
            if ($x[tei:date/@when=$date])
            then (<li style="font-weight: bold;"><a href="../tageskalender/detail.xql?id={$item/@xml:id}&amp;datum={$x/tei:date/@when}&amp;f=1#{$x/tei:date/@when}">{$x//text()}</a></li>)
            else (<li>{$x//text()}</li>) }
        </ul>
        </div>
        }
        </div>
    </div>
                
let $h1 := <h1> Suche nach {transform:transform(<datum>{$date}</datum>, doc('../resources/datum.xsl'), ())}</h1>

let $header :=  <transferContainer>
                    <div class="grid_16">
                        {$h1}
                    </div>
                </transferContainer>

let $content := <transferContainer>
                    <div class="grid_10">
                           {$letters}
                           {$diaries}
                    </div>
                    <div class="grid_6 box graybox">
                        <div class="boxInner">
                            <h2>Zeit</h2>
                            <p>Suchen Sie nach Briefen und Tageskalendereinträgen zu einem bestimmten Datum:</p>
                            {edwebSearch:formZeitsuche($p_date)}    
                        </div>
                    </div>
                 </transferContainer>

let $output := edweb:transformHTML($header, $content, 'suche')

return 
$output