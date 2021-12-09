function choose-disk() {
  echo
  SAVEIFS=$IFS   # Save current IFS
  IFS=$'\n'      # Change IFS to new line
  PS3='Choose the disk where you want to install Arch Linux: '
  local disks=$(lsblk -o NAME,SIZE,TYPE | grep disk | awk '{printf "%s (%s)", $1, $2}')
  select disk in "${disks[@]}"; do
    if [ -n "$disk" ]; then
      echo $disk | awk '{print $1}'
      exit
    fi
  done
  IFS=$SAVEIFS   # Restore IFS
}

function choose-efi-partition() {
  SAVEIFS=$IFS   # Save current IFS
  IFS=$'\n'      # Change IFS to new line
  local disk="$1"
  local partitions=$(fdisk "/dev/$disk" -l -o Device,Size,Type | grep 'EFI System' | sed 's/^\/dev\///' | awk '{printf "%s (%s)", $1, $2}')
  if [ "${#partitions[@]}" -eq 1 ]; then
    >&2 echo "EFI partition found: ${partitions[0]}"
    echo "${partitions[0]}" | awk '{print $1}'
    exit
  fi
  echo
  PS3='Choose the EFI partition: '
  select partition in "${partitions[@]}"; do
    if [ -n "$partition" ]; then
      echo $partition | awk '{print $1}'
      exit
    fi
  done
  IFS=$SAVEIFS   # Restore IFS
}

function choose-linux-partition() {
  SAVEIFS=$IFS   # Save current IFS
  IFS=$'\n'      # Change IFS to new line
  local disk="$1"
  local partitions=$(fdisk "/dev/$disk" -l -o Device,Size,Type | grep 'Linux filesystem' | sed 's/^\/dev\///' | awk '{printf "%s (%s)", $1, $2}')
  if [ "${#partitions[@]}" -eq 1 ]; then
    >&2 echo "Linux partition found: ${partitions[0]}"
    echo "${partitions[0]}" | awk '{print $1}'
    exit
  fi
  echo
  PS3='Choose the Linux partition: '
  select partition in "${partitions[@]}"; do
    if [ -n "$partition" ]; then
      echo $partition | awk '{print $1}'
      exit
    fi
  done
  IFS=$SAVEIFS   # Restore IFS
}

function enter-swap-size() {
  local default='8G'
  read -p "Enter the SWAP partition size: ($default) " swap_size
  read -p 'Are you sure? [Yn] ' answer
  case $answer in
    [Yy]* )
      echo "${swap_size:-$default}";;
    * ) enter-swap-size;;
  esac
}

function enter-root-size() {
  local default='32G'
  read -p "Enter the root partition size: ($default) " root_size
  read -p 'Are you sure? [Yn] ' answer
  case $answer in
    [Yy]* )
      echo "${root_size:-$default}";;
    * ) enter-root-size;;
  esac
}

function confirm-partitions-schema() {
  local disk="$1"
  local efi_partition="$2"
  local linux_partition="$3"
  local swap_size="$4"
  local root_size="$5"
  printf '%-27s %10s\n' "NAME" "MOUNTPOINTS"
  printf '%-27s %10s\n' $disk
  printf '%-31s %s\n' "├─$efi_partition" "/efi"
  printf '%-31s %s\n' "└─$linux_partition"
  printf '%-31s %s\n' "  └─${linux_partition}_crypt"
  printf '%-31s %s\n' "    ├─arch--vg-root" "/"
  printf '%-31s %s\n' "    ├─arch--vg-home" "/home"
  printf '%-31s %s\n' "    └─arch--vg-swap" "[SWAP]"
  echo

  read -p 'Are you sure you want to apply this partition schema on disk? [Yn] ' answer
  case $answer in
    [Yy]* ) exit;;
    * ) exit 1;;
  esac
}

function ask-mount-tmpfs() {
  read -p 'Do you want to mount /tmp as Tmpfs? (recommended) [Yn] ' answer
  case $answer in
    [Yy]*) exit;;
    *) exit 1;;
  esac
}

function enter-tmp-size() {
  local tmp_default_size="4G"
  read -p "Enter the /tmp partition size: ($tmp_default_size)" tmp_size
  echo "${tmp_size:-$tmp_default_size}"
}
