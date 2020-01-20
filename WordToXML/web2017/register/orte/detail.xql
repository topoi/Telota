xquery version "3.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../resources/functions.xql";
import module namespace edwebRegister="http://www.bbaw.de/telota/ediarum/web/register" at "../functions.xql";
import module namespace kwic="http://exist-db.org/xquery/kwic";

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
let $place := collection($edweb:dataRegister)//tei:place[@xml:id=concat($p_id, '')]
let $placeName := $place/tei:placeName[@type='reg']/text()

let $redirect := 
        if (not($place))
        then (response:redirect-to(xs:anyURI(concat($edweb:baseURL, '/register/orte/index.xql'))))
        else ()

let $orgsAtPlace :=
    <div class="box whitebox">
    <div class="boxInner hinweise">
    <h3>Einrichtungen in {$placeName}</h3>
    <ul>{
    for $org in collection($edweb:dataRegister)//tei:org[.//tei:settlement/@key=$p_id]
    let $id := $org/@xml:id
    let $name := $org/tei:orgName[@type='reg']
    order by $name
    return    
    <li><a href="../einrichtungen/detail.xql?id={$id}">{$name}</a></li>
    }</ul></div></div>
    
let $personIndexMentioned :=
    <div class="box whitebox">
        <div class="boxInner hinweise">
            <h3>Erwähnt im Personenregister</h3>
            <ul>
                {for $person in collection($edweb:dataRegister)//tei:person[.//tei:placeName/@key=$p_id]
                return
                <li><a href="../personen/detail.xql?id={$person/@xml:id}">{edweb:persName($person/tei:persName[@type='reg'], 'surname')}</a></li>}
            </ul>
        </div>
    </div>
    
    
let $noteAndNames :=
    if ($place/tei:note//text() or edwebRegister:altNames($place)//li) then (
    <div class="box whitebox">
        <div class="boxInner">
                {if ($place/tei:note//text()) then (<p>{$place/tei:note//text()}</p>) else ()}
                {if (edwebRegister:altNames($place)//li) then (edwebRegister:altNames($place)) else ()}
        </div>
    </div>
    ) else ()

let $lettersWritingPlace := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspAction[@type='sent']/tei:placeName[@key=$p_id]]
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        'Schreibort')
    
let $lettersMentionPlace := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspDesc and ((tei:text|.//tei:abstract)//tei:rs[@type='place' and @key=$p_id  and not(ancestor::tei:note[parent::tei:seg])] or (tei:text|.//tei:abstract)//tei:placeName[@key=$p_id and not(ancestor::tei:note[parent::tei:seg])] or .//tei:index[substring(@corresp, 2)=$p_id])]
        order by edweb:defaultOrderBy($brief)
        return
        $brief,
        'Erwähnungen in Briefen')
        
let $lettersCommentsMentionPlace := 
    edwebRegister:viewLetterTable(
        for $brief in collection($edweb:dataLetters)//tei:TEI[.//tei:correspDesc and (.//tei:seg/tei:note//tei:rs[@key=$p_id] or .//tei:seg/tei:note//tei:placeName[@key=$p_id] or tei:text//tei:index[substring(@corresp, 2)=$p_id])]
        order by edweb:defaultOrderBy($brief)
        return
        $brief
    , 'Erwähnungen in Erläuterungen zu Briefen')        


(: ########### HTML-Ausgabe ########### :)
let $header :=  
    <transferContainer>
        <div id="subnavbar">
            {edwebRegister:sectionNav($place/tei:placeName[@type='reg']/text())}
        </div>
        <h1>{$placeName}</h1>
        <p>{$place/parent::gruppe/ort[@type='grname']/ortsname}</p>
    </transferContainer>
                

let $content := 
    <transferContainer>
        <div class="grid_11">
            {if ($noteAndNames//(p|li)) then ($noteAndNames) else ()}
            <div class="box whitebox">
                        <div class="boxInner">
                            {if ($lettersWritingPlace//td) then ($lettersWritingPlace) else ()}
                            {if ($lettersMentionPlace//td) then ($lettersMentionPlace) else ()}
                            {if ($lettersCommentsMentionPlace//td) then ($lettersCommentsMentionPlace) else ()}
                            {if (edwebRegister:printReferences($place, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))//ul/li) then (edwebRegister:printReferences($place, concat($edweb:data, '/Wertelisten/avh_editionen.xml'))) else ()}
                        </div>
                    </div>
                    </div>
                    <div class="grid_5">
                        {if ($place//tei:idno/text()) then (
                            <div class="box whitebox">{local:getGeoName($place//tei:idno/text())}</div>) else ()
                        }
                        {if ($orgsAtPlace//li) then ($orgsAtPlace) else ()}
                        {if ($personIndexMentioned//li) then ($personIndexMentioned) else ()}
                    </div>
     </transferContainer>

let $output := edweb:transformHTML($header, $content, 'register')

return 
$output