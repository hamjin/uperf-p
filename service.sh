#!/system/bin/sh
ASH_STANDALONE=0
MODDIR=${0%/*}
BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="$BASEDIR/script"
/system/bin/resetprop --file $MODDIR/system.prop
#BootStrap Uperf
sh $BASEDIR/initsvc_uperf.sh