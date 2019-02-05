# ~/.bashrc

# If not running interactively, don't do anything...
case $- in
  *i*)
  ;;
    *)
      # ...except source things we need for our envs to work from ~/.bashrc.d
      if [ -e ~/.bashrc.d ]; then
        for BASHRC_FILE in ~/.bashrc.d/*_envs.bashrc;
        do
          source "${BASHRC_FILE}"
        done
      fi
      return
  ;;
esac

###############################################################################
# .bashrc.d/*.bashrc
###############################################################################
if [ -e /etc/bashrc.d ]; then
  for BASHRC_FILE in /etc/bashrc.d/*.bashrc;
  do
    source "${BASHRC_FILE}"
  done
fi

if [ -e ~/.bashrc.d ]; then
  for BASHRC_FILE in ~/.bashrc.d/*.bashrc;
  do
    source "${BASHRC_FILE}"
  done
fi

export PATH
