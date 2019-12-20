Stand: 18.12.2019   


### Tutorial   
http://telota.bbaw.de/ediarum/manual/setup/#ediarum_uebergreifend/concepts/c_ueberblick_setupDoku.html    

**Hinweis:** ediarum nur bis eXist DB 4.4 getestet (neuere eXist DB ( > 5) nicht kompatibel mit ediarum.

**Allgemein:** Eventuell wäre ein Schaubild der Verzahnung der 5 Komponenten:    

Oxygen(Author,Editor)      
eXistDB   
Ediarum        
Author        
Entwickler         

hilfreich. 

Im Tutorial bis Oxygen mit der Datenbank verbinden ist alles up to date und super erklärt (lokale Installation, XML Author 21.1 wurde verwendet).   



### Oxygen mit der Datenbank verbinden:     
evtl. bei WebDAV noch mal klar machen, dass lokal der Name "ediarum" nicht im Pfad auftaucht(?)   
ansonsten bis zum Ende wieder schön erklärt.

### ediarum-Frameworks einrichten:  
hier trat das Phänomen auf (zumindest unter Linux), dass wenn man die unter **Punkt 7** dargestellten Dokumenttypen wieder aus der 
Datenbank löscht, dass die Daten auch lokal (physisch) modifiziert werden   
z.B. entfernen von ediarum.BASE.edit führt dazu, dass lokal im Ordner *ediarum.BASE.edit* die Datei *ediarum.BASE.framework*
gelöscht wird(?!?)    
Unter **Punkt 8** noch mal klar machen, dass man nicht auf ediarum.BASE.edit doppelklickt, sondern dieses Feld auswählt und dann auf erweitern geht (sonst überschreibt man ediarum.BASE.edit....)    

### Projekt in Oxygen anlegen:    
In **Punkt 5** aktuellere Beispiele für die Angabe des Wertes (insbesondere bei *${ediarum_project_domain}* und 
*${ediarum_project_domain}*. Auch noch mal Unterschied zwischen lokaler Installation und serverbasierter Installation)


## Quellcode für eine eingefügte Benutzer Aktion in der Symbolleiste

```xml
<String>authorExtensionDescriptor/actionDescriptors</String>
 		</field>
 		<field name="index">
 		  <Integer>163</Integer>
 		</field>
 		<field name="value">
 		  <action>
 		    <field name="id">
 		      <String>Goedel_Gordon_AddError</String>
 		    </field>
 		    <field name="name">
 		      <String>Fehler</String>
 		    </field>
 		    <field name="description">
 		      <String>Füge die Bermerkung "FEHLER" hinzu</String>
 		    </field>
 		    <field name="largeIconPath">
 		      <String>file:/home/gordon/Bilder/Latex.png</String>
 		    </field>
 		    <field name="smallIconPath">
 		      <String>file:/home/gordon/Bilder/Latex.png</String>
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
 			    <String>ancestor-or-self::text</String>
 			  </field>
 			  <field name="argValues">
 			    <serializableOrderedMap>
 			      <entry>
 				<String>text</String>
 				<String>FEHLER</String>
 			      </entry>
 			    </serializableOrderedMap>
 			  </field>
 			  <field name="operationID">
 			    <String>ro.sync.ecss.extensions.commons.operations.InsertOrReplaceTextOperation</String>
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
 	      <poPatch>
 		<field name="fieldPath">
 		</field>
 	      </toolbarItem>
 	    </field>
 	    <field name="patchHandling">
 	      <String>addIndex</String>
 	    </field>
 	    <field name="anchor">
 	      <null/>
 	    </field>
 	  </poPatch>
 	  <poPatch>
 	    <field name="fieldPath">
 	      <String>authorExtensionDescriptor/toolbarDescriptor/toolbarEntriesDescriptorList</String>
 	    </field>
 	    <field name="index">
 	      <Integer>10</Integer>
 	    </field>
 	    <field name="value">
 	      <toolbarItem>
 		<field name="actionID">
 		  <String>Goedel_Gordon_AddError</String>

```


