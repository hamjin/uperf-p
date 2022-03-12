#!/system/bin/sh
# Uperf https://github.com/yc9559/uperf/
# Author: Matt Yang

BASEDIR="$(dirname "$0")"
. $BASEDIR/libcommon.sh
. $BASEDIR/libuperf.sh

action="$1"

# $1: power_mode
verify_power_mode() {
    local mihoyo=$(echo $top_app | grep "miHoYo")
    local huanta=$(echo $top_app | grep "hotta")
    local battery_temp=$(cat /sys/class/power_supply/battery/temp)
    if [ $mihoyo ]; then
        case "$1" in
        "powersave" | "balance" | "fast") action="$1" ;;
        "performance") action= "yuanshen" ;;
        *) action="lowtemp" ;;
        esac
        return 0
    elif [ $huanta ]; then
        case "$1" in
        "powersave" | "balance" | "fast") action="$1" ;;
        "performance") action="yuanshen" ;;
        *) action="lowtemp" ;;
        esac
        return 0
    elif [ "$battery_temp" -lt "150" ]; then
        case "$1" in
        "powersave") action="lowtemp" ;;
        "balance" | "performance" | "fast") action="$1" ;;
        *) action="balance" ;;
        esac
        return 0
    else
        case "$1" in
        "powersave" | "balance" | "performance" | "fast") action="$1" ;;
        *) action="balance" ;;
        esac
        return 0
    fi
}

# 1. target from exec parameter

if [ $action ]; then
    verify_power_mode "$1"
    uperf_set_powermode "$action"
    exit 0
fi

exit 0
