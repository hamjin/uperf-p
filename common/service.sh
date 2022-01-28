#!/system/bin/sh
ASH_STANDALONE=1
BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="$BASEDIR/script"

sh $BASEDIR/initsvc_uperf.sh &
