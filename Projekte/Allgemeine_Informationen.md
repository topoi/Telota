Hinweise zu Ediarum:    
https://redmine.bbaw.de/projects/ediarum/wiki/Doku-uebersicht#F%C3%BCr-neue-Kolleginnen   

### Neues Projekt anlegen ediarum.basis --> ediarum.BASE    
- **Allgemein**:    
-- Schreibrechte für die Ordner überprüfen!       
-- Daran denken, dass Aktionen im XML-Author die Dateien und Pfade im lokalen File-System modifizieren können!     

- BASE allein funktioniert nicht, daher eine Erweiterung nötig    
- Vorgabe: ediarum.MEINPROJEKT.edit (MEINPROJEKT in Großbuchstaben)       
- Aufpassen beim Stylesheet, wenn die Fehlermeldung /Warnung (unten)        
https://www.oxygenxml.com/doc/versions/21.1/ug-editor/topics/dg-css-stylesheet.html

kommt, dann stylesheet in Textdatei einfügen!     

in BASE sind folgende CSS Styles definiert:   

Standardansicht:  *standard.css*          
Kritischer Text: *text-critical-css*      
Lesetext mit Kommentar:   *text-comments.css*     
Links anzeigen:    *links.css*              

fonts Directory nach ediarum.MEINPROJEKT.edit kopieren(?), wenn das Stylesheet händisch geladen werden muss.    

**WICHTIG**   

man muss die Verknüpfung des doctypes anpassen:   
![alt text]()
