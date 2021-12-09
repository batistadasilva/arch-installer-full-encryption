#!/bin/bash

source $(dirname "$0")/install/disk.sh
source $(dirname "$0")/install/packages.sh

set -e

echo 'Synchronizing system time'
timedatectl set-ntp true
echo

echo 'Preparing the disk'
echo
prepare-disk
echo

echo 'Installing packages'
echo
install-packages
echo

echo 'Done!'
