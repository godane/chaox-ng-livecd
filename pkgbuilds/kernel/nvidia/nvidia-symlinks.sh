_symlist="/etc/chaox-opengl-tools/nvidia-symlinks"
rm $_symlist
for lib in /usr/lib/nvidia/*.so*
do
  if [ -h /usr/lib/$(basename "$lib") ]
  then
    _ln $lib /usr/lib/$(basename "$lib") $_symlist
  elif [ ! -e /usr/lib/$(basename "$lib") ]
  then
    _ln $lib /usr/lib/$(basename "$lib") $_symlist
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
if [ -h /usr/lib/xorg/modules/drivers/nvidia_drv.so ]
then
  _ln /usr/lib/nvidia/modules/drivers/nvidia_drv.so /usr/lib/xorg/modules/drivers/nvidia_drv.so $_symlist
elif [ ! -e /usr/lib/xorg/modules/drivers/nvidia_drv.so ]
then
  _ln /usr/lib/nvidia/modules/drivers/nvidia_drv.so /usr/lib/xorg/modules/drivers/nvidia_drv.so $_symlist
else
  echo "there is already a library of the same name available, bailing out" && return 2
fi
for ext in /usr/lib/nvidia/modules/extensions/*.so*
do
  if [ -h /usr/lib/xorg/modules/extensions/$(basename $ext) ]
  then
    _ln $ext /usr/lib/xorg/modules/extensions/$(basename $ext) $_symlist
  elif [ ! -e /usr/lib/xorg/modules/extensions/$(basename $ext) ]
  then
    _ln $ext /usr/lib/xorg/modules/extensions/$(basename $ext) $_symlist
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
if [ -h /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko ]
then
  _ln /usr/lib/nvidia/modules/$(uname -r)/nvidia.ko /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko $_symlist
  depmod -A
elif [ ! -e /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko ]
then
  _ln /usr/lib/nvidia/modules/$(uname -r)/nvidia.ko /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko $_symlist
  depmod -A
else
  echo "there is already a module of the same name available, bailing out" && exit 2
fi
