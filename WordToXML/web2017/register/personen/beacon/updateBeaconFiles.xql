xquery version "1.0";

import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../../resources/functions.xql";

declare namespace httpclient="http://exist-db.org/xquery/httpclient";

let $login := edweb:login()

let $ausgabe := for $beacon in $edweb:beacons/group/url
                let $response := httpclient:head(xs:anyURI($beacon/text()), true(), (<headers></headers>))
                let $group := $beacon/parent::group/@name/data(.)
                let $position := $beacon/count(preceding-sibling::url) + 1
                return
                    if ($response//@statusCode='200')
                    then (transform:transform(<dummy></dummy>, doc('beacon.xsl'), (<parameters><param name="urlname" value="{$beacon/@name}" /><param name="url" value="{$beacon}"/><param name="group" value="{$group}"/><param name="position" value="{$position}"/></parameters>)))
                    else (update insert <error timestamp="{fn:current-dateTime()}" source="updateBeaconFiles.xql">Beacon {$beacon/text()} not found</error> into doc('errorLog.xml')/errorlog)

let $store := for $beacon in $ausgabe
              let $filename := concat(replace(normalize-space($beacon/@name), ' ', ''), '.xml')
              return
              xmldb:store(concat($edweb:beaconDir, '/files'), $filename, $beacon)

return
<message>Update successful!</message>