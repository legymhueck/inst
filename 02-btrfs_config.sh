ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc
timedatectl set-timezone UTC

echo "de_DE.UTF-8 UTF-8
en_US.UTF-8 UTF-8" > /etc/locale.gen

locale-gen

echo "KEYMAP=de-latin1" >> /etc/vconsole.conf

echo "arch" > /etc/hostname

echo "127.0.0.1 localhost
::1       localhost
127.0.1.1 arch.localdomain  arch" > /etc/hosts

passwd

bootctl --path=/boot install

echo "default arch
timeout 1
editor 0" > /boot/loader/loader.conf

echo "title ArchLinux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=/dev/disk/by-label/ROOT:arch root=/dev/mapper/arch zswap.enabled=0 rootflags=subvol=@ quiet nowatchdog quiet rw rootfstype=btrfs" > /boot/loader/entries/arch.conf

systemctl enable acpid
systemctl enable NetworkManager
systemctl enable cups
systemctl enable bluetooth.service
systemctl enable reflector.timer
systemctl enable reflector.service


# sed -i '/%wheel ALL=(ALL) ALL/s/^#//g' /etc/sudoers
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//g' /etc/sudoers
sed -i '/BUILDDIR=\/tmp\/makepkg/s/^#//g' /etc/makepkg.conf

echo 'vm.swappiness=10' | tee /etc/sysctl.d/99-swappiness.conf

# base udev block keymap keyboard autodetect modconf encrypt filesystems
exit
umount -R /mnt

