if [ -d ~/.anyenv ]; then
  export ANYENV_ROOT="$HOME/.anyenv"
  if [ -d $ANYENV_ROOT/bin ]; then
    PATH="$ANYENV_ROOT/bin:$PATH"
  fi
  eval "$(anyenv init -)"
fi

if [ $GOENV_ROOT ]; then
  export GOROOT="$(goenv prefix)"
fi
export GOPATH=$DEVEL_ROOT/gopath
if [ -d $GOPATH/bin ]; then
  PATH=$GOPATH/bin:$PATH
fi

if [ $PYENV_ROOT ]; then
  if [ -f $PYENV_ROOT/completions/pyenv.bash ]; then
    . $PYENV_ROOT/completions/pyenv.bash
  fi
  if [ -d $PYENV_ROOT/plugins/pyenv-virtualenv ]; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi
