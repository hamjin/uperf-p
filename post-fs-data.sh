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

MODDIR=${0%/*}
touch /data/adb/modules/asoul_affinity_opt/flag/dont_fuck
touch /data/adb/modules_update/asoul_affinity_opt/flag/dont_fuck
if [ -f "$MODDIR/flag/need_recuser" ]; then
    rm -f $MODDIR/flag/need_recuser
    true >$MODDIR/disable
    chmod 666 /data/powercfg.sh
    chmod 666 /data/powercfg.json
    rm -rf /data/powercfg.sh /data/powercfg.json
else
    true >$MODDIR/flag/need_recuser
fi
mkdir /dev/cpuset/background/untrustedapp
echo "0-3" >/dev/cpuset/background/untrustedapp