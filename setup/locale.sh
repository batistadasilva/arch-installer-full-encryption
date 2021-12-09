function setup-locale() {
  ls /etc/locale.conf > /dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    echo 'Already setup, skipping...'
  fi
  cp /etc/locale.gen /etc/locale.gen.bkp
  sed -i '/#en_US.UTF-8/s/^#//g' /etc/locale.gen
  echo 'LANG=en_US.UTF-8' > /etc/locale.conf
  locale-gen
}
