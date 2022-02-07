#!/vendor/bin/sh
# Uperf Service Script
# https://github.com/yc9559/
# Author: Matt Yang
# Version: 20200401
USER_PATH="/data/media/0/yc/uperf"
BASEDIR="$(dirname $(readlink -f "$0"))"
wait_until_login() {
    # in case of /data encryption is disabled
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    # we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
    local test_file="/sdcard/Android/.PERMISSION_TEST"
    true >"$test_file"
    while [ ! -f "$test_file" ]; do
        true >"$test_file"
        sleep 1
    done
    rm "$test_file"

}

crash_recuser() {
    # rm $BASEDIR/logcat.log
    # logcat -f $BASEDIR/logcat.log &
    sleep 60
    # killall logcat
    rm -f $BASEDIR/.need_recuser
    #rm $BASEDIR/logcat.log
}
lock_volt() {
    for p in $2; do
        if [ -f "$p" ]; then
            echo "Locking $1 -> $p" >>$USER_PATH/init_uperf.txt
            chmod 0666 "$p" 2>/dev/null
            echo "$1" >"$p"
            chmod 0444 "$p" 2>/dev/null
            echo "Locking $1 -> $p Done!" >>$USER_PATH/init_uperf.txt
        else
            echo "Not found $p , continue" >>$USER_PATH/init_uperf.txt &>1
        fi
    done
}
unlock() {
    if [ -f "$1" ]; then
        echo "Locking $1 's Permission" >>$USER_PATH/init_uperf.txt 2>&1
        chmod 0444 "$1" 2>/dev/null
        echo "Locking $1 's Permission Done!" >>$USER_PATH/init_uperf.txt 2>&1
    else
        echo "Not found $p , continue" >>$USER_PATH/init_uperf.txt 2>&1
    fi
}
reset_volt() {
    if ["$DEVICE" != "mtd1000" ]; then
        echo "正在取消降压设定,避免欠压重启!" >>$USER_PATH/init_uperf.txt 2>&1
        lock_val "0" /proc/eem/EEM_DET_B/eem_offset
        lock_val "0" /proc/eem/EEM_DET_BL/eem_offset
        lock_val "0" /proc/eem/EEM_DET_L/eem_offset
        lock_val "0" /proc/eem/EEM_DET_CCI/eem_offset
        lock_val "0" /proc/eemg/EEM_DET_GPU/eem_offset
        lock_val "0" /proc/eem/EEM_DET_GPU_HI/eem_offset
    fi
    sleep 90s
    echo "重新允许降压！" >>$USER_PATH/init_uperf.txt 2>&1
    unlock /proc/eem/EEM_DET_B/eem_offset
    unlock /proc/eem/EEM_DET_BL/eem_offset
    unlock /proc/eem/EEM_DET_L/eem_offset
    unlock /proc/eem/EEM_DET_CCI/eem_offset
    unlock /proc/eemg/EEM_DET_GPU/eem_offset
    unlock /proc/eem/EEM_DET_GPU_HI/eem_offset
    echo "现在允许降压！" >>$USER_PATH/init_uperf.txt 2>&1
}
(crash_recuser &)
wait_until_login
mv $USER_PATH/init_uperf.txt $USER_PATH/init_uperf.lastgood.txt 2>&1
date '+%Y-%m-%d %H:%M:%S' >>$USER_PATH/init_uperf.txt 2>&1
echo "YC调度-天玑优化：开始加载" >>$USER_PATH/init_uperf.txt 2>&1
echo "balance" >>$USER_PATH/cur_powermode
env >>$USER_PATH/init_uperf.txt 2>&1
#(reset_volt &)
sh $BASEDIR/run_uperf.sh >>$USER_PATH/init_uperf.txt 2>&1
