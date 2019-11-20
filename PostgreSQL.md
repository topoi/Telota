## Installation von PostgreSQL unter Arch Linux  

https://wiki.archlinux.org/index.php/PostgreSQL  
https://github.com/malnvenshorn/OctoPrint-FilamentManager/wiki/Setup-PostgreSQL-on-Arch-Linux  

sudo pacman -S postgresql  
sudo -iu postgres  
**[postgres]$** initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data

**[postgres]$** exit  

sudo systemctl start postgresql.service  
sudo systemctl enable postgresql.service


*In the /var/lib/postgres/data/postgresql.conf change the line with listen_addresses to*

*listen_addresses = '*'*

*Then append the following line to /var/lib/postgres/data/pg_hba.conf*

*host octoprint_filamentmanager octoprint 192.168.178.0/24 md5*

*Adapt the IP address to your network, e.g. if your server has the IP 192.168.0.25 use 192.168.0.0/24 instead. This allows all clients in your network to access the database. For more information see https://en.wikipedia.org/wiki/Subnetwork*

sudo systemctl restart postgresql.service

**[postgres]$** psql  
*- current connection*      
postgres=# \conninfo     
 
*- connect to database*    
psql memphis_project    

*- connect to database memphis_project as user grobian*      
psql -d memphis_project -U grobian      

*- create DB memphis_project_1120 for user postgres*   
createdb -O postgres memphis_project_1120    

*- delete database*    
dropdb 'database name'  

*- Import SQL File into DB   memphis_project; user: postgres)    
sudo -u postgres psql memphis_project < /home/gordon/Memphis/current_db/20190923memphis.sql   
