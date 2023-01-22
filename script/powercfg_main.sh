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
top_app="$2"
category="$3"
echo "$action $top_app $category" >/dev/uperf_scene
HAS_GAME="$(grep "gbalance" <$USER_PATH/uperf.json)"
[ [ "$HAS_GAME" != "" ] && [ [ "$category" == "game" ] || [ "$(cat /dev/asopt_game)" == "1" ] ] ] && action="g$action"

case "$action" in
    "powersave" | "balance" | "performance" | "fast") echo "$action" >"$USER_PATH"/cur_powermode.txt ;;
    "gpowersave" | "gbalance" | "gfast") echo "$action" >"$USER_PATH"/cur_powermode.txt ;; #game mode
    "gperformance")
        if [ -f $USER_PATH/.ENABLE_GAME_PERFORMACE_MODE ]; then
            echo "$action" >"$USER_PATH"/cur_powermode.txt #USE IT AT YOUR OWN RISK
        else
            echo "gfast" >"$USER_PATH"/cur_powermode.txt
        fi
    ;;
    "init") echo "balance" >"$USER_PATH/cur_powermode.txt" ;; #default balance
    "pedestal")
        if [ "$(grep -E "pedestal" <"$USER_PATH"/uperf.json)" != "" ]; then
            echo "pedestal" >"$USER_PATH"/cur_powermode.txt
        else
            echo "performance" >"$USER_PATH"/cur_powermode.txt
        fi
    ;;
    "gpedestal") echo "gperformance" >"$USER_PATH"/cur_powermode.txt ;;
    *)    echo "Failed to apply unknown action '$1'.";;
esac
