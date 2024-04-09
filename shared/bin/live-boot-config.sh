#!/bin/bash

usermod -p '$1$6Olunr9.$HFDWaI1bGuSmE6ZTuLugS/' root
usermod -p '$1$hWwRfLgE$sc5mZnyFGgp5z9rrgIhlL.' user

touch /etc/subuid
touch /etc/subgid
if ! grep --quiet user /etc/subuid; then
  usermod --add-subuids 200000-265535 user
fi
if ! grep --quiet user /etc/subgid; then
  usermod --add-subgids 200000-265535 user
fi
loginctl enable-linger user

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
