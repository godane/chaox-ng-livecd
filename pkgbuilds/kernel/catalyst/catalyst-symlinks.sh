_symlist="/etc/chaox-opengl-tools/catalyst-symlinks"
rm $_symlist
for lib in /usr/lib/catalyst/*.so*
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
if [ -h /usr/lib/xorg/modules/drivers/fglrx_drv.so ]
then
  _ln /usr/lib/catalyst/modules/drivers/fglrx_drv.so /usr/lib/xorg/modules/drivers/fglrx_drv.so 
elif [ ! -e /usr/lib/xorg/modules/drivers/fglrx_drv.so ]
then
  _ln /usr/lib/catalyst/modules/drivers/fglrx_drv.so /usr/lib/xorg/modules/drivers/fglrx_drv.so 
else
  echo "there is already a library of the same name available, bailing out" && return 2
fi
for ext in /usr/lib/catalyst/modules/extensions/*.so*
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
if [ -h /lib/modules/$(uname -r)/kernel/drivers/video/fglrx.ko ]
then
  _ln /usr/lib/catalyst/modules/$(uname -r)/video/fglrx.ko /lib/modules/$(uname -r)/kernel/drivers/video/fglrx.ko
  depmod -A
elif [ ! -e /lib/modules/$(uname -r)/kernel/drivers/video/fglrx.ko ]
then
  _ln /usr/lib/fglrx/modules/$(uname -r)/video/fglrx.ko /lib/modules/$(uname -r)/kernel/drivers/video/fglrx.ko
  depmod -A
else
  echo "there is already a module of the same name available, bailing out" && exit 2
fi
