install-packages() {
  echo 'Installing base packages'
  install-base
  echo

  echo 'Installing bootloader utilities'
  install-bootloader-utilities
  echo

  echo 'Installing microcode updates'
  install-ucode
  echo
}

function install-base() {
  pacstrap /mnt base linux linux-firmware
}

function install-bootloader-utilities() {
  pacstrap /mnt lvm2 grub efibootmgr efitools sbsigntools
}

function install-ucode() {
  echo 'Checking CPU type'
  check-cpu-intel
  if [ $? -eq 0 ]; then
    echo 'Intel CPU detected'
    echo 'Installing Intel microcode updates'
    install-intel-ucode
    exit
  fi
  check-cpu-amd
  if [ $? -eq 0 ]; then
    echo 'AMD CPU detected'
    echo 'Installing AMD microcode updates'
    install-amd-ucode
    exit
  fi
  echo 'CPU type not detected, no microcode updates installed'
}

function check-cpu-intel() {
  grep -m 1 'model name' /proc/cpuinfo | grep Intel
}

function check-cpu-amd() {
  echo 'Sorry, AMD CPU type detection is not implemented yet... feel free to submit a patch for this'
  exit 1
}

function install-intel-ucode() {
  pacstrap /mnt intel-ucode
}

function install-amd-ucode() {
  pacstrap /mnt amd-ucode
}
