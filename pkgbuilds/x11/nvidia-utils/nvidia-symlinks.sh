for lib in /usr/lib/nvidia/*.so*
do
  if [ -h /usr/lib/$(basename "$lib") ]
  then
    ln -sf $lib /usr/lib/$(basename "$lib")
  elif [ ! -e /usr/lib/$(basename "$lib") ]
    ln -sf $lib /usr/lib/$(basename "$lib")
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
if [ -h /usr/lib/xorg/driver/nvidia_drv.so ]
then
  ln -sf /usr/lib/nvidia/driver/nvidia_drv.so /usr/lib/xorg/driver/nvidia_drv.so
elif [ ! -e /usr/lib/xorg/driver/nvidia_drv.so ]
  ln -sf /usr/lib/nvidia/driver/nvidia_drv.so /usr/lib/xorg/driver/nvidia_drv.so
else
  echo "there is already a library of the same name available, bailing out" && return 2
fi
for ext in /usr/lib/nvidia/modules/extensions/*.so*
do
  if [ -h /usr/lib/xorg/modules/extensions/$(basename $ext) ]
  then
    ln -sf $ext /usr/lib/xorg/modules/extensions/$(basename $ext)
  elif [ ! -e /usr/lib/xorg/modules/extensions/$(basename $ext) ]
    ln -sf $ext /usr/lib/xorg/modules/extensions/$(basename $ext)
  else
    echo "there is already a library of the same name available, bailing out" && return 2
  fi
done
