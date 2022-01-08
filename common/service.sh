#!/bin/sh
BASEDIR="$(dirname $(readlink -f "$0"))"
MODDIR=${0%/*}
SCRIPT_DIR="$BASEDIR/script"
sh $BASEDIR/initsvc_uperf.sh

. $BASEDIR/script/pathinfo.sh
mv /data/media/0/yc/uperf/init_uperf.txt /data/media/0/yc/uperf/init_uperf.txt.lastgood
lock_val()
{
    echo "Locking $1 -> $p" >>$USER_PATH/init_uperf.txt
    for p in $2; do
        if [ -f "$p" ]; then
            chmod 0666 "$p" 2> /dev/null
            echo "$1" > "$p"
            chmod 0444 "$p" 2> /dev/null
        fi
    done
}
detect uperf()
{
    sleep 5s
    isstart=`pgrep Uperf`
    if [ $isstart = ""]; then
        chmod +x /data/adb/modules/uperf/bin/uperf
        sh $BASEDIR/initsvc_uperf.sh
        $BASEDIR/bin/uperf -o $USER_PATH/log_uperf.txt $USER_PATH/cfg_uperf.json
        isstart=`pgrep Uperf`
        sleep 15s
    fi
}
lock_gpudeboost()
{
    while true; do
    lock_val "0" /sys/kernel/eara_thermal/enable;
    lock_val "1" /sys/kernel/eara_thermal/fake_throttle;
    lock_val "1" /sys/kernel/fpsgo/common/stop_boost;
    lock_val "0" /sys/kernel/fpsgo/common/force_onoff;
    lock_val "full" /sys/devices/platform/13000000.mali/scheduling/serialize_jobs;
    sleep 120s;
    done
}
lock_cpu()
{
    sleep 1s
    lock_val "0-7" /dev/cpuset/top-app/boost/cpus
    lock_val "0-7" /dev/cpuset/top-app/cpus
    lock_val "0-7" /dev/cpuset/game/cpus
    lock_val "0-7" /dev/cpuset/gamelite/cpus
    lock_val "0-7" /dev/cpuset/foreground/boost/cpus
    lock_val "0-7" /dev/cpuset/foreground/cpus
    lock_val "0-6" /dev/cpuset/restricted/cpus
    lock_val "0-3" /dev/cpuset/system-background/cpus
    lock_val "0-3" /dev/cpuset/background/cpus
    sleep 120s
    lock_val "0-7" /dev/cpuset/top-app/boost/cpus
    lock_val "0-7" /dev/cpuset/top-app/cpus
    lock_val "0-7" /dev/cpuset/game/cpus
    lock_val "0-7" /dev/cpuset/gamelite/cpus
    lock_val "0-7" /dev/cpuset/foreground/boost/cpus
    lock_val "0-3,5-6" /dev/cpuset/foreground/cpus
    lock_val "0-3" /dev/cpuset/restricted/cpus
    lock_val "0-3" /dev/cpuset/system-background/cpus
    lock_val "2-3" /dev/cpuset/background/cpus
}
(lock_cpu &)
(lock_gpudeboost &)
(detect_uperf &)
exit 0