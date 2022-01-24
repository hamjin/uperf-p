MODDIR=${0%/*}

if [ -f "$MODDIR/flags/.need_recuser" ]; then
    rm -f $MODDIR/flags/.need_recuser
    true >$MODDIR/disable
else
    true >$MODDIR/flags/.need_recuser
fi
sh $MODDIR/script/FPSGO.sh
/system/bin/resetprop --file $MODDIR/common/system.prop
killall -9 lmkd
killall -9 lmkd
killall -9 lmkd
killall -9 lmkd
killall -9 lmkd
stop thermal_manager
stop thermal_core
stop gbe
stop thermal
killall -9 thermal_manager getgameserver gbe
