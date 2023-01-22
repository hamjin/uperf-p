#!/system/bin/sh

BASEDIR=${0%/*}
ROOTDIR=$BASEDIR/../
# curl bin
CURL=$ROOTDIR/bin/curl

# main link
updateJsonUrl=https://gitee.com/hamjin/uperf/raw/update/uperf-hamjty-dynamic-v3.json
updateZipUrl=https://uperf-mtk.jintaiyang123.org/https://raw.githubusercontent.com/hamjin/uperf-mtk/update/uperf-v3-p-latest.zip

# code
grep_prop() {
    REGEX="s/^$1=//p"
    shift
    FILES="$@"
    [ -z "$FILES" ] && FILES='/system/build.prop'
    dos2unix < "$FILES" | sed -n "$REGEX" | head -n 1
}
while true;do
    netjson=$($CURL --parallel -sLk $updateJsonUrl)
    gitver=$(echo "$netjson" | sed -n '/versionCode/p' | awk -v FS=': ' '{print $2}' | awk -v FS=',' '{print $1}')
    curver=$(grep_prop versionCode "$ROOTDIR"/module.prop 2>/dev/null)
    if [ "$gitver" -gt "$curver" ]; then
        $CURL --parallel -sLk $updateZipUrl --output /cache/newver.zip
        magisk --install-module /cache/newver.zip
        rm -rf /cache/newver.zip
        exit 0
    fi
    sleep 300s
done
