function setup-root() {
  echo 'Setting root password'
  setup-root-passord
  echo
}

function setup-root-passord() {
  passwd
  if [ $? -ne 0 ]; then
    >&2 echo
    >&2 echo 'Try again...'
    setup-root-password
  fi
}
