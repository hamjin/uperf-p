#!/vendor/bin/sh
# Uperf Runner
# https://github.com/yc9559/
# Author: Matt Yang
# Version: 20200401
BASEDIR=${0%/*}
SCRIPT_DIR="$BASEDIR/script"

# support vtools
cat $SCRIPT_DIR/powercfg_main.sh >/data/powercfg.sh
#echo "sh $SCRIPT_DIR/powercfg_main.sh \"\$1\"" >/data/powercfg.sh
#cp -af $SCRIPT_DIR/vtools-powercfg.sh /data/powercfg.sh
#cp -af $SCRIPT_DIR/vtools-powercfg.sh /data/powercfg-base.sh
chmod 755 /data/powercfg.sh
#chmod 755 /data/powercfg-base.sh
# powercfg path provided by magisk module
#Bootstrap Uperf
sh $SCRIPT_DIR/prepare.sh 2>&1
sh $SCRIPT_DIR/powercfg_once.sh 2>&1
sh $SCRIPT_DIR/start_injector.sh 2>&1
