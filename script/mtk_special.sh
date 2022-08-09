#!/system/bin/sh
#
# Copyright (C) 2022 Ham Jin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Runonce after boot, to speed up the transition of power modes in powercfg

# "Matt Yang(yc9559) is too lazy to copy and paste", said hellokf@github
hide_value() {
    umount "$1" 2>/dev/null
    if [[ ! -f "/cache/$1" ]]; then
        mkdir -p "/cache/$1"
        rm -r "/cache/$1"
        cat "$1" >"/cache/$1"
    fi
    if [[ "$2" != "" ]]; then
        lock_val "$2" "$1"
    fi
    mount "/cache/$1" "$1"
}
#Mediatek Task Turbo
task_turbo() {
    PRE_PID=$(cat /cache/task_turbo_pid)
    for i in $PRE_PID; do
        echo "$i" >>/sys/module/task_turbo/parameters/unset_turbo_pid
    done
    echo "$top_app" >/cache/cur_top_app
    echo "" >/cache/task_turbo_pid
    PID=$(pgrep $top_app)
    for i in $PID; do
        echo "$i" >>/cache/task_turbo_pid
        echo "$i" >>/sys/module/task_turbo/parameters/turbo_pid
    done
    #lock_val "$PID" /sys/module/task_turbo/parameters/turbo_pid
}
BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh
. $BASEDIR/libsysinfo.sh
lock_val "0" /proc/sys/kernel/sched_big_task_rotation
lock_val "0" /proc/perfmgr/boost_ctrl/eas_ctrl/sched_big_task_rotation
# work with uperf/ContextScheduler
lock_val "0" "/sys/module/mtk_fpsgo/parameters/boost_affinity*"
lock_val "0" "/sys/module/fbt_cpu/parameters/boost_affinity*"
lock_val "0" /sys/kernel/fpsgo/fbt/switch_idleprefer
lock_val "1" /proc/perfmgr/syslimiter/syslimiter_force_disable
lock_val "0" /sys/module/mtk_core_ctl/parameters/policy_enable
#enable asopt
#touch /data/adb/modules/asoul_affinity_opt/flag/dont_fuck

#lock_val "99" /sys/kernel/ged/hal/custom_boost_gpu_freq
#hide_value /sys/kernel/ged/hal/custom_boost_gpu_freq "99"

#Platform Specify Config
if [ -d "/proc/gpufreqv2" ]; then
    echo "detected new platform"
    IS_MIUI=$(getprop ro.miui.ui.version.code)
    if [ $IS_MIUI -gt 12 ]; then
        echo "enable fpsgo"
        lock_val "1" /sys/kernel/fpsgo/common/fpsgo_enable
        lock_val "2" /sys/kernel/fpsgo/common/force_onoff
    else
        echo "stop fpsgo"
        lock_val "0" /sys/kernel/fpsgo/common/fpsgo_enable
        lock_val "0" /sys/kernel/fpsgo/common/force_onoff
    fi
    #echo "start resuming config for new devices"
    #for file in powercontable.xml power_app_cfg.xml powerscntbl.xml task_profiles.json; do
    #    find /data/adb/modules -name $file | while read found; do
    #        rm -f $found
    #    done
    #done
    #Infinite Cache
    #LIST=`ls -1 /sys/kernel/debug/mali0/ctx`
    #for i in $LIST;do
    #lock_val "Y" /sys/kernel/debug/mali0/ctx/$i/infinite_cache
    #done
    #cpu_loading
    lock_val "1" /proc/cpu_loading/cpu_onoff
    lock_val "1" /proc/cpu_loading/debug_enable
    lock_val "1" /proc/cpu_loading/uevent_enable
    lock_val "1" /proc/cpu_loading/polling_sec
    #lock_val "1" /proc/cpu_loading/polling_nsec
    lock_val "68" /proc/cpu_loading/overThrhld
    lock_val "45" /proc/cpu_loading/underThrhld
    lock_val "68" /proc/cpu_loading/specify_overThrhld
    lock_val "7654" /proc/cpu_loading/specify_cpus
    #PMSR
    lock_val "1" /proc/pmsr/enable
    # Disabel auto voltage add by MTK
    lock_val "disable" /proc/gpufreqv2/aging_mode
    #lock_val "disable" /proc/gpufreqv2/gpm_mode
    # Fix gpu always boost in MT6983 and MT6895, f**K buggy MTK kernel drivers.
    lock_val "0" /sys/kernel/ged/hal/dcs_mode
    #MTK New Thermal
    #lock_val "disable_thermal.conf" /data/vendor/thermal/.permanent_tp
    #lock_val "disable_thermal.conf" /data/vendor/thermal/.current_tp
    #/vendor/bin/thermal_core /vendor/etc/thermal/disable_thermal.conf
    #lock_val "120000" /sys/class/thermal/thermal_zone0/trip_point_0_temp
    # MTK-EARA
    stop eara-io
    # MemLatency Fix For Mediatek,
    # About whitelist : no such file or directory
    #Battery current limit
    lock_val "stop 1" /proc/mtk_batoc_throttling/battery_oc_protect_stop
    #lock_val "stop 1" /proc/pbm/pbm_stop
    # MemLatency Fix For Mediatek,
    # About whitelist : no such file or directory
    ## 6983&6895
    #slbc
    #lock_val "slbc_enable 0" /proc/slbc/dbg_slbc
    #lock_val "slb_disable 1" /proc/slbc/dbg_slbc
    #lock_val "slc_disable 1" /proc/slbc/dbg_slbc
    #lock_val "slbc_sram_enable 0" /proc/slbc/dbg_slbc
    #lock_val "slbc_scmi_enable 0" /proc/slbc/dbg_slbc
    #cm_mgr
    lock_val "cm_mgr_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_disable_fb 0" /sys/kernel/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_aggr 0" /sys/kernel/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_cpu_map_dram_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_perf_force_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_perf_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
    lock_val "dsu_enable 1" /sys/kernel/cm_mgr/dbg_cm_mgr
    #dcm
    #lock_val "disable 47fff" /sys/dcm/dcm_state
    #lock_val "disable 3ffffff" /sys/dcm/dcm_state
    #swpm
    #lock_val "65535 1" /proc/swpm/enable
    #lock_val "65535 0" /proc/swpm/enable
    #lock_val "0" /proc/swpm/pmu_ms_mode
    #lock_val "0" /proc/swpm/swpm_arm_dsu_pmu
    #lock_val "0" /proc/swpm/swpm_arm_pmu
    #lock_val "0" /proc/swpm/swpm_pmsr_en
else
    echo "detected old platform"
    lock_val "0" /sys/module/cache_ctl/parameters/enable
    echo "stop fpsgo"
    lock_val "0" /sys/kernel/fpsgo/common/fpsgo_enable
    lock_val "0" /sys/kernel/fpsgo/common/force_onoff
    # Disabel auto voltage add by MTK
    lock_val "0" /proc/gpufreq/gpufreq_aging_enable
    # EAS Fix for MTK, MT6893 and before
    lock_val "1" /sys/devices/system/cpu/sched/hint_enable
    chmod 004 /sys/devices/system/cpu/sched/hint_enable
    lock_val "68" /sys/devices/system/cpu/sched/hint_load_thresh
    chmod 004 /sys/devices/system/cpu/sched/hint_load_thresh
    lock_val "1" /sys/devices/system/cpu/eas/enable
    chmod 004 /sys/devices/system/cpu/eas/enable
    # Enable CPU7 for MTK, MT6893 and before(need empty power_app_cfg.xml)
    lock /sys/devices/system/cpu/sched/set_sched_isolation
    for i in 0 1 2 3 4 5 6 7 8 9; do
        lock_val "0" $CPU/cpu$i/sched_load_boost
        lock_val "$i" /sys/devices/system/cpu/sched/set_sched_deisolation
    done
    #force use ppm
    echo "force uperf use PPM"
    lock_val "0 3200000" /proc/ppm/policy/hard_userlimit_max_cpu_freq
    lock_val "0 3200000" /proc/ppm/policy/hard_userlimit_min_cpu_freq
    lock_val "1 3200000" /proc/ppm/policy/hard_userlimit_max_cpu_freq
    lock_val "1 3200000" /proc/ppm/policy/hard_userlimit_min_cpu_freq
    lock_val "2 3200000" /proc/ppm/policy/hard_userlimit_max_cpu_freq
    lock_val "2 3200000" /proc/ppm/policy/hard_userlimit_min_cpu_freq

    # MTK-EARA
    lock_val "0" /sys/kernel/eara_thermal/enable
    # MTK Low Mem Hint
    #lock_val "1" /proc/mtk-perf/lowmem_hint_enable
    #lock_val "102400" /proc/mtk-perf/mt_costomized_target
    # MemLatency Fix For Mediatek,
    # About whitelist : no such file or directory
    ##6893 and before?
    #lock_val "disable 1f7" /sys/power/dcm_state
    #lock_val "disable 3ffffff" /sys/power/dcm_state
    #swpm
    #lock_val "65535 1" /proc/swpm/enable
    #lock_val "65535 0" /proc/swpm/enable
    #lock_val "0" /proc/swpm/pmu_ms_mode
    #lock_val "0" /proc/swpm/swpm_arm_dsu_pmu
    #lock_val "0" /proc/swpm/swpm_arm_pmu
    #lock_val "0" /proc/swpm/swpm_pmsr_en
    ##slbc
    lock_val "slbc_enable 1" /proc/slbc/dbg_slbc
    #cm_mgr
    lock_val "cm_mgr_enable 0" /proc/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_cpu_disable_fb 0" /proc/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_cpu_map_dram_enable 0" /proc/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_perf_force_enable 0" /proc/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_perf_enable 0" /proc/cm_mgr/dbg_cm_mgr
    lock_val "cm_mgr_opp_enable 0" /proc/cm_mgr/dbg_cm_mgr

fi
#SLA
lock_val "enable=1" /proc/sla/config
# Mi Thermal Driver
chmod 444 /sys/class/devfreq/mtk-dvfsrc-devfreq/min_freq
#stop mi_thermald
#lock_val "1" /sys/class/thermal/thermal_message/balance_mode
#lock_val "boost:1" /sys/class/thermal/thermal_message/boost

#mi_thermald:tgame 13,nolimits 10,normal 0
lock_val "13" /sys/class/thermal/thermal_message/sconfig

#GPU Optimize
#lock_val "1" /sys/class/misc/mali0/device/csg_scheduling_period
#lock_val "1" /sys/class/misc/mali0/device/js_scheduling_period
#lock_val "50" /sys/class/misc/mali0/device/idle_hysteresis_time
#lock_val "always_on" /sys/class/misc/mali0/device/power_policy
lock_val "1" /proc/mgq/job_status
setprop debug.mali.disable_backend_affinity false
# mi special
stop vendor_tcpdump
stop miuibooster
stop vendor.miperf
#stop vendor.misys
#stop vendor.misys@2.0
#stop vendor.misys@3.0
#stop thermald
#stop thermal
#stop getgameserver
#stop mi_thermald

# mi mcd always lock resolution and fps
#stop mcd_service
#start mcd_service

# MTK thermal-hal
stop vendor.thermal-hal-2-0.mtk
#stop fpsgo
#rmmod frs
#start fpsgo

#killall fpsgo tcpdump-vendor
# MTK Task Turbo
#lock_val "15" /sys/module/task_turbo/parameters/feats
#lock_val "-1" /sys/module/task_turbo/parameters/turbo_pid
#lock_val "-1" /sys/module/task_turbo/parameters/unset_turbo_pid

lock_val "0" /sys/module/task_turbo/parameters/feats

#chmod 444 /sys/devices/virtual/thermal/thermal_message/*
#lock_val "1" /sys/kernel/thermal/sports_mode

# MTK FPSGO
## Useless Boost
lock_val "1" /sys/kernel/ged/hal/dvfs_loading_mode
lock_val "40" /sys/kernel/ged/hal/timer_base_dvfs_margin
lock_val "3" /sys/kernel/ged/hal/loading_base_dvfs_step
lock_val "130" /sys/kernel/ged/hal/dvfs_margin_value
lock /sys/module/ged/parameters/gpu_bottom_freq
lock_val "0" /sys/module/ged/parameters/gpu_cust_boost_freq

#lock_val "0" /sys/kernel/fpsgo/common/stop_boost

#chmod 444 /sys/kernel/fpsgo/common/*
lock_val "1" /sys/module/ged/parameters/is_GED_KPI_enabled

#lock_val "1" /sys/kernel/gbe/gbe_enable1
#lock_val "1" /sys/kernel/gbe/gbe_enable2
#lock_val "50" /sys/kernel/gbe/gbe2_loading_th
#lock_val "6000" /sys/kernel/gbe/gbe2_max_boost_cnt

lock_val "0" /sys/kernel/fpsgo/fbt/thrm_enable
lock_val "300" /sys/kernel/fpsgo/fbt/thrm_temp_th
lock_val "45" /sys/kernel/fpsgo/fbt/light_loading_policy
lock_val "0" /sys/kernel/fpsgo/fbt/boost_ta
lock_val "123" /sys/kernel/fpsgo/fbt/thrm_activate_fps
lock_val "-1" /sys/kernel/fpsgo/fbt/thrm_limit_cpu
lock_val "-1" /sys/kernel/fpsgo/fbt/thrm_sub_cpu
lock_val "1" /sys/kernel/fpsgo/fbt/ultra_rescue
lock_val "0" /sys/kernel/fpsgo/fbt/enable_ceiling
lock_val "0" /sys/kernel/fpsgo/fstb/tfps_to_powerhal_enable

#chmod 444 /sys/kernel/fpsgo/fbt/*

#lock_val "0" /sys/module/mtk_fpsgo/parameters/adjust_loading
lock_val "122" /sys/module/mtk_fpsgo/parameters/fixed_target_fps
#lock_val "0" /sys/module/mtk_fpsgo/parameters/cfp_onoff
#lock_val "0" /sys/module/mtk_fpsgo/parameters/gcc_enable
#lock_val "0" /sys/module/mtk_fpsgo/parameters/perfmgr_enable
#lock_val "0" /sys/module/mtk_fpsgo/parameters/qr_enable
#lock_val "0" /sys/module/mtk_fpsgo/parameters/start_limit
#lock_val "1" /sys/module/mtk_fpsgo/parameters/fps_level_range
#lock_val "20" /sys/module/mtk_fpsgo/parameters/qr_t2wnt_y_n
#lock_val "1" /sys/module/mtk_fpsgo/parameters/xgf_cfg_spid
#lock_val "0" /sys/module/mtk_fpsgo/parameters/xgf_ema2_enable
#lock_val "3" /sys/module/mtk_fpsgo/parameters/xgf_ema_dividend
#lock_val "50" /sys/module/mtk_fpsgo/parameters/gcc_reserved_up_quota_pct
#chmod 444 /sys/module/mtk_fpsgo/parameters/*

#lock_val "1" /sys/kernel/fpsgo/fstb/fstb_debug
#lock_val "1" /sys/kernel/fpsgo/fstb/set_renderer_no_ctrl
#chmod 444 /sys/kernel/fpsgo/fstb/*

lock_val "1" /sys/kernel/fpsgo/minitop/enable
lock_val "30" /sys/kernel/fpsgo/minitop/thrs_heavy
#chmod 444 /sys/kernel/fpsgo/minitop/*


#lock_val "0" /sys/module/ged/parameters/ap_self_frc_detection_rate
lock_val "0" /sys/module/ged/parameters/enable_cpu_boost
lock_val "0" /sys/module/ged/parameters/enable_gpu_boost
lock_val "1" /sys/module/ged/parameters/gx_game_mode
lock_val "47" /sys/module/ged/parameters/gx_fb_dvfs_margin
#lock_val "0" /sys/module/xgf/parameters/xgf_uboost

killall mi_thermald
