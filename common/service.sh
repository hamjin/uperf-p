#!/bin/sh

BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="$BASEDIR/script"

sh $BASEDIR/initsvc_uperf.sh
sh -c "sleep 10s && settings put Secure speed_mode_enable" &
sh -c "sleep 120s;chmod 777 /sys/kernel/eara_thermal/enable ; echo 0 >/sys/kernel/eara_thermal/enable ;chmod 444 /sys/kernel/eara_thermal/enable" &
sh -c "sleep 120s;chmod 777 /sys/kernel/eara_thermal/fake_throttle ; echo 1 >/sys/kernel/eara_thermal/fake_throttle ;chmod 444 /sys/kernel/eara_thermal/fake_throttle" &
exit 0