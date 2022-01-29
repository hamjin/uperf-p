MODDIR=${0%/*}
ASH_STANDALONE=1
if [ -f "$MODDIR/.need_recuser" ]; then
    rm -f $MODDIR/.need_recuser
    true >$MODDIR/disable
    exit 0
else
    true >$MODDIR/.need_recuser
fi
