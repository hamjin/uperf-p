#!/system/bin/sh
# Uperf https://github.com/yc9559/uperf/
# Author: Matt Yang

BASEDIR="$(dirname "$0")"
. $BASEDIR/libcommon.sh
. $BASEDIR/libuperf.sh

action="$1"
battery_temp=$(cat /sys/class/power_supply/battery/temp)
LOWTEMP=0
# $1: power_mode
apply_power_mode() {
    uperf_set_powermode "$1"
}

# $1: power_mode
verify_power_mode() {
    # fast -> performance
    if ["$LOWTEMP" -eq "1" ]; then
        case "$1" in
        "powersave" | "balance") echo "lowtemp" ;;
        "performance" | "fast") echo "$1" ;;
        *) echo "lowtemp" ;;
        esac
    else
        case "$1" in
        "powersave" | "balance" | "performance" | "fast") echo "$1" ;;
        *) echo "balance" ;;
        esac
    fi
}

# 1. target from exec parameter
if [ ! -f "$BASEDIR/flags/disable_lowtemp"]; then
    if [ "$battery_temp" -lt "220" ]; then
        LOWTEMP=1
    fi
fi
if [ "$action" != "" ]; then
    action="$(verify_power_mode "$action")"
    apply_power_mode "$action"
    exit 0
fi

exit 0
