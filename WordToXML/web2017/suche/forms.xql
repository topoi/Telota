xquery version "3.0";

module namespace edwebSearch="http://www.bbaw.de/telota/ediarum/web/search";
import module namespace edweb="http://www.bbaw.de/telota/ediarum/web" at "../resources/functions.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace transform = "http://exist-db.org/xquery/transform";

declare function edwebSearch:formVorlesungssuche($param_q_head, $param_q_text, $param_q_note, $q_vorlesung, $q_vorlesungstyp){ 
    <form id="search" action="ergebnis.xql" accept-charset="utf-8">
        <label for="q_head">Überschriften</label>
            <input type="text" name="q_head" value="{$param_q_head}" />            
        <label for="q_text">Text</label>
            <input type="text" name="q_text" value="{$param_q_text}" />
        <label for="q_note">Erläuterungen</label>
            <input type="text" name="q_note" value="{$param_q_note}" />
        <label for="vorlesung">Vorlesung</label>
            <select name="vorlesung">
                <option value="">alle</option>
                {if ($q_vorlesung='ethik')
                then (<option  selected="1" value="ethik">Ethik</option>)
                else (<option value="ethik">Ethik</option>),
                if ($q_vorlesung='praktische_theologie')
                then (<option selected="1" value="praktische_theologie">Praktische Theologie</option>)
                else (<option value="praktische_theologie">Praktische Theologie</option>)
                }
            </select>
        <label for="vorlesungstyp">Typ</label>
            <fieldset class="checkboxes">
                <label>{
                    if (matches($q_vorlesungstyp, 'Manuskript')) 
                    then (<input checked="checked" type="checkbox" name="vorlesungstyp" value="Manuskript" />)
                    else (<input type="checkbox" name="vorlesungstyp" value="Manuskript" />)
                    }Manuskripte</label>
                <label>{
                    if (matches($q_vorlesungstyp, 'Nachschrift')) 
                    then (<input checked="checked" type="checkbox" name="vorlesungstyp" value="Nachschrift" />)
                    else (<input type="checkbox" name="vorlesungstyp" value="Nachschrift" />)
                    }Nachschriften</label>
                <label>{
                    if (matches($q_vorlesungstyp, 'Notizen')) 
                    then (<input checked="checked" type="checkbox" name="vorlesungstyp" value="Notizen" />)
                    else (<input type="checkbox" name="vorlesungstyp" value="Notizen" />)
                    }Notizen</label>
            </fieldset>
            <hr class="clearer" />
            <input type="hidden" name="doctype" value="vorlesungen" />
            <input class="right submit" type="submit" value="Absenden"/>
    </form>                     
};

declare function edwebSearch:formBriefsuche($param_q_text, $param_q_title, $param_q_abstract, $param_q_note, $q_korrespondent, $isoStartDate, $isoEndDate, $param_q_zb){
    let $briefordner := '/db/data/Briefe'
    let $registerdateiPersonen := '/db/apps/ediarum/data_copy/personen_copy.xml'
    let $personenInBriefen := collection($briefordner)//tei:TEI[.//tei:creation/tei:persName]
    let $personenInBriefenIDs := $personenInBriefen//tei:creation/tei:persName/@key/data(.)
    let $registerPersonen := doc($registerdateiPersonen)//person
    let $correspondents :=
        (collection($edweb:dataLetters)//tei:TEI[.//tei:correspAction/tei:persName]//tei:correspAction/tei:persName/@key/data(.))
    
    let $form :=
    <form id="search" action="ergebnis.xql" accept-charset="utf-8">
        <label for="q_text">Text</label>
            <input type="text" name="q_text" value="{$param_q_text}" />
        <label for="q_title">Titel</label>
            <input type="text" name="q_title" value="{$param_q_title}" />
        <label for="q_note">Erläuterungen</label>
            <input type="text" name="q_note" value="{$param_q_note}" />
        <label for="q_note">Zeugenbeschreibungen</label>
            <input type="text" name="q_zb" value="{$param_q_zb}" />
        <label for="korrespondent">Korrespondent</label>
            <select name="korrespondent"><option value="">alle</option> 
            {
            for $person in collection($edweb:dataRegister)//tei:person[@xml:id/data(.)=$correspondents and @xml:id/data(.)!='prov_uhm_svf_ks']
            let $name := edweb:persName($person/tei:persName[@type='reg'], 'surname'),
                $id := $person/@xml:id/data(.)
            order by $name
            return 
               if ($id=$q_korrespondent) 
               then (<option selected="1" value="{$id}">{$name}</option>)
               else (<option value="{$id}">{$name}</option>)
         }
            </select>
        <label for="q_startDate">Von (Datum)</label>
            <input type="text" name="startDate" value="{$isoStartDate}" placeholder="Datum im Format JJJJ-MM-TT" />
        <label for="q_text">Bis (Datum)</label>
            <input type="text" name="endDate" value="{$isoEndDate}" placeholder="Datum im Format JJJJ-MM-TT" />
            <input type="hidden" name="doctype" value="briefe" />
            <input class="submit" type="submit" value="Absenden"/>
    </form>
    
    return
    $form
};

declare function edwebSearch:formTageskalendersuche($param_q_text, $param_q_note, $q_tageskalender, $q_tageskalendertyp){
    let $tageskalenderordner := '/db/data/Tageskalender'
    
    let $form :=
    <form id="search" action="ergebnis.xql" accept-charset="utf-8">
        <label for="q_text">Text</label>
            <input type="text" name="q_text" value="{$param_q_text}" />
        <label for="q_note">Erläuterungen</label>
            <input type="text" name="q_note" value="{$param_q_note}"/>
        <label for="tageskalender">Tageskalender</label>
            <select name="tageskalender"><option value="">alle</option> 
            {
               for $doc in collection($tageskalenderordner)//tei:TEI
               order by $doc//tei:titleStmt//text()
               return 
               if ($doc/@xml:id=$q_tageskalender)
               then (<option selected="1" value="{$doc/@xml:id}">{$doc//tei:titleStmt//text()}</option>)
               else (<option value="{$doc/@xml:id}">{$doc//tei:titleStmt//text()}</option>)
            }
            </select>
        <label for="tageskalendertyp">Teil</label>
            <select name="tageskalendertyp">
                <option value="">alle</option>
                {if ($q_tageskalendertyp='kalender') 
                then (<option value="kalender">Kalender</option>)
                else (<option value="kalender">Kalender</option>),
                if ($q_tageskalendertyp='anhang')
                then (<option selected="1" value="anhang">Anhang</option>)
                else (<option value="anhang">Anhang</option>)}
            </select>
            <input type="hidden" name="doctype" value="tageskalender" />
            <input class="submit" type="submit" value="Absenden"/>
    </form>
    
    return
    $form
};

declare function edwebSearch:formRegistersuche($param_q_text) {
    <form id="search" action="../suche/ergebnisRegistersuche.xql" accept-charset="utf-8">
        <label for="q_text">Suchbegriff </label>
            <input type="text" name="q_text" value="{$param_q_text}" placeholder="Suchbegriff eingeben"/>
        <label for="typ">Suchen im Register </label>
            <select name="typ" size="1">
                <option value="1">Personen</option>
                <option value="2">Orte</option>
                <option value="3">Werke</option>
            </select>
            <input class="submit" type="submit" value="Absenden"/>
    </form>                        
};

declare function edwebSearch:formZeitsuche($datumUnformatiert){
    <form action="datumssuche.xql" accept-charset="utf-8">
        <input id="datum" name="datum" />
        <input type="submit" value="Absenden"/>
        <script charset="utf-8" type="text/javascript">
              var k4 = new Kalendae.Input('datum', &#123;
                  format: 'YYYY-MM-DD',
                  months:1,
                  mode: 'single',
                  viewStartDate: '1808-01-01'
              &#125;);
       </script>
    </form>
};