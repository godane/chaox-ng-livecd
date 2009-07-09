#!/bin/bash
# error codes:
# 1) partition/drive is mounted
# 2) user exit
# 3) failed to mount chaox
# log file:
LOG=/var/log/write_usb.log
_tmp_file=$(mktemp)
add_persistable() {
  _drive=$1
  # cylinder size
  cylsize="$(sfdisk -l $_drive |awk -F"cylinders of " '{print $2}'|awk -F" bytes" '{print $1}'|sed '/^$/d')"
  # convert drivesize to number of cylinders
  udi="$(hal-find-by-property --key block.device --string $_drive)"
  drivesize_in_cyl="$(( $(hal-get-property --udi $udi --key storage.removable.media_size) / $cylsize ))"
  pers_start_cyl="$(sfdisk -l $_drive|grep ${_drive}1|awk '{print $5}')"
  # maximum partition size in cyl
  max_size_in_cyl="$(( $drivesize_in_cyl - $pers_start_cyl ))"
  if zenity --entry --title "Adding persistable changes"\
    --text "Enter the size of the persistable storage in MB, leave it at 0 for using the rest of the drive.If you specify a size larger than the capacity of the usb drive the storage will be as large as possible."\
    --entry-text "0" >$_tmp_file
  then
    storage_size="$(<$_tmp_file)"
    storage_size="$(( $storage_size * 1024 * 1024 ))"
    storage_size_in_cyl="$(( $storage_size / $cylsize ))"
    if [ $storage_size = 0 ]
    then
      if  ! create_partition $max_size_in_cyl
      then
        zenity --error --text "Failed to create partition, please report this error and include $LOG in your report"
      fi
    elif [ $storage_size_in_cyl > $max_size_in_cyl ]
    then
      if ! create_partition $max_size_in_cyl
      then
        zenity --error --text "Failed to create partition, please report this error and include $LOG in your report"
      fi
    else
      if ! create_partition $storage_size_in_cyl
      then
        zenity -error --text "Failed to create partition, please report this error and include $LOG in your report"
      fi
    fi
    zenity --info --title "Success!" --text "Successfully created persistable storage, you are ready to go now"
    exit
  else
    exit 2
  fi
}
# most of this function from http://www.unixboard.de/vb3/showthread.php?t=43210
copy_image() {
  _in=$1
  _out=$2
  rm $_tmp_file
  touch $_tmp_file
  dd if=$_in of=$_out 2>$_tmp_file &
  ddpid=$!
  if [ $3 = chaox ]
  then
    tmp_mnt_point=$(mktemp -d)
     if mount $_in $(mktemp -d) >>$LOG 2>&1
     then
      image_size=$(($(df |grep $_in|awk '{print $2}') * 1024))
      umount $_in
      rm -r $tmp_mnt_point
    else
      zenity --error --text "Failed to calculate size of chaox image. Please report the error and include  $LOG in your report."
      exit 3
    fi
  else
    image_size=$(du -b $_in)
  fi
  while [ -d /proc/$ddpid ]
  do
	  sleep 1
    kill -USR1 $ddpid
    if [ -s $_tmp_file ]
    then
      currentprogress="$(tail -n 1 $_tmp_file|awk '{print $1}')"
      echo "$(( $(echo $currentprogress) * 100 / $image_size ))"
    fi
  done|zenity --progress --text "Copying image"
}
create_partition() {
  _partsize="$1"
  sfdisk -f -N 2 $_drive >>$LOG 2>&1 <<EOF
${pers_start_cyl},${_partsize},L  
EOF
  mke2fs ${_drive}2 >>$LOG 2>&1
}
get_chaox_live_image() {
  grep "/bootmnt" /proc/mounts |awk '{print $1}'
}
get_usb_storage_details() {
  for udi in $(hal-find-by-capability --capability storage)
  do
    if [[ $(hal-get-property --udi $udi --key storage.bus) = "usb" ]]
    then
      device=$(hal-get-property --udi $udi --key block.device)
      vendordesc="$(hal-get-property --udi $udi --key storage.vendor) $(hal-get-property --udi $udi --key storage.model)"
      size="$(($(hal-get-property --udi $udi --key storage.removable.media_size)/$((1000*1000*1000))))"
      echo "" 
      echo "$device" 
      echo "$vendordesc $size GB"
    fi
  done
}
zenity --warning --text "This script will write the chaox image to your usb thumb drive or hard disc. You have to be *absolutly sure* to pick the correct drive. All data on the drive will be lost. The thunar service will be stopped, as it might interfere with partitioning. It will be restarted after you exit the installer."
get_usb_storage_details|zenity --list --radiolist --text "Which device do you want to write the image to?" --title "Disk choice" --column "" --column Device --column "Vendor description" > $_tmp_file
_selected_drive=$(<$_tmp_file)
if grep -q $_selected_drive /proc/mounts
then
  zenity --error --text "The drive or partitions from the drive are mounted. Make sure they are umounted and run this script again"
  rm -f $_tmp_file
  exit 1
fi
if [[ $(hostname) == chaox ]]
then
  THUNAR_IS_STARTED=$(su livecd -c 'dbus-send --session --type=method_call --print-reply --dest=org.freedesktop.DBus / org.freedesktop.DBus.NameHasOwner string:"org.xfce.Thunar"' | grep -q 'boolean true'; echo $?)
  if [ $THUNAR_IS_STARTED -eq 0 ]
  then
    trap 'su livecd -c "dbus-send --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.StartServiceByName string:org.xfce.Thunar uint32:0"' EXIT
    su livecd -c "dbus-send --session --dest=org.xfce.Thunar --type=method_call /org/xfce/FileManager org.xfce.Thunar.Terminate"
  fi
  if zenity --question --text "It seems like you're running from the chaox live environment, do you want me to copy the running image to ${_selected_drive}?"
  then
    if zenity --question --text "Starting image write now. This is your last chance to bail out. Continue?"
    then
      if copy_image $(get_chaox_live_image) $_selected_drive chaox
      then
        if zenity --question --text "Image was successfully written, do you want to create a partition for persistable changes?"
        then
          add_persistable $_selected_drive
        fi
      else
        exit 2
      fi
    else
      exit 2
    fi
  fi
else
  zenity --info --text "Please select the image file you want to write to the usb drive"
  image_file="$(zenity --file-selection --title "select image file")"
  if [ $? = 0 ]
  then
    if zenity --question --text "Starting image write now. This is your last chance to bail out. Continue?"
    then
      if copy_image "$image_file" $_selected_drive
      then
        if zenity --question --text "Image was successfully written, do you want to create a partition for persistable changes?"
        then
          add_persistable $_selected_drive
        fi
      else
        exit 2
      fi
    else
      exit 2
    fi
  else
    exit 2
  fi
fi
