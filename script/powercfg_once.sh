#!/system/bin/sh
# Uperf https://github.com/yc9559/uperf/
# Author: Matt Yang

# Runonce after boot, to speed up the transition of power modes in powercfg

BASEDIR="$(dirname "$0")"
. $BASEDIR/libcommon.sh
. $BASEDIR/libcgroup.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libuperf.sh

unify_cgroup() {
    # clear stune & uclamp
    for g in background foreground top-app; do
        lock_val "0" /dev/stune/$g/schedtune.sched_boost_no_override
        lock_val "0" /dev/stune/$g/schedtune.boost
        lock_val "0" /dev/stune/$g/schedtune.prefer_idle
        lock_val "0" /dev/cpuctl/$g/cpu.uclamp.sched_boost_no_override
        lock_val "0" /dev/cpuctl/$g/cpu.uclamp.min
        lock_val "0" /dev/cpuctl/$g/cpu.uclamp.latency_sensitive
    done
    for cg in stune cpuctl; do
        for p in $(cat /dev/$cg/top-app/tasks); do
            echo $p >/dev/$cg/foreground/tasks
        done
    done

    # Reduce Perf Cluster Wakeup
    # daemons
    pin_proc_on_pwr "crtc_commit|crtc_event|pp_event|msm_irqbalance|netd|mdnsd|analytics"
    pin_proc_on_pwr "imsdaemon|cnss-daemon|qadaemon|qseecomd|time_daemon|ATFWD-daemon|ims_rtp_daemon|qcrilNrd"
    # ueventd related to hotplug of camera, wifi, usb...
    # pin_proc_on_pwr "ueventd"
    # hardware services, eg. android.hardware.sensors@1.0-service
    #pin_proc_on_pwr "android.hardware.bluetooth"
    pin_proc_on_pwr "android.hardware.gnss"
    pin_proc_on_pwr "android.hardware.health"
    pin_proc_on_pwr "android.hardware.thermal"
    #pin_proc_on_pwr "android.hardware.wifi"
    pin_proc_on_pwr "android.hardware.keymaster"
    pin_proc_on_pwr "vendor.qti.hardware.qseecom"
    pin_proc_on_pwr "hardware.sensors"
    pin_proc_on_pwr "sensorservice"
    # com.android.providers.media.module controlled by uperf
    pin_proc_on_pwr "android.process.media"
    # com.miui.securitycenter & com.miui.securityadd
    pin_proc_on_pwr "miui\.security"

    # system_server blacklist
    # system_server controlled by uperf
    change_proc_cgroup "system_server" "" "cpuset"
    # input dispatcher
    change_thread_high_prio "system_server" "input"
    # related to camera startup
    change_thread_affinity "system_server" "ProcessManager" "ff"
    # not important
    pin_thread_on_pwr "system_server" "Miui|Connect|Wifi|backup|Sync|Observer|Power|Sensor|batterystats"
    pin_thread_on_pwr "system_server" "Thread-|pool-|Jit|CachedAppOpt|Greezer|TaskSnapshot|Oom"
    change_thread_nice "system_server" "Greezer|TaskSnapshot|Oom" "4"
    # pin_thread_on_pwr "system_server" "Async" # it blocks camera
    # pin_thread_on_pwr "system_server" "\.bg" # it blocks binders
    # pin_thread_on_pwr "system_server" "Network" # may reduce network speed on MIUI
    # do not let GC thread block system_server
    # pin_thread_on_mid "system_server" "HeapTaskDaemon"
    # pin_thread_on_mid "system_server" "FinalizerDaemon"

    # Render Pipeline
    # surfaceflinger controlled by uperf
    # android.phone controlled by uperf
    # speed up searching service binder
    change_task_cgroup "servicemanag" "top-app" "cpuset"
    # prevent display service from being preempted by normal tasks
    # vendor.qti.hardware.display.allocator-service cannot be set to RT policy, will be reset to 120
    unpin_proc "\.hardware\.display"
    change_task_affinity "\.hardware\.display" "7f"
    change_task_rt "\.hardware\.display" "2"
    # let UX related Binders run with top-app
    change_thread_cgroup "\.hardware\.display" "^Binder" "top-app" "cpuset"
    change_thread_cgroup "\.hardware\.display" "^HwBinder" "top-app" "cpuset"
    change_thread_cgroup "\.composer" "^Binder" "top-app" "cpuset"

    # Heavy Scene Boost
    # boost app boot process, zygote--com.xxxx.xxx
    # boost android process pool, usap--com.xxxx.xxx
    unpin_proc "zygote|usap"
    change_task_high_prio "zygote|usap"

    # busybox fork from magiskd
    pin_proc_on_mid "magiskd"
    change_task_nice "magiskd" "19"
}

unify_cpufreq() {
    # no msm_performance limit
    set_cpufreq_min "0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0"
    set_cpufreq_max "0:9999000 1:9999000 2:9999000 3:9999000 4:9999000 5:9999000 6:9999000 7:9999000"

    # stop sched core_ctl, game's main thread need be pinned on prime core
    set_corectl_param "enable" "0:0 2:0 4:0 6:0 7:0"
    # lock_val "99999" /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq
    # lock_val "0" /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq
    # lock_val "99999" /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
    # lock_val "0" /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
    # lock_val "99999" /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    # lock_val "0" /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    # lock_val "99999" /sys/devices/system/cpu/cpufreq/policy7/scaling_max_freq
    # lock_val "0" /sys/devices/system/cpu/cpufreq/policy7/scaling_min_freq
    # lock_val "99999" /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq
    # lock_val "0" /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq
    # lock_val "99999" /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
    # lock_val "0" /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    # clear cpu load scale factor
    for i in 0 1 2 3 4 5 6 7 8 9; do
        lock_val $i $CPU/cpu$i/sched_load_boost
    done
    for i in 0 1 2 3 4 5 6 7; do
        lock_val "$i" /sys/devices/system/cpu/sched/set_sched_deisolation
        #lock /sys/devices/system/cpu/cpu$i/scaling_max_freq
        #lock /sys/devices/system/cpu/cpu$i/scaling_min_freq
        #lock /sys/devices/system/cpu/cpu$i/scaling_setspeed
        lock_val "0" /sys/devices/system/cpu/cpu$i/cpufreq/schedutil/up_rate_limit_us
        lock_val "0" /sys/devices/system/cpu/cpu$i/cpufreq/schedutil/down_rate_limit_us
    done
    lock /sys/devices/system/cpu/sched/set_sched_isolation
    #for i in 0 2 4 6 7; do
    #    #lock /sys/devices/system/cpu/cpufreq/policy$i/scaling_max_freq
    #    #lock /sys/devices/system/cpu/cpufreq/policy$i/scaling_min_freq
    #    #lock /sys/devices/system/cpu/cpufreq/policy$i/scaling_setspeed
    #    lock_val "0" /sys/devices/system/cpu/cpufreq/policy$i/schedutil/up_rate_limit_us
    #    lock_val "0" /sys/devices/system/cpu/cpufreq/policy$i/schedutil/down_rate_limit_us
    #done
    #lock /sys/devices/system/cpu/rq-stats/htask_cpucap_ctrl

    # unify governor, not use schedutil if kernel has broken it
    lock_val "0" /sys/devices/system/cpu/sched/hint_enable
    chmod 000 /sys/devices/system/cpu/sched/hint_enable
    lock_val "0" /sys/devices/system/cpu/eas/enable
    chmod 400 /sys/devices/system/cpu/eas/enable
    #do not change governor on 10x
    #some devices don't have interactive, use ondemand instead
    #set_governor_param "scaling_governor" "0:ondemand 2:ondemand 4:ondemand 6:ondemand 7:ondemand"
    #set_governor_param "scaling_governor" "0:interactive 2:interactive 4:interactive 6:interactive 7:interactive"
    #set_governor_param "scaling_governor" "0:schedutil 2:schedutil 4:schedutil 6:schedutil 7:schedutil"
    # unify walt schedutil governor
    set_governor_param "schedutil/hispeed_freq" "0:0 2:0 4:0 6:0 7:0"
    set_governor_param "schedutil/hispeed_load" "0:100 2:100 4:100 6:100 7:100"
    set_governor_param "schedutil/pl" "0:1 2:1 4:1 6:1 7:1"
    # unify hmp interactive governor, for 2+2 4+2 4+4 1+3+4 2+6
    set_governor_param "interactive/use_sched_load" "0:1 2:1 4:1 6:1 7:1"
    set_governor_param "interactive/use_migration_notif" "0:1 2:1 4:1 6:1 7:1"
    set_governor_param "interactive/enable_prediction" "0:0 2:0 4:0 6:0 7:0"
    set_governor_param "interactive/ignore_hispeed_on_notif" "0:0 2:0 4:0 6:0 7:0"
    set_governor_param "interactive/fast_ramp_down" "0:0 2:0 4:0 6:0 7:0"
    set_governor_param "interactive/boostpulse_duration" "0:0 2:0 4:0 6:0 7:0"
    set_governor_param "interactive/boost" "0:0 2:0 4:0 6:0 7:0"
    set_governor_param "interactive/timer_slack" "0:12345678 2:12345678 4:12345678 6:12345678 7:12345678"
    # unify HMP ondemand governor for 2+2 4+2 4+4 1+3+4 2+6
    set_governor_param "ondemand/ignore_nice_load" "0:1 2:1 4:1 6:1 7:1"
    set_governor_param "ondemand/io_is_busy" "0:1 2:1 4:1 6:1 7:1" #io is busy at boot time
    set_governor_param "ondemand/up_threshold" "0:60 2:60 4:60 6:60 7:60"
    set_governor_param "ondemand/sampling_rate" "0:30000 2:30000 4:30000 6:30000 7:30000"
    set_governor_param "ondemand/sampling_down_factor" "0:30000 2:30000 4:30000 6:30000 7:30000"

}

unify_sched() {
    #if [ -d /proc/perfmgr/boost_ctrl/eas_ctrl/ ]; then
    #    #lock_val "0" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_prefer_idle"
    #    #lock_val "0" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_fg_boost"
    #    #lock_val "0" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_ta_boost"
    #    #lock_val "-100" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_bg_boost"
    #    #lock_val "0" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_uclamp_min"
    #    #lock_val "0" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_fg_uclamp_min"
    #    #lock_val "0" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_ta_uclamp_min"
    #    #lock_val "0" "/proc/perfmgr/boost_ctrl/eas_ctrl/perfserv_bg_uclamp_min"
    #    # lock_val "1" "/proc/perfmgr/boost_ctrl/cpu_ctrl/cfp_enable"
    #    #lock_val "80" "/proc/perfmgr/boost_ctrl/cpu_ctrl/cfp_up_loading"
    #    #lock_val "60" "/proc/perfmgr/boost_ctrl/cpu_ctrl/cfp_down_loading"
    #fi
    # disable sched global placement boost
    lock_val "0" $SCHED/sched_boost
    lock_val "1000" $SCHED/sched_min_task_util_for_boost
    lock_val "1000" $SCHED/sched_min_task_util_for_colocation
    lock_val "0" $SCHED/sched_conservative_pl
    lock_val "0" $SCHED/sched_force_lb_enable
    lock_val "0" $SCHED/sched_boost_top_app

    # unify WALT HMP sched
    lock_val "5" $SCHED/sched_ravg_hist_size
    lock_val "2" $SCHED/sched_window_stats_policy
    lock_val "90" $SCHED/sched_spill_load
    lock_val "1" $SCHED/sched_restrict_cluster_spill
    lock_val "1" $SCHED/sched_prefer_sync_wakee_to_waker
    lock_val "200000" $SCHED/sched_freq_inc_notify
    lock_val "400000" $SCHED/sched_freq_dec_notify

    # place a little heavier processes on big cluster, due to Cortex-A55 poor efficiency
    # The same Binder, A55@1.0g took 7.3ms，A76@1.0g took 3.0ms, in this case, A76's efficiency is 2.4x of A55's.
    # However in EAS model A76's efficiency is 1.7x of A55's, so the down migrate threshold need compensate.
    set_sched_migrate "50" "15" "999" "888"
    set_sched_migrate "50 90" "15 70" "999" "888"

    # 10ms=10000000, prefer to use prev cpu, decrease jitter from 0.5ms to 0.3ms with lpm settings
    # 0.2ms=200000, prevent system_server binders pinned on perf cluster
    lock_val "200000" $SCHED/sched_migration_cost_ns
    if [ -d /sys/kernel/hmp/ ]; then
        lock_val "0" "/sys/kernel/hmp/boost"
        lock_val "0" "/sys/kernel/hmp/boostpulse_duration"
        lock_val "500" "/sys/kernel/hmp/up_threshold"
        lock_val "300" "/sys/kernel/hmp/down_threshold"
        lock_val "400" "/sys/kernel/hmp/sb_up_threshold"
        lock_val "200" "/sys/kernel/hmp/sb_down_threshold"
    fi
    # lock /proc/perfmgr/boost_ctrl/cpu_ctrl/boot_freq

    # lock_val "1" /proc/perfmgr/syslimiter/syslimiter_fps_120
    # lock /proc/ppm/policy/forcelimit_cpu_core
}

unify_lpm() {
    # enter C-state level 3 took ~500us
    # Qualcomm C-state ctrl
    lock_val "0" $LPM/sleep_disabled
    lock_val "0" $LPM/lpm_ipi_prediction
    if [ -f "$LPM/bias_hyst" ]; then
        lock_val "5" $LPM/bias_hyst
        lock_val "0" $LPM/lpm_prediction
    elif [ -f "$SCHED/sched_busy_hyst_ns" ]; then
        lock_val "127" $SCHED/sched_busy_hysteresis_enable_cpus # seem not working well on cpu7
        lock_val "0" $SCHED/sched_coloc_busy_hysteresis_enable_cpus
        lock_val "5000000" $SCHED/sched_busy_hyst_ns
        lock_val "0" $LPM/lpm_prediction
    else
        lock_val "1" $LPM/lpm_prediction
    fi
}

disable_hotplug() {
    # Exynos hotplug
    mutate "0" /sys/power/cpuhotplug/enabled
    mutate "0" $CPU/cpuhotplug/enabled

    # turn off msm_thermal
    lock_val "0" /sys/module/msm_thermal/core_control/enabled
    lock_val "N" /sys/module/msm_thermal/parameters/enabled

    # 3rd
    lock_val "0" /sys/kernel/intelli_plug/intelli_plug_active
    lock_val "0" /sys/module/blu_plug/parameters/enabled
    lock_val "0" /sys/devices/virtual/misc/mako_hotplug_control/enabled
    lock_val "0" /sys/module/autosmp/parameters/enabled
    lock_val "0" /sys/kernel/zen_decision/enabled

    # bring all cores online
    for i in 0 1 2 3 4 5 6 7 8 9; do
        lock_val "1" $CPU/cpu$i/online
    done
}

disable_kernel_boost() {
    # Qualcomm
    lock_val "0" "/sys/devices/system/cpu/cpu_boost/*"
    lock_val "0" "/sys/devices/system/cpu/cpu_boost/parameters/*"
    lock_val "0" "/sys/module/cpu_boost/parameters/*"
    lock_val "0" "/sys/module/msm_performance/parameters/*"

    # MediaTek

    # policy_status
    # [0] PPM_POLICY_PTPOD: Meature PMIC buck currents
    # [1] PPM_POLICY_UT: Unit test
    # [2] PPM_POLICY_FORCE_LIMIT: enabled
    # [3] PPM_POLICY_PWR_THRO: enabled
    # [4] PPM_POLICY_THERMAL: enabled
    # [5] PPM_POLICY_DLPT: Power measurment and power budget managing
    # [6] PPM_POLICY_HARD_USER_LIMIT: enabled
    # [7] PPM_POLICY_USER_LIMIT: enabled
    # [8] PPM_POLICY_LCM_OFF: disabled
    # [9] PPM_POLICY_SYS_BOOST: disabled
    # [10] PPM_POLICY_HICA: ?
    # Usage: echo <policy_idx> <1(enable)/0(disable)> > /proc/ppm/policy_status
    # Selinux May should be disabled

    #MTK PPM must be enabled
    lock_val "1" /proc/ppm/enabled
    lock_val "0 0" /proc/ppm/policy_status
    lock_val "1 0" /proc/ppm/policy_status
    lock_val "2 0" /proc/ppm/policy_status
    lock_val "3 0" /proc/ppm/policy_status
    lock_val "4 0" /proc/ppm/policy_status
    lock_val "5 0" /proc/ppm/policy_status
    lock_val "7 0" /proc/ppm/policy_status
    lock_val "8 0" /proc/ppm/policy_status
    lock_val "9 0" /proc/ppm/policy_status
    # used by uperf
    lock_val "6 1" /proc/ppm/policy_status
    #Active MTK Memery Management
    # lock_val "1" /proc/mtk-perf/lowmem_hint_enable
    # lock_val "0" /proc/cpu_loading/onoff
    lock_val "1" /proc/perfmgr/syslimiter/syslimiter_force_disable
    # load balance is useless
    # lock_val "0" /dev/cpuset/sched_relax_domain_level
    # lock_val "0" /dev/cpuset/background/sched_relax_domain_level
    # lock_val "0" /dev/cpuset/game/sched_relax_domain_level
    # lock_val "0" /dev/cpuset/gamelite/sched_relax_domain_level
    # lock_val "0" /dev/cpuset/restricted/sched_relax_domain_level
    # lock_val "0" /dev/cpuset/system-background/sched_relax_domain_level
    # lock_val "0" /dev/cpuset/top-app/sched_relax_domain_level
    # lock_val "0" /dev/cpuset/vr/sched_relax_domain_level

    # Samsung
    mutate "0" "/sys/class/input_booster/*"

    # Samsung EPIC interfaces, used by uperf
    # mutate "0" /dev/cluster0_freq_min
    # mutate "0" /dev/cluster1_freq_min
    # mutate "0" /dev/cluster2_freq_min
    # lock_val "0" /dev/bus_throughput
    # lock_val "0" /dev/gpu_freq_min
    # Samsung /kernel/sched/ems/...
    mutate "0" /sys/kernel/ems/eff_mode

    # Oneplus
    lock_val "N" "/sys/module/control_center/parameters/*"
    lock_val "0" /sys/module/aigov/parameters/enable
    lock_val "0" "/sys/module/houston/parameters/*"
    # OnePlus opchain always pins UX threads on the big cluster
    lock_val "0" /sys/module/opchain/parameters/chain_on

    # HTC
    lock_val "0" "/sys/power/pnpmgr/*"

    # 3rd
    lock_val "0" "/sys/kernel/cpu_input_boost/*"
    lock_val "0" "/sys/module/cpu_input_boost/parameters/*"
    lock_val "0" "/sys/module/dsboost/parameters/*"
    lock_val "0" "/sys/module/devfreq_boost/parameters/*"

}

disable_userspace_boost() {
    # Qualcomm perfd
    stop perfd 2

    # Qualcomm&MTK perfhal
    # keep perfhal running with empty config file in magisk mode
    [ ! -f "$FLAGS/enable_perfhal_stub" ] && perfhal_stop

    # xiaomi perfservice
    # stop vendor.perfservice

    # brain service maybe not smart
    stop oneplus_brain_service

    # disable service below will BOOM
    # stop vendor.power.stats-hal-1-0
    # stop vendor.power-hal-1-0
}

log "PATH=$PATH"
log "sh=$(which sh)"
rebuild_process_scan_cache
disable_userspace_boost
disable_kernel_boost
disable_hotplug
unify_cpufreq
unify_sched
unify_lpm

# make sure that all the related cpu is online
unify_cgroup

# start uperf once only
uperf_stop
uperf_start
