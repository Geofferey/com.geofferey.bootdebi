#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode
# More info in the main Magisk thread


#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will work
# if Magisk changes it's mount point in the future

PATH=/system/bin:/sbin:/sbin/.core/busybox:/system/xbin

MODDIR=${0%/*}

IMGDIR=/sbin/.magisk/img
UPDDIR=/data/adb/modules_update
id=com.geofferey.bootdebi

if [ -e ${UPDDIR}/${id}/bootdebi/scripts/bootdebi ]; then

    HOME=${UPDDIR}/${id}

elif [ -e ${IMGDIR}/${id}/bootdebi/scripts/bootdebi ]; then

    HOME=${IMGDIR}/${id}

else

    HOME=${MODDIR}

fi

bootdebi_dir=${HOME}/bootdebi

sed -i -e"s:^bootdebi_dir=.*:bootdebi_dir=${bootdebi_dir}:" /sbin/.magisk/img/com.geofferey.bootdebi/bootdebi/conf/bootdebi.conf 

ln -sf ${HOME}/bootdebi/scripts/bootdebi /sbin/bootdebi

ln -sf ${HOME}/bootdebi/scripts/bootdebi_login /sbin/login

ln -sf ${HOME}/bootdebi/scripts/bootdebi-config /sbin/bootdebi-config

ln -sf ${HOME}/bash /sbin/bash

su -M -c $bootdebi_dir/scripts/bootdebi start

exit 0
