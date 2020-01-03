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
#### in ediarum.meinprojekt.edit.framework sind folgender Source Code für eine Aktion notwendig:    

