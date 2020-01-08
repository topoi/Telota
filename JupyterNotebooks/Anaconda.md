https://www.digitalocean.com/community/tutorials/how-to-install-anaconda-on-ubuntu-18-04-quickstart

RunAnaconda.sh  

source /home/gordon/anaconda3/bin/activate root  
cd /home/gordon/Telota/JupyterProjekte  
/home/gordon/anaconda3/bin/anaconda-navigator  

https://github.com/quantopian/qgrid/releases  

wenn pip nicht funktioniert: (ImportError....)    
export PATH="${HOME}/.local/bin:$PATH"    


in /home/gordon/anaconda3/bin/:   
*source deactivate   

wenn Fehler kommt:    
/Anaconda$ ./RunAnaconda.sh   
Traceback (most recent call last):    
  File "/home/gordon/anaconda3/bin/anaconda-navigator", line 11, in <module>    
    sys.exit(main())    
  File "/home/gordon/anaconda3/lib/python3.7/site-packages/anaconda_navigator/app/main.py", line 100, in main   
    clean_logs()    
  File "/home/gordon/anaconda3/lib/python3.7/site-packages/anaconda_navigator/utils/logs.py", line 157, in clean_logs   
    with open(path, 'w') as f:    
PermissionError: [Errno 13] Permission denied: '/home/gordon/.anaconda/navigator/logs/navigator.log'    

dann Lösung:    
*sudo rm -rf /home/gordon/.anaconda/*
