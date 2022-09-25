#!/vendor/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk

BASEDIR="$(dirname "$(readlink -f "$0")")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh
. $BASEDIR/libsysinfo.sh
exit 0