###############################################################################
# BASH PROMPT
###############################################################################
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

if [ $WINDOWS10 ]; then
  PROMPT_COLOR="0;35m"  # magenta

else
  #PRIMARY_IP=$(ip route get 1 | head -n 1 | cols 7)
  PRIMARY_IP=$(ip route get 255.255.255.255 | grep -Po '(?<=src )(\d{1,3}.){4}' | sed "s/ //g")

  case "$PRIMARY_IP" in
          172.16.0.41)
              PROMPT_COLOR="0;32m"  # green
              ;;

          172.16.0.2)
              PROMPT_COLOR="0;34m"  # blue
              ;;

          172.16.10.185)
              PROMPT_COLOR="0;35m"  # magenta
              ;;

          172.16.10.179)
              PROMPT_COLOR="0;36m"  # cyan
              ;;

          *)
              PROMPT_COLOR="0;31m"  # red
              ;;
  esac
fi

if [ -f /.dockerenv ]; then
  # DOCKER: we are inside a container, change a color or do anything else different you'd like to do
  PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00;31m\]@\h\[\033[1;30m\]:\[\033[01;34m\]\W\[\033[00m\]\[\033[01;30m\]\[\033[01;37m\]\$ \[\033[00;37m\]"
  alias chromium="chromium --no-sandbox"
  alias chrome="google-chrome --no-sandbox"

elif [ $WINDOWS10 ]; then
  # Windows Subsystem for Linux
  PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[0$PROMPT_COLOR\]@win10\[\033[1;30m\]:\[\033[01;34m\]\W\[\033[00m\]\[\033[01;30m\]\$(parse_git_branch)\[\033[01;37m\]\$ \[\033[00;37m\]"
  cd ~

else
  # Linux/Mac
  PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[0$PROMPT_COLOR\]@\h\[\033[1;30m\]:\[\033[01;34m\]\W\[\033[00m\]\[\033[01;30m\]\$(parse_git_branch)\[\033[01;37m\]\$ \[\033[00;37m\]"
fi
