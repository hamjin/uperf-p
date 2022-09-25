#!/system/bin/sh

BASEDIR="$(dirname "$0")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libcgroup.sh

# AsoulOpt
asopt_stop() {
    pkill AsoulOpt
}
asopt_start() {
    asopt_stop
    nohup "$BIN_PATH"/AsoulOpt >/dev/null 2>&1 &
}
asopt_testversion(){
    #For we embeded AsoulOpt, detect outside version
    if [ -d "/data/adb/modules/asoul_affinity_opt" ]; then
        CUR_ASOPT_VERSIONCODE="$(grep_prop ASOPT_VERSIONCODE $MODULE_PATH/module.prop)"
        asopt_module_version="$(grep_prop versionCode /data/adb/modules/asoul_affinity_opt/module.prop)"
        if [ "$CUR_ASOPT_VERSIONCODE" -ge "$asopt_module_version" ];then
            #Using our newer AsoulOpt
            asopt_stop
            rm -rf /data/adb/modules/asoul_affinity_opt
            asopt_start
        fi
    else
        asopt_start
    fi
}
# cpulimiter
cpulimiter_stop() {
    killall -9 cpu_limiter
    pkill cpu_limiter
}
cpulimiter_start() {
    cpulimiter_stop
    nohup "$BIN_PATH"/cpu_limiter >/dev/null 2>&1 &
}
cpulimiter_testdevice(){
    if [ -d /proc/gpufreqv2 ];then
        cpulimiter_start
    fi
}