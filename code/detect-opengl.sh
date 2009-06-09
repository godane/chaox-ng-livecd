#!/bin/bash
# this little script is supposed to detect hardware which has closed source drivers
# if it finds matching hardware the kernel modules are loaded and necessary symlinks are made
#FIXME this propably won't work with several nvidia cards
# a lot of the script is taken from chakra: http://chakra-project.org/code/index.php/view/tools:/live-scripts/abs/chakra-hardware-detection/opt/chakra/hooks/hwdetect_6_graphics
# thanks guys!

nvidia_card=$(lspci -n | sed -n "s/.* 0300: 10de:\(....\).*/\1/p")
if [ -n $nvidia_card ]
then
  for dbentry in /usr/share/detect-opengl/nvidia*.db
  do
    grep $nvidia_card $dbentry
    dbentry_name=$(basename $dbentry .db)
    case "$dbentry_name" in 
      nvidia)
        select-opengl.sh nvidia
        modprobe nvidia
        ;;
      nvidia-173xx)
        select-opengl.sh nvidia-173xx
        modprobe nvidia
        ;;
      nvidia-96xx)
        select-opengl.sh nvidia-96xx
        modprobe nvidia
        ;;
      *)
        echo "no drivers for your nvidia hardware found"
        ;;
    esac
  done
else
 select-opengl.sh xorg
fi 
