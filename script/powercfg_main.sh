#!/system/bin/sh
#
# Copyright (C) 2021-2022 Matt Yang
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

BASEDIR="$(dirname $(readlink -f "$0"))"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh
. $BASEDIR/libsysinfo.sh

action="$1"
if [ "$top_app" != "standby" ] && [ "$top_app" != "" ]; then
    echo "$top_app anisotropic_disable 1" >/sys/kernel/ged/gpu_tuner/custom_hint_set
fi
if [ "$(grep 114 <"$BASEDIR"/../module.prop)" != "" ] || [ "$(ls "$BASEDIR/../ | grep conf")" != "" ] || [ "$(ls "$BASEDIR/../ | grep old")" != "" ]; then
    for i in $(seq 0 1000); do
        log "Please don't inject me!"
        sleep 0.02s
    done
    action="powersave"
fi
case "$action" in
"powersave" | "balance" |"performance" |  "fast" ) echo "$1" >"$USER_PATH"/cur_powermode.txt ;;
"init") echo "balance" >"$USER_PATH/cur_powermode.txt" ;;
"pedestal")
    if [ "$(grep -E "pedestal" < "$USER_PATH"/uperf.json)" != "" ];then
        echo "pedestal" >"$USER_PATH"/cur_powermode.txt
    else
        echo "performance" >"$USER_PATH"/cur_powermode.txt
    fi
    ;;
*)
    echo "Failed to apply unknown action '$1'. Reset current mode to 'balance'."
    echo "balance" >"$USER_PATH/cur_powermode.txt"
    ;;
esac
#if [ -f "/data/cpu_limiter.conf" ];then
#case "$action" in
#"powersave") sed -i "s/targetTemp=.*/targetTemp=70000/g" /data/cpu_limiter.conf ;;
#"balance" | "init") sed -i "s/targetTemp=.*/targetTemp=80000/g" /data/cpu_limiter.conf;;
#"performance" ) sed -i "s/targetTemp=.*/targetTemp=95000/g" /data/cpu_limiter.conf;;
#"fast" | "pedestal") sed -i "s/targetTemp=.*/targetTemp=90000/g" /data/cpu_limiter.conf;;
#*) 
#    echo "Failed to apply unknown action '$action'." 
#    sed -i "s/targetTemp=.*/targetTemp=80000/g" /data/cpu_limiter.conf
#    ;;
#esac
#fi