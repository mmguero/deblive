#!/bin/bash

usermod -p '6/5nDf.XACQHs' root
usermod -p 'ZQZa4GDRa9IY2' user

# Disable automatic freshclam updates
systemctl status clamav-freshclam && systemctl stop clamav-freshclam
systemctl disable clamav-freshclam

# Disable sshd service by default
systemctl status ssh && systemctl stop ssh
systemctl disable ssh

# make symlink for vte.sh if it doesn't exist
if [ ! -f /etc/profile.d/vte.sh ]; then
  pushd /etc/profile.d >/dev/null 2>&1
  ln -s "$(ls vte-*.sh | tail -n 1)" vte.sh >/dev/null 2>&1 || true
  popd >/dev/null 2>&1
fi

exit 0
