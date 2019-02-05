###############################################################################
# ALIASES AND FUNCTIONS
###############################################################################
if [ -f /etc/bash.bash_aliases ]; then
    . /etc/bash.bash_aliases
fi

if [ -f /etc/bash.bash_functions ]; then
    . /etc/bash.bash_functions
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi
