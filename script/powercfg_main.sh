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
target="$(getprop ro.board.platform)"
cfgname="$(get_config_name $target)"
if [ "$cfgname" == "unsupported" ]; then
    target="$(getprop ro.product.board)"
    cfgname="$(get_config_name $target)"
fi
#if [ "$cfgname" == "mtd9000" ]; then
#    lock_val "0 200000 1600000" /proc/cpudvfs/cpufreq_debug
#    if [ "$top_app" == "com.tencent.tmgp.sgame" ] || [ "$top_app" == "com.tencent.tmgp.sgamece" ] ; then
#        lock_val "4 1600000 1800000" /proc/cpudvfs/cpufreq_debug
#        lock_val "7 1600000 1800000" /proc/cpudvfs/cpufreq_debug
#    else if [ "$top_app" == "com.miHoYo.Yuanshen"];then
#        lock_val "4 1800000 2400000" /proc/cpudvfs/cpufreq_debug
#        lock_val "7 1800000 2400000" /proc/cpudvfs/cpufreq_debug
#    else
#        lock_val "4 4000000 2850000" /proc/cpudvfs/cpufreq_debug
#        lock_val "7 1300000 3000000" /proc/cpudvfs/cpufreq_debug
#    fi
#fi
action="$1"
case "$1" in
"powersave" | "balance" | "performance" | "fast" | "pedestal") echo "$1" >"$USER_PATH/cur_powermode.txt" ;;
"auto") echo "balance" >"$USER_PATH/cur_powermode.txt" ;;
*) echo "Failed to apply unknown action '$1'." ;;
esac