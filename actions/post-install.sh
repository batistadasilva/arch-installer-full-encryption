function setup-kernel-update() {
  read -p 'Do you want to prevent automatic updates on Kernel? (recommended) [Yn] ' answer
  case $answer in
    [Yy]* ) sed -i '/^#IgnorePkg   =/c\IgnorePkg    = linux' /mnt/etc/pacman.conf;;
  esac
  echo
}
