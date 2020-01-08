## 1. eXist DB   
### 1.1 eXistDB installieren

https://linuxize.com/post/install-java-on-ubuntu-18-04/

https://exist-db.org/exist/apps/doc/basic-installation

### 1.2. eXistDB de-installieren
#### 1.2.1 in lokalem Installationspfad:   
uninstall.jar   


### 1.2. eXist DB releases
https://github.com/eXist-db/exist/releases

### 1.3. Zugriff auf eXist DB
#### 1.3.1 check targets:
./build.sh -projecthelp -f build/scripts/jarsigner.xml 

#### 1.3.2 run client.sh
setze JAVA_HOME=/usr/lib/jvm/java-\*\*-openjdk    
dann in Installationspfad (z.B. /usr/local/eXistDB:   
bin/client.sh   

### 1.4. Backup der Datenbank:     
bin/backup.sh -u admin -p fischer -b /db/projects/project1/ -d /var/backup/sunday   

### 1.5.Daten hochladen:   
bin/client.sh -u admin -P fischer -m /db/projects/project1/data/ -p /usr/local/eXist-db/conf.xml    


## 2.Oxygen   
https://www.oxygenxml.com/    

Achtung: wichtig welche Java Dist:           
Linux 64-bit (Includes OpenJDK 12.0.1)       

Strg + S: Datei abspeichern   
Strg + Shift + C: Neue Transformation anwenden

### 2.2 LizenzKey Oxygen    
Registration_Name=gordonthegerman @ gmx.de

Company=-

Category=Enterprise

Component=XML-Editor, XSLT-Debugger, Saxon-SA

Version=21

Number_of_Licenses=1

Date=12-16-2019

Trial=31

SGN=MC0CFAUESvLhHpU9AO6m0J/g4Mt9cWWdAhUAlRBQg3zcdeAuyuLwo05C+AgJU/8\=

### 2.3 Neue Aktion (z.B. Latex)    

1. Link https://www.oxygenxml.com/doc/versions/21.1/ug-editor/topics/dita-embedding-latex-equations.html    
2. Aktion:    

```xml
<topic id="testEquation">      
     <body>       
       <p><foreign outputclass="embed-latex">   
          </foreign>    
       </p>   
     </body>    
</topic>    
```


## 3. Ediarum    
### 3.1 Konflikte ediarum mit aktuelleren eXist DB 
https://github.com/ediarum

http://localhost:8080/exist/webdav/db/projects/Goedel_Gordon/data   
http://localhost:8080/exist/apps/ediarum/projects/Goedel_Gordon/data.html?_cache=no#    

Beginner Tutorial
http://telota.bbaw.de/ediarum/manual/setup/#oxygen/tasks/t_projekt_anlegen.html   
(Anmerkungen:   
- Links überarbeiten
- Unter Linux: beim Löschen in der Oxygen Datei darauf achten, dass in den lokalen Verzeichnissen nichts gelöscht wird.

https://www.oxygenxml.com/xml_editor/eXist_support.html#data-source-explorer-view

Ediarum in eXistDB einpflegen:          
https://github.com/ediarum/ediarum.DB/releases         

### 3.2 Jupyter Code für Ediarum        
git clone https://github.com/quantopian/qgrid.git      

