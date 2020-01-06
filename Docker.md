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

wenn 403: forbidden, dann eventuell alter Proxy:                        
*ps aux | grep configurable-http-proxy*                     
oder                                        
*pkill -f configurable-http-proxy*              
*pkill -f jupyterhub*               


erstelle config python file:                     
*jupyterhub --generate-config*

### modifiziere das jupyterhub_config.py script:                        
#-----------------------------------------------------------------------------------------------------------------------------------------------------
# Application configuration
#-----------------------------------------------------------------------------------------------------------------------------------------------------

# This is an application.                       
c.JupyterHub.authenticator_class = 'oauthenticator.GitHubOAuthenticator'                        
c.GitHubOAuthenticator.oauth_callback_url = 'https://192.168.124.214:443/hub/oauth_callback'                
c.GitHubOAuthenticator.client_id = '5d45d363b4f83331af47'               
c.GitHubOAuthenticator.client_secret = '43274b267e1ed3d900938a6f249a59f215e4cc2f'               
# This is an application.                                               
# create system users that don't exist yet                  
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

