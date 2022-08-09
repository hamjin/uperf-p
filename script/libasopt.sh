#!/system/bin/sh

BASEDIR="$(dirname "$0")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libcgroup.sh

asopt_stop() {
    killall -9 AsoulOpt
}
asopt_start() {
    asopt_stop
    nohup $BIN_PATH/AsoulOpt >/dev/null 2>&1 &
}
