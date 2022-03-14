#!/system/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk
BASEDIR=${0%/*}
USER_PATH="/data/media/0/yc/uperf"
adj_log_path="$USER_PATH/log_adj.txt"
lock_val() {
    for p in $2; do
        if [ -f "$p" ]; then
            #echo "Write $1 to $p and lock" >>$USER_PATH/init_uperf.txt 2>&1
            chmod 0666 "$p" 2>/dev/null
            echo "$1" >"$p"
            chmod 0444 "$p" 2>/dev/null
            #echo "Locking $1 -> $p Done!" >>$USER_PATH/init_uperf.txt 2>&1
        fi
        #echo "Not found $p , continue" >>$USER_PATH/init_uperf.txt 2>&1
    done
}
change_task_rt() {
    for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/$temp_pid/task/"); do
            comm="$(cat /proc/$temp_pid/task/$temp_tid/comm)"
            chrt -f -p "$2" "$temp_tid" >>$LOG_FILE
        done
    done
}
change_task_cgroup() {
    local comm
    for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/$temp_pid/task/"); do
            comm="$(cat /proc/$temp_pid/task/$temp_tid/comm)"
            echo "$temp_tid" >"/dev/$3/$2/tasks"
        done
    done
}
change_task_affinity() {
    local comm
    for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/$temp_pid/task/"); do
            comm="$(cat /proc/$temp_pid/task/$temp_tid/comm)"
            taskset -p "$2" "$temp_tid" >>$LOG_FILE
        done
    done
}
unpin_proc() {
    change_task_cgroup "$1" "" "cpuset"
}
pin_proc_on_pwr() {
    unpin_proc "$1"
    change_task_cgroup "$1" "background" "cpuset"
    change_task_affinity "$1" "f"
}
echo 1 >/dev/gpufreq_id
echo 5 >/dev/gpufreq_step
mv $USER_PATH/log_adj.txt $USER_PATH/log_adj.lastboot.txt
chmod 777 $BASEDIR/bin/adjustment
nohup $BASEDIR/bin/adjustment -l "$adj_log_path" &
sleep 10s
change_task_rt "adjustment" "19"
pin_proc_on_pwr "adjustment"
for g in background foreground top-app background/untrustedapp; do
    lock_val "0" /dev/stune/$g/schedtune.prefer_idle
    lock_val "0" /dev/cpuset/$g/sched_load_balance
    lock_val "1000" /dev/stune/background/schedtune.util.max
    lock_val "0" /dev/stune/background/schedtune.util.min
    chmod 000 /dev/stune/background/schedtune.util.min
    lock_val "1" /dev/stune/background/schedtune.util.max
    chmod 000 /dev/stune/background/schedtune.util.max
done
sleep 120s
for g in background foreground top-app background/untrustedapp; do
    lock_val "0" /dev/stune/$g/schedtune.prefer_idle
    lock_val "0" /dev/cpuset/$g/sched_load_balance
    lock_val "1000" /dev/stune/background/schedtune.util.max
    lock_val "0" /dev/stune/background/schedtune.util.min
    chmod 000 /dev/stune/background/schedtune.util.min
    lock_val "1" /dev/stune/background/schedtune.util.max
    chmod 000 /dev/stune/background/schedtune.util.max
done
sleep 240s
for g in background foreground top-app background/untrustedapp; do
    lock_val "0" /dev/stune/$g/schedtune.prefer_idle
    lock_val "0" /dev/cpuset/$g/sched_load_balance
    lock_val "1000" /dev/stune/background/schedtune.util.max
    lock_val "0" /dev/stune/background/schedtune.util.min
    chmod 000 /dev/stune/background/schedtune.util.min
    lock_val "1" /dev/stune/background/schedtune.util.max
    chmod 000 /dev/stune/background/schedtune.util.max
done
sleep 300s
while true; do
    for g in background foreground top-app background/untrustedapp; do
        lock_val "0" /dev/stune/$g/schedtune.prefer_idle
        lock_val "0" /dev/cpuset/$g/sched_load_balance
        lock_val "1000" /dev/stune/background/schedtune.util.max
        lock_val "0" /dev/stune/background/schedtune.util.min
        chmod 000 /dev/stune/background/schedtune.util.min
        lock_val "1" /dev/stune/background/schedtune.util.max
        chmod 000 /dev/stune/background/schedtune.util.max
    done
    sleep 3600s
done
