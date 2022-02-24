MODDIR=${0%/*}

/system/bin/resetprop --file $MODDIR/system.prop &
/system/bin/resetprop --file -n $MODDIR/system.prop &
/system/bin/resetprop --file -p $MODDIR/system.prop &
