### ExistDB Backup mit Github

```xml
<job type="system" class="org.exist.storage.ConsistencyCheckTask" cron-trigger="0 17 * * * ?">      
      <!-- the output directory. paths are relative to the data dir -->         
      <parameter name="output" value="export"/>        
      <parameter name="zip" value="no"/>          
      <parameter name="backup" value="yes"/>      
      <parameter name="incremental" value="yes"/>      
      <parameter name="incremental-check" value="no"/>      
</job>         
```
Script zu bestimmter Zeit ausführen (cron):
https://askubuntu.com/questions/2368/how-do-i-set-up-a-cron-job

push2git.sh:        

rm -rf backupfiles       
latest_file=$(ls -t | head -n 1)        
scp -rp "$latest_file" backupfiles      
git add backupfiles      
git commit -m "Backup from $(date)"          
git push       

ssh-keygen -t rsa -b 4096 -C "gfischer@bbaw.de"                
cd /root/.ssh/id_rsa.pub      
less /root/.ssh/id_rsa.pub         
eval "$(ssh-agent -s)"        
ssh-add ~/.ssh/id_rsa         
ssh -T git@github.com         

https://help.github.com/en/github/authenticating-to-github/testing-your-ssh-connection

## Git Projekt für ediarum bearbeiten:       
https://redmine.bbaw.de/projects/ediarum/wiki/Projektentwicklung  

## 1. eXist DB   
### 1.1 eXistDB installieren
**Wichtig**  
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk/bin 

(evtl. export JAVA_HOME=/usr/lib/jvm/java-8-openjdk/jre)

export PATH=$PATH:/usr/lib/jvm/java-8-openjdk    
https://linuxize.com/post/install-java-on-ubuntu-18-04/

https://exist-db.org/exist/apps/doc/basic-installation

### 1.2. eXistDB de-installieren
#### lokal auf Arbeitsrechner (in eXistDB Ordner):          
java -jar eXist-db-setup-4.4.0.jar

#### 1.2.1 in lokalem Installationspfad:   
uninstall.jar   


### error messages eXist DB
/usr/local/eXist-db/webapp/WEB-INF/logs

### 1.2. eXist DB releases
https://github.com/eXist-db/exist/releases

### 1.3. Zugriff auf eXist DB
#### 1.3.1 check targets:
./build.sh -projecthelp -f build/scripts/jarsigner.xml 

#### 1.3.2 run client.sh
setze JAVA_HOME=/usr/lib/jvm/java-\*\*-openjdk    
dann in Installationspfad (z.B. /usr/local/eXistDB:   
bin/client.sh   

#### 1.3.3 character encoding
-Dfile.encoding=UTF-8

### 1.4. Backup der Datenbank:     
bin/backup.sh -u admin -p fischer -b /db/projects/project1/ -d /var/backup/sunday         
z.B.:          
sudo /usr/local/eXist-db/bin/backup.sh -u admin -p telota -b /db/projects/goedel/data -d /var/backup/         

### 1.5.Daten hochladen:   
in /home/gordon/cluster_preussen/exist/exist  
sudo /usr/local/eXist-db431/bin/client.sh -u admin -P fischer -d -m /db/projects/avhr/web -p web  
oder   
sudo /usr/local/eXist-db431/bin/client.sh -u admin -P fischer -d -m /db/projects/avhr/web -p /home/gordon/cluster_preussen/exist/exist/web  

sudo /usr/local/eXist-db/bin/client.sh -u admin -P fischer -d -m /db/projects/ -p /home/gordon/cluster_preussen/xmledit_backup/full20200403-0712/db/projects/avhr/





bin/client.sh -u admin -P fischer -m /db/projects/project1/data/ -p /usr/local/eXist-db/conf.xml         
     z.B.:                
sudo /usr/local/eXist-db/bin/client.sh -u admin -P telota -m /db/projects/goedel/data/Korrektur -p Max III.xml          

upload folder (-d):              
bin/client.sh -d -m /db/movies -p /home/exist/xml/movies         
/usr/local/eXist-db/bin/client.sh -u admin -P telota -d -m /db/projects/xmledit_goedel/data/web2020 -p web2017

### 1.6.Datenspeicher  
/usr/local/eXist-db/webapp/WEB-INF/data/fs/db/projects  

### existance installieren:        
https://github.com/telota/existance          

sudo -H pip3 install texttable         falls "ModuleNotFoundError: No module named 'texttable'"          

Einschub: nginx installieren:           
sudo apt update          
sudo apt install nginx        
sudo ufw app list        
sudo ufw allow 'Nginx HTTP'        
sudo ufw status          
systemctl status apache2.service        
systemctl stop apache2.service          
sudo ufw status          
sudo ufw allow 'Nginx HTTP'        
sudo ufw status          
sudo ufw enable          
sudo ufw default deny         
sudo ufw status          


## 2.Oxygen   
https://www.oxygenxml.com/    

Achtun: für xql den Dateityp ändern!! (in Optionen -> Dateityp)       

Achtung: wichtig welche Java Dist:           
Linux 64-bit (Includes OpenJDK 12.0.1)    

install Java on Arch-Linux:   
https://www.tecmint.com/install-java-on-arch-linux/         

check and switch java Versions on Arch-Linux:         
https://wiki.archlinux.org/index.php/Java#List_compatible_Java_environments_installed           

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
### FAQ:       
https://redmine.bbaw.de/projects/ediarum/wiki/Developer-FAQ      

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

Beispiellink für ein Projekt:      
http://localhost:8080/exist/webdav/db/projects/goede

Um ein Projekt aus dem git zu klonen: (normaler user):      
git clone gfischer@git.bbaw.de:/git/ediarum.MEGA.edit.git

## Schemata bearbeiten:  
das Schema wird in .rng abgespeichert und definiert eine Teilmenge des TEI Schemas.             
https://www.w3.org/Math/RelaxNG/

Customize TEI schemata:       
https://roma2.tei-c.org/      


### MathFlow einbinden: (für MathML):        

https://www.oxygenxml.com/oxygen_sdk/download.html          
https://www.oxygenxml.com/doc/versions/21.1/ug-editor/topics/mathml_support_mathflow.html      

## Druckansicht erstellen:  

in /path-to-project/web/:          
den Pfad in print.xql anpassen.         

in /path-to-project/web/resources/xslt/transcription.xsl                   
die Aktion einbinden:      
```xml
 <xsl:template match="tei:hi[@rendition='#u']" mode="#all">
        <span class="unterstrichen">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
```

in /path-to-project/web/resources/css/transkription.css          
den Stylesheet definieren:         

```xml
span.unterstrichen {
    text-decoration: underline;
}
```
bei der Angabe von relativen Pfaden in transcription.xql ergibt sich folgendes Problem:        
http://exist.2174344.n4.nabble.com/XSLT-processing-failing-in-trunk-build-td4659645.html       

https://github.com/eXist-db/exist/releases

### Liste mit Unicode characters:       
https://www.codetable.net/unicodecharacters?page=14      

alpha-nummerische Symbole:         
https://de.wikipedia.org/wiki/Unicodeblock_Mathematische_alphanumerische_Symbole          

Character Search:        
https://www.fileformat.info/info/unicode/char/search.htm

Find Unicode Character:       
https://shapecatcher.com/

## Ediarum Anpassung mit eXist DB 5.2.0:     
https://www.oueta.com/linux/extract-pkg-and-mpkg-files-with-xar-on-linux/       

xar file bearbeiten:                 
7za e ediarum.db-3.2.5.445.xar modules/config.xqm   
7za a ediarum.db-3.2.5.445.xar modules/config.xqm

namespaces:         
https://www.w3.org/TR/2014/WD-xpath-functions-31-20140424/xpath-functions-31-diff.html#func-map-new  
Änderungen 4.4. -> 5.2:       
https://github.com/eXist-db/exist/issues/2626#issuecomment-480319383       
