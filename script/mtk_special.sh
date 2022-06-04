#!/system/bin/sh
#
# Copyright (C) 2022 Ham Jin

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh
. $BASEDIR/libsysinfo.sh

# Fix gpu always boost in MT6983 and MT6895, f**K buggy MTK kernel drivers.
lock_val "0" /sys/kernel/ged/hal/dcs_mode
sleep 10s

#Keep MTK Config
target="$(getprop ro.board.platform)"
cfgname="$(get_config_name $target)"
if [ "$cfgname" == "unsupported" ]; then
    target="$(getprop ro.product.board)"
    cfgname="$(get_config_name $target)"
fi
if [ "$cfgname" == "mtd9000" ] || [ "$cfgname" == "mtd8100"] || [ "$cfgname" == "mtd8000" ]; then
    log "start resuming config for new devices"
    for file in powercontable.xml power_app_cfg.xml powerscntbl.xml task_profiles.json; do
        find /data/adb/modules -name $file | while read found; do
            rm -f $found
        done
    done
fi
if [ "$cfgname" == "mtd9000" ]; then
    log "limiting cortex-a510's frequency"
    lock_val "0 200000 1600000" /proc/cpudvfs/cpufreq_debug
fi
#SLA
lock_val "enable=1" /proc/sla/config
# Mi Thermal Driver
#mi_thermald:tgame 13,nolimits 10,normal 0
lock_val "10" /sys/class/thermal/thermal_message/sconfig

#GPU Optimize
lock_val "1" /proc/mgq/job_status
setprop debug.mali.disable_backend_affinity false

# Disabel auto voltage add by MTK
lock_val "disable" /proc/gpufreqv2/aging_mode
lock_val "disable" /proc/gpufreqv2/gpm_mode
lock_val "0" /proc/gpufreq/gpufreq_aging_enable

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

# mi special
stop vendor_tcpdump
stop fpsgo
# mi mcd always lock resolution and fps
stop mcd_service
chattr -i /data/system/mcd/*
chattr -i /data/system/mcd
chmod 666 /data/system/mcd/*
chmod 666 /data/system/mcd
rm -rf /data/system/mcd
touch /data/system/mcd
chmod 666 /data/system/mcd
chattr +i /data/system/mcd

# MTK thermal-hal
stop fpsgo
rmmod frs
chmod 0000 /proc/perfmgr/xgff_ioctl
hide_value /proc/perfmgr/xgff_ioctl 0
chmod 0000 /proc/perfmgr/eara_ioctl
hide_value /proc/perfmgr/eara_ioctl 0
chmod 0000 /proc/perfmgr/eara_ioctl
hide_value /proc/perfmgr/perf_ioctl 0
#start fpsgo
killall fpsgo tcpdump-vendor

# MTK-EARA
#stop eara-io
lock_val "0" /sys/kernel/eara_thermal/enable

# MTK FPSGO
## Useless Boost
stop fpsgo
lock_val "1" /sys/kernel/fpsgo/common/stop_boost
lock_val "0" /sys/kernel/fpsgo/common/fpsgo_enable
lock_val "0" /sys/kernel/fpsgo/common/force_onoff
start fpsgo

#chmod 444 /sys/kernel/fpsgo/common/*
lock_val "1" /sys/module/ged/parameters/is_GED_KPI_enabled

#chmod 444 /sys/kernel/fpsgo/fbt/*
#chmod 444 /sys/module/mtk_fpsgo/parameters/*

lock_val "1" /sys/kernel/fpsgo/fstb/fstb_debug
lock_val "1" /sys/kernel/fpsgo/fstb/set_renderer_no_ctrl
#chmod 444 /sys/kernel/fpsgo/fstb/*

lock_val "1" /sys/kernel/fpsgo/minitop/enable
lock_val "20" /sys/kernel/fpsgo/minitop/thrs_heavy
#chmod 444 /sys/kernel/fpsgo/minitop/*

lock_val "0" /sys/module/cache_ctl/enable

lock_val "1" /sys/module/ged/parameters/gx_game_mode
lock_val "0" /sys/module/ged/parameters/gx_fb_dvfs_margin
lock_val "1" /sys/module/xgf/parameters/xgf_uboost


#Battery current limit
lock_val "stop 1" /proc/mtk_batoc_throttling/battery_oc_protect_stop
lock_val "stop 1" /proc/pbm/pbm_stop
# MemLatency Fix For Mediatek. About whitelist : no such file or directory
#slbc
lock_val "slbc_enable 1" /proc/slbc/dbg_slbc
lock_val "slb_disable 0" /proc/slbc/dbg_slbc
lock_val "slc_disable 0" /proc/slbc/dbg_slbc
lock_val "slbc_sram_enable 1" /proc/slbc/dbg_slbc
lock_val "slbc_scmi_enable 1" /proc/slbc/dbg_slbc
#dcm
lock_val "disable 47fff" /sys/dcm/dcm_state
lock_val "disable 3ffffff" /sys/dcm/dcm_state
lock_val "disable 1f7" /sys/power/dcm_state
lock_val "disable 3ffffff" /sys/power/dcm_state
#cm_mgr
## 6983&6895
lock_val "cm_mgr_disable_fb 0" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_aggr 1" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_cpu_map_dram_enable 0" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_force_enable 1" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_enable 1" /sys/kernel/cm_mgr/dbg_cm_mgr
lock_val "dsu_enable 1" /sys/kernel/cm_mgr/dbg_cm_mgr
##6893 and before
lock_val "cm_mgr_cpu_disable_fb 0" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_cpu_map_dram_enable 1" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_force_enable 1" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_perf_enable 1" /proc/cm_mgr/dbg_cm_mgr
lock_val "cm_mgr_opp_enable 0" /proc/cm_mgr/dbg_cm_mgr

killall mi_thermald
