# some more ls aliases

#safety
alias mv='mv -i'
alias rm='rm -I -v'
alias cp='cp -i'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'

#package management
alias aptorphaned='apt-show-versions |grep -i "No available"'
alias aptnondeb='apt-show-versions |grep -iPv "((/(testing|buster|debian-buster|unstable|sid|debian-sid))|not installed)"'
alias debkeys='sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80'

#make watch work with aliases
alias watch='watch --color '

#convenience
alias ls="ls --block-size=\"'1\" --color=auto --group-directories-first"
alias la='ls -A'
alias l='ls -oah'
alias ll='ls -l --si --color=auto --group-directories-first'
alias lt='ls -ltr'
alias lsize='ls -lSrh'
alias df='df -Th'
alias ln='ln -s'
alias lp='lesspipe'
alias grep='GREP_COLOR="1;33;40" LANG=C grep -D skip --color=auto --exclude-dir=\.svn --exclude-dir=\.git --exclude-dir=backup --exclude=*~'
alias grpe='GREP_COLOR="1;33;40" LANG=C grep -D skip --color=auto --exclude-dir=\.svn --exclude-dir=\.git --exclude-dir=backup --exclude=*~'
alias grepi='GREP_COLOR="1;33;40" LANG=C grep -i -D skip --color=auto --exclude-dir=\.svn --exclude-dir=\.git --exclude-dir=backup --exclude=*~'
alias grepp='GREP_COLOR="1;33;40" LANG=C grep -P -D skip --color=auto --exclude-dir=\.svn --exclude-dir=\.git --exclude-dir=backup --exclude=*~'
alias greppi='GREP_COLOR="1;33;40" LANG=C grep -P -i -D skip --color=auto --exclude-dir=\.svn --exclude-dir=\.git --exclude-dir=backup --exclude=*~'
alias egrep='GREP_COLOR="1;33;40" LANG=C egrep -D skip --color=auto --exclude-dir=\.svn --exclude-dir=\.git --exclude-dir=backup --exclude=*~'
alias nuke='shred -u -z -v'
alias rsync="rsync --info=progress2 --no-inc-recursive"
alias rcp="rsync --info=progress2 --no-inc-recursive --size-only --inplace --verbose"
alias scpresume="rsync -Pahv -e ssh"
alias ..='cd ..'
alias cd..='cd ..'
alias cd-='cd -'
alias cdp='cd -P'
alias nohist='unset HISTFILE'
alias rmbacks='find -L -iname "*~" -exec rm -v {} \;'
alias dump='hexdump -C'
alias findbroken='find . -type l ! -exec test -r {} \; -print'
alias utime='date +%s'
alias s='sshrc'
alias sshx='ssh -Y -C'
alias remove_key='ssh-keygen -R'
alias colordiff='colordiff -yW"`tput cols`"'
alias hd='od -Ax -tx1z -v'
alias dutop='du -csh ./* 2>/dev/null | sort -rh'
alias mountcol='mount | column -t'
alias lld='ls -lUd */'
alias dateh='date --help|sed "/^ *%a/,/^ *%Z/!d;y/_/!/;s/^ *%\([:a-z]\+\) \+/\1_/gI;s/%/#/g;s/^\([a-y]\|[z:]\+\)_/%%\1_%\1_/I"|while read L;do date "+${L}"|sed y/!#/%%/;done|column -ts_'
alias keyrepeat='xset r rate 350 30'
alias dmesg='dmesg -wH'
alias tran='trans --brief'
alias neo='neofetch'

#development
alias extip='curl -s ifconfig.io'
