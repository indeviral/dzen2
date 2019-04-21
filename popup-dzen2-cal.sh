#!/bin/bash
source ./dzen2.conf
$(kill_popup)
day=$(date +%e)
year=$(date +%Y)
month=$(date +%-m)
while :; do
if [ -f $tmp ];then
  dzen_cal_var=$(cat $tmp)
else
  dzen_cal_var=
fi
if [[ $dzen_cal_var == + ]]; then
  if (( "$month" > "11" )); then
    month=$(( $month - 11 ))
    year=$(( $year + 1 ))
  else
    month=$(( $month + 1 ))
  fi
elif [[ $dzen_cal_var == - ]]; then
  if (( "$month" < "2" )); then
    month=$(( $month + 11 )) 
    year=$(( $year - 1 ))
  else
    month=$(( $month - 1 ))
  fi
fi  
date=$(cal -m  $month $year | awk NR==1'{print $1" "$2}')
back="^ca(1,echo - > $tmp)^pa(0) < ^pa(40)^ca()"
next="^ca(1,echo + > $tmp)^pa(150) > ^pa()^ca()"
echo "$back$fg1$date$fc0$next" > $tmp
if [[ $month-$year == $(date +%-m-%Y) ]]; then 
  cal -m  $month $year | tail -7 | sed "s/${day}\b/${fg3}${day}${fc0}/" >> $tmp
else
  cal -m  $month $year | tail -7 >> $tmp
fi
cat $tmp
sleep 1
done | dzen2 -title-name "$title" -p -e "$exp2" -fn "$font" -w 200 -sa c -u -l 7 -y 24 -h 20 -x -200 
