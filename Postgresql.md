Installation von PostgreSQL unter Arch Linux  

sudo pacman -S postgresql  
sudo -iu postgres  
**[postgres]$** initdb --locale=en_US.UTF-8 -E UTF8 -D /var/lib/postgres/data

exit
sudo systemctl start postgresql.service
sudo systemctl enable postgresql.service
