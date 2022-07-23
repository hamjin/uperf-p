#!/vendor/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh
. $BASEDIR/libsysinfo.sh
chattr -i /data/adb/modules*/uperf_enhance*
chmod 666 /data/adb/modules*/uperf_enhance*
rm -rf /data/adb/modules*/uperf_enhance*
touch /data/adb/modules*/uperf_enhance*
chmod 000 /data/adb/modules*/uperf_enhance*
chattr +i /data/adb/modules*/uperf_enhance*