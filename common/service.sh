#!/bin/sh
BASEDIR="$(dirname $(readlink -f "$0"))"
MODDIR=${0%/*}
SCRIPT_DIR="$BASEDIR/script"
sh $BASEDIR/initsvc_uperf.sh

USER_PATH=/data/media/0/yc/uperf/
detect_uperf() {
    settings put Secure speed_mode_enable 1
    setprop ro.config.low_ram 0
    setprop ro.lmk.use_psi true
    setprop ro.lmk.use_minfree_levels false
    sleep 5s
    isstart=$(pgrep Uperf)
    if [ $isstart = ""]; then
        chmod +x /data/adb/modules/uperf/bin/uperf
        sh $BASEDIR/initsvc_uperf.sh
        $BASEDIR/bin/uperf -o $USER_PATH/log_uperf.txt $USER_PATH/cfg_uperf.json
        isstart=$(pgrep Uperf)
    fi
}
/system/bin/resetprop --file $BASEDIR/common/system.prop
killall -9 lmkd
killall -9 lmkd
killall -9 lmkd
killall -9 lmkd
killall -9 lmkd
detect_uperf &
sh $BASEDIR/script/FPSGO_Afterboot.sh &
sh $BASEDIR/script/lock_core.sh &

exit 0
