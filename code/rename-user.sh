#!/bin/bash
# Rename the livecd user, move the homedir and add a password

_usage() {
  echo "$0 newusername"
  echo "$0 oldusername newusername"
  exit 1
}

_rename() {
  local olduser="$1"
  local newuser="$2"
  sed -i "s/$olduser/$newuser/g" /home/$olduser/.config/xfce4/panel/xfce4-menu-12322101260.rc
  usermod -m -d /home/$newuser -l $newuser $olduser || exit 1
}

if [ $(id -u) -ne 0 ]
then
  echo "You need root priviledges for this script to work" > /dev/stderr
  exit 1
fi

if [ $# -eq 0 ]
then
  _usage
elif [ $# -eq 1 ]
then
  _rename livecd $1
  passwd $1
elif [ $# -eq 2 ]
  _rename $1 $2
  passwd $2
else
  _usage
fi
