# k3os-iso-remaster
Remaster the k3OS ISO image to enjoy fully automatic installations !

## Prerequisites
Ubuntu: apt install grub-efi grub-pc-bin mtools xorriso  
CentOS: dnf install grub2-efi grub2-pc mtools xorriso  
Alpine: apk add grub-bios grub-efi mtools xorriso

Check if the `remaster.sh` script matches to your grub-mkrescue command.