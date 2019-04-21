#!/bin/bash
source ./dzen2.conf
$(kill_popup)
export MPD_HOST=$1
export MPD_PORT=$2
host(){
if [[ $MPD_HOST == home.loc ]]; then
  host='MPD (remote)'
else
  host='MPD (local)'
fi
echo "$host"
}
ctrl(){
ctrl+="^p(20)$fg1^ca(1,mpc -q prev)< prev ^ca()"
if [[ -n $(mpc | grep playing) ]];then
  ctrl+="^ca(1,mpc -q toggle ) pause ^ca()"
else
  ctrl+="^ca(1,mpc -q toggle ) start ^ca()"
fi
ctrl+="^ca(1,mpc -q stop && pkill -f $prefix ) stop ^ca()"
if [[ $(mpc | grep random | awk '{print $6}') == on ]]; then
  ctrl+="$fg3^ca(1,mpc -q random ) rand ^ca()$fg1" 
else
  ctrl+="$fc0^ca(1,mpc -q random ) rand ^ca()$fg1" 
fi
ctrl+="^ca(1,mpc -q next) next >^ca()$fc0^p()"
ctrl+="^p(50)$(mpc | awk NR==2'{print $3}')^p()"
echo "$ctrl"
}
seek(){
state=$(mpc | awk NR==2'{print $4}' | grep -o '[0-9]*')
for i in {1..100}; do
  if (( $i < $state )); then
    seek+="^ca(1,mpc -q seek $i%)$fg3^r(4x4)$fc0^ca()"
  elif (( $i == $state )); then
    seek+="$fg1^r(4x8)$fc0"
  else
    seek+="^ca(1,mpc -q seek $i%)$fg2^r(4x4)$fc0^ca()" 
  fi
done
echo "^pa(20)$seek^pa()"
}
playlist(){
current=$((`mpc | awk NR==2'{print $2}' | grep -o '[0-9]*' | head -1` - 1))
IFS=$'\n' mpc_playlist=($(mpc playlist)) 
for i in ${!mpc_playlist[*]}; do
  if [[ $i == $current ]]; then
    playlist+="^pa(20)${fg3}${mpc_playlist[$i]}${fc0}^pa()\n"
    for num in $(seq $(( $i + 1 ))  $(( $i + 4 ))); do
      playlist+="^pa(20)${mpc_playlist[$num]}^pa()\n"
    done 
  fi
done
echo -en "$playlist"
}
(echo "$(host)"
while :; do
if [[ -n $(mpc | grep "playing\|pause") ]];then
  echo "$(ctrl)
  $(seek)
  $(playlist)
  " > $tmp
  cat $tmp
else
  $(kill_popup)
fi
sleep 1
done) | dzen2 -title-name "$title" -p -y 24 -x -450 -l 8 -w 450 -ta c -fn "$font" -e "$exp2"
