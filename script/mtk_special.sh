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

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh
sleep 10s
#mi_thermald:tgame 13,nolimits 10,normal 0
lock_val "10" /sys/class/thermal/thermal_message/sconfig
chmod 444 /sys/class/devfreq/mtk-dvfsrc-devfreq/userspace/set_freq

#GPU Optimize
lock_val "1" /sys/class/misc/mali0/device/csg_scheduling_period
lock_val "1" /sys/class/misc/mali0/device/js_scheduling_period
lock_val "50" /sys/class/misc/mali0/device/idle_hysteresis_time
#lock_val "always_on" /sys/class/misc/mali0/device/power_policy

# EAS Fix for MTK, MT6893 and before
lock_val "1" /sys/devices/system/cpu/sched/hint_enable
chmod 004 /sys/devices/system/cpu/sched/hint_enable
lock_val "85" /sys/devices/system/cpu/sched/hint_load_thresh
chmod 004 /sys/devices/system/cpu/sched/hint_load_thresh
lock_val "2" /sys/devices/system/cpu/eas/enable
chmod 004 /sys/devices/system/cpu/eas/enable

# Enable CPU7 for MTK, MT6893 and before(need empty power_app_cfg.xml)
lock /sys/devices/system/cpu/sched/set_sched_isolation
for i in 0 1 2 3 4 5 6 7 8 9; do
    lock_val "0" $CPU/cpu$i/sched_load_boost
    lock_val "$i" /sys/devices/system/cpu/sched/set_sched_deisolation
done

#MTK New Thermal
#lock_val "disable_thermal.conf" /data/vendor/thermal/.permanent_tp
#lock_val "disable_thermal.conf" /data/vendor/thermal/.current_tp
#/vendor/bin/thermal_core /vendor/etc/thermal/disable_thermal.conf
#lock_val "120000" /sys/class/thermal/thermal_zone0/trip_point_0_temp

# mi special
stop vendor_tcpdump
#stop miuibooster
#stop vendor.miperf
#stop vendor.misys
#stop vendor.misys@2.0
#stop vendor.misys@3.0
#stop thermald
#stop thermal
#stop getgameserver
#stop mi_thermald

# mi mcd always lock resolution and fps
stop mcd_service

# MTK thermal-hal
#stop vendor.thermal-hal-2-0.mtk

#stop fpsgo
#killall fpsgo tcpdump-vendor
# MTK Task Turbo
lock_val "0" /sys/module/task_turbo/parameters/feats
#hide_value /sys/module/task_turbo/parameters/feats 0

# MTK Low Mem Hint
#lock_val "0" /proc/mtk-perf/lowmem_hint_enable
#lock_val "102400" /proc/mtk-perf/mt_costomized_target

# MTK-EARA
stop eara-io
lock_val "0" /sys/kernel/eara_thermal/enable
#hide_value /sys/kernel/eara_thermal/enable 0

# stop mtk_core_ctl
#lock_val "0" /sys/module/mtk_core_ctl/parameters/policy_enable
# Mi Thermal Driver
lock_val "0" /sys/class/thermal/thermal_message/balance_mode
#chmod 444 /sys/devices/virtual/thermal/thermal_message/*
lock_val "1" /sys/kernel/thermal/sports_mode

# MTK FPSGO
## Useless Boost
#lock_val "0" /sys/kernel/fpsgo/common/force_onoff
#lock_val "0" /sys/kernel/fpsgo/common/fpsgo_enable
#lock_val "1" /sys/kernel/fpsgo/common/stop_boost
#chmod 444 /sys/kernel/fpsgo/common/*
#lock_val "0" /sys/module/ged/parameters/is_GED_KPI_enabled

#lock_val "1" /sys/kernel/gbe/gbe_enable1
#lock_val "1" /sys/kernel/gbe/gbe_enable2

#lock_val "100" /sys/kernel/fpsgo/fbt/thrm_temp_th
#lock_val "-1" /sys/kernel/fpsgo/fbt/thrm_limit_cpu
#lock_val "-1" /sys/kernel/fpsgo/fbt/thrm_sub_cpu
#lock_val "0" /sys/kernel/fpsgo/fbt/ultra_rescue
#chmod 444 /sys/kernel/fpsgo/fbt/*

#lock_val "1" /sys/module/mtk_fpsgo/parameters/adjust_loading
#lock_val "0" /sys/module/mtk_fpsgo/parameters/cfp_onoff
#lock_val "0" /sys/module/mtk_fpsgo/parameters/gcc_enable
#lock_val "0" /sys/module/mtk_fpsgo/parameters/qr_enable
#lock_val "0" /sys/module/mtk_fpsgo/parameters/start_limit
#lock_val "1" /sys/module/mtk_fpsgo/parameters/fps_level_range
#chmod 444 /sys/module/mtk_fpsgo/parameters/*

#lock_val "1" /sys/kernel/fpsgo/fstb/set_renderer_no_ctrl
#chmod 444 /sys/kernel/fpsgo/fstb/*

#lock_val "0" /sys/kernel/fpsgo/minitop/enable
#chmod 444 /sys/kernel/fpsgo/minitop/*

# Disable automatic voltage increase by MTK
lock_val "disable" /proc/gpufreqv2/aging_mode
lock_val "disable" /proc/gpufreqv2/gpm_mode
lock_val "0" /proc/gpufreq/gpufreq_aging_enable

# Fix gpu always boost in MT6983 and MT6895, f**K buggy MTK kernel drivers.
lock_val "0" /sys/kernel/ged/hal/dcs_mode

# MemLatency Fix For Mediatek, f**k the whitelist
## 6983&6895
lock_val "slbc_enable 0" /proc/slbc/dbg_slbc
#lock_val "slb_disable 1" /proc/slbc/dbg_slbc
#lock_val "slc_disable 1" /proc/slbc/dbg_slbc
#lock_val "slbc_sram_enable 0" /proc/slbc/dbg_slbc
#lock_val "slbc_scmi_enable 0" /proc/slbc/dbg_slbc
lock_val "cm_mgr_disable_fb 0" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_cpu_map_dram_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_force_enable 1" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_enable 1" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "dsu_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_ipi_enable 1" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_dram_level 6" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_emi_demand_check 0" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "dsu_opp_send 0" /sys/kernel/cm_mgr/dbg_cm_mgr
##6893 and before?
lock_val "slbc_enable 0" /proc/slbc/dbg_slbc
#lock_val "slb_disable 1" /proc/slbc/dbg_slbc
#lock_val "slc_disable 1" /proc/slbc/dbg_slbc
#lock_val "slbc_sram_enable 0" /proc/slbc/dbg_slbc
#lock_val "slbc_scmi_enable 0" /proc/slbc/dbg_slbc
lock_val "cm_mgr_disable_fb 0" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_cpu_map_dram_enable 0" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_force_enable 1" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_enable 1" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_opp_enable 1" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_enable 0" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_sspm_enable 0" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_ipi_enable 0" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_dram_level 6" /proc/cm_mgr/dbg_cm_mgr
