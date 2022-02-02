MODDIR=${0%/*}

if [ -f "$MODDIR/.need_recuser" ]; then
    rm -f $MODDIR/.need_recuser
    true >$MODDIR/disable
    exit 0
else
    true >$MODDIR/.need_recuser
fi
/system/bin/resetprop --file $MODDIR/system.prop &
