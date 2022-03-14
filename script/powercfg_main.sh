#!/system/bin/sh
# Uperf https://github.com/yc9559/uperf/
# Author: Matt Yang

#BASEDIR="$(dirname "$0")"
##. $BASEDIR/libcommon.sh
##. $BASEDIR/libuperf.sh

action=
mihoyo=$(echo "$top_app" | grep "miHoYo")
#echo "$mihoyo" >/data/mihoyo.txt
huanta=$(echo "$top_app" | grep "hotta")
battery_temp=$(cat /sys/class/power_supply/battery/temp)
if [ "$mihoyo" != "" ]; then
    case "$1" in
    "powersave" | "balance") action="$1" ;;
    "performance" | "fast") action="yuanshen" ;;
    *) action="balance" ;;
    esac
    echo "$action" >/sdcard/yc/uperf/cur_powermode
    exit 0
fi
if [ "$huanta" != "" ]; then
    case "$1" in
    "powersave" | "balance") action="$1" ;;
    "performance" | "fast") action="yuanshen" ;;
    *) action="balance" ;;
    esac
    echo "$action" >/sdcard/yc/uperf/cur_powermode
    exit 0
fi
if [ "$battery_temp" -lt "150" ]; then
    case "$1" in
    "powersave") action="lowtemp" ;;
    "balance" | "performance" | "fast") action="$1" ;;
    *) action="balance" ;;
    esac
    echo "$action" >/sdcard/yc/uperf/cur_powermode
    exit 0
fi
if [ "$1" == "init" ]; then
    action="fast"
    echo "$action" >/sdcard/yc/uperf/cur_powermode
    exit 0
fi
case "$1" in
"powersave" | "balance" | "performance" | "fast") action="$1" ;;
*) action="balance" ;;
esac
echo "$action" >/sdcard/yc/uperf/cur_powermode
exit 0

echo "$action" >/sdcard/yc/uperf/cur_powermode

exit 0
