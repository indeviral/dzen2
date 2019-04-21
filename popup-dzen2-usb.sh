#!/bin/bash
source dzen2.conf
$(kill_popup)
mnt(){
cformat=`lsblk -dnro FSTYPE "/dev/$1"`
mkdir /media/mnt-$1
#chown $cuser:$cuser /media/mnt-$1
if [[ "$1" == "mtp" ]];then
  simple-mtpfs /media/mnt-$1 | cerr $1
#elif [[ "$1" == "nikon" ]]; then
#  su $cuser -c "simple-mtpfs /dev/libmtp-nikon /media/mnt-$1" | cerr $1
else
  case "$cformat" in
    ntfs) opt_mount="uid=1000,fmask=113,dmask=002,utf8" ;;
    *) opt_mount="uid=1000,utf8";;
  esac
  sudo mount /dev/$1 /media/mnt-$1 -o $opt_mount 
fi
if [[ -n $(pidof vifm) ]]; then    
  vifm --remote -c "cd /media/mnt-$1"
fi
}

umnt(){
sudo umount /media/mnt-$1
rmdir /media/mnt-$1
}

ctrl(){
script="ctrl-dzen2-usb.sh"
mass_dev=($(ls /dev/* | grep "sd[c-z]\|mmc")) 
int=1
for i in ${!mass_dev[*]}; do
  _dev=$(basename ${mass_dev[$i]})
  _fs=$(lsblk -dnro FSTYPE /dev/$_dev)
  _size=$(lsblk -dnro SIZE /dev/$_dev)
  _fm=$(findmnt /dev/$_dev)
  if [[ -n $_fs ]];then
    if [[ -z $_fm ]];then
      mass+="^pa(20)$int: $_dev ^pa(220)$_size^pa(290)$_fs^pa(350)"
      mass+="${fg1}^ca(1,bash $script mnt $_dev)mount^ca()${fc0}^pa()\n"
    else
      mass+="^pa(20)$int: $_dev ^pa(220)$_size^pa(290)$_fs^pa(350)"
      mass+="${fg1}^ca(1,bash $script umnt $_dev)umount^ca()${fc0}^pa()\n"  
    fi
    int=$(( $int + 1 ))
  fi
done
#if [[ -n $(mtp-detect | grep OK.) ]]; then 
#mass+="MTP:\n"
#mass_mtp=$(simple-mtpfs -l | awk '{print $2 $3 $4}')
#for i in ${!mass_mtp[*]}; do
#  _dev="${mass_mtp[$i]}"
#  _fm=$(findmnt /media/mnt-mtp)
#  if [[ -z $_fm ]];then
#    mass+="^pa(20)${fg3}$_dev^pa(250)^ca(1,$script mnt mtp)mount^ca()${fc0}^pa()\n"
#  else
#    mass+="^pa(20)${fg3}$_dev^pa(250)^ca(1,$script umnt mtp)umount^ca()${fc0}^pa()\n"  
#  fi
#done
#fi



echo -en "$mass"
}
if [[ -n $(ctrl) ]]; then
line=$(( `ctrl | wc -l` + 1 ))
(echo "^pa(20)name ^pa(220)size ^pa(290)fs ^pa(350)state"
while :; do
  echo "$(ctrl)
  " > $tmp
  cat $tmp
  line2=$(( `ctrl | wc -l` + 1 ))
  if [[ $line != $line2 ]]; then
    $(kill_popup)
  fi
sleep 1
done) | dzen2 -title-name "$title" -p -y 24 -x -400 -w 400 -ta l -l $line -fn "$font" -e "$exp2"
fi
