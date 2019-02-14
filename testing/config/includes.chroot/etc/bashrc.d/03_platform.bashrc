###############################################################################
# mappings/environment variables cross-platform use
###############################################################################

# determine OS
unset MACOS
unset LINUX
unset WINDOWS10
unset LC_WINDOWS10

if [ $(uname -s) = 'Darwin' ]; then
  export MACOS=0
elif grep -q Microsoft /proc/version; then
  export WINDOWS10=0
  export LC_WINDOWS10=$WINDOWS10
  alias open='explorer.exe'
else
  export LINUX=0
  alias open='xdg-open'
fi

function o() {
  if [ $# -eq 0 ]; then
    open .;
  else
    open "$@";
  fi;
}
