https://www.digitalocean.com/community/tutorials/how-to-install-anaconda-on-ubuntu-18-04-quickstart

RunAnaconda.sh  

source /home/gordon/anaconda3/bin/activate root  
cd /home/gordon/Telota/JupyterProjekte  
/home/gordon/anaconda3/bin/anaconda-navigator  

https://github.com/quantopian/qgrid/releases  

wenn pip nicht funktioniert: (ImportError....)    
export PATH="${HOME}/.local/bin:$PATH"    


in /home/gordon/anaconda3/bin/:   
source deactivate   

wenn Fehler kommt:    
sudo rm -rf /home/gordon/.anaconda/
