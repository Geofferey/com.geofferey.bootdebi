clear
echo

export host=android
export HOME=/data/home/$(whoami)

if ! [ -d /data/home ] && [ $(whoami) = root ]; then

  mkdir -p /data/home
  chmod 730 /data/home
  chown root:everybody /data/home
  chcon u:object_r:app_data_file:s0 /data/home

fi

if [ -d /data/home ] && ! [ -d $HOME ]; then

  mkdir -p $HOME
  chmod 700 $HOME
  
fi

export HOSTNAME=$(getprop ro.product.device)
export TERM=xterm
export TMPDIR=/data/local/tmp
export USER=$(whoami)
export TIME=$(date '+%H:%M')
export TZ="/system/usr/share/zoneinfo/Pacific"
export GREP_COLOR='1;36'

if [ -d "/sbin/.magisk/busybox" ]; then
  BBDIR=":/sbin/.magisk/busybox"
elif [ -d "/sbin/.core/busybox" ]; then
  BBDIR=":/sbin/.core/busybox"
fi

PATH=$PATH:/system/bin:/system/xbin:/sbin

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

# Expand the history size
export HISTFILE=$HOME/.bash_history
HISTFILESIZE=10000
HISTSIZE=100
# ... and ignore same sucessive entries.
HISTCONTROL=ignoreboth

cdn() {
  cmd=""
  for (( i=0; i < $1; i++)) do
    cmd="$cmd../"
  done
  cd "$cmd"
}
setpriority() {
case $2 in
    high) su -c cmd overlay set-priority $1 lowest
          su -c cmd overlay set-priority $1 highest;;
    low) su -c cmd overlay set-priority $1 highest
         su -c cmd overlay set-priority $1 lowest;;
    *) echo "Usage: setpriority overlay [option]"
       echo " "
       echo "Options:"
       echo " high - Sets the overlay to the highest priority"
       echo " low  - Sets the overlay to the lowest priority";;
  esac
}
adbfi() {
  case $1 in
    on) setprop service.adb.tcp.port 5555
        su -c stop adbd
        su -c start adbd
        echo "ADB over WiFi enabled";;
    off) setprop service.adb.tcp.port -1
         su -c stop adbd
         su -c start adbd
         echo "ADB over WiFi disabled";;
    stats) case `getprop service.adb.tcp.port` in -1) echo "off";; 5555) echo "on";; *) echo "off";; esac;;
    *) echo "Usage: adbfi [option]"
       echo " "
       echo "Options:"
       echo " on    - Enables ADB over Wifi"
       echo " off   - Disables ADB over WiFi"
       echo " stats - Gets current status";;
  esac
}

if [ -e /sdcard/.aliases ]; then
. /sdcard/.aliases >> /dev/null 2>&1
fi

if [ -e ~/.aliases ]; then
. ~/.aliases >> /dev/null 2>&1
fi

# establish colours for PS1

red_p="\e[1;31m\]"
blue_p="\e[1;34m\]"
green_p="\e[1;32m\]"
cyan_p="\e[1;36m\]"
light_cyan_p="\e[1;96m\]"
purple_p="\e[1;35m\]"
blank_p="\e[m\]"
yellow_p="\e[1;33m\]"

trap 'echo -ne "\e[1;33m"' DEBUG

echo "$(uname -a)" "$(getprop ro.build.display.id)"
echo 
date
echo
uptime | cut -d ' ' -f3- | tr -d '\n'

# Sexy af PS1

if [ $(whoami) = root ]; then

trap 'echo && echo -ne "\e[1;32m"' DEBUG

export PS1="\n$yellow_p┌[\T]$yellow_p-$red_p[$USER@$HOSTNAME]$yellow_p-[$cyan_p\!$yellow_p]-[\W]:\n$yellow_p└─$yellow_p # $light_cyan_p"

else

#trap 'echo' DEBUG

trap 'echo && echo -ne "\e[1;32m"' DEBUG

export PS1="
$yellow_p┌[\@]$blue_p [$USER] $cyan_p[\W]\n$yellow_p└─$yellow_p $ $cyan_p"

fi

