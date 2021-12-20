#!/bin/sh

BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="$BASEDIR/script"

sh $BASEDIR/initsvc_uperf.sh
sleep 120s
echo 0 >/dev/cpuset/sched_load_balance
chmod 444 /dev/cpuset/sched_load_balance
echo 0 >/dev/cpuset/background/sched_load_balance
chmod 444 /dev/cpuset/background/sched_load_balance
echo 0 >/dev/cpuset/foreground/sched_load_balance
chmod 444 /dev/cpuset/foreground/sched_load_balance
echo 0 >/dev/cpuset/game/sched_load_balance
chmod 444 /dev/cpuset/game/sched_load_balance
echo 0 >/dev/cpuset/gamelite/sched_load_balance
chmod 444 /dev/cpuset/gamelite/sched_load_balance
echo 0 >/dev/cpuset/restricted/sched_load_balance
chmod 444 /dev/cpuset/restricted/sched_load_balance
echo 0 >/dev/cpuset/system-background/sched_load_balance
chmod 444 /dev/cpuset/system-background/sched_load_balance
echo 0 >/dev/cpuset/top-app/sched_load_balance
chmod 444 /dev/cpuset/top-app/sched_load_balance
echo 0 >/dev/cpuset/vr/sched_load_balance
chmod 444 /dev/cpuset/vr/sched_load_balance
userdata=$(getprop dev.mnt.blk.data)
echo "1" > /sys/fs/f2fs/${userdata}/gc_booster
exit 0