lsblk
echo -p "sda / vda / nvme: " drive
echo -p "username: " username
disk=/dev/$drive
progs="acpi acpid base base-devel btrfs-progs bluez bluez-utils cryptsetup cups dosfstools efibootmgr git intel-ucode kitty linux linux-firmware linux-headers mtools networkmanager polkit reflector sbctl sudo unzip vim xdg-user-dirs"

sgdisk -Z $disk
sgdisk -o $disk
# 8304 Linux x86-64 root
sgdisk -n1:0:+512M -t1:ef00 -c1:EFI -n2 -t2:8304 -c2:ROOT $disk

cryptsetup luksFormat  $disk\2
cryptsetup open $disk\2 root

mkfs.vfat -F 32 -n BOOT $disk\1
mkfs.btrfs -f -L ROOT /dev/mapper/root

mount /dev/mapper/root /mnt
mkdir /mnt/efi
mount /dev/$disk\1 /mnt/efi
btrfs su cr /mnt/home

pacstrap -K /mnt $progs
sed -i -e "/^#"en_US.UTF-8"/s/^#//" /mnt/etc/locale.gen
sed -i -e "/^#"de_DE.UTF-8"/s/^#//" /mnt/etc/locale.gen
systemd-firstboot --root /mnt --prompt
arch-chroot /mnt locale-gen

arch-chroot /mnt useradd -G wheel -m $username
arch-chroot /mnt passwd $username
sed -i -e '/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/s/^# //' /mnt/etc/sudoers

echo "quiet rw" >/mnt/etc/kernel/cmdline
echo "Edit HOOKS like this: HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole sd-encrypt block filesystems fsck)"
vim /mnt/etc/mkinitcpio.conf

echo "Update preset"
echo "comment default_config and default_image"
echo "comment fallback_config and fallback_image"
vim /mnt/etc/mkinitcpio.d/linux.preset
arch-chroot /mnt mkinitcpio -P

systemctl --root /mnt enable systemd-resolved systemd-timesyncd NetworkManager
systemctl --root /mnt mask systemd-networkd
arch-chroot /mnt bootctl install --esp-path=/efi

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
