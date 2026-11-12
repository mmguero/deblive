#!/bin/bash

# load dconf defaults shipped in /etc/skel on the user's first graphical login, then
#   remove the files so this only happens once

# GTK4/libadwaita apps (ghostty, etc.) take their theme from here rather than from xsettings
#   (same settings as XFCE_DCONF_CONFIG_B64 in dotfiles' GueroSymlinks)
[[ -r ~/.config/desktop-interface.dconf ]] && \
  dconf load / < ~/.config/desktop-interface.dconf && \
  rm -f ~/.config/desktop-interface.dconf

exit 0
