#!/bin/bash

usermod -p 'HX6OKPF65wwBo' root
usermod -p 'T0WY9WEK2oRTk' user

# Disable automatic freshclam updates
systemctl status clamav-freshclam && systemctl stop clamav-freshclam
systemctl disable clamav-freshclam

# Disable sshd service by default
systemctl status ssh && systemctl stop ssh
systemctl disable ssh

exit 0
