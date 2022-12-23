#!/system/bin/sh
chmod 666 /data/media/0/Android/yc/uperf/*
chattr -i /data/media/0/Android/yc/uperf/*
rm -rf /sdcard/yc/uperf/ /data/adb/*/uperf
chmod 666 /data/powercfg*
rm -rf /data/powercfg*
rm -rf /sdcard/yc/uperf
rm -rf /sdcard/Android/yc
chattr -i /data/system/mcd /data/system/mcd.bak /data/system/mcd.bak/*
chmod 666  /data/system/mcd /data/system/mcd.bak /data/system/mcd.bak/*
chattr -i /data/system/mcd
chmod 644 /data/system/mcd
rm -rf /data/system/mcd
chmod 444 /data/system/mcd.bak /data/system/mcd.bak/*
chattr +i /data/system/mcd.bak/* /data/system/mcd.bak
mv /data/system/mcd.bak /data/system/mcd
