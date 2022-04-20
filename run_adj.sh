#!/system/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk
BASEDIR="$(dirname $(readlink -f "$0"))"
USER_PATH="/data/media/0/yc/uperf"
adj_log_path="$USER_PATH/log_adj.txt"
l0ck_va1() {
    for p in $2; do
        if [ -f "$p" ]; then
            chmod 0666 "$p" 2>/dev/null
            echo "$1" >"$p"
            chmod 0444 "$p" 2>/dev/null
        fi
    done
}
l0ck() {
    for p in $2; do
        if [ -f "$p" ]; then
            chmod 0444 "$p" 2>/dev/null
        fi
    done
}
change_task_1rt() {
    for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
        for temp_tid in $(ls "/proc/$temp_pid/task/"); do
            comm="$(cat /proc/$temp_pid/task/$temp_tid/comm)"
            chrt -f -p "$2" "$temp_tid" >>$LOG_FILE
        done
    done
}
change_1task_cgroup() {
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
unpin_tproc() {
    change_1task_cgroup "$1" "" "cpuset"
}
pin_proc_on_1pwr() {
    unpin_tproc "$1"
    change_1task_cgroup "$1" "background" "cpuset"
    change_task_affinity "$1" "f"
}
echo 11 >/dev/gpufreq_id
echo 1 >/dev/gpufreq_step
mv $USER_PATH/log_adj.txt $USER_PATH/log_adj.lastboot.txt
killall -9 adjustment
chmod 777 $BASEDIR/bin/adjustment
nohup $BASEDIR/bin/adjustment -l "$adj_log_path" &
sleep 10s
change_task_1rt "adjustment" "19"
pin_proc_on_1pwr "adjustment"
#l0ck /dev/cpuctl/background/cpu.uclamp.max
#l0ck_va1 "0" /dev/cpuctl/background/cpu.uclamp.min
#l0ck /dev/cpuctl/background/cpu.uclamp.min
#l0ck_va1 "0" /dev/cpuctl/background/cpu.uclamp.max
#l0ck /dev/cpuctl/system-background/cpu.uclamp.max
#l0ck_va1 "0" /dev/cpuctl/system-background/cpu.uclamp.min
#l0ck /dev/cpuctl/system-background/cpu.uclamp.min
#l0ck_va1 "0" /dev/cpuctl/system-background/cpu.uclamp.max
#l0ck /dev/stune/background/schedtune.util.max
#l0ck /dev/stune/background/schedtune.util.min
#l0ck /dev/stune/background/schedtune.util.min
#l0ck /dev/stune/background/schedtune.util.max
#l0ck /dev/cpuctl/system-background/cpu.uclamp.max
#l0ck /dev/cpuctl/system-background/cpu.uclamp.min
#l0ck /dev/cpuctl/system-background/cpu.uclamp.min
#l0ck /dev/cpuctl/system-background/cpu.uclamp.max
#l0ck /dev/stune/system-background/schedtune.util.max
#l0ck /dev/stune/system-background/schedtune.util.min
#l0ck /dev/stune/system-background/schedtune.util.min
#l0ck /dev/stune/system-background/schedtune.util.max
#l0ck_va1 "99" /sys/kernel/ged/hal/custom_boost_gpu_freq
##chmod 400 /sys/kernel/ged/hal/custom_boost_gpu_freq
lock_cpu() {
    while true; do
        for i in 0 4 7; do
            chmod 444 /sys/devices/system/cpu/cpufreq/policy$i/scaling_min_freq
            chmod 444 /sys/devices/system/cpu/cpufreq/policy$i/scaling_max_freq
            chmod 444 /sys/devices/system/cpu/cpufreq/policy$i/scaling_min_freq
        done
        for i in 0 1 2 3 4 5 6 7; do
            chmod 444 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
            chmod 444 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
            chmod 444 /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
        done
        #for g in background foreground top-app background/untrustedapp system-background; do
        #    l0ck_va1 "0" /dev/stune/$g/schedtune.prefer_idle
        #    l0ck_va1 "0" /dev/cpuset/$g/sched_load_balance
        #    l0ck_va1 "0" /dev/cpuctl/$g/cpu.uclamp.latency_sensitive
        #done
        sleep 60s
    done
}
(lock_cpu &)
