#!/bin/sh

BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="$BASEDIR/script"

sh $BASEDIR/initsvc_uperf.sh >/sdcard/yc/uperf/init_uperf.txt
sh -c "sleep 10s && settings put Secure speed_mode_enable" &
sh -c "am kill com.miui.daemon;pm disable com.miui.daemon" &
sh -c "am kill com.mediatek.duraspeed;pm disable com.mediatek.duraspeed" &
sh -c "sleep 120s;chmod 777 /sys/kernel/eara_thermal/enable ; echo 0 >/sys/kernel/eara_thermal/enable ;chmod 444 /sys/kernel/eara_thermal/enable" &
sh -c "sleep 120s;chmod 777 /sys/kernel/eara_thermal/fake_throttle ; echo 1 >/sys/kernel/eara_thermal/fake_throttle ;chmod 444 /sys/kernel/eara_thermal/fake_throttle" &
sleep 120s
isstart=`pgrep Uperf`
chmod +x $BASEDIR/bin/uperf
$BASEDIR/bin/uperf -o /sdcard/yc/uperf/log_uperf.txt /sdcard/yc/uperf/cfg_uperf.json
sleep 15s
while [ $isstart = ""] ;do
echo "uperf not loaded">/sdcard/yc/uperf/init_uperf.tx
chmod +x /data/uperf//bin/uperf
$BASEDIR/bin/uperf -o /sdcard/yc/uperf/log_uperf.txt
isstart=`pgrep Uperf`
sleep 15s
done
exit 0