rm -rf /sdcard/yc/uperf/ /data/adb/*/uperf
chattr -i /data/thermal
chattr -i /data/system/mcd
rm -rf /data/thermal /data/system/mcd
chattr -i "/data/vendor/.tp"
rm -rf "/data/vendor/.tp"
chattr -i /data/thermal 2>&1
chattr -i /data/system/mcd 2>&1
rm -rf /data/thermal /data/system/mcd /data/vendor/thermal 2>&1
chattr -i /data/system/migt 2>&1
chattr -i /data/system/whetstone 2>&1
rm -rf /data/system/migt /data/system/whetstone 2>&1
chmod 666 /data/powercfg*
rm -rf /data/powercfg*
