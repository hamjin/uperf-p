#!/vendor/bin/sh
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
. $BASEDIR/libuperf.sh
. $BASEDIR/libcorp.sh

wait_until_login

cp -r "$USER_PATH"/initsvc.log "$USER_PATH"/initsvc.lastboot.log
clear_log
exec 1>>"$LOG_FILE"
exec 2>&1
date
echo "PATH=$PATH"
echo "sh=$(which sh)"
echo "Bootstraping Uperf"

# create busybox symlinks
$BIN_PATH/busybox/busybox --install -s $BIN_PATH/busybox

#Scene 3rd Scheduler Adapter Config
cp -af "$SCRIPT_PATH"/vtools_powercfg.sh /data/powercfg.sh
cat "$SCRIPT_PATH"/powercfg.json >/data/powercfg.json
chmod 755 /data/powercfg.sh
chmod 755 /data/powercfg-base.sh
echo "sh $SCRIPT_PATH/powercfg_main.sh \"\$1\"" >>/data/powercfg.sh



top_app="com.android.systemui" sh /data/powercfg.sh "init"

{
    sh "$SCRIPT_PATH"/powercfg_once.sh 
    sh "$SCRIPT_PATH"/gpu_adj.sh
    sh "$SCRIPT_PATH"/mtk_special.sh
}   >>"$LOG_FILE"  2>&1

asopt_testversion
uperf_start
cpulimiter_start