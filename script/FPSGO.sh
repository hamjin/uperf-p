#/system/bin/sh
USER_PATH="/data/media/0/yc/uperf"
lock_val() {
    for p in $2; do
        if [ -f "$p" ]; then
            echo "Locking $1 -> $p  " >>$USER_PATH/init_uperf.txt
            chmod 0666 "$p" 2>/dev/null
            echo "$1" >"$p"
            chmod 0444 "$p" 2>/dev/null
            echo "Locking $1 -> $p Done! " >>$USER_PATH/init_uperf.txt
        fi
    done
}
stop thermal_manager
stop thermal_core
stop gbe
stop thermal
killall -9 thermal_manager getgameserver gbe
/system/vendor/bin/thermal_manager /system/vendor/etc/.tp/ht120.mtc
lock_val "none" /sys/devices/platform/13000000.mali/scheduling/serialize_jobs
lock_val "0" /sys/kernel/eara_thermal/enable
lock_val "0" /sys/kernel/eara_thermal/fake_throttle
lock_val "1" /sys/kernel/fpsgo/common/stop_boost
lock_val "0" /sys/kernel/fpsgo/common/force_onoff
lock_val "101" /proc/perfmgr/syslimiter/syslimitertolerance_percent
lock_val "1" /proc/perfmgr/syslimiter/syslimiter_force_disable
lock_val "enable: 1" /proc/perfmgr/tchbst/user/usrtch
lock_val "1" /proc/perfmgr/boost_ctrl/cpu_ctrl/cfp_enable
exit 0
