source $(dirname "$0")/inputs.sh

function setup-optional() {
  echo 'Setup desktop environment'
  install-desktop-environment
  echo
}

function install-desktop-environment() {
  local desktop=$(choose-desktop-environment)
  case $choice in
    "gnome")
      echo 'Installing GNOME'
      install-gnome
      echo
      ;;
    *) exit;;
  esac
  setup-user
}

function install-gnome() {
  pacman -S gnome networkmanager crda bluez bluez-utils fwupd sudo
  systemctl enable NetworkManager.service
  systemctl enable bluetooth.service
  systemctl enable gdm
}

function setup-user() {
  local username=$(enter-username)
  cat /etc/passwd | grep -e "^$username:" > /dev/null 2> /dev/null
  if [ $? -eq 0 ]; then
    echo 'Already setup, skipping...'
  fi
  local full_name=$(enter-fullname)
  useradd --create-home --groups wheel --comment "$full_name" "$username"
  if [ $? -ne 0 ]; then
    >&2 echo
    >&2 echo 'Try again...'
    setup-user
  fi
  setup-user-password "$username"
  echo
  echo "Adding superuser privileges to $username"
  sed -i '/# %wheel ALL=(ALL) ALL/s/# //g' /etc/sudoers
}

function setup-user-password() {
  local username="$1"
  passwd "$username"
  if [ $? -ne 0 ]; then
    >&2 echo
    >&2 echo 'Try again...'
    setup-user-password "$username"
  fi
}
