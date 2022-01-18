#!/bin/sh
BASEDIR="$(dirname $(readlink -f "$0"))"
MODDIR=${0%/*}
SCRIPT_DIR="$BASEDIR/script"
sh $BASEDIR/initsvc_uperf.sh

USER_PATH=/data/media/0/yc/uperf/
detect_uperf() {
    settings put Secure speed_mode_enable 1

    sleep 5s
    isstart=$(pgrep Uperf)
    if [ $isstart = ""]; then
        chmod +x /data/adb/modules/uperf/bin/uperf
        sh $BASEDIR/initsvc_uperf.sh
        $BASEDIR/bin/uperf -o $USER_PATH/log_uperf.txt $USER_PATH/cfg_uperf.json
        isstart=$(pgrep Uperf)
    fi
}
detect_uperf
sh $BASEDIR/FPSGO_Afterboot.sh
exit 0
