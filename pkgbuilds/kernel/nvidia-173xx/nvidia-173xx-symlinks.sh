for lib in /usr/lib/nvidia-173xx/*.so*
do
  if [ -h /usr/lib/$(basename "$lib") ]
  then
    ln -sf $lib /usr/lib/$(basename "$lib")
  elif [ ! -e /usr/lib/$(basename "$lib") ]
  then
    ln -sf $lib /usr/lib/$(basename "$lib")
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
if [ -h /usr/lib/xorg/modules/drivers/nvidia_drv.so ]
then
  ln -sf /usr/lib/nvidia-173xx/driver/nvidia_drv.so /usr/lib/xorg/modules/drivers/nvidia_drv.so
elif [ ! -e /usr/lib/xorg/modules/drivers/nvidia_drv.so ]
then
  ln -sf /usr/lib/nvidia-173xx/driver/nvidia_drv.so /usr/lib/xorg/modules/drivers/nvidia_drv.so
else
  echo "there is already a library of the same name available, bailing out" && return 2
fi
for ext in /usr/lib/nvidia-173xx/modules/extensions/*.so*
do
  if [ -h /usr/lib/xorg/modules/extensions/$(basename $ext) ]
  then
    ln -sf $ext /usr/lib/xorg/modules/extensions/$(basename $ext)
  elif [ ! -e /usr/lib/xorg/modules/extensions/$(basename $ext) ]
  then
    ln -sf $ext /usr/lib/xorg/modules/extensions/$(basename $ext)
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
if [ -h /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko ]
then
  ln -sf /usr/lib/nvidia-173xx/modules/$(uname -r)/nvidia.ko /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko
elif [ ! -e /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko ]
then
  ln -sf /usr/lib/nvidia-173xx/modules/$(uname -r)/nvidia.ko /lib/modules/$(uname -r)/kernel/drivers/video/nvidia.ko
else
  echo "there is already a module of the same name available, bailing out" && exit 2
fi
