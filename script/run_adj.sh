#!/system/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk
BASEDIR="$(dirname "$0")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
adj_log_path="$USER_PATH/log_adj.txt"
chmod 777 $BASEDIR/../bin/adjustment
$BASEDIR/../bin/adjustment -l "$adj_log_path"
exit 0
