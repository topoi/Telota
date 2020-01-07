Hinweise zu Ediarum:    
https://redmine.bbaw.de/projects/ediarum/wiki/Doku-uebersicht#F%C3%BCr-neue-Kolleginnen   

### Neues Projekt anlegen ediarum.basis --> ediarum.BASE    
- **Allgemein**:    
-- Schreibrechte für die Ordner überprüfen!       
-- Daran denken, dass Aktionen im XML-Author die Dateien und Pfade im lokalen File-System modifizieren können!     

- BASE allein funktioniert nicht, daher eine Erweiterung nötig    
- Vorgabe: ediarum.MEINPROJEKT.edit (MEINPROJEKT in Großbuchstaben)       

kommt, dann stylesheet in Textdatei einfügen!     

in BASE sind folgende CSS Styles definiert:   

Standardansicht:  *standard.css*          
Kritischer Text: *text-critical-css*      
Lesetext mit Kommentar:   *text-comments.css*     
Links anzeigen:    *links.css*              

fonts Directory nach ediarum.MEINPROJEKT.edit kopieren(?), wenn das Stylesheet händisch geladen werden muss.    

**WICHTIG**   
- Aufpassen beim Stylesheet, wenn die Fehlermeldung /Warnung        

![alt text](https://github.com/topoi/Telota/blob/master/Projekte/author_no_css.png)

kommt, dann muss man die Verknüpfung des doctypes anpassen: (wenn das Project z.B. eine Lecture ist, dann muss in Verknüpfungen der doctype lecture definiert werden:   
![alt text](https://github.com/topoi/Telota/blob/master/Projekte/Bildschirmfoto%20von%202020-01-03%2013-57-40.png)    

### Neue Aktion einfügen    
um eine neue Aktion anzulegen, siehe:		
https://docs.google.com/document/d/18XK17qWvcWheQD9H0zhWYoQ2y3QnQcWNBoCS2QJh0Y0/edit#heading=h.201y1uizsay3		

auch im css einfügen!!		
Neue Aktionen in der css Datei goedel.css einbinden.

in ediarum.meinprojekt.edit.framework sind folgender Source Code für eine Aktion notwendig:    

```xml
<poPatch>
<field name="fieldPath">
    <String>authorExtensionDescriptor/actionDescriptors</String>
</field>
<field name="index">
     <Integer>166</Integer>
</field>
<field name="value">

	<action>
	    <field name="id">
		<String>goedel_hi[Langschrift]</String>
	    </field>
	    <field name="name">
		<String>LS</String>
	    </field>
	    <field name="description">
		<String>Markieren von Langschrift (im Gegegensatz zu Stenographie)</String>
	    </field>
	    <field name="largeIconPath">
		<String></String>
	    </field>
	    <field name="smallIconPath">
		<String></String>
	    </field>
	    <field name="accessKey">
		<String></String>
	    </field>
	    <field name="accelerator">
		<null/>
	    </field>
	    <field name="actionModes">
		<actionMode-array>
			<actionMode>
			    <field name="xpathCondition">
				<String></String>
			   </field>
			   <field name="argValues">
				<serializableOrderedMap>
					<entry>
						<String>fragment</String>
						<String>&lt;hi rendition="#normal" xmlns="http://www.tei-c.org/ns/1.0">&lt;/hi></String>
					</entry>
				</serializableOrderedMap>
		           </field>
			   <field name="operationID">
				<String>ro.sync.ecss.extensions.commons.operations.SurroundWithFragmentOperation</String>
		           </field>
			</actionMode>
		</actionMode-array>
	     </field>
	     <field name="enabledInReadOnlyContext">
			<Boolean>false</Boolean>
	     </field>
	</action>
</field>
<field name="patchHandling">
	<String>addIndex</String>
</field>
<field name="anchor">
	<null/>
</field>
</poPatch>



```
