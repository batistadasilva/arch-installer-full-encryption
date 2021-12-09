#!/bin/bash

source $(dirname "$0")/setup/boot.sh
source $(dirname "$0")/setup/host.sh
source $(dirname "$0")/setup/locale.sh
source $(dirname "$0")/setup/optional.sh
source $(dirname "$0")/setup/root.sh
source $(dirname "$0")/setup/time.sh

set -e

echo 'System setup'
echo

echo 'Host setup'
echo
setup-host
echo

echo 'Time setup'
echo
setup-time
echo

echo 'Locale setup'
echo
setup-locale
echo

echo 'Boot setup'
echo
setup-boot
echo

echo 'Root user setup'
echo
setup-root
echo

echo 'Optional settings'
echo
setup-optional
echo

echo 'Done!'
