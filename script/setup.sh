#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
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

BASEDIR="$(dirname $(readlink -f "$0"))"
MODULE_PATH=$BASEDIR/../
. $BASEDIR/pathinfo.sh
. $BASEDIR/libsysinfo.sh

# $1:error_message
abort() {
    echo "$1"
    echo "! Uperf installation failed."
    exit 1
}

# $1:file_node $2:owner $3:group $4:permission $5:secontext
set_perm() {
    local con
    chown $2:$3 $1
    chmod $4 $1
    con=$5
    [ -z $con ] && con=u:object_r:system_file:s0
    chcon $con $1
}

# $1:directory $2:owner $3:group $4:dir_permission $5:file_permission $6:secontext
set_perm_recursive() {
    find $1 -type d 2>/dev/null | while read dir; do
        set_perm $dir $2 $3 $4 $6
    done
    find $1 -type f -o -type l 2>/dev/null | while read file; do
        set_perm $file $2 $3 $5 $6
    done
}

set_permissions() {
    set_perm_recursive $BIN_PATH 0 0 0755 0755 u:object_r:system_file:s0
    set_perm_recursive "$MODULE_PATH"/system/vendor/etc 0 0 0755 0644 u:object_r:vendor_configs_file:s0
    set_perm_recursive "$MODULE_PATH"/zygisk 0 0 0755 0644 u:object_r:system_file:s0
}

#grep_prop comes from https://github.com/topjohnwu/Magisk/blob/master/scripts/util_functions.sh#L30
grep_prop() {
    REGEX="s/^$1=//p"
    shift
    FILES="$@"
    [ -z "$FILES" ] && FILES='/system/build.prop'
    cat $FILES 2>/dev/null | dos2unix | sed -n "$REGEX" | head -n 1
}

install_uperf() {
    echo "- ro.board.platform=$(getprop ro.board.platform)"
    echo "- ro.product.board=$(getprop ro.product.board)"

    target="$(getprop ro.board.platform)"
    cfgname="$(get_config_name $target)"
    if [ "$cfgname" = "unsupported" ]; then
        target="$(getprop ro.product.board)"
        cfgname="$(get_config_name "$target")"
    fi
    if [ "$cfgname" = "unsupported" ] || [ ! -f "$MODULE_PATH"/config/cpu/"$cfgname".json ]; then
        abort "! Target [$target] not supported."
    fi
    mkdir -p "$USER_PATH"
    rm -rf /data/media/0/yc/uperf
    mv -f "$USER_PATH"/uperf.json "$USER_PATH"/uperf.json.bak
    cp -f "$MODULE_PATH"/config/cpu/"$cfgname".json "$USER_PATH"/uperf.json
    [ ! -e "$USER_PATH/perapp_powermode.txt" ] && cp $MODULE_PATH/config/perapp_powermode.txt $USER_PATH/perapp_powermode.txt
    echo "! Deprecated Support of perapp_powermode. Please use Scene"
    rm -rf "$MODULE_PATH"/config
    echo "- Uperf config is located at $USER_PATH/uperf.json"
}

install_powerhal_stub() {
    echo "- Fixing charge problem"
    resetprop --delete persist.sys.thermal.config
}

#Install cooperate modules
install_sfanalysis() {
    echo "- Installing uperf surfaceflinger analysis"
    echo "! Some device will break when enabled surfaceflinger analysis"
    echo "! It is default diabled at the first installation"
    echo "! You can enable it manually"
    sleep 5s
    magisk --install-module "$MODULE_PATH"/sfanalysis-magisk.zip
    if [ ! -f "/data/adb/modules/sfanalysis/disable" ];then
        rm /data/adb/modules_update/sfanalysis/disable
    fi
    rm "$MODULE_PATH"/sfanalysis-magisk.zip
}

install_corp() {
    #For we embeded AsoulOpt, detect outside version
    if [ -d "/data/adb/modules/unity_affinity_opt" ] || [ -d "/data/adb/modules_update/unity_affinity_opt" ]; then
        rm /data/adb/modules*/unity_affinity_opt
    fi
    CUR_ASOPT_VERSIONCODE="$(grep_prop ASOPT_VERSIONCODE "$MODULE_PATH"/module.prop)"
    asopt_module_version="0"
    if [ -f "/data/adb/modules/asoul_affinity_opt/module.prop" ]; then
        asopt_module_version="$(grep_prop versionCode /data/adb/modules/asoul_affinity_opt/module.prop)"
        echo "- AsoulOpt current:$asopt_module_version"
        echo "- AsoulOpt embeded:$CUR_ASOPT_VERSIONCODE"
        if [ "$CUR_ASOPT_VERSIONCODE" -ge "$asopt_module_version" ]; then
            #Using our newer AsoulOpt
            echo "! You are using an old version AsoulOpt. Installing embeded AsoulOpt"
            magisk --install-module "$MODULE_PATH"/asoulopt.zip
            if [ -f "/data/adb/modules/asoul_affinity_opt/disable" ]; then
                echo "- You have disabled the AsoulOpt. Keep the previous status."
                touch /data/adb/modules_update/asoul_affinity_opt/disable
            fi
        else
            echo "- Detected Same or Newer Version Of AsoulOpt"
        fi
    else
        echo "! AsoulOpt is not installed"
        killall -9 AsoulOpt
        rm -rf /data/adb/modules*/asoul_affinity_opt
        echo "- Installing embeded AsoulOpt"
        magisk --install-module "$MODULE_PATH"/asoulopt.zip
    fi

}

# get module version
module_version="$(grep_prop version "$MODULE_PATH"/module.prop)"
# get module name
module_name="$(grep_prop name "$MODULE_PATH"/module.prop)"
# get module id
#module_id="$(grep_prop id "$MODULE_PATH"/module.prop)"
# get module author
module_author="$(grep_prop author "$MODULE_PATH"/module.prop)"

echo ""
echo "* $module_name https://gitee.com/hamjin/uperf/"
echo "* Author: $module_author"
echo "* Version: $module_version"
echo ""

echo "- Installing $module_name"
install_uperf
install_powerhal_stub
install_sfanalysis
install_corp
set_permissions

echo "- Install Finished"
