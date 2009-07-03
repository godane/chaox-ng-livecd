#!/bin/bash
driver_select_menu() {
  dialog --backtitle "Select driver" --title "main menu" --cancel-label "quit" --menu "select your wifi driver" 17 60 10\
  rt73-k2wrlz "rt73 k2wrlz driver (ieee80211)"\
  rt73-rt2x00 "rt73 rt2x00 driver (mac80211)"\
  rt2570-kw2rlz "rt2570 k2wrlz driver (ieee80211)"\
  rt2570-rt2x00 "rt2570 rt2x00 driver (mac80211)"\
  r8187 "r8187 driver (ieee80211)"\
  rtl8187 "rtl8187 driver (mac80211)"\
  madwifi-newhal "madwifi-newhal driver (ieee80211)"\
  ath5k "ath5k driver (mac80211)" 2> /tmp/.driver-select.tmp
  if [ $? != 0 ]
  then
    exit; clear
  fi
  _selection="$(cat /tmp/.driver-select.tmp)"
  case $_selection in 	
    rt73-k2wrlz) rt73_k2wrlz;;
    rt73-rt2x00) rt73_rt2x00;;
    rt2570-k2wrlz) rt2570_k2wrlz;;
    rt2570-rt2x00) rt2570_rt2x00;;
    r8187) r8187;;
    rtl8187) rtl8187;;
    madwifi-newhal) madwifi_newhal;;
    ath5k) ath5k;;
  esac
}
down_iface_for_module() {
  module="$1"
  for iface in $(iwconfig 2>&1|grep IEEE|awk '{print $1}')
  do 
    if ls /sys/class/net/$iface/device/driver/module/drivers/ |grep -q "$module"
    then 
      sudo ifconfig $iface down
      sleep 3
    fi
  done
}
rt73_k2wrlz() {
  if lsmod |grep -q rt2x00lib
  then
    dialog --yesno "rt2x00 drivers are loaded, these have to be unloaded before we can load rt73-k2wrlz drivers - shall I do this for you?" 0 0
    if [ $? = 0 ]
    then
      down_iface_for_module rt73usb
      sudo rmmod rt2500usb 2>/dev/null
      sudo rmmod rt73usb 2>/dev/null
      sudo rmmod rt2x00usb 2>/dev/null
      sudo rmmod rt2x00lib 2>/dev/null
    else
      exit
    fi
  fi
  if $(sudo modprobe rt73)
  then
    dialog --msgbox "Successfully loaded rt73-k2wrlz driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}
rt73_rt2x00() {
  if lsmod |grep -q "rt73 "
  then
    dialog --yesno "rt73-k2wrlz drivers are loaded, these have to be unloaded before we can load rt73-rt2x00 drivers - shall I do this for you?" 0 0    
    if [ $? = 0 ]
    then
      down_iface_for_module rt73
      sudo rmmod rt73
    else
      exit
    fi
  fi
  if sudo modprobe rt73usb
  then
    dialog --msgbox "Successfully loaded rt73-rt2x00 driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}
rt2570_k2wrlz() {
  if lsmod |grep -q "rt2x00lib"
  then
    dialog --yesno "rt2x00 drivers are loaded, these have to be unloaded before we can load rt2570-k2wrlz drivers - shall I do this for you?" 0 0
    if [ $? = 0 ]
    then
      down_iface_for_module rt2500usb
      sudo rmmod rt2500usb 
      sudo rmmod rt2x00usb 2>/dev/null
      sudo rmmod rt2x00lib 2>/dev/null
    else
      exit
    fi
  fi
  if sudo modprobe rt2570
  then
    dialog --msgbox "Successfully loaded rt2570-k2wrlz driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}
rt2570_rt2x00() {
  if lsmod |grep -q "rt2570 "
  then
    dialog --yesno "rt2570-k2wrlz drivers are loaded, these have to be unloaded before we can load rt2570-rt2x00 drivers - shall I do this for you?" 0 0    
    if [ $? = 0 ]
    then
      down_iface_for_module rt73
      sudo rmmod rt73
    else
      exit
    fi
  fi
  if sudo modprobe rt73usb
  then
    dialog --msgbox "Successfully loaded rt73-rt2x00 driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}
r8187() {
  if lsmod |grep -q rtl8187
  then
    dialog --yesno "rtl8187 driver is loaded, it has to be unloaded before we can load r8187 driver - shall I do this for you?" 0 0    
    if [ $? = 0 ]
    then
      down_iface_for_module rtl8187
      sudo rmmod rtl8187
    else
      exit
    fi
  fi
  if sudo modprobe r8187
  then
    dialog --msgbox "Successfully loaded r8187 driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}
rtl8187() {
  if lsmod |grep -q r8187
  then
    dialog --yesno "r8187 driver is loaded, it has to be unloaded before we can load rtl8187 driver - shall I do this for you?" 0 0    
    if [ $? = 0 ]
    then
      down_iface_for_module r8187
      sudo rmmod r8187
    else
      exit
    fi
  fi
  if sudo modprobe rtl8187
  then
    dialog --msgbox "Successfully loaded rtl8187 driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}
madwifi_newhal() {
  if lsmod |grep -q ath5k
  then
    dialog --yesno "ath5k driver is loaded, it has to be unloaded before we can load madwifi-newhal driver - shall I do this for you?" 0 0    
    if [ $? = 0 ]
    then
      down_iface_for_module ath5k
      sudo rmmod ath5k
    else
      exit
    fi
  fi
  #FIXME very ugly workaround
  if sleep 3 && sudo modprobe ath_pci && sudo madwifi-unload >/dev/null && sudo modprobe ath_pci
  then
    dialog --msgbox "Successfully loaded madwifi-newhal driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}	    
ath5k() {
  if lsmod |grep -q ath_pci
  then
    dialog --yesno "madwifi driver is loaded, it has to be unloaded before we can load ath5k driver - shall I do this for you?" 0 0
    if [ $? = 0 ]
    then
      down_iface_for_module ath_pci
      sudo madwifi-unload >/dev/null 2>&1
    else
      exit
    fi
  fi
  if sudo modprobe ath5k
  then
    dialog --msgbox "Successfully loaded ath5k driver" 0 0
  else
    dialog --msgbox "Something went wrong, make sure you have a device supported by the driver and contact support" 0 0
  fi
}
dialog --msgbox "This script is regarded fairly experimental - it propably won't break anything, but don't be suprised if it fails. If it doesn't work please report the error, thanks." 0 0
while true
do
  driver_select_menu
done
