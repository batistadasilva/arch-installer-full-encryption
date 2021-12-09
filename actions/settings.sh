function enable-mirror-updates() {
  echo 'Enabling packages mirrors updates'
  systemctl enable reflector.timer
  echo
}
