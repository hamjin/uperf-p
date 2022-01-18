##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

DEBUG_FLAG=false
##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
# REPLACE_EXAMPLE="
# /system/app/Youtube
# /system/priv-app/SystemUI
# /system/priv-app/Settings
# /system/framework
# "

# Construct your own list here
REPLACE=""

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################x

# Set what you want to display when installing your module
print_modname() {
    # use setup_uperf.sh/uperf_print_banner
    return
}

# Copy/extract your module files into $MODPATH in on_install.
on_install() {
    $BOOTMODE || abort "! Uperf cannot be installed in recovery."

    ui_print "- Extracting module files"
    unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >/dev/null
    # use universal setup.sh
    sh $MODPATH/setup_uperf.sh
    [ "$?" != "0" ] && abort
    ui_print "- 开始选择性安装系统修改部分"
    chmod +x $BASEDIR/system-modify-choose.sh

    $MODPATH/system-modify-choose.sh
    # 提醒救砖
    ui_print "
- 修改系统有卡开机或者总是自动重启风险（偶发自动重启可以不用担心）, 必须使用有效救砖模块
- 或者刷入可以自动解密Data的recovery（数量极少，特别是安卓12），在rec→高级→文件管理
- →data→adb→modules
- 删除对应的$id文件夹，不会就自行百度
- K40G的可以加群378033245询问
- 提交问题也可以在上面K40G的群、酷安私信、Gitee里问（建议），要附上打包的/sdcard/yc/uperf文件夹，注明机型、MIUI版本，发生时间
"
    # use once
    rm $MODPATH/setup_uperf.sh
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases
set_permissions() {
    # Here are some examples:
    # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
    # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
    # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
    # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
    return
}

# You can add more functions to assist your custom script code
