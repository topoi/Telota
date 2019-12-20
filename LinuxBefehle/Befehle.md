##um die eXist DB im bashrc anzumelden   
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/eXist-db/bin   


 

#Manual für Couche DB  
curl -X PUT http://www.ancient-astronomy.org/webapplications/repositoryDB/diaries_all/vers170 -d@pl567A.json -H  "Content-Type: application/json"  

#um eine neue DB zu erstellen  
curl -X PUT http://127.0.0.1:5984/[name]  
#um ein JSON file zu einer Datenbank hinzuzufügen  
curl -X POST http://127.0.0.1:5984/topoi -d @test.json -H "Content-Type: application/json"  
#um alle DB anzuzeigen  
curl -X GET http://127.0.0.1:5984/_all_dbs  
#um eine DB zu löschen  
curl -X DELETE http://127.0.0.1:5984/[name]  
#um alle Daten in einer DB anzuzeigen  
curl -X GET http://127.0.0.1:5984/sundials/_all_docs  
#um den Inhalt anzuzeigen  
curl -X GET http://127.0.0.1:5984/sundials/3509b79d894fd7b51fa4540746003117  
 
 

########################################################################################
#add [ to beginning of a line  
sed -i 's/^/[/' file  
#add ] to the end of a line  
sed -i.bak 's/$/ ]/' file  
#add [ nur zur ersten Zeile  
sed -i '1 s/\[ ,/\[\[/g' *.json  
#add ] nur zur letzten Zeile  
sed -i '$ s/\] ,/\]\]/g' *.json  
#um ^M wegzubekommen  
sed -i 's/^M//g' file  
#Achtung!  
when you type the command, for ^M you type Ctrl-V Ctrl-M  
 
#kopiere alle files mit einer anderen Endung (z.B. *.csv nach *.json)  
for i in *.csv; do cp $i ${i%.csv}.json; done  
#um den digilib Ordner zu ändern  
/var/lib/tomcat6/webapps/digilib.topoi.org/digitallibrary/WEB-INF/digilib-config.xml  
service tomcat6 restart  
#kill firefox process  
killall firefox && nohup firefox > /dev/null  
#record desktop  
recordmydesktop  
strg C  
 
#um auf root das Alias (z.B. cgi-bin) zu ändern  
pico /etc/apache2/sites-available/default  
#ipad  
Sundialspad1   
#an den Anfang etwas machen  
echo "50 $( cat PT-060A.text )" > PT-060A.text
#finde Ubuntu Version
lsb_release -a
#um auf archimedes zu kommen
cd ~/.ssh
ssh 141.20.159.95

#zweites firefox fenster starten  
firefox new-tab <file.html>  
#alles auf einmal in einem file ändern  
sed -i 's/old-word/new-word/g' *.txt  
#um neue mathematica version zu laden  
mount MathematicaVers.iso /media/<file>  
run Installer  
#um tar.gz zu oeffnen  
tar xfvz  
#um Root Rechte zu setzen  
sudo su -  
#um Rechte zu vergeben  
chmod ugo+x  

#um Bilddateien zu komprimieren  
find *.JPG -exec convert -sample 50% {} out/{} \;  
find *.JPG -exec convert -sample 50% {} {} \;
#um Bilder in einem Ordner umzubenennen  
for i in *.JPG; do mv $i ${i%.JPG}_small.JPG; done  
 
