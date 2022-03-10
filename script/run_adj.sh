#!/system/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk
BASEDIR="$(dirname "$0")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
adj_log_path="$USER_PATH/log_adj.txt"
chmod 777 $BASEDIR/../bin/adjustment
nohup $BASEDIR/../bin/adjustment -l "$adj_log_path" >/dev/null &
sleep 10s
change_task_rt "adjustment" "19"
pin_proc_on_pwr "adjustment"
while true; do
    for g in background foreground top-app background/untrustedapp; do
        lock_val "0" /dev/stune/$g/schedtune.prefer_idle
        lock_val "1" /dev/cpuset/$g/sched_load_balance
    done
    sleep 60s
done
