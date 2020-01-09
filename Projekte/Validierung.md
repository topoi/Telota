
In XML Author weisen rote Balken auf mögliche Fehler im Quellcode hin.    
Schema muss evtl. angepasst werden    

oben die rote "Nadel" und Schema zuweisen. 

Korrekturen über Interface, oder terminal:    
z.B.:   
sudo sed  's@rend=\"underline\"@rendition=\"#u\"@g' Max_Corr.xml | egrep "#u"  

sed -i 's/<hi id="_anchor/<h3 id="_anchor/g' Max_Corr.xml   

oder mit Perl:    
perl -pe 's/\b(_anchor[A-Z,a-z,0-9,\<,\>,\/,\s,\=,\",\_,\],\[]{14})/\1h3/g' Max_Corr.xml    
