#!/system/bin/sh
MODDIR=${0%/*}
stop vendor.miperf
stop vendor.tcpdump
stop thermald
stop miuibooster
#BootStrap Uperf
sh $MODDIR/initsvc_uperf.sh
