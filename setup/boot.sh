function setup-boot() {
  echo 'Setting initramfs'
  setup-initramfs
  echo

  echo 'Setting GRUB'
  setup-grub
  echo
}

function setup-initramfs() {
  local linux_partition=$(echo pvs --select vg_name=arch-vg -o pv_name --noheadings | sed '/.*\/dev\/mapper\//s/.*\/dev\/mapper\///g' | sed 's/_crypt//')
  cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bkp
  sed -i '/^HOOKS=/c\HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems keyboard fsck)' /etc/mkinitcpio.conf
  sed -i "/^GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\"cryptdevice=/dev/$linux_partition:${linux_partition}_crypt root=/dev/arch-vg/root\"" /etc/default/grub
  mkinitcpio -P
}

function setup-grub() {
  mkdir -p /boot/grub
  grub-mkconfig -o /boot/grub/grub.cfg
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id='Arch Linux'
}
