#!/system/bin/sh

BASEDIR="$(dirname "$0")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libcgroup.sh

# AsoulOpt
asopt_stop() {
    pkill AsoulOpt
    killall -15 AsoulOpt
}
asopt_start() {
    asopt_stop
    log "Bring AsoulOpt start"
    cd "/data/adb/modules/asoul_affinity_opt/"
    sh /data/adb/modules/asoul_affinity_opt/service.sh
    cd -
}
asopt_start_upd() {
    asopt_stop
    log "Bring AsoulOpt start"
    cd "/data/adb/modules_update/asoul_affinity_opt/"
        sh /data/adb/modules_update/asoul_affinity_opt/service.sh
    cd -
}
asopt_testversion() {
    #For we embeded AsoulOpt, detect outside version
    CUR_ASOPT_VERSIONCODE="$(grep_prop ASOPT_VERSIONCODE $MODULE_PATH/module.prop)"
    asopt_module_version="$(grep_prop versionCode /data/adb/modules/asoul_affinity_opt/module.prop)"
    if [ "$CUR_ASOPT_VERSIONCODE" -gt "$asopt_module_version" ]; then
        #Using our newer AsoulOpt
        log "- Installing embeded AsoulOpt which is newer"
        magisk --install-module "$MODULE_PATH"/asoulopt.zip
        if [ -f "/data/adb/modules/asoul_affinity_opt/disable" ]; then
            echo "You have disabled the AsoulOpt. Keep the previous status."
            touch /data/adb/modules_update/asoul_affinity_opt/disable
        else
            asopt_start_upd
        fi
    fi
}
