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
install_uperf() {
    echo "- ro.board.platform=$(getprop ro.board.platform)"
    echo "- ro.product.board=$(getprop ro.product.board)"

    target="$(getprop ro.board.platform)"
    cfgname="$(get_config_name $target)"
    if [ "$cfgname" = "unsupported" ]; then
        target="$(getprop ro.product.board)"
        cfgname="$(get_config_name "$target")"
    fi

    if [ "$cfgname" = "unsupported" ] || [ ! -f "$MODULE_PATH"/config/"$cfgname".json ]; then
        abort "! Target [$target] not supported."
    fi
    mkdir -p "$USER_PATH"
    rm -rf /sdcard/yc/uperf
    mv -f "$USER_PATH"/uperf.json "$USER_PATH"/uperf.json.bak
    cp -f "$MODULE_PATH"/config/"$cfgname".json "$USER_PATH"/uperf.json
    chattr -i /data/media/0/Android/yc/uperf/perapp_powermode.txt
    chmod 666 /data/media/0/Android/yc/uperf/perapp_powermode.txt
    [ ! -e ""$USER_PATH"/perapp_powermode.txt" ] && cp "$MODULE_PATH"/config/perapp_powermode.txt "$USER_PATH"/perapp_powermode.txt
    #Force use Scene
    echo "! Deprecated Support of perapp_powermode. Please use Scene"
    rm -rf "$MODULE_PATH"/config
    echo "- Uperf config is located at $USER_PATH"
}

install_powerhal_stub() {
    echo "- Detecting platform specific perfhal stub"
    target="$(getprop ro.board.platform)"
    cfgname="$(get_config_name "$target")"
    if [ "$cfgname" = "unsupported" ]; then
        target="$(getprop ro.product.board)"
        cfgname="$(get_config_name "$target")"
    fi

    # do not place empty json if it doesn't exist in system
    # vendor/etc/powerhint.json: android perf hal
    # vendor/etc/powerscntbl.cfg: mediatek perf hal (android 9)
    # vendor/etc/powerscntbl.xml: mediatek perf hal (android 10+)
    # vendor/etc/perf/commonresourceconfigs.json: qualcomm perf hal resource
    # vendor/etc/perf/targetresourceconfigs.json: qualcomm perf hal resource overrides
    if [ "$cfgname" = "mtd9000" ] || [ "$cfgname" = "mtd8100" ]; then
        echo "- Found new devices, using modified version"
        rm -rf "$MODULE_PATH"/system/vendor/etc/powerscntbl.xml.empty
        rm -rf "$MODULE_PATH"/system/vendor/etc/power_app_cfg.xml.empty
        rm -rf "$MODULE_PATH"/system/vendor/etc/powercontable.xml.empty
    else
        echo "- Found old devices, clearing perfhal config"
        perfcfgs="
        vendor/etc/powerscntbl.xml
        vendor/etc/powercontable.xml
        vendor/etc/power_app_cfg.xml
        "
        for f in $perfcfgs; do
            if [ ! -f "/$f" ]; then
                echo "- Not found /$f, bypass it."
                rm "$MODULE_PATH/system/$f"
                rm "$MODULE_PATH/system/$f.empty"
            else
                cat "$MODULE_PATH/system/$f.empty" >"$MODULE_PATH/system/$f"
                rm "$MODULE_PATH/system/$f.empty"
            fi
        done
    fi
    if [ -d "/data/system/mcd" ]; then
        echo "- Dealing with some limits"
        mv /data/system/mcd /data/system/mcd.bak
        chmod 444 /data/system/mcd.bak
        chmod 444 /data/system/mcd.bak/*
        chattr +i /data/system/mcd.bak/*
        chattr +i /data/system/mcd.bak
        touch /data/system/mcd
        chmod 000 /data/system/mcd
        chattr +i /data/system/mcd
    fi
}
#Install cooperate modules
install_sfanalysis() {
    echo "- Installing uperf surfaceflinger analysis"
    magisk --install-module "$MODULE_PATH"/sfanalysis-magisk.zip
    rm "$MODULE_PATH"/sfanalysis-magisk.zip
}
install_ssanalysis_old() {
    echo "- Warning! Device not running MIUI should disable it by yourself to avoid some problem!"
    echo "- 警告! 非MIUI设备请手动禁用这个模块避免部分系统问题"
    sleep 10s
    magisk --install-module "$MODULE_PATH"/ssanalysis-magisk.zip
    rm "$MODULE_PATH"/ssanalysis-magisk.zip
}
install_ssanalysis() {

    #if [ ! -d "/data/adb/modules/ssanalysis" ]; then
    #    echo "- Please install uperf system_server analysis by yourself"
    #    echo "- It is at /sdcard/Android/yc/uperf/ssanalysis-magisk.zip"
    #    cp -r "$MODULE_PATH"/ssanalysis-magisk.zip /sdcard/Android/yc/uperf/ssanalysis-magisk.zip
    #else
    #    if [ -f "/sdcard/Android/yc/uperf/ssanalysis-magisk.zip" ]; then
    #        rm /sdcard/Android/yc/uperf/ssanalysis-magisk.zip
    #    fi
    #fi
    echo "- Deprecated support of SystemServer Analysis"
    if [ -f "/sdcard/Android/yc/uperf/ssanalysis-magisk.zip" ]; then
        rm /sdcard/Android/yc/uperf/ssanalysis-magisk.zip
    fi
}
install_asopt_old() {
    touch /data/adb/modules/asoul_affinity_opt/remove
    echo "- Installing AsoulOpt"
    magisk --install-module "$MODULE_PATH"/asoulopt.zip
    rm "$MODULE_PATH"/asoulopt.zip
}
install_corp() {
    #For we embeded AsoulOpt, detect outside version
    if [ -d "/data/adb/modules/unity_affinity_opt" ] || [ -d "/data/adb/modules_update/unity_affinity_opt" ]; then
        rm /data/adb/modules*/unity_affinity_opt
    fi
    rm -rf /data/adb/asopt
    if [ -d "/data/adb/modules/asoul_affinity_opt" ]; then
        CUR_ASOPT_VERSIONCODE="$(grep_prop ASOPT_VERSIONCODE "$MODULE_PATH"/module.prop)"
        asopt_module_version="$(grep_prop versionCode /data/adb/modules/asoul_affinity_opt/module.prop)"
        if [ "$CUR_ASOPT_VERSIONCODE" -ge "$asopt_module_version" ]; then
            #Using our newer AsoulOpt
            echo "! You are using an old version AsoulOpt"
            killall -9 AsoulOpt
            rm -rf /data/adb/modules*/asoul_affinity_opt
        fi
        echo "- Installing embeded AsoulOpt"
        echo
        echo "- You need to uninstall or disable other schedulers"
        echo "- Like Scene-Online, Scene-Traditional, Femind, and CuToolbox(CupurumAdjustment)"
        echo "- You can tweak configs in $CONFIG_PATH"
        echo "- You can find the log in $LOG_PATH"
        echo "- If there is a log tagged 'E' in the log file, you can submit a feedback with the log."
        echo "- Others are normal situation"
        echo 

        if [ -d /data/adb/modules/unity_affinity_opt ]; then
            mv /data/adb/modules/unity_affinity_opt /data/adb/modules/asoul_affinity_opt
        fi

        rm -rf /data/adb/asopt
        mkdir -p /sdcard/Android/asopt
        CONFIG_PATH="/sdcard/Android/asopt/asopt.conf"
        LOG_PATH="/sdcard/Android/asopt/asopt.log"
        note="# cpuset：是否使用cpuset控制游戏线程
# 0：使用syscall
# 1：使用cpuset
# 若在游戏中遇到莫名卡顿等问题
# 可尝试调为0，但不生效的概率会提升

# preempt：防非游戏进程抢占优化
# 0：关闭
# 1：只允许非游戏线程使用不重要的CPU
# 2：只允许非游戏线程使用小核
# 调为2可最大化游戏性能
# 但会导致小窗体验糟糕
# 若遇到了一些奇怪的问题
# 可尝试调为0，但会降低游戏性能
"
        cpuset=$(grep cpuset= $CONFIG_PATH)
        preempt=$(grep preempt= $CONFIG_PATH)

        if [[ ! -f $CONFIG_PATH ]]; then
            cpuset=$(grep cpuset= /data/asopt.conf)
            preempt=$(grep preempt= /data/asopt.conf)

            rm /data/asopt.conf
        fi

        if [[ -z $cpuset ]]; then
            cpuset="cpuset=1"
        fi

        if [[ -z $preempt ]]; then
            preempt="preempt=1"
        fi

        echo "$note" >$CONFIG_PATH
        echo "$cpuset" >>$CONFIG_PATH
        echo "$preempt" >>$CONFIG_PATH

    fi
}
#grep_prop comes from https://github.com/topjohnwu/Magisk/blob/master/scripts/util_functions.sh#L30
grep_prop() {
    REGEX="s/^$1=//p"
    shift
    FILES="$@"
    [ -z "$FILES" ] && FILES='/system/build.prop'
    cat $FILES 2>/dev/null | dos2unix | sed -n "$REGEX" | head -n 1
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

echo "- Installing uperf"
install_uperf

install_powerhal_stub
install_sfanalysis
install_ssanalysis
install_corp
set_permissions

echo "- Install Finished"
