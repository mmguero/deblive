###############################################################################
# BASH OPTIONS
###############################################################################
# don't put duplicate lines in the history and ignore same sucessive entries.
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="&:ls:ll:cd:history:h:[bf]g:exit:shred *:pwd:clear"
export HISTFILESIZE=1000000000
export HISTSIZE=1000000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "

shopt -s extglob
shopt -s dotglob
shopt -s cdspell
shopt -s histverify
shopt -s histappend
shopt -u progcomp

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# enable programmable completion features
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  source /etc/profile.d/vte.sh
fi

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] ; then
  if [ -f /usr/bin/screenfetch ]; then screenfetch; fi
fi

if [ $ITERM_SESSION_ID ]; then
  if [ -f ~/.iterm2_shell_integration.bash ]; then source ~/.iterm2_shell_integration.bash; fi
fi
