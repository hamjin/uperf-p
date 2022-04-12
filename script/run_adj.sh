#!/vendor/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk
BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh
#Init Write Node
echo 11 >/dev/gpufreq_id
echo 1 >/dev/gpufreq_step

# Why does yc9559 like using this trash on Mediatek?
#lock_val "99" /sys/kernel/ged/hal/custom_boost_gpu_freq
#chmod 004 /sys/kernel/ged/hal/custom_boost_gpu_freq
mv $USER_PATH/log.gpuadj.txt $USER_PATH/log.gpuadj.lastboot.txt
touch $USER_PATH/log.gpuadj.txt
cd $USER_PATH
chmod 777 $BASEDIR/../bin/adjustment
nohup $BASEDIR/../bin/adjustment -l &
sleep 2s
change_task_rt "adjustment" "19"
pin_proc_on_pwr "adjustment"
