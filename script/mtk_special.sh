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
BASEDIR="$(dirname "$(readlink -f "$0")")"
. "$BASEDIR"/pathinfo.sh
. "$BASEDIR"/libcommon.sh
. "$BASEDIR"/libpowercfg.sh
. "$BASEDIR"/libcgroup.sh
. "$BASEDIR"/libsysinfo.sh

# work with uperf/ContextScheduler && AsoulOpt
if [ "$(is_mtk)" == "true" ]; then
    #MTK
    #MTK thermal-hal
    stop vendor.thermal-hal-2-0.mtk
    setenforce 0
    setenforce 0
    setenforce 0
    settings put system le_audio 1
    settings put system setting.duraspeed.enabled 1
    settings put secure doze_enabled 0
    settings put global is_default_icon 1
    settings put global lc3Enable true
    setenforce 1
    setenforce 1
    setenforce 1
    lock_val "0" "/sys/module/mtk_fpsgo/parameters/boost_affinity*"
    lock_val "0" "/sys/module/fbt_cpu/parameters/boost_affinity*"
    lock_val "0" "/sys/module/xgf/parameters/xgf_uboost"
    #lock_val "0" /sys/kernel/fpsgo/fbt/switch_idleprefer
    #lock_val "0" /sys/kernel/fpsgo/minitop/enable
    mask_val "0" /sys/module/mtk_core_ctl/parameters/policy_enable
    #FPSGO
    mask_val "1" /sys/kernel/fpsgo/common/perfserv_ta
    mask_val "0" /sys/kernel/fpsgo/fbt/enable_switch_down_throttle
    mask_val "0" /sys/kernel/fpsgo/fbt/enable_switch_cap_margin
    mask_val "0" /sys/kernel/fpsgo/fbt/enable_switch_sync_flag
    mas_val "0" /sys/kernel/fpsgo/fbt/thrm_enable
    mask_val "300000" /sys/kernel/fpsgo/fbt/thrm_temp_th
    mask_val "-1" /sys/kernel/fpsgo/fbt/thrm_limit_cpu
    mask_val "-1" /sys/kernel/fpsgo/fbt/thrm_sub_cpu

    #for i in {1..3}; do
    #    for i in $(ls /sys/kernel/fpsgo/fbt); do
    #        lock_val "0" /sys/kernel/fpsgo/fbt/$i
    #    done
    #done

    #Platform Specify Config
    if [ -d "/proc/gpufreqv2" ]; then
        # Disabel auto voltage scaling by MTK
        lock_val "disable" /proc/gpufreqv2/aging_mode
        #Battery current limit
        lock_val "stop 1" /proc/mtk_batoc_throttling/battery_oc_protect_stop
        #echo "killing gpu thermal"
        for i in $(seq 0 10); do
            lock_val "$i 0 0" /proc/gpufreqv2/limit_table
        done
        lock_val "1 1 1" /proc/gpufreqv2/limit_table
        lock_val "3 1 1" /proc/gpufreqv2/limit_table
        #cm_mgr
        lock_val "cm_mgr_disable_fb 0" /sys/kernel/cm_mgr/dbg_cm_mgr
    elif [ -d "/proc/gpufreq" ]; then
        mask_val "0" /sys/module/cache_ctl/parameters/enable
        # Disabel auto voltage add by MTK
        lock_val "0" /proc/gpufreq/gpufreq_aging_enable
        # Enable CPU7 for MTK, MT6893 and before(need empty power_app_cfg.xml)
        mask_val "" /sys/devices/system/cpu/sched/cpu_prefer
        mask_val "" /sys/devices/system/cpu/sched/set_sched_isolation
        for i in $(seq 0 9); do
            lock_val "0" "$CPU"/cpu"$i"/sched_load_boost
            lock_val "$i" /sys/devices/system/cpu/sched/set_sched_deisolation
        done
        lock_val "1" /sys/devices/system/cpu/sched/hint_enable
        lock_val "99" /sys/devices/system/cpu/sched/hint_load_thresh
        #force use ppm
        echo "force uperf use PPM"
        lock_val "0 3200000" /proc/ppm/policy/hard_userlimit_max_cpu_freq
        lock_val "0 3200000" /proc/ppm/policy/hard_userlimit_min_cpu_freq
        lock_val "1 3200000" /proc/ppm/policy/hard_userlimit_max_cpu_freq
        lock_val "1 3200000" /proc/ppm/policy/hard_userlimit_min_cpu_freq
        lock_val "2 3200000" /proc/ppm/policy/hard_userlimit_max_cpu_freq
        lock_val "2 3200000" /proc/ppm/policy/hard_userlimit_min_cpu_freq
        lock_val "0" /proc/ppm/cobra_limit_to_budget
        lock_val "0" /proc/ppm/cobra_budget_to_limit
        lock /proc/ppm/policy/*
        lock /proc/ppm/*
        echo "killing gpu thermal"
        for i in $(seq 0 8); do
            lock_val "$i 0 0" /proc/gpufreq/gpufreq_limit_table
        done
        lock_val "1 1 1" /proc/gpufreq/gpufreq_limit_table
        # MTK-EARA
        mask_val "0" /sys/kernel/eara_thermal/enable
        ##slbc
        #lock_val "slbc_enable 1" /proc/slbc/dbg_slbc
        #cm_mgr
        #lock_val "cm_mgr_cpu_disable_fb 0" /proc/cm_mgr/dbg_cm_mgr
    fi
    killall -9 vendor.mediatek.hardware.mtkpower@1.0-service
fi

#mi_thermald:tgame 13,nolimits 10,normal 0
#lock_val "10" /sys/class/thermal/thermal_message/sconfig
stop mcd_service
stop mimd-service
stop miuibooster
stop vendor_tcpdump
