## Installation und Anwendung von Docker

https://www.youtube.com/watch?v=fqMOX6JJhGo

https://hub.docker.com/u/jupyter/   


### Install docker linux:       
*apt install docker.io*       
*systemctl start docker*   
*systemctl enable docker*      

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




erstelle config python file:                     
*jupyterhub --generate-config*

