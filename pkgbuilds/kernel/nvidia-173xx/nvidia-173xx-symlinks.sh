_symlist="/etc/chaox-opengl-tools/nvidia-173xx-symlinks"
rm $_symlist
for lib in /usr/lib/nvidia-173xx/*.so*
do
  if [ -h /usr/lib/$(basename "$lib") ]
  then
    _ln $lib /usr/lib/$(basename "$lib") 
  elif [ ! -e /usr/lib/$(basename "$lib") ]
  then
    _ln $lib /usr/lib/$(basename "$lib") 
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
if [ -h /usr/lib/xorg/modules/drivers/nvidia_drv.so ]
then
  _ln /usr/lib/nvidia-173xx/modules/drivers/nvidia_drv.so /usr/lib/xorg/modules/drivers/nvidia_drv.so 
elif [ ! -e /usr/lib/xorg/modules/drivers/nvidia_drv.so ]
then
  _ln /usr/lib/nvidia-173xx/modules/drivers/nvidia_drv.so /usr/lib/xorg/modules/drivers/nvidia_drv.so 
else
  echo "there is already a library of the same name available, bailing out" && return 2
fi
for ext in /usr/lib/nvidia-173xx/modules/extensions/*.so*
do
  if [ -h /usr/lib/xorg/modules/extensions/$(basename $ext) ]
  then
    _ln $ext /usr/lib/xorg/modules/extensions/$(basename $ext) 
  elif [ ! -e /usr/lib/xorg/modules/extensions/$(basename $ext) ]
  then
    _ln $ext /usr/lib/xorg/modules/extensions/$(basename $ext) 
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
if [ -h /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko ]
then
  _ln /usr/lib/nvidia-173xx/modules/$(uname -r)/nvidia.ko /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko 
  depmod -A
elif [ ! -e /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko ]
then
  _ln /usr/lib/nvidia-173xx/modules/$(uname -r)/nvidia.ko /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko 
  depmod -A
else
  echo "there is already a module of the same name available, bailing out" && exit 2
fi
if [ -h /usr/lib/xorg/modules/extensions/libdri.so ]
then
  _ln /usr/lib/xorg/modules/_extensions/libdri.so /usr/lib/xorg/modules/extensions/libdri.so
elif [ ! -e /usr/lib/xorg/modules/extensions/libdri.so ]
then
  _ln /usr/lib/xorg/modules/_extensions/libdri.so /usr/lib/xorg/modules/extensions/libdri.so
else
  echo "there is already a library of the same name available, bailing out" && return 2
fi

