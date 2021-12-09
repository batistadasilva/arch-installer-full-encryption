function enter-hostname() {
  read -p 'Enter the hostname: ' hostname
  echo $hostname
}

function enter-timezone() {
  read -p 'Enter the time zone: ' zone
  ls "/usr/share/zoneinfo/$zone" 2>/dev/null
  if [ $? -ne 0 ]; then
    >&2 echo
    >&2 echo 'Invalid time zone, try again...'
    enter-timezone
  fi
  echo $zone
}

function choose-desktop-environment() {
  PS3='Choose a desktop environment: (optional) '
  local choices=("GNOME" "None")
  select choice in "${choices[@]}"; do
    case $choice in
      "GNOME") echo 'gnome';;
      "None") echo 'none';;
    esac
  done
}

function enter-username() {
  read -p 'Enter your username: ' username
  echo $username
}

function enter-fullname() {
  read -p 'Enter your full name: ' full_name
  echo $full_name
}
