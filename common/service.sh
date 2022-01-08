#!/bin/sh
mv /data/media/0/yc/uperf/init_uperf.txt /data/media/0/yc/uperf/init_uperf.txt.lastgood
BASEDIR="$(dirname $(readlink -f "$0"))"
MODDIR=${0%/*}
SCRIPT_DIR="$BASEDIR/script"
sh $BASEDIR/initsvc_uperf.sh

. $BASEDIR/script/pathinfo.sh

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
(detect_uperf &)
exit 0