## Installation von Arch Linunx

https://wiki.archlinux.org/index.php/installation_guide  
https://wiki.archlinux.de/title/Anleitung_f%C3%BCr_Einsteiger

https://wiki.archlinux.de/title/Pacman

Anmerkungen:  
mkfs.ext4 /dev/sdX2  
bei UEFI --> mkfs.fat -F32 /dev/sdX1  
um zu schauen, welche devices: lsblk     

GRUB:  
nicht vergessen: pacman -S efibootmgr  
Syntax anders ls (hd0,1)  
grub-mkconfig -o /boot/grub/grub.cfg  

wichtig: dhcp Pakete laden  
(USB stick mounten, dann darauf kopieren)  

arch-chroot: Umgebung für Installation (Netzzugriff)    
um Netzwerk einzurichten: dhcp daemon  
https://wiki.archlinux.de/title/DHCP  
https://www.archlinux.de/packages?search=dhcpcd  

### snap    
https://snapcraft.io/install/ant/arch

### nach Upgrade/Update Kernel-Versionen abgleichen   
$ uname -r    
.....   
$ pacman -Q linux   
.....   
