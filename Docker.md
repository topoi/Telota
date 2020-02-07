## Installation und Anwendung von Docker

https://www.youtube.com/watch?v=fqMOX6JJhGo                 

https://docs.docker.com/install/linux/docker-ce/ubuntu/                 
https://hub.docker.com/             
https://kodekloud.com/p/docker-labs             

ausführlicher:                      
https://kodekloud.com/courses/docker-for-the-absolute-beginner-hands-on/lectures/4554686       

Notebooks im Dockerfile:                        
https://u.group/thinking/how-to-put-jupyter-notebooks-in-a-dockerfile/

eXistDB im Dockerfile:              
https://hub.docker.com/r/existdb/existdb/tags/              
docker run -it -d -p 8080:8080 -p 8443:8443 --name exist existdb/existdb:5.2.0                                   
Achtung: nginx muss laufen, nicht apache2!!                 
systemctl start nginx.service                                           
systemctl stop apache2.service                  

Kommandos:                            

docker ps               
docker run docker/whalesay cowsay Hello-World!              
docker ps -a            
docker rm hopeful_buck              
docker images                       
docker rmi nginx                    
docker run nginx                    
docker pull nginx                               

stoppe und lösche alle Container:               
docker stop $(docker ps -a -q)                  
docker rm $(docker ps -a -q)                    
Ein Container existiert nur so lange wie der Prozeß im Container dauert!                        
daher zeigt docker ps nichts an, aber docker ps -a                      

Kommando in Container ausführen:                

docker run **-it** ......


Port Mapping:           
docker run host:container....                   

### Daten sichern:                      
wenn der Container gelöscht wird, dann sind auch die Daten weg! Hilfe:              
docker run -v /path-to-local-folder:path-container <image>                          
            --> die Directory wird in lokalen Pfad gemounted

### genaue Untersuchung des Containers:             
docker inspect <name,id>                        
docker logs <name,id>               

## Docker Environment Variablen                 
python script app.py welches Hintergrundfarbe ändert:                   
color = os.environ.get('APP_COLOR') -->                     
export APP_COLOR=blue; python app.py    
app.py --> Docker Image: webapp-color                 
**docker run -e APP_COLOR=blue webapp-color**              

## Create own image
**Dockerfile**: Instruction Argument
alle Dockerfiles müssen mit *FROM* beginnen z.B. FROM Ubuntu (also von einem anderen Image)                 

erzeuge Image:                               
docker build -t my-first-image .                

**WICHTIG!**    
im Ordner, in welchem sich das Docker-Image befindet ausprobieren!
Am besten ein leeres File, weil sonst der Inhalt des gesamten Ordners als Image erzeugt wird          

### Beispiel für ein Image, welches ein Python Script startet                       

starte mit vorhandenen Image (ubuntu)                       
um den Container laufen zu lassen, wird die bash gestartet und die Parameter -it hinzugefügt um im Container Befehle                
ausführen zu können:                
docker run -it ubuntu bash
root@123:/#   apt-get update                    
root@123:/#   apt-get install -y python                     
root@123:/#   apt-get install -y python-pip
root@123:/#   pip install flask
root@123:/#

https://linuxconfig.org/how-to-build-a-docker-image-using-a-dockerfile              

## Docker Compose:                  
docker run -d --name=redis redis                
docker run -d --name=db postgres

docker pull docker/example-voting-app-vote                  
docker run -d --name=vote -p 5000:80 *--link redis:redis* docker/example-voting-app-vote                 

docker pull h0tbird/result-app                  
docker run -d --name=result -p 5001:80 *--link db:db* result-app                       

docker pull dockersamples/worker                
docker run -d --name=worker *--link db:db --link redis:redis*  dockersamples/worker:latest                 

*--link X:Y* nicht mehr Standard (wird abgeschafft!  --> Lösung Docker Swarm und Networking)                                    

docker compose file (docker-compose.yml):

```yml
redis:
 image: redis
db:
 image: postgres
vote:
 image: docker/example-voting-app-vote
 ports:
  - 5000:80
 links:
    - redis
result:
 image: h0tbird/result-app
 ports:
  - 5001:80
 links:
  - db
worker:
 image: dockersamples/worker
 links:
  - redis
  - db
```

apt  install docker-compose
docker-compose up

alernativ 

```yml
build: ./vote/example-voting-app/vote
```
anstelle von 

```yml
build: ./vote/example-voting-app/vote
```

docker compose versions 

```yml
version: 2
services:
   redis:
      image: redis
      
      networks:
        - back-end
   db:
      image: postgres
      networks:
        - back-end
   vote:
      image: voting-app
      networks:
         - front-end
         - back-end
  result:
      image: result
      networks:
         - front-end
         - back-end
```


### Install docker linux:       
*apt install docker.io*       
*systemctl start docker*   
*systemctl enable docker*                       

checken ob docker läuft:                        
*systemctl status docker*                       

eventuell user zu Gruppe hinzufügen:    
*sudo usermod -aG docker $USER*                 
(BTW, adduser in ArchLinux nicht vorhanden, daher: *sudo useradd -m -G docker -s /bin/bash gordon*)                                           

Testen, ob man Docker ohne root passwort ausführen kann:                
*sudo usermod -aG docker $USER*                 

*"If you initially ran Docker CLI commands using sudo before adding your user to the docker group, you may see the following                       error, which indicates that your ~/.docker/ directory was created with incorrect permissions due to the sudo commands."*             

*WARNING: Error loading config file: /home/user/.docker/config.json - *             
*stat /home/user/.docker/config.json: permission denied *                

wichtig: docker wird nicht als root ausgeführt:             
*"The Docker daemon binds to a Unix socket instead of a TCP port. By default that Unix socket is owned by the user root and  other users can only access it using sudo. The Docker daemon always runs as the root user.*

*If you don’t want to preface the docker command with sudo, create a Unix group called docker and add users to it. When the   Docker daemon starts, it creates a Unix socket accessible by members of the docker group."*  


# Jupyter               
https://hub.docker.com/u/jupyter/   


### Jupyter-Hub Installation   

remote server:                      
https://github.com/jupyterhub/jupyterhub/wiki/Installation-of-Jupyterhub-on-remote-server

https://jupyterhub.readthedocs.io/en/stable/installation-basics.html    

https://mybinder.org/

**wichtig: Python > 3.3:**     
*apt-get -y install python3-pip*    
*python3 -m pip install jupyterhub*

wenn bei jupyter -h Fehler kommt (ERROR:asyncio:Task exception was never retrieved):    

*apt-get install npm*   
*pip3 install git+https://github.com/jupyterhub/jupyterhub.git@master* 

proxy installieren:   
*npm install -g configurable-http-proxy*

vor anmelden:   
*python3 -m pip install notebook*

### docker:   
Liste mit Kommandozeilenbefehlen:   
https://docs.docker.com/engine/reference/commandline/docker/        
Port überprüfen:    
*nmap -p 8000 localhost*    
*nmap -F 192.168.124.214*      

wenn nichts mehr geht:      
*lsof -i -P -n | grep 8000*       
*kill <process id>*
            
Container erstellen:                
*docker run -p 8000:8000 -d --name jupyterhub jupyterhub/jupyterhub jupyterhub*                 
wenn Fehler kommt:      
Error starting userland proxy: listen tcp 0.0.0.0:8000: bind: address already in use        
dann:           
(apt  install docker-compose)       
*docker rm -fv $(docker ps -aq)*

wenn 403: forbidden, dann eventuell alter Proxy:                        
*ps aux | grep configurable-http-proxy*                     
oder                                        
*pkill -f configurable-http-proxy*              
*pkill -f jupyterhub*               


erstelle config python file:                     
*jupyterhub --generate-config*

### modifiziere das jupyterhub_config.py script:                        

c.JupyterHub.authenticator_class = 'oauthenticator.GitHubOAuthenticator'                        
c.GitHubOAuthenticator.oauth_callback_url = 'https://192.168.124.214:443/hub/oauth_callback'                
c.GitHubOAuthenticator.client_id = '5d45d363b4f83331af47'               
c.GitHubOAuthenticator.client_secret = '43274b267e1ed3d900938a6f249a59f215e4cc2f'               
// This is an application.                                               
// create system users that don't exist yet                  
c.JupyterHub.port = 443             
c.LocalAuthenticator.create_system_users = True             
c.Authenticator.whitelist = {'gordon', 'topoi'}             
c.Authenticator.admin_users = {'gordon', 'topoi'}                       
c.Spawner.notebook_dir = '~/notebooks'                      
c.JupyterHub.ssl_cert = 'mycert.pem'                        
c.JupyterHub.ssl_key = 'mykey.key'              
c.JupyterHub.cookie_secret_file = '/home/gordon/jupyterhub_cookie_secret'                                           
c.JupyterHub.proxy_cmd = ['/usr/local/bin/configurable-http-proxy']                 

die client_id und client_secret kommen aus dem registrieren der App 0Auth:                                           
https://auth0.com/docs/connections/social/github

## Gesis notebooks (Leibnitz)   
https://notebooks.gesis.org/                    

Start My Server (passwd (W!))                   

binder für docker image:                        
https://notebooks.gesis.org/binder/                                  

Link zum Teilen:                    
https://notebooks.gesis.org/binder/v2/gh/topoi/Telota/master


## Debugging:                       
A)                      
wenn            
/.docker/config.json: permission denied                             

dann:                   
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R                     
sudo chmod g+rwx "/home/$USER/.docker" -R                                
B)
