#!/bin/sh
lock_val()
{
    echo "Locking $1 -> $p" >>/sdcard/yc/uperf/init_uperf.txt
    for p in $2; do
        if [ -f "$p" ]; then
            chmod 0666 "$p" 2> /dev/null
            echo "$1" > "$p"
            chmod 0444 "$p" 2> /dev/null
        fi
    done
}
BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="$BASEDIR/script"
sh $BASEDIR/initsvc_uperf.sh >>/sdcard/yc/uperf/init_uperf.txt
lock_cpu()
{
    sleep 240s
    lock_val "0-7" /dev/cpuset/top-app/boost/cpus
    lock_val "0-7" /dev/cpuset/top-app/cpus
    lock_val "0-7" /dev/cpuset/game/cpus
    lock_val "0-7" /dev/cpuset/gamelite/cpus
    lock_val "0-7" /dev/cpuset/foreground/boost/cpus
    lock_val "0-7" /dev/cpuset/foreground/cpus
    lock_val "0-6" /dev/cpuset/restricted/cpus
    lock_val "0-3" /dev/cpuset/system-background/cpus
    lock_val "0-3" /dev/cpuset/background/cpus
}
(lock_cpu &)
lock_val "enable=1" /prooc/sla/config
lock_val "1" /proc/perfmgr/syslimiter/syslimiter_force_disable
lock_val "100" /proc/perfmgr/syslimiter/syslimitertolerance_percent
lock_val "1" /sys/module/ged/parameters/ged_force_mdp_enable
lock_val "0" /sys/kernel/eara_thermal/enable
lock_val "1" /sys/kernel/eara_thermal/fake_throttle
lock_val "1" /sys/kernel/fpsgo/common/stop_boost
lock_val "0" /sys/kernel/fpsgo/common/force_onoff
lock_val "1" /proc/mtk-perf/lowmem_hint_enable
lock_val "enable: 0" /proc/perfmgr/tchbst/user/usrtch

sleep 5s
isstart=`pgrep Uperf`
chmod +x $BASEDIR/bin/uperf
sh $BASEDIR/initsvc_uperf.sh >>/sdcard/yc/uperf/init_uperf.txt
$BASEDIR/bin/uperf -o /sdcard/yc/uperf/log_uperf.txt /sdcard/yc/uperf/cfg_uperf.json
sleep 10s
while [ $isstart = ""] ;do
    echo "uperf not loaded">/sdcard/yc/uperf/init_uperf.tx
    chmod +x /data/uperf//bin/uperf
    sh $BASEDIR/initsvc_uperf.sh >>/sdcard/yc/uperf/init_uperf.txt
    $BASEDIR/bin/uperf -o /sdcard/yc/uperf/log_uperf.txt
    isstart=`pgrep Uperf`
    sleep 15s
done
exit 0