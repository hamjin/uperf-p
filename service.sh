#!/system/bin/sh
MODDIR=${0%/*}
/system/bin/resetprop --file $MODDIR/system.prop
#BootStrap Uperf
sh $MODDIR/initsvc_uperf.sh
