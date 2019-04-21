source ./dzen2.conf
$(kill_popup)
seek(){
state=$(xbacklight -get | cut -f1 -d.)
for i in {1..100}; do
  if (( $i < $state )); then
    seek+="^ca(1,xbacklight -set $i)$fg3^r(2x6)$fc0^ca()"
  elif (( $i == $state )); then
    seek+="$fg1^r(4x10)$fc0" 
  else
    seek+="^ca(1,xbacklight -set $i)$fg2^r(2x6)$fc0^ca()" 
  fi
done
echo "^pa(25)bright: $seek^pa()"
}
while :; do
  echo "
  $(seek)
  " > $tmp
  cat $tmp
sleep 1
done | dzen2 -title-name "$title" -p -y 24 -x -310 -w 310 -l 2 -sa l -h 12 -u  -fn "$font" -e "$exp2"
