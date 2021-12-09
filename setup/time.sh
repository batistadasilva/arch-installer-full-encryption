source $(dirname "$0")/inputs.sh

function setup-time() {
  echo 'Setting time zone'
  setup-timezone
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  echo 'Setting system clock'
  setup-clock
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo
}

function setup-timezone() {
  ls /etc/localtime > /dev/null 2> /dev/null
  if [ $? -eq 0 ]; then
    echo 'Already setup, skipping...'
  fi
  local zone=$(enter-timezone)
  ln -sf /usr/share/zoneinfo/$zone /etc/localtime
}

function setup-clock() {
  hwclock --systohc
  timedatectl set-ntp true
}
