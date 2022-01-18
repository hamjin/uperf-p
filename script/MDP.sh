#/system/bin/sh
USER_PATH="/data/media/0/yc/uperf"
lock_val() {
    for p in $2; do
        if [ -f "$p" ]; then
            echo "Locking $1 -> $p  " >>$USER_PATH/init_uperf.txt
            chmod 0666 "$p" 2>/dev/null
            echo "$1" >"$p"
            chmod 0444 "$p" 2>/dev/null
            echo "Locking $1 -> $p Done! " >>$USER_PATH/init_uperf.txt
        fi
    done
}
lock_val "1" /sys/module/ged/parameters/ged_force_mdp_enable
lock_val "1" /sys/module/ged/parameters/is_GED_KPI_enabled
lock_val "1" /sys/module/ged/parameters/gx_frc_mode
lock_val "1" /sys/module/ged/parameters/enable_game_self_frc_detect
