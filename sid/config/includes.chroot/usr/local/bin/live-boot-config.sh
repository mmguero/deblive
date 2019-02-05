#!/bin/bash

usermod -p '6/5nDf.XACQHs' root
usermod -p 'ZQZa4GDRa9IY2' user

# Disable automatic freshclam updates
systemctl status clamav-freshclam && systemctl stop clamav-freshclam
systemctl disable clamav-freshclam

# Disable sshd service by default
systemctl status ssh && systemctl stop ssh
systemctl disable ssh

exit 0
