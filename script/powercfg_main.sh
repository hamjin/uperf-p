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
. $BASEDIR/cpuset_lock.sh

if [ "$top_app" != "standby" ]; then
    echo "$top_app anisotropic_disable 1" >/sys/kernel/ged/gpu_tuner/custom_hint_set
    (cpuset_lock &)
else
    (cpuset_lock_stop &)
fi

action="$1"
case "$action" in
"powersave" | "balance" | "pedestal") echo "$1" >"$USER_PATH/cur_powermode.txt" ;;
"performance") echo "fast" >"$USER_PATH/cur_powermode.txt" ;;
"fast") echo "performance" >"$USER_PATH/cur_powermode.txt" ;;
"init") echo "pedestal" >"$USER_PATH/cur_powermode.txt" ;;
*)
    echo "Failed to apply unknown action '$1'. Reset current mode to 'balance'."
    echo "balance" >"$USER_PATH/cur_powermode.txt"
    ;;
esac
