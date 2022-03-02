#!/vendor/bin/sh
# Uperf Setup
# https://github.com/yc9559/
# Author: Matt Yang & cjybyjk (cjybyjk@gmail.com) &HamJTY(coolapk@HamJTY)
# Version: 20201129

BASEDIR=$MODPATH
USER_PATH="/data/media/0/yc/uperf"

# $1:error_message
_abort() {
    echo "$1"
    echo "! Uperf installation failed."
    exit 1
}

# $1:file_node $2:owner $3:group $4:permission $5:secontext
_set_perm() {
    local con
    chown $2:$3 $1
    chmod $4 $1
    con=$5
    [ -z $con ] && con=u:object_r:system_file:s0
    chcon $con $1
}

# $1:directory $2:owner $3:group $4:dir_permission $5:file_permission $6:secontext
_set_perm_recursive() {
    find $1 -type d 2>/dev/null | while read dir; do
        _set_perm $dir $2 $3 $4 $6
    done
    find $1 -type f -o -type l 2>/dev/null | while read file; do
        _set_perm $file $2 $3 $5 $6
    done
}

_get_nr_core() {
    echo "$(cat /proc/stat | grep cpu[0-9] | wc -l)"
}

_is_aarch64() {
    if [ "$(getprop ro.product.cpu.abi)" == "arm64-v8a" ]; then
        echo "true"
    else
        echo "false"
    fi
}

_is_eas() {
    if [ "$(grep sched /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors)" != "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# $1:cpuid
_get_maxfreq() {
    local fpath="/sys/devices/system/cpu/cpu$1/cpufreq/cpuinfo_max_freq"
    local maxfreq="0"

    if [ ! -f "$fpath" ]; then
        echo ""
        return
    fi

    for f in $(cat $fpath); do
        [ "$f" -gt "$maxfreq" ] && maxfreq="$f"
    done
    echo "$maxfreq"
}

_get_maxfreq_6893() {
    local fpath="/sys/devices/system/cpu/cpufreq/policy$1/cpuinfo_max_freq"
    local maxfreq="0"
    if [ ! -f "$fpath" ]; then
        echo ""
        return
    fi

    for f in $(cat $fpath); do
        [ "$f" -gt "$maxfreq" ] && maxfreq="$f"
    done
    echo "$maxfreq"
}

_get_socid() {
    if [ -f /sys/devices/soc0/soc_id ]; then
        echo "$(cat /sys/devices/soc0/soc_id)"
    else
        echo "$(cat /sys/devices/system/soc/soc0/id)"
    fi
}

_get_sm6150_type() {
    [ -f /sys/devices/soc0/soc_id ] && SOC_ID="$(cat /sys/devices/soc0/soc_id)"
    [ -f /sys/devices/system/soc/soc0/id ] && SOC_ID="$(cat /sys/devices/system/soc/soc0/id)"
    case "$SOC_ID" in
    365 | 366) echo "sdm730" ;;
    355 | 369) echo "sdm675" ;;
    esac
}

_get_sdm76x_type() {
    if [ "$(_get_maxfreq 7)" -gt 2800000 ]; then
        echo "sdm768"
    elif [ "$(_get_maxfreq 7)" -gt 2300000 ]; then
        echo "sdm765"
    else
        echo "sdm750"
    fi
}

_get_msm8916_type() {
    case "$(_get_socid)" in
    "206" | "247" | "248" | "249" | "250") ui_print "msm8916" ;;
    "233" | "240" | "242") ui_print "sdm610" ;;
    "239" | "241" | "263" | "268" | "269" | "270" | "271") ui_print "sdm616" ;;
    *) ui_print "msm8916" ;;
    esac
}

_get_msm8952_type() {
    case "$(_get_socid)" in
    "264" | "289")
        echo "msm8952"
        ;;
    *)
        if [ "$(_get_nr_core)" == "8" ]; then
            echo "sdm652"
        else
            echo "sdm650"
        fi
        ;;
    esac
}

_get_sdm636_type() {
    if [ "$(_is_eas)" == "true" ]; then
        echo "sdm636_eas"
    else
        echo "sdm636_hmp"
    fi
}

_get_sdm660_type() {
    local b_max
    b_max="$(_get_maxfreq 4)"
    # sdm660 & sdm636 may share the same platform name
    if [ "$b_max" -gt 2000000 ]; then
        if [ "$(_is_eas)" == "true" ]; then
            echo "sdm660_eas"
        else
            echo "sdm660_hmp"
        fi
    else
        echo "$(_get_sdm636_type)"
    fi
}

_get_sdm652_type() {
    if [ "$(_is_eas)" == "true" ]; then
        echo "sdm652_eas"
    else
        echo "sdm652_hmp"
    fi
}

_get_sdm650_type() {
    if [ "$(_is_eas)" == "true" ]; then
        echo "sdm650_eas"
    else
        echo "sdm650_hmp"
    fi
}

_get_sdm626_type() {
    if [ "$(_is_eas)" == "true" ]; then
        echo "sdm626_eas"
    else
        echo "sdm626_hmp"
    fi
}

_get_sdm625_type() {
    local b_max
    b_max="$(_get_maxfreq 4)"
    # sdm625 & sdm626 may share the same platform name
    if [ "$b_max" -lt 2100000 ]; then
        if [ "$(_is_eas)" == "true" ]; then
            echo "sdm625_eas"
        else
            echo "sdm625_hmp"
        fi
    else
        echo "$(_get_sdm626_type)"
    fi
}

_get_sdm835_type() {
    if [ "$(_is_eas)" == "true" ]; then
        echo "sdm835_eas"
    else
        echo "sdm835_hmp"
    fi
}

_get_sdm82x_type() {
    if [ "$(_is_eas)" == "true" ]; then
        ui_print "sdm82x_eas"
        return
    fi

    local l_max
    local b_max
    l_max="$(_get_maxfreq 0)"
    b_max="$(_get_maxfreq 2)"

    # sdm820 OC 1728/2150
    if [ "$l_max" -lt 1800000 ]; then
        if [ "$b_max" -gt 2100000 ]; then
            # 1593/2150
            echo "sdm820_hmp"
        elif [ "$b_max" -gt 1900000 ]; then
            # 1593/1996
            echo "sdm821_v1_hmp"
        else
            # 1363/1824
            echo "sdm820_hmp"
        fi
    else
        if [ "$b_max" -gt 2300000 ]; then
            # 2188/2342
            echo "sdm821_v3_hmp"
        else
            # 1996/2150
            echo "sdm821_v2_hmp"
        fi
    fi
}

_get_e8890_type() {
    if [ "$(_is_eas)" == "true" ]; then
        echo "e8890_eas"
    else
        echo "e8890_hmp"
    fi
}

_get_e8895_type() {
    if [ "$(_is_eas)" == "true" ]; then
        echo "e8895_eas"
    else
        echo "e8895_hmp"
    fi
}

_get_mt6853_type() {
    local b_max
    b_max="$(_get_maxfreq 6)"
    if [ "$b_max" -gt 2200000 ]; then
        echo "mtd800u"
    else
        echo "mtd720"
    fi
}

_get_mt6873_type() {
    local b_max
    b_max="$(_get_maxfreq 4)"
    if [ "$b_max" -gt 2500000 ]; then
        echo "mtd820"
    else
        echo "mtd800"
    fi
}

_get_mt6877_type() {
    local b_max
    b_max="$(_get_maxfreq 4)"
    if [ "$b_max" -gt 2500000 ]; then
        echo "mtd920"
    else
        echo "mtd900"
    fi
}
_get_mt6885_type() {
    local b_max
    b_max="$(_get_maxfreq 4)"
    if [ "$b_max" -ge 2500000 ]; then
        echo "mtd1000"
    else
        echo "mtd1000l"
    fi
}

_get_mt6893_type() {
    local b_max
    b_max="$(_get_maxfreq_6893 7)"
    if [ "$b_max" -ge 2700000 ]; then
        echo "mtd1200"
    else
        echo "mtd1100"
    fi
}
_get_mt6895_type() {
    local b_max
    b_max="$(_get_maxfreq_6895 4)"
    if [ "$b_max" -ge 2800000 ]; then
        echo "mtd8100"
    else
        echo "mtd8000"
    fi
}
_get_mt6833_type() {
    local b_max
    b_max="$(_get_maxfreq 7)"
    if [ "$b_max" -ge 2300000 ]; then
        echo "mtd810"
    else
        echo "mtd700"
    fi
}
_get_lahaina_type() {
    local b_max
    b_max="$(_get_maxfreq 7)"
    if [ "$b_max" -gt 2600000 ]; then
        echo "sdm888"
    else
        echo "sdm780"
    fi
}

# $1:cfg_name
_setup_platform_file() {
    mv -f $USER_PATH/cfg_uperf.json $USER_PATH/cfg_uperf.json.bak 2>/dev/null
    cp $BASEDIR/config/$1.json $USER_PATH/cfg_uperf.json 2>/dev/null
    echo "balance" >$USER_PATH/cur_powermode
}

_place_user_config() {
    if [ ! -e "$USER_PATH/cfg_uperf_display.txt" ]; then
        cp $BASEDIR/config/cfg_uperf_display.txt $USER_PATH/cfg_uperf_display.txt 2>/dev/null
    fi
}

# $1:board_name
_get_cfgname() {
    local ret
    case "$1" in
    "lahaina") ret="$(_get_lahaina_type)" ;;
    "shima") ret="sdm775" ;;
    "kona") ret="sdm865" ;;
    "msmnile") ret="sdm855" ;;
    "sdm845") ret="sdm845" ;;
    "lito") ret="$(_get_sdm76x_type)" ;;
    "sm6150") ret="$(_get_sm6150_type)" ;;
    "sdm710") ret="sdm710" ;;
    "msm8916") ret="$(_get_msm8916_type)" ;;
    "msm8939") ret="sdm616" ;;
    "msm8952") ret="$(_get_msm8952_type)" ;;
    "msm8953") ret="$(_get_sdm625_type)" ;;
    "msm8953pro") ret="$(_get_sdm626_type)" ;;
    "sdm660") ret="$(_get_sdm660_type)" ;;
    "sdm636") ret="$(_get_sdm636_type)" ;;
    "trinket") ret="sdm665" ;;
    "bengal") ret="sdm665" ;; # sdm662
    "msm8976") ret="$(_get_sdm652_type)" ;;
    "msm8956") ret="$(_get_sdm650_type)" ;;
    "msm8998") ret="$(_get_sdm835_type)" ;;
    "msm8996") ret="$(_get_sdm82x_type)" ;;
    "msm8996pro") ret="$(_get_sdm82x_type)" ;;
    "exynos2100") ret="e2100" ;;
    "exynos1080") ret="e1080" ;;
    "exynos990") ret="e990" ;;
    "universal2100") ret="e2100" ;;
    "universal1080") ret="e1080" ;;
    "universal990") ret="e990" ;;
    "universal9825") ret="e9820" ;;
    "universal9820") ret="e9820" ;;
    "universal9810") ret="e9810" ;;
    "universal8895") ret="$(_get_e8895_type)" ;;
    "universal8890") ret="$(_get_e8890_type)" ;;
    "universal7420") ret="e7420" ;;
    "mt6768") ret="mtg80" ;; # Helio P65(mt6768)/G70(mt6769v)/G80(mt6769t)/G85(mt6769z)
    "mt6785") ret="mtg90t" ;;
    "mt6853") ret="$(_get_mt6853_type)" ;;
    "mt6873") ret="$(_get_mt6873_type)" ;;
    "mt6875") ret="$(_get_mt6873_type)" ;;
    "mt6885") ret="$(_get_mt6885_type)" ;;
    "mt6889") ret="$(_get_mt6885_type)" ;;
    "mt6891") ret="mtd1100" ;;             # D1100(4+4)
    "mt6893") ret="$(_get_mt6893_type)" ;; # D1100(1+3+4) & D1200 & D1300
    "mt6877") ret="$(_get_mt6877_type)" ;; # D900 D920
    "mt6833") ret="$(_get_mt6833_type)" ;; # D810 & D700
    "mt6833p") ret="mtd810" ;;             # D810
    "mt6833v") ret="mtd810" ;;             # D810
    "mt6983") ret="mtd9000" ;;             # D9000
    "mt6895") ret="$(_get_mt6895_type)" ;; # D8000 & D8100
    *) ret="unsupported" ;;
    esac
    echo "$ret"
}

uperf_print_banner() {
    # 获取模块版本
    module_version="$(grep_prop version $MODPATH/module.prop)"
    # 获取模块名称
    module_name="$(grep_prop name $MODPATH/module.prop)"
    # 获取模块id
    module_id="$(grep_prop id $MODPATH/module.prop)"
    # 获取模块作者
    module_author="$(grep_prop author $MODPATH/module.prop)"
    ui_print ""
    ui_print "* YC调度—天玑优化(Uperf) https://gitee.com/hamjin/uperf/"
    ui_print "* 作者: $module_author"
    ui_print "* 版本: $module_version"
}

uperf_print_finish() {
    ui_print "- Uperf 成功安装."
}

uperf_install() {
    ui_print "- 开始安装"
    DEVICE=$(getprop ro.product.board)
    DEVCODE=$(getprop ro.product.device)
    ui_print "- 设备平台: $(getprop ro.board.platform)"
    ui_print "- 设备型号: $DEVCODE"
    ui_print "- 设备代号: $DEVICE"
    # ui_print "- Android 12上ro.product.board可能是空的, 可以忽略"
    local target
    local cfgname
    target="$(getprop ro.board.platform)"
    setprop ro.product.board $target
    cfgname="$(_get_cfgname $target)"
    if [ "$cfgname" == "unsupported" ]; then
        target="$(getprop ro.product.board)"
        cfgname="$(_get_cfgname $target)"
    fi
    if [ "$cfgname" != "unsupported" ] && [ -f $MODPATH/config/$cfgname.json ]; then
        if [ "$DEVICE" == "cezanne" ]; then
            cfgname="k30u"
            ui_print "- 检测到平台为Redmi K30 Ultra！正在使用专用配置！"
        elif [ "$DEVCODE" == "cezanne" ]; then
            cfgname="k30u"
            ui_print "- 检测到平台为Redmi K30 Ultra！正在使用专用配置！"
        elif [ "$DEVCODE" == "atom" ]; then
            cfgname="10x"
            ui_print "- 检测到Redmi 10X Series！正在使用专用配置！"
        elif [ "$DEVICE" == "atom" ]; then
            cfgname="10x"
            ui_print "- 检测到Redmi 10X Series！正在使用专用配置！"
        elif [ "$DEVCODE" == "bomb" ]; then
            cfgname="10x"
            ui_print "- 检测到Redmi 10X Series！正在使用专用配置！"
        elif [ "$DEVICE" == "bomb" ]; then
            cfgname="10x"
            ui_print "- 检测到Redmi 10X Series！正在使用专用配置！"
        else
            ui_print "- 检测到CPU: $target"
        fi
        #make dir for the platform is supported
        mkdir -p $USER_PATH
        echo $cfgname >$USER_PATH/cfgname
        echo $DEVICE >$USER_PATH/device
        echo $DEVCODE >$USER_PATH/device_code
        ui_print "- 配置平台文件: $cfgname"
        #已经彻底修复
        #ui_print "- 由于联发科的问题"
        #ui_print "- Android 12上天玑1100、1200识别错误的可能性大幅提高"
        #ui_print "- 请注意平台判断"
        #ui_print "- 如果不对请及时私信"
        #sleep 3s
        _setup_platform_file "$cfgname"
    else
        ui_print "- 配置平台文件: $cfgname"
        _abort "! [$target] 暂时没有支持."
    fi

    _place_user_config
    rm -rf $BASEDIR/config
    #ARM64
    if [ "$(_is_aarch64)" == "true" ]; then
        cp "$BASEDIR/uperf/aarch64/uperf" "$BASEDIR/bin"
    else
        cp "$BASEDIR/uperf/arm/uperf" "$BASEDIR/bin"
    fi
    _set_perm_recursive $BASEDIR 0 0 0755 0644
    _set_perm_recursive $BASEDIR/bin 0 0 0755 0755
    # in case of set_perm_recursive is broken
    chmod 0755 $BASEDIR/bin/*
    rm -rf $BASEDIR/uperf
    ui_print "- 关闭位于Vendor分区的MTK官方温控锁帧等负优化"
    ui_print "- 关闭位于用户数据分区的MTK官方温控"
    ui_print "- 关闭位于用户数据分区的小米云控"
}
disable_mtk_thermal() {

    chattr -i "/data/vendor/.tp"
    chattr -i /data/vendor/thermal
    rm -rf "/data/vendor/.tp"
    rm -rf /data/vendor/thermal
    touch "/data/vendor/.tp"
    touch /data/vendor/thermal
    chattr +i "/data/vendor/.tp"
    chattr +i /data/vendor/thermal
    chattr -i /data/thermal 2>&1
    chattr -i /data/system/mcd 2>&1
    rm -rf /data/thermal 2>&1
    rm -rf /data/system/mcd 2>&1
    touch /data/system/mcd 2>&1
    touch /data/thermal 2>&1
    chattr +i /data/thermal 2>&1
    chattr +i /data/system/mcd 2>&1
    chattr -i /data/system/migt 2>&1
    chattr -i /data/system/whetstone 2>&1
    rm -rf /data/system/migt /data/system/whetstone 2>&1
    touch /data/system/whetstone 2>&1
    touch /data/system/migt 2>&1
    chattr +i /data/system/migt 2>&1
    chattr +i /data/system/whetstone 2>&1
}
injector_install() {
    ui_print "- 安装注入器"
    ui_print "- 关闭SELinux可以获得更高的兼容性和可用性"
    ui_print "- 请手动删除模块目录下的flags/allow_permissive以阻止自动关闭SELinux"

    local src_path
    local dst_path
    if [ "$(_is_aarch64)" == "true" ]; then
        src_path="$BASEDIR/injector/aarch64"
        dst_path="$BASEDIR/system/lib64"
    else
        src_path="$BASEDIR/injector/arm"
        dst_path="$BASEDIR/system/lib"
    fi

    mkdir -p "$dst_path"
    cp "$src_path/sfa_injector" "$BASEDIR/bin/"
    cp "$src_path/libsfanalysis.so" "$dst_path"
    _set_perm "$BASEDIR/bin/sfa_injector" 0 0 0755 u:object_r:system_file:s0
    _set_perm "$dst_path/libsfanalysis.so" 0 0 0644 u:object_r:system_lib_file:s0

    # in case of set_perm_recursive is broken
    chmod 0755 $BASEDIR/bin/*

    rm -rf $BASEDIR/injector
}

powerhal_stub_install() {
    ui_print "- 替换 perfhal 文件"

    # do not place empty json if it doesn't exist in system
    # vendor/etc/powerhint.json: android perf hal
    # vendor/etc/powerscntbl.cfg: mediatek perf hal (android 9)
    # vendor/etc/powerscntbl.xml: mediatek perf hal (android 10+)
    # vendor/etc/perf/commonresourceconfigs.json: qualcomm perf hal resource
    # vendor/etc/perf/targetresourceconfigs.json: qualcomm perf hal resource overrides
    local perfcfgs
    perfcfgs="
    vendor/etc/powerhint.json
    vendor/etc/powerscntbl.cfg
    vendor/etc/powerscntbl.xml
    vendor/etc/perf/commonresourceconfigs.xml
    vendor/etc/perf/targetresourceconfigs.xml
    vendor/etc/power_app_cfg.xml
    vendor/etc/powercontable.xml
    vendor/etc/task_profiles.json
    vendor/etc/fstb.cfg
    vendor/etc/gbe.cfg
    vendor/etc/xgf.cfg
    "
    for f in $perfcfgs; do
        if [ ! -f "/$f" ]; then
            rm "$BASEDIR/system/$f"
        else
            _set_perm "$BASEDIR/system/$f" 0 0 0644 u:object_r:vendor_configs_file:s0
            true >$BASEDIR/flags/enable_perfhal_stub
        fi
    done
}

busybox_install() {
    # ui_print "- 安装自带的busybox"
    ui_print "- 使用Magisk的busybox"
    local dst_path
    dst_path="$BASEDIR/bin/busybox/"

    mkdir -p "$dst_path"
    if [ "$(_is_aarch64)" == "true" ]; then
        ln -s "/data/adb/magisk/busybox" "$dst_path/busybox"
    else
        ln -s "/data/adb/magisk/busybox" "$dst_path/busybox"
    fi
    chmod 0755 "$dst_path/busybox"

    rm -rf $BASEDIR/busybox
}

uperf_print_banner
uperf_install
(disable_mtk_thermal &)
injector_install
powerhal_stub_install
busybox_install
uperf_print_finish
