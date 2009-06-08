#!/bin/bash
_usage() {
  echo "$0 action [arguments]"
  echo "action can be:"
  echo "list (list opengl implementations)"
  echo "set [opengl-implementation] (set specific opengl implementation)"
}
if [ "$#" -lt 1 ]
  then
    _usage
fi
if [ "$1" == "list" ]
then
  ls /usr/share/select-opengl/functions/* |sed -e 's/-symlinks.sh//g'
elif [ "$1" == "set" ]
  if [ -z $2 ]
  then
    echo "you must specify an opengl implementation"
  elif [ -e /usr/share/select/opengl/functions/$2-symlinks.sh ]
    source /usr/share/select/opengl/functions/$2-symlinks.sh
  else 
    echo "implementation doesn't exist, check $0 list"
  fi
else
  _usage 
fi
