
In XML Author weisen rote Balken auf mögliche Fehler im Quellcode hin.    
Schema muss evtl. angepasst werden    

oben die rote "Nadel" und Schema zuweisen. 

Korrekturen über Interface, oder terminal:    
z.B.:   
sudo sed  's@rend=\"underline\"@rendition=\"#u\"@g' Max_Corr.xml | egrep "#u"  

sed  's/<hi id=\"_anchor.*<\/hi>/<h3 id=\"_anchor.*<\/h3>/g' Max\ III.xml | egrep _anchor


oder mit Perl:    
perl -pe 's/\b([A-Z,a-z,0-9,<,>,\/,\s,\=,\",\_]{5}_anchor[A-Z,a-z,0-9,<,>,\/,\s,\=,\",\_]{8})/\2h3/g' text.txt | egrep h3   
