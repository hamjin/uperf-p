rm -rf /sdcard/yc/uperf/ /data/adb/*/uperf
chattr -i /data/thermal
chattr -i /data/system/mcd
rm -rf /data/thermal /data/system/mcd
chattr -i "/data/vendor/.tp"
chattr -i /data/vendor/thermal
rm -rf "/data/vendor/.tp" "/data/vendor/thermal"
chattr -i /data/thermal 2>&1
chattr -i /data/system/mcd 2>&1
rm -rf /data/thermal /data/system/mcd 2>&1
chattr -i /data/system/migt 2>&1
chattr -i /data/system/whetstone 2>&1
rm -rf /data/system/migt /data/system/whetstone 2>&1
rm -rf /data/powercfg*
