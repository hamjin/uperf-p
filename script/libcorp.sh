#!/system/bin/sh

BASEDIR="$(dirname "$0")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libcgroup.sh

# AsoulOpt
asopt_stop() {
    pkill AsoulOpt
    killall -9 AsoulOpt
}
asopt_start() {
    asopt_stop
    log "Bring AsoulOpt start"
    nohup /data/adb/modules/asoul_affinity_opt/AsoulOpt >/dev/null 2>&1 &
}
asopt_start_upd() {
    asopt_stop
    log "Bring AsoulOpt start"
    nohup /data/adb/modules_update/asoul_affinity_opt/AsoulOpt >/dev/null 2>&1 &
}
asopt_testversion() {
    #For we embeded AsoulOpt, detect outside version
    #if [ -d "/data/adb/modules/asoul_affinity_opt" ]; then
    CUR_ASOPT_VERSIONCODE="$(grep_prop ASOPT_VERSIONCODE $MODULE_PATH/module.prop)"
    asopt_module_version="$(grep_prop versionCode /data/adb/modules/asoul_affinity_opt/module.prop)"
    if [ "$CUR_ASOPT_VERSIONCODE" -gt "$asopt_module_version" ]; then
        #Using our newer AsoulOpt
        log "- Installing embeded AsoulOpt which is newer"
        magisk --install-module "$MODULE_PATH"/asoulopt.zip
        asopt_start_upd
    fi
    if [ -f "/data/adb/modules/asoul_affinity_opt/disable" ]; then
        log "! AsoulOpt is DISABLED"
        chattr -i /data/adb/modules/asoul_affinity_opt/disable
        chmod 666 /data/adb/modules/asoul_affinity_opt/disable
        rm -rf /data/adb/modules/asoul_affinity_opt/disable
        asopt_start
    fi
}
