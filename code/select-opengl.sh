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
    exit 1
fi
if [ "$1" == "list" ]
then
  for func in /usr/share/select-opengl/functions/*
  do
    ls $func |sed -e 's/-symlinks.sh//g'|xargs basename
  done
elif [ "$1" == "set" ]
then
  if [ -z $2 ]
  then
    echo "you must specify an opengl implementation"
  elif [ -e /usr/share/select-opengl/functions/$2-symlinks.sh ]
  then
    source /usr/share/select-opengl/functions/$2-symlinks.sh
  else 
    echo "implementation doesn't exist, check $0 list"
  fi
else
  _usage
  exit 1
fi
