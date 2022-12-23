#!/system/bin/sh

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

#Try to unzip by magisk
SKIPUNZIP=0

on_install() {
    $BOOTMODE || abort "! Uperf cannot be installed in recovery."
    [ "$ARCH" = "arm64" ] || abort "! Uperf ONLY support arm64 platform."
    if [ ! -f "$MODPATH/sfanalysis-magisk.zip" ]; then
        ui_print "- Extracting module files"
        unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >/dev/null
    fi
    # use universal setup.sh
    sh "$MODPATH"/script/setup.sh 2>&1
    [ "$?" != "0" ] && abort

    # use once
    rm "$MODPATH"/script/setup.sh
    rm "$MODPATH"/customize.sh
}
set_permissions() {
    set_perm_recursive "$MODPATH" 0 0 0755 0644
    chmod 755 "$MODPATH"/bin/*
    chmod 755 "$MODPATH"/*.sh
    chmod 755 "$MODPATH"/script/*.sh
}
on_install
set_permissions
