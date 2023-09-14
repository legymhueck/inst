disk=/dev/sda
progs="acpi acpid base base-devel btrfs-progs bluez bluez-utils cups dosfstools efibootmgr git intel-ucode linux linux-firmware linux-headers mtools networkmanager polkit reflector sudo vim xdg-user-dirs"

sgdisk --zap-all $disk
sgdisk -o $disk
sgdisk -n 1:0:+500M -t 1:ef00 -c 1:"BOOT" $disk
sgdisk -n 2:0:0     -t 2:8300 -c 2:"ROOT" $disk

cryptsetup luksFormat  $disk\2
cryptsetup open $disk\2 arch

mkfs.vfat -F 32 -n BOOT $disk\1
mkfs.btrfs -f -L ROOT /dev/mapper/arch
mount /dev/mapper/arch /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@var
umount /mnt
mount -o ssd,compress=zstd:1,noatime,discard=async,subvol=@ /dev/mapper/arch /mnt
mkdir /mnt/{boot,var,home}
mount -o ssd,compress=zstd:1,noatime,discard=async,subvol=@var /dev/mapper/arch /mnt/var
mount -o ssd,compress=zstd:1,noatime,discard=async,subvol=@home /dev/mapper/arch /mnt/home
mount $disk\1 /mnt/boot
pacstrap -K /mnt $progs
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
