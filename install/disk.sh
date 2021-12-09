source $(dirname "$0")/inputs.sh

function prepare-disk() {
  local disk=$(choose-disk)
  local efi_partition=$(choose-efi-partition)
  local linux_partition=$(chose-linux-partition)
  local swap_size=$(enter-swap-size)
  local root_size=$(enter-root-size)

  echo 'Confirm the partition schema'
  confirm-partitions-schema $disk $efi_partition $linux_partition "$swap_size" "$root_size"
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  apply-partitions $disk $efi_partition $linux_partition "$swap_size" "$root_size"
  if [ $? -ne 0 ]; then
    >&2 echo
    >&2 echo 'Try again...'
    prepare-disk
  fi
}

function apply-partitions() {
  local disk="$1"
  local efi_partition="$2"
  local linux_partition="$3"
  local swap_size="$4"
  local root_size="$5"

  echo 'Formatting the EFI partition'
  format-fat32-partition $efi_partition
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  echo 'Encrypting the Linux partition'
  encrypt-partition $linux_partition
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  echo 'Opening encrypted partition'
  open-encrypted-partition $linux_partition
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  echo 'Creating physical and logical volumes on encrypted partition'
  create-physical-and-logical-volumes $linux_partition $swap_size $root_size
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  echo 'Formatting the logical volumes'
  format-logical-volumes $linux_partition
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  echo 'Mounting filesystem'
  mount-filesystem $efi_partition $linux_partition
  if [ $? -ne 0 ]; then
    echo 'Exit'
    exit 1
  fi
  echo

  echo 'Generating file fstab'
  init-fstab
  ask-mount-tmpfs
  if [ $? -eq 0 ]; then
    echo 'Mounting /tmp as Tmpfs'
    local tmp_size=$(enter-tmp-size)
    mount-tmp-as-tmpfs $tmp_size
  fi
  echo
}

function format-fat32-partition() {
  local partition="$1"
  mkfs.fat -F32 "/dev/$partition"
}

function encrypt-partition() {
  local partition="$1"
  cryptsetup luksFormat --type luks2 --use-random -s 512 -h sha512 "/dev/$partition"
  if [ $? -ne 0 ]; then
    >&2 echo
    >&2 echo 'Try again...'
    encrypt-partition $partition
  fi
}

function open-encrypted-partition() {
  local partition="$1"
  cryptsetup open "/dev/$partition" "${partition}_crypt"
  if [ $? -ne 0 ]; then
    >&2 echo
    >&2 echo 'Try again...'
    open-encrypted-partition $partition
  fi
}

function create-physical-and-logical-volumes() {
  local partition="$1"
  local swap_size="$2"
  local root_size="$3"
  pvcreate "/dev/mapper/${partition}_crypt"
  vgcreate arch-vg "/dev/mapper/${partition}_crypt"
  lvcreate -L "$swap_size" arch-vg -n swap
  lvcreate -L "$root_size" arch-vg -n root
  lvcreate -l 100%FREE arch-vg -n home
}

function format-logical-volumes() {
  local partition="$1"
  mkfs.ext4 /dev/arch-vg/root
  mkfs.ext4 /dev/arch-vg/home
  mkswap /dev/arch-vg/swap
}

function mount-filesystem() {
  local efi_partition="$1"
  local linux_partition="$2"
  mount /dev/arch-vg/root /mnt
  mkdir /mnt/home
  mount /dev/arch-vg/home /mnt/home
  mkdir /mnt/boot
  mount "/dev/$efi_partition" /mnt/boot
  swapon /dev/arch-vg/swap
}

function init-fstab() {
  genfstab -U /mnt >> /mnt/etc/fstab
}

function mount-tmp-as-tmpfs() {
  local tmp_size="$1"
  echo -e "tmpfs\t\t\t\t\t\t/tmp\t\ttmpfs\t\trw,nodev,nosuid,size=${tmp_size}\t\t0 0" >> /mnt/etc/fstab
}
