source $(dirname "$0")/inputs.sh

function setup-host() {
  cat /etc/hostname | grep localdomain > /dev/null
  if [ $? -eq 0 ]; then
    echo 'Already setup, skipping...'
  fi
  local hostname=$(enter-hostname)
  echo $hostname > /etc/hostname
  echo -e '127.0.0.1\tlocalhost' >> /etc/hosts
  echo -e '::1\t\tlocalhost' >> /etc/hosts
  echo -e "127.0.1.1\t$hostname.localdomain\t$hostname" >> /etc/hosts
}
