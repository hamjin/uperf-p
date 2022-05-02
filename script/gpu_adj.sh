#!/vendor/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh

#Fix dcs
lock_val "99" /sys/kernel/ged/hal/custom_boost_gpu_freq

#Init Write Node
echo 11 >/dev/gpufreq_id
echo 1 >/dev/gpufreq_step

# Disabel auto voltage add by MTK
lock_val "disable" /proc/gpufreqv2/aging_mode
lock_val "disable" /proc/gpufreqv2/gpm_mode
lock_val "disable" /proc/gpufreq/aging_mode

#lock_val "0" /sys/kernel/ged/hal/dcs_mode
#lock_val "99" /sys/kernel/ged/hal/custom_boost_gpu_freq
mv $USER_PATH/log.gpuadj.txt $USER_PATH/log.gpuadj.lastboot.txt
touch $USER_PATH/log.gpuadj.txt
cd $USER_PATH
chmod 777 $BASEDIR/../bin/gpu_adj
nohup $BASEDIR/../bin/gpu_adj >/dev/null &
sleep 2s
change_task_rt "gpu_adj" "19"
pin_proc_on_pwr "gpu_adj"
change_task_cgroup "gpu_adj" "background" "cpuset"
