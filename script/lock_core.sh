#/system/bin/sh
USER_PATH="/data/media/0/yc/uperf"
lock_val() {

    for p in $2; do
        if [ -f "$p" ]; then
            echo "Locking $1 -> $p after boot " >>$USER_PATH/init_uperf.txt
            chmod 0666 "$p" 2>/dev/null
            echo "$1" >"$p"
            chmod 0444 "$p" 2>/dev/null
            echo "Locking $1 -> $p after boot Done! " >>$USER_PATH/init_uperf.txt
        fi
    done
}
lock() {
    if [ -f "$1" ]; then
        echo "Locking $1 's Permission" >>$USER_PATH/init_uperf.txt
        chmod 0444 "$1" 2>/dev/null
        echo "Locking $1 's Permission Done!" >>$USER_PATH/init_uperf.txt
    fi
}
lock_val "0-7" /dev/cpuset/top-app/boost/cpus
lock_val "0-7" /dev/cpuset/top-app/cpus
lock_val "0-7" /dev/cpuset/foreground/boost/cpus
lock_val "0-7" /dev/cpuset/foreground/cpus
lock_val "0-6" /dev/cpuset/restricted/cpus
lock_val "0-4" /dev/cpuset/background/cpus
lock_val "0-4" /dev/cpuset/system-background/cpus
# VMOS may set cpuset/background/cpus to "0"
lock /dev/cpuset/background/cpus
#Do Not Let Games Run On A55
lock_val "4-7" /dev/cpuset/game/cpus
lock_val "4-7" /dev/cpuset/gamelite/cpus
