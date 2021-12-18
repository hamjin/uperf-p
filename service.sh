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
while true;
do
    echo 0-3 >/dev/cpuset/cpus
    echo 0-1 >/dev/cpuset/background/cpus
    echo 2-5 >/dev/cpuset/foreground/cpus
    echo 4-7 >/dev/cpuset/game/cpus
    echo 4-7 >/dev/cpuset/gamelite/cpus
    echo 0-1 >/dev/cpuset/restricted/cpus
    echo 2-3 >/dev/cpuset/system-background/cpus
    echo 2-6 >/dev/cpuset/top-app/cpus
    echo 0-7 >/dev/cpuset/vr/cpus
    sleep 60s
done;
exit 0