#!/bin/sh
BASEDIR="$(dirname $(readlink -f "$0"))"
MODDIR=${0%/*}
SCRIPT_DIR="$BASEDIR/script"
sh $BASEDIR/initsvc_uperf.sh

USER_PATH=/data/media/0/yc/uperf/
lock_value()
{
    
    for p in $2; do
        if [ -f "$p" ]; then
            echo "Locking $1 -> $p after boot " >>$USER_PATH/init_uperf.txt
            chmod 0666 "$p" 2> /dev/null
            echo "$1" > "$p"
            chmod 0444 "$p" 2> /dev/null
            echo "Locking $1 -> $p after boot Done! " >>$USER_PATH/init_uperf.txt
        fi
    done
}
detect_uperf()
{
    lock_value "0" /sys/kernel/eara_thermal/enable
    lock_value "1" /sys/kernel/eara_thermal/fake_throttle
    lock_value "1" /sys/kernel/fpsgo/common/stop_boost
    lock_value "0" /sys/kernel/fpsgo/common/force_onoff
    settings put Secure speed_mode_enable 1
    lock_value "none" /sys/devices/platform/13000000.mali/scheduling/serialize_jobs
    sleep 5s
    isstart=`pgrep Uperf`
    if [ $isstart = ""]; then
        chmod +x /data/adb/modules/uperf/bin/uperf
        sh $BASEDIR/initsvc_uperf.sh
        $BASEDIR/bin/uperf -o $USER_PATH/log_uperf.txt $USER_PATH/cfg_uperf.json
        isstart=`pgrep Uperf`
    fi
}
detect_uperf
exit 0