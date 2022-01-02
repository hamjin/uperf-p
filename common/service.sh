#!/bin/sh

BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="$BASEDIR/script"

sh $BASEDIR/initsvc_uperf.sh
sleep 10s
settings put Secure speed_mode_enable
exit 0