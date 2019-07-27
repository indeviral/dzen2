#!/bin/bash
rr
cd $(cd $(dirname $0) && pwd)
source ./dzen2.conf
#_usb(){
#usb=$(ls /dev/* | grep "sd[c-z]\|mmc")
#if [[ -n $usb ]]; then 
#  echo "$fg3^ca(1,./${prefix}usb.sh) usb ^ca()"
#fi
#}
_mus(){
if [[ -n `mpc | grep playing` ]];then
  export MPD_HOST="$HOME/.mpd/mpd.socket"
else
  export MPD_HOST="home.loc"
  export MPD_PORT="6600"
fi
title=$(mpc current -f %title% | sed -r 's/(.{,40}).*/\1/')
artist=$(mpc current -f %artist% | sed -r 's/(.{,40}).*/\1/')
file=$(mpc current -f %file% | sed -r 's/(.{,40}).*/\1/')
if [[ -n `mpc | grep playing` ]];then
  if [[ -n $artist ]]; then
    echo "$fg1^ca(1,./${prefix}mpd.sh $MPD_HOST $MPD_PORT) $artist - $fg3$title ^ca()"
  elif [[ -z $title && -z $artist ]]; then
    echo "$fg1^ca(1,./${prefix}mpd.sh $MPD_HOST $MPD_PORT) $file ^ca()"
  else
    echo "$fg1^ca(1,./${prefix}mpd.sh $MPD_HOST $MPD_PORT) $title ^ca()"
  fi
fi
}
_bri(){
bri=$(xbacklight -get | cut -f1 -d.)
if (( $bri <= "95" )); then
  echo "^ca(1,./${prefix}bri.sh) ${fg2}bri:${fg1}$bri ^ca()"
fi;
}
_vol(){
if ! ponymix is-muted; then
  vol=$(ponymix get-volume)
  echo "^ca(1,./${prefix}vol.sh) ${fg2}vol:${fg1}$vol ^ca()"
else
  echo "^ca(1,./${prefix}vol.sh) ${fg2}vol:${fg4}!mute ^ca()"
fi
}
_bat(){
bat=(`cat /sys/class/power_supply/BAT1/uevent | sed "s/POWER.*=//"`)
if [ ${bat[1]} == "Discharging" ]; then
  if (( ${bat[11]} >= 25 )); then
    echo " ${fg2}bat:${fg1}${bat[11]}${fc0} "
  elif (( ${bat[11]} < 25 )); then
    echo " ${fg2}bat:${fg4}!${bat[11]}${fc0} "
  fi
else
  if ((  ${bat[11]} <= 90 )); then
    echo " ${fg2}charge:$fg1${bat[11]}${fc0} "
  fi
fi
}
_net(){
lan_dev=(`ls /sys/class/net/`)
lan_st=(`cat /sys/class/net/*/operstate`)
for i in ${!lan_dev[*]}; do
  if [[ ${lan_st[$i]} == "up" ]]; then
  lan_ip=$(ip addr show wlp3s0 | grep -oP 'inet \K\S[0-9.]+')
#  lan_essid=$(iw dev wlp3s0 info | grep 'ssid' | awk '{print $2}')
    if [[ -n $lan_ip ]]; then
      echo " $fg1${lan_dev[$i]} "
    fi
  fi
done
}
_date(){
  echo "^ca(1,./${prefix}cal.sh) ${fg1}$(date "+%H:%M")${fc0} ^ca()" 
}
_lang(){
if [[ $(skb -1) == Eng ]]; then 
  echo " ${fg2}en "
else
  echo " ${fg2}ru "
fi
}
while true; do
  echo "$(_mus)$(_net)$(_bri)$(_vol)$(_bat)$(_date)$(_lang)"
  sleep 1
done | dzen2 -ta r -w 800 -x -800 -y 0 -h 24 -fn "$font" -e "$exp1"
