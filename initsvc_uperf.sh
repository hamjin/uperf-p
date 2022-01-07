#!/vendor/bin/sh
# Uperf Service Script
# https://github.com/yc9559/
# Author: Matt Yang
# Version: 20200401

BASEDIR="$(dirname $(readlink -f "$0"))"

wait_until_login()
{
    # in case of /data encryption is disabled
    while [ "$(getprop sys.boot_completed)" != "1" ]; do
        sleep 1
    done

    # we doesn't have the permission to rw "/sdcard" before the user unlocks the screen
    local test_file="/data/media/0/Android/.PERMISSION_TEST"
    true > "$test_file"
    while [ ! -f "$test_file" ]; do
        true > "$test_file"
        sleep 1
    done
    rm "$test_file"
}

crash_recuser()
{
    rm $BASEDIR/logcat.log
    logcat -f $BASEDIR/logcat.log &
    sleep 60
    killall logcat
    rm -f $BASEDIR/flags/.need_recuser
}

# (crash_recuser &)
wait_until_login
mv /data/media/0/yc/uperf/init_uperf.txt /data/media/0/yc/uperf/init_uperf.txt.lastgood
echo "balance" >/data/media/0/yc/uperf/cur_powermode
sh $BASEDIR/run_uperf.sh
