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

    let $mapID := substring-after($id, 'http://www.geonames.org/') 

    let $map :=
    <div>
        <div id="map_{$mapID}" style="height: 300px;"></div>
        <script>
		var map = L.map('map_{$mapID}').setView([{$lat}, {$lng}], 15);
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
    if ($lat and $lng)
    then ($map)
    else (element p {'[ID wurde in Normdatei nicht gefunden]'})
};

let $login := edweb:login()

let $p_id := request:get-parameter("id", ())
let $org := collection($edweb:dataRegister)//tei:org[@xml:id=concat($p_id, '')]

let $redirect := 
        if (not($org))
        then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/register/einrichtungen/index.xql'))))
        else ()
        
let $locations := 
    if ($org/tei:location)
    then (
        for $location in $org/tei:location
        let $settlement := <a href="../orte/detail.xql?id={$location//tei:settlement/@key}">{$location//tei:settlement/text()}</a>
        let $note := $location//tei:note/text()
        let $date := if ($location/@from/data(.) or $location/@to/data(.)) then (<h4>{$location/@from/data(.)||'&#x2013;'||$location/@to/data(.)}</h4>) else ()
        return
        <div class="location">
            {$date}
            <p>
                {if ($note) 
                then ($settlement||', '||$note)
                else ($settlement)}
            </p>
            {if ($location//tei:idno/text()) then (local:getGeoName($location//tei:idno/text())) else ()}
            {(: Refs auf bestimmte Orte einer Einrichtung :) if (edwebRegister:printReferences($location/tei:address, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($location/tei:address, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
        </div>
    
    ) else ()

let $lettersWrittenBy := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspDesc//tei:orgName[@key=$p_id]]
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        'Korrespondenz')
    
let $lettersMentionPlace := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspDesc and (tei:text//tei:orgName[@key=$p_id and not(ancestor::tei:note[parent::tei:seg])] or tei:text//tei:index[substring(@corresp, 2)=$p_id])]
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        'Erwähnungen in Briefen')
        
let $lettersCommentsMentionPlace := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspDesc and (.//tei:seg/tei:note//tei:orgName[@key=$p_id] or tei:text//tei:index[substring(@corresp, 2)=$p_id])]
        order by edweb:defaultOrderBy($brief)
        return
        $brief
    , 'Erwähnungen in Erläuterungen zu Briefen')        

let $personIndexMentioned :=
    <div class="box whitebox">
        <div class="boxInner hinweise">
            <h3>Erwähnt im Personenregister</h3>
            <ul>
                {for $person in collection($edweb:dataRegister)//tei:person[.//tei:orgName/@key=$p_id]
                return
                <li><a href="../personen/detail.xql?id={$person/@xml:id}">{edweb:persName($person/tei:persName[@type='reg'], 'surname')}</a></li>}
            </ul>
        </div>
    </div>
          
(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($org/tei:orgName[@type='reg']/text())}
        </div>
        <h1>{$org/tei:orgName[@type='reg']/text()}</h1>
        <p>{$org/tei:location[1]//tei:settlement/text()}</p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11 box whitebox">
                        <div class="boxInner">
                            <p>{transform:transform($org/tei:desc, doc('../register.xsl'), ())}</p>
                            {$locations}
                            {if ($lettersWrittenBy//td) then ($lettersWrittenBy) else ()}
                            {if ($lettersMentionPlace//td) then ($lettersMentionPlace) else ()}
                            {if ($lettersCommentsMentionPlace//td) then ($lettersCommentsMentionPlace) else ()}
                            {if (edwebRegister:printReferences($org, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($org, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
                        </div>
                    </div> 
                    <div class="grid_5">
                        {if ($personIndexMentioned//li) then ($personIndexMentioned) else ()}
                    </div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output