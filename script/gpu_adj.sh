#!/vendor/bin/sh
# GPU Adjustment
# Author: HamJin @CoolApk

BASEDIR="$(dirname "$(readlink -f "$0")")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libpowercfg.sh
. $BASEDIR/libcgroup.sh
. $BASEDIR/libsysinfo.sh

GPUADJ_LOGPATH="/data/media/0/Android/yc/uperf/gpu_adj.conf"
GPUADJ_CONFPATH="/data/media/0/Android/yc/uperf/log.gpu_adj.txt"

gpuadj_stop(){
    pkill loadmonitor_gpu
}
gpuadj_start(){
    gpuadj_stop
    nohup "$BIN_PATH"/loadmonitor_gpu -l "$GPUADJ_LOGPATH" -c "$GPUADJ_CONFPATH" >/dev/null 2>&1 & 
}
gpuadj_testconf(){
    if [ -f "/data/media/0/Android/yc/uperf/gpu_adj.conf" ]; then
        GPUADJ_CONFPATH="/data/media/0/Android/yc/uperf/gpu_adj.conf"
        gpuadj_start
    elif [ -f "/data/gpu_freq_table.conf" ];then
        GPUADJ_CONFPATH="/data/gpu_freq_table.conf"
        gpuadj_start
    fi
}