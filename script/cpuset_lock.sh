#!/system/bin/sh

BASEDIR="$(dirname "$(readlink -f "$0")")"
. "$BASEDIR"/pathinfo.sh
. "$BASEDIR"/libcommon.sh
. "$BASEDIR"/libpowercfg.sh
. "$BASEDIR"/libcgroup.sh

cpuset_lock_stop() {
    killall -9 cpuset_writer
}
cpuset_lock_run() {
    "$BIN_PATH"/cpuset_writer "$1" "$2" &
}
cpuset_lock() {
    get_run_status=$(pidof cpuset_writer)
    if [ "$get_run_status" != "" ]; then
        exit 0
    fi
    cpuset_lock_stop
    if [ ! -d "/proc/gpufreqv2" ]; then
        cpuset_lock_run "surfaceflinger" "top-app"
    fi
    cpuset_lock_run "com.android.systemui" "top-app"
    cpuset_lock_run "com.miui.home" "top-app"
    # waiting for cpuset_writer initialization
    sleep 2
    # cpuset_writer shouldn't preempt foreground tasks
    rebuild_process_scan_cache
    change_task_cgroup "cpuset_writer" "system-background" "cpuset"
}
