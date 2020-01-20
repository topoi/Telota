xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace schema = "http://schema.org/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare option exist:serialize "method=html5 media-type=text/html";

declare function local:cleanGeoName($id) {
    let $id := normalize-space($id)
    return
    if (matches($id, 'http://www.geonames.org/\d+/\w+\.html'))
    then substring-before(substring-after($id, 'http://www.geonames.org/'), '/')
    else if (matches($id, 'http://www.geonames.org/\d+/'))
    then substring-before(substring-after($id, 'http://www.geonames.org/'), '/')
    else (substring-after($id, 'http://www.geonames.org/'))
};

declare function local:getGeoName($id) {
    let $record :=
    if (matches($id, 'http://www.geonames.org'))
    then (doc(concat('http://api.geonames.org/get?geonameId=', local:cleanGeoName($id), '&amp;username=dumont&amp;style=SHORT%27'))//geoname)
        else if (matches($id, 'http://vocab.getty.edu/tgn/'))
        then (doc(concat($id, '.rdf'))//rdf:RDF)
        else ()
    let $lat :=
        if (matches($id, 'http://www.geonames.org'))
        then ($record//lat/text())
        else if (matches($id, 'http://vocab.getty.edu/tgn/'))
        then ($record//schema:latitude/text())
        else ()
        
    let $lng :=
        if (matches($id, 'http://www.geonames.org'))
        then ($record//lng/text())
        else if (matches($id, 'http://vocab.getty.edu/tgn/'))
        then ($record//schema:longitude/text())
        else ()
        
    let $map :=
    <div>
        <div id="map" style="height: 300px;"></div>
        <script>
		var map = L.map('map').setView([{$lat}, {$lng}], 4);
		L.tileLayer('http://&#123;s&#125;.tile.osm.org/&#123;z&#125;/&#123;x&#125;/&#123;y&#125;.png', &#123;
			maxZoom: 18,
			attribution: 'Map data © &#60;a href="http://openstreetmap.org"&#62;OpenStreetMap&#60;/a&#62; contributors, ' +
				'&#60;a href="http://creativecommons.org/licenses/by-sa/2.0/"&#62;CC-BY-SA&#60;/a&#62; ',
			id: 'mapbox.streets'
		&#125;).addTo(map);


		L.marker([{$lat}, {$lng}]).addTo(map)

		map.on('click', onMapClick);
	</script>
    </div>

    return
    $map
};

let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $place := doc($edweb:dataRegisterPlaces)//tei:place[@xml:id=concat($p_id, '')]

let $redirect := 
        if (not($place))
        then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/register/orte/index.xql'))))
        else ()

let $subPlaces := 
    <div><h3>Weitere Orte in {$place/parent::gruppe/ort[@type='grname']}</h3><ul>
        { if ($place/@type='grname')
        then ( 
            for $unterort in doc($edweb:dataRegisterPlaces)//ort[@id=$p_id and @type="grname"]/following-sibling::ort
            return
            <li><a href="detail.xql?id={$unterort/@id}">{$unterort}</a></li>
        )
        else (
            if ($place/parent::gruppe)
            then (
            for $unterort in doc($edweb:dataRegisterPlaces)//ort[@id=$p_id]/preceding-sibling::ort[@type="grname"]/following-sibling::ort
            return
            <li><a href="detail.xql?id={$unterort/@id}">{$unterort}</a></li>
            )
            else ()
        )
        }
    </ul></div>

let $lettersWritingPlaces := 
    <div><h3>Schreibort</h3><ul>
    {for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspAction[@type='sent']/tei:placeName[@key=$p_id]]
    order by edweb:defaultOrderBy($brief)
    return
        <li><a href="../../briefe/detail.xql?id={$brief/@xml:id}">{$brief//tei:titleStmt/tei:title//text()}</a></li>
    }
    </ul></div>

let $lettersMentionPlaces := 
    <div><h3>Erwähnungen in Briefen</h3><ul>
    {for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:abstract//tei:placeName/@key=$p_id or .//tei:rs[@type='place' and @key=$p_id] or ./tei:text//tei:placeName[@key=$p_id] or tei:text//tei:index[substring(@corresp, 2)=$p_id]]
    order by edweb:defaultOrderBy($brief)
    return
        <li><a href="../../briefe/detail.xql?id={$brief/@xml:id}">{$brief//tei:titleStmt/tei:title//text()}</a></li>
    }
    </ul></div>

let $diariesMentionPlaces := 
    <div><h3>Erwähnungen in Tageskalendern</h3><ul>
    {for $tageskalender in collection($edweb:dataDiaries)//tei:TEI[./tei:text//tei:placeName[@key=$p_id] or ./tei:text//tei:index[substring(@corresp, 2)=$p_id]]
    order by edweb:defaultOrderBy($tageskalender)
    return
        <li> 
            <ul>{
                for $eintrag in $tageskalender//tei:div[@type='tag' and .//tei:placeName[@key=$p_id]]
                let $datum := $eintrag//tei:date/@when/data(.)
                return
                <li><a href="../../tageskalender/detail.xql?id={$tageskalender/@xml:id}&amp;datum={$datum}">{replace($datum, '(\d\d\d\d)-(\d\d)-(\d\d)', '$3.$2.$1')}</a></li>
                }</ul></li>
    }
    </ul></div>
    
          
(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($place/tei:placeName[@type='reg']/text())}
        </div>
        <h1>{$place/tei:placeName[@type='reg']/text()}</h1>
        <p>{$place/parent::gruppe/ort[@type='grname']/ortsname}</p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11 box whitebox">
                        <div class="boxInner">
                            <p>{$place/tei:note//text()}</p>
                            {if ($lettersWritingPlaces/ul/li) then ($lettersWritingPlaces) else ()}
                            {if ($lettersMentionPlaces/ul/li) then ($lettersMentionPlaces) else ()}
                            {if ($diariesMentionPlaces/ul/li) then ($diariesMentionPlaces) else ()}
                            {if (edwebRegister:printReferences($place, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($place, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
                        </div>
                    </div> 
                    <div class="grid_5 box whitebox">{if ($place//tei:idno/text()) then (local:getGeoName($place//tei:idno/text())) else ()}</div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output