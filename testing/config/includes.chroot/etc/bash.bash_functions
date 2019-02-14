########################################################################
# text processing
########################################################################
function cols () {
    first="awk '{print "
    last="}'"
    cmd="${first}"
    commatime=""
    for var in "$@"
    do
      if [ -z $commatime ]
      then
        commatime="no"
        cmd=${cmd}\$${var}
      else
        cmd=${cmd}\,\$${var}
      fi
    done
    cmd="${cmd}${last}"
    eval $cmd
}

function headtail () {
  awk -v offset="$1" '{ if (NR <= offset) print; else { a[NR] = $0; delete a[NR-offset] } } END { { print "--------------------------------" } for (i=NR-offset+1; i<=NR; i++) print a[i] }' ;
}

function wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  until test $((wait_seconds--)) -eq 0 -o -f "$file" ; do sleep 1; done

  ((++wait_seconds))
}

function taildiff () {
  LEFT_FILE=$1
  RIGHT_FILE=$2
  RIGHT_LINES=$(wc -l "$RIGHT_FILE" | cut -d ' ' -f1)
  diff -bwBy --suppress-common-lines <(head -n $RIGHT_LINES "$LEFT_FILE") <(head -n $RIGHT_LINES "$RIGHT_FILE")
}

function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* ./*;
  fi;
}

function lin () {
  sed -n $1p
}

function multigrep() { local IFS='|'; grep -rinE "$*" . ; }

function ord() { printf "%d\n" "'$1"; }

function chr() { printf \\$(($1/64*100+$1%64/8*10+$1%8))\\n; }

# Create a data URL from a file
function dataurl() {
  local mimeType=$(file -b --mime-type "$1");
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8";
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

function colors () {
  for i in {0..255}; do echo -e "\e[38;05;${i}m${i}"; done | column -c 80 -s '  '; echo -e "\e[m"
}

########################################################################
# media
########################################################################
function yt () {
  youtube-dl -o - "$1" | mplayer -
}

function ytsel () {
  youtube-dl -o - "$(xsel)" | mplayer -
}

function pyt() {
  youtube-dl -f bestaudio -q --max-downloads 1 --no-playlist --default-search ${2:-ytsearch} "$1" -o - | mplayer -vo null /dev/fd/3 3<&0 </dev/tty
}

function ytmp3() {
  # old way
  #youtube-dl -f bestaudio -q --max-downloads 1 --no-playlist --default-search ${2:-ytsearch} "$1" -o - | mplayer -vo null -ao pcm:fast:file="$1.wav" /dev/fd/3 3<&0 </dev/tty
  #ffmpeg -i "$1.wav" -codec:a libmp3lame -qscale:a 2 "$1.mp3"
  #rm "$1.wav"

  # automatic way
  search="$1"
  if [[ "$search" =~ ^http ]]
  then
    youtube-dl -f bestaudio --extract-audio --audio-format mp3 --audio-quality 2 -q --max-downloads 1 "$search"
  else
    youtube-dl -f bestaudio --extract-audio --audio-format mp3 --audio-quality 2 -q --max-downloads 1 --no-playlist --default-search ${2:-ytsearch} "$search"
  fi
}

function pytv() {
  youtube-dl -q --max-downloads 1 --no-playlist --default-search ${2:-ytsearch} "$1" -o - | mplayer -
}

function ytsearch() {
  youtube-dl -F --max-downloads 1 --no-playlist --default-search ${2:-ytsearch} "$1"
}

function brownnoise() {
  play -c2 -n synth pinknoise band -n 280 80 band -n 60 25 gain +20 treble +40 500 bass -3 20 flanger 4 2 95 50 .3 sine 50 lin
}

function noise() {
  brownnoise
}

########################################################################
# reference
########################################################################


########################################################################
# math
########################################################################
function calc () { python -c "from math import *; n = $1; print n; print '$'+hex(trunc(n))[2:]; print '&'+oct(trunc(n))[1:]; print '%'+bin(trunc(n))[2:];"; }

function add () {
  awk '{s+=$1} END {print s}'
  # alternately: paste -sd+ - | bc
}

########################################################################
# directory navigation/file manipulation
########################################################################
function cd() { if [[ "$1" =~ ^\.\.+$ ]];then local a dir;a=${#1};while [ $a -ne 1 ];do dir=${dir}"../";((a--));done;builtin cd $dir;else builtin cd "$@";fi ;}

function fcd() { [ -f $1  ] && { cd $(dirname $1);  } || { cd $1 ; } }

function up { cd $(eval printf '../'%.0s {1..$1}) && pwd; }

function realpath {
  if [ $MACOS ]; then
    /usr/local/bin/realpath "$@"
  else
    readlink -f "$@"
  fi
}

function realgo() { fcd $(realpath $(which $1)) && pwd ; }

function realwhich() { realpath $(which $1) ; }

function renmod() {
  FILENAME="$@";
  TIMESTAMP=$(date -d @$(stat -c%Y "$FILENAME") +"%Y%m%d%H%M%S")
  mv -iv "$FILENAME" "$FILENAME.$TIMESTAMP"
}

function unp() {
  for ARCHIVE_FILENAME in "$@"
  do
    TIMESTAMP=$(date -d @$(stat -c%Y "$ARCHIVE_FILENAME") +"%Y%m%d%H%M%S")
    DEST_DIR="$(basename "$ARCHIVE_FILENAME")_$TIMESTAMP"
    mkdir "$DEST_DIR" 2>/dev/null || {
      DEST_DIR="$(mktemp -d -p . -t $(basename "$ARCHIVE_FILENAME")_XXXXXX)"
    }
    python -m pyunpack.cli -a "$ARCHIVE_FILENAME" "$DEST_DIR/"
    DEST_DIR_CONTENTS=()
    while IFS=  read -r -d $'\0'; do
        DEST_DIR_CONTENTS+=("$REPLY")
    done < <(find "$DEST_DIR" -mindepth 1 -maxdepth 1 -print0)
    if [[ ${#DEST_DIR_CONTENTS[@]} -eq 1 ]]; then
      (mv -n "$DEST_DIR"/* "$DEST_DIR"/.. >/dev/null 2>&1 && \
         rmdir "$DEST_DIR" >/dev/null 2>&1 && \
         echo "\"$ARCHIVE_FILENAME\" -> \"$(basename "${DEST_DIR_CONTENTS[0]}")\"" ) || \
      echo "\"$ARCHIVE_FILENAME\" -> \"$DEST_DIR/\""
    else
      echo "\"$ARCHIVE_FILENAME\" -> \"$DEST_DIR/\""
    fi
  done
}

function upto() {
  local EXPRESSION="$1"
  if [ -z "$EXPRESSION" ]; then
    echo "A folder expression must be provided." >&2
    return 1
  fi
  if [ "$EXPRESSION" = "/" ]; then
    cd "/"
    return 0
  fi
  local CURRENT_FOLDER="$(pwd)"
  local MATCHED_DIR=""
  local MATCHING=true

  while [ "$MATCHING" = true ]; do
    if [[ "$CURRENT_FOLDER" =~ "$EXPRESSION" ]]; then
      MATCHED_DIR="$CURRENT_FOLDER"
      CURRENT_FOLDER=$(dirname "$CURRENT_FOLDER")
    else
      MATCHING=false
    fi
  done
  if [ -n "$MATCHED_DIR" ]; then
    cd "$MATCHED_DIR"
    return 0
  else
    echo "No Match." >&2
    return 1
  fi
}

# complete upto
_upto () {
  # necessary locals for _init_completion
  local cur prev words cword
  _init_completion || return

  COMPREPLY+=( $( compgen -W "$( echo ${PWD//\// } )" -- $cur ) )
}
complete -F _upto upto

########################################################################
# history
########################################################################
function h() { if [ -z "$1" ]; then history; else history | grep -i "$@"; fi; }

########################################################################
# searching
########################################################################
function fname() { find . -iname "*$@*"; }

########################################################################
# examine running processes
########################################################################
function auxer() {
  ps aux | grep -i "$(echo "$1" | sed "s/^\(.\)\(.*$\)/\[\1\]\2/")"
}

function psgrep() {
  if [ ! $MACOS ]; then
    ps axuf | grep -v grep | grep "$@" -i --color=auto;
  else
    /usr/local/bin/psgrep "$@"
  fi
}

function killtree() {
  if [ "$1" ]
  then
    kill $(pstree -p $1 | sed 's/(/\n(/g' | grep '(' | sed 's/(\(.*\)).*/\1/' | tr "\n" " ")
  else
    echo "No PID specified">&2
  fi
}

function howmuchmem () {
  PROCNAME="$@";
  RAMKILOBYTES=($(ps axo rss,comm|grep $PROCNAME| awk '{ TOTAL += $1 } END { print TOTAL }'));
  RAMBYTES=$(echo "$RAMKILOBYTES*1024" | bc);
  RAM=$(fsize $RAMBYTES);
  echo "$RAM";
}

function mempercent () {
  PROCNAME="$@";
  ps -eo pmem,comm | grep "$PROCNAME" | awk '{sum+=$1} END {print sum " % of RAM"}'
}

function htopid () {
  PROCPID="$1"
  htop -p $(pstree -p $PROCPID | perl -ne 'push @t, /\((\d+)\)/g; END { print join ",", @t }')
}

function lport () {
  if [ "$1" ]
  then
    netstat -anp 2>/dev/null|grep "$1"|grep LISTEN|awk '{print $4}'|grep -P -o "\d+"|grep -v "^0$"
  else
    echo "No process specified">&2
  fi
}

########################################################################
# news/weather
########################################################################
function weather() {
  if [ "$1" ]
  then
    CITY="$1"
  else
    CITY="83401"
  fi
  curl "wttr.in/$CITY"
}

########################################################################
# APT package management
########################################################################
function aptsearch() { apt-cache search "$1"; }

function aptsize() {
  dpkg-query --show --showformat='${Package;-50}\t${Installed-Size} ${Status}\n' | sort -k 2 -n | grep -v deinstall
}

########################################################################
# python package management
########################################################################
function pipup() {
  pip2 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip2 install -U
  pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U
}

########################################################################
# network
########################################################################
function sshscr()
{
  if [ "$1" ]
  then
    PNGNAME="sshscreencap_$(date +"%Y%m%d_%H%M%S").png"
    ssh "$@" 'DISPLAY=":0.0" import -window root png:-' > "$PNGNAME" && \
      echo "captured screenshot to \"$PNGNAME\"" || \
      rm -f "$PNGNAME" >/dev/null 2>&1
  else
    echo "No ssh parameters specified">&2
  fi
}

function server()
{
    local port="${1:-8000}"
    sleep 1 && open "http://localhost:${port}/" &
    # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
    # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
    python2 -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

########################################################################
# date/time
########################################################################
function dateu()
{
  if [ "$1" ]
  then
    echo $(date -u -d @$1);
  else
    echo "No UNIX time specified">&2
  fi
}

function udate()
{
  if [ "$1" ]
  then
    date -u +%s -d "$1"
  else
    date -u +%s
  fi
}

function sec2dhms() {
  declare -i SS="$1" D=$(( SS / 86400 )) H=$(( SS % 86400 / 3600 )) M=$(( SS % 3600 / 60 )) S=$(( SS % 60 )) [ "$D" -gt 0 ] && echo -n "${D}:" [ "$H" -gt 0 ] && printf "%02g:" "$H" printf "%02g:%02g\n" "$M" "$S"
}

########################################################################
# GIT
########################################################################
function current_git_branch ()
{
  (git symbolic-ref --short HEAD 2>/dev/null) | sed 's/development/dvl/' | sed 's/origin/org/' | sed 's/patch/pat/' | sed 's/tpc/tpc/' | sed 's/master/mas/'
}

function parse_git_remote_info ()
{
  (git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null) | sed 's/development/dvl/' | sed 's/origin/org/' | sed 's/patch/pat/' | sed 's/topic/tpc/' | sed 's/master/mas/'
}

function parse_git_branch ()
{
  GIT_BRANCH=$(current_git_branch)
  if [ ! -z "$GIT_BRANCH" ]; then
    GIT_REMOTE=$(parse_git_remote_info)
    if [ ! -z "$GIT_REMOTE" ]; then
      echo "[$GIT_BRANCH -> $GIT_REMOTE]"
    else
      echo "($GIT_BRANCH)"
    fi
  fi
}

########################################################################
# development
########################################################################
function cmdfu () {
  curl "https://www.commandlinefu.com/commands/matching/$@/$(echo -n $@ | openssl base64)/plaintext";
}

function goog() {
  search=""
  for term in $*; do
    search="$search%20$term"
  done
  open "https://www.google.com/search?ie=utf-8&oe=utf-8&q=$search"
}

function googcli {
  Q="$@";
  GOOG_URL='https://www.google.com/search?tbs=li:1&q=';
  AGENT="Mozilla/4.0";
  stream=$(curl -A "$AGENT" -skLm 20 "${GOOG_URL}${Q//\ /+}" | grep -oP '\/url\?q=.+?&amp' | sed 's|/url?q=||; s|&amp||');
  echo -e "${stream//\%/\x}";
}

function wiki() {
  search=""
  for term in $*; do
    search="$search%20$term"
  done
  open "http://en.wikipedia.org/w/index.php?search=$search"
}

function stackoverflow() {
  search=""
  for term in $*; do
    search="$search%20$term"
  done
  open "http://stackoverflow.com/search?q=$search"
}

function urlencode() {
    # urlencode <string>
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c"
        esac
    done
}

function urldecode() {
    # urldecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

########################################################################
# system
########################################################################
function find_linux_root_device() {
  local PDEVICE=`stat -c %04D /`
  for file in $(find /dev -type b 2>/dev/null) ; do
    local CURRENT_DEVICE=$(stat -c "%02t%02T" $file)
    if [ $CURRENT_DEVICE = $PDEVICE ]; then
      ROOTDEVICE="$file"
      break;
    fi
  done
  echo "$ROOTDEVICE"
}

function rotationals() {
  for f in /sys/block/sd?/queue/rotational; do printf "$f is "; cat $f; done
}

function schedulers() {
  for f in /sys/block/sd?/queue/scheduler; do printf "$f is "; cat $f; done
}

function watch_file_size() {
  perl -e '
  $file = shift; die "no file [$file]" unless ((-f $file) || (-d $file));
  $isDir = (-d $file);
  $sleep = shift; $sleep = 1 unless $sleep =~ /^[0-9]+$/;
  $format = "%0.2f %0.2f\n";
  while(1){
    if ($isDir) {
      $size = `du -0scb $file`;
      $size =~ s/\s+.*//;
    } else {
      $size = ((stat($file))[7]);
    }
    $change = $size - $lastsize;
    printf $format, $size/1024/1024, $change/1024/1024/$sleep;
    sleep $sleep;
    $lastsize = $size;
  }' "$1" "$2"
}

function dux() {
  du -x --max-depth=1|sort -rn|awk -F / -v c=$COLUMNS 'NR==1{t=$1} NR>1{r=int($1/t*c+.5); b="\033[1;31m"; for (i=0; i<r; i++) b=b"#"; printf " %5.2f%% %s\033[0m %s\n", $1/t*100, b, $2}'|tac
}

function tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

function mountcrypt() {
  if [ "$1" ]
  then
    if [ "$2" ]
    then
      sudo /sbin/cryptsetup luksOpen "$1" "$2"
      pmount -A -e "/dev/mapper/$2"
    else
      echo "No map name specified">&2
    fi
  else
    echo "No file specified">&2
  fi
}

function umountcrypt() {
  if [ "$1" ]
  then
    pumount "/media/mapper_$1"
  else
    echo "No map name specified">&2
  fi
}

function dirtydev() {
  while true; do cat /sys/block/$1/stat|cols 9; grep -P "(Dirty)\b" /proc/meminfo; sleep 1; done
}

function cpuuse() {
  if [ "$1" ]
  then
    SLEEPSEC="$1"
  else
    SLEEPSEC=1
  fi
   { cat /proc/stat; sleep "$SLEEPSEC"; cat /proc/stat; } | \
      awk '/^cpu / {usr=$2-usr; sys=$4-sys; idle=$5-idle; iow=$6-iow} \
      END {total=usr+sys+idle+iow; printf "%.2f\n", (total-idle)*100/total}'
}

########################################################################
# things I want to nohup
########################################################################
function sublime() {
  nohup "/opt/sublime_text/sublime_text" $@ </dev/null >/dev/null 2>&1 &
}

function subl() {
  sublime "$@"
}
