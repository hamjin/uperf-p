#!/system/bin/sh
# Module Path Header
# https://github.com/yc9559/
# Author: Matt Yang && HamJTY
BASEDIR="$(dirname $(readlink -f "$0"))"
SCRIPT_DIR="script"
BIN_DIR="bin"
MODULE_PATH="$(dirname $(readlink -f "$0"))"
MODULE_PATH="${MODULE_PATH%\/$SCRIPT_DIR}"
USER_PATH="/data/media/0/yc/uperf"
PANEL_FILE="$USER_PATH/panel_uperf.txt"
LOG_FILE="$USER_PATH/log_uperf_initsvc.log"
FLAGS="$MODULE_PATH/flags"

# do not use private busybox
PATH="/sbin:/system/sbin:/system/xbin:/system/bin:/vendor/xbin:/vendor/bin"
PATH="$MODULE_PATH/$BIN_DIR/busybox:$PATH"