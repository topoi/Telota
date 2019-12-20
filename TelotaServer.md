## Verfügbare Server:          

telotawebdev    
telotawebpubli    
xmldev      
xmledit   
xmlpublic   

### Kommado in der Konsole (Achtung /root/.ssh!!)
ssh git.bbaw.de   
cd /git   

ssh gfischer@XXX.bbaw.de    

*OLD: "ssh -i .ssh/bbaw_hosts gfischer@telotawebdev.bbaw.de"*       

https://redmine.bbaw.de/projects/team/wiki    

### mit dem Telota POM Server verbinden   
mount -t cifs //192.168.4.15/pom /home/gordon/pom/ -o vers=1.0,username=gordon,sec=ntlm
