Installation von PostgreSQL unter Arch Linux  

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
postgres=# \conninfo  *(shows current connection)*
psql memphis_project  *(connect to database)*

psql -d memphis_project -U grobian  *(connect to database memphis_project as user grobian)*
