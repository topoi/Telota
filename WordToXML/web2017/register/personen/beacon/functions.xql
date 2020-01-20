xquery version "3.0";

module namespace ediarumBeacon="http://www.bbaw.de/telota/ediarum/beacon";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../../../resources/functions.xql";

declare namespace beacon = "http://purl.org/net/beacon";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function ediarumBeacon:beaconLinks($normid) {
    let $login := edweb:login()

    let $authorityPrefix := 
        for $x in map:keys($edweb:authorities)
        return
        if (matches($normid, map:get($edweb:authorities, $x)))
        then (map:get($edweb:authorities, $x))
        else ()
    
    let $idWithoutPrefix :=
        substring-after($normid, $authorityPrefix)

    (: let $cacheAvailable :=
        if (doc('cache/beacon_cache.xml')/items/ul/@data-id/data(.)=$normid)
        then (true())
        else (false()) :)

    let $links :=   
              <ul data-id="{$normid}">
                   {for $link in collection($edweb:beaconDir)//beacon:beacon[@prefix=$authorityPrefix and @name!="Wikipedia"]/beacon:link[ft:query(@source, $idWithoutPrefix)]
                    let $name := $link/ancestor::beacon:beacon/data(@name)
                    let $url := concat(substring-before($link/ancestor::beacon:beacon/@target, '{'), $link/@source, substring-after($link/ancestor::beacon:beacon/@target, '}'))
                    let $group := $link/ancestor::beacon:beacon/data(@group)
                    let $position := $link/ancestor::beacon:beacon/data(@position)
                    order by $group, $position
                    return
                    <li><a href="{$url}">{$name}</a></li>
                    }
                </ul>
              
    (:let $createCache :=    
    if (not($cacheAvailable))
    then (update insert $links into doc("cache/beacon_cache.xml")/items)
    else () :)

return
if ($links//li)
then ($links)
else ('Keine externen Angebote gefunden.')
};