_symlist="/etc/chaox-opengl-tools/xorg-symlinks"
rm -f $_symlist
for lib in /usr/lib/xorg/*.so*
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
for ext in /usr/lib/xorg/modules/_extensions/*.so*
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
