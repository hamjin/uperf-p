#!/system/bin/sh
# Injector Library
# https://github.com/yc9559/
# Author: Matt Yang
# Version: 20220331

BASEDIR="$(dirname "$0")"
. $BASEDIR/pathinfo.sh
. $BASEDIR/libcommon.sh

###############################
# PATHs
###############################

INJ_REL="$BIN_DIR"
INJ_NAME="sfa_injector"

###############################
# Injector tool functions
###############################

add_selinux() {
   mkdir -p ""$USER_PATH"/kmsg/"
   rm -rf "$USER_PATH"/kmsg/"$2".log
   cat /proc/kmsg >>"$USER_PATH"/kmsg/"$2".log &
   local ppid=$!
   sleep "$3"
   kill -9 $ppid >>"$LOG_FILE"
   local rule=""
   eval $(cat "$USER_PATH"/kmsg/"$2".log | sed -n -r "/(avc: denied.*comm\=\"$1\")/p" | awk -F " " '{print $13, $21, $22}' | awk '!a[$0]++{print}' | awk -F " |:|=" '{printf("rule=%s; local domain=%s; local type=%s", $1, $5, $8)}')
   #cat "$USER_PATH"/kmsg/"$2".log | sed -n -r "/(avc: denied.*comm\=\"$1\")/p" | awk -F " " '{print $13, $21, $22}' | awk '!a[$0]++{print}' | awk -F " |:|=" '{print}' >>"$LOG_FILE"
   if [ "$rule" != "" ]; then
      echo "Add SELinux rule: allow" "$1" "$domain" "$type" "$rule" >>"$LOG_FILE"
      magiskpolicy --live "allow $1 $domain $type { $rule }" >>"$LOG_FILE"
      local com=magiskpolicy" "--live' "'allow" "$1" "$domain" "$type" "$rule'"'
      chmod 777 ""$MODULE_PATH"/script/sepolicy.sh" >>"$LOG_FILE"
      echo "$com" >>""$MODULE_PATH"/script/sepolicy.sh"
      sleep 1
   fi
}

# $1:process $2:dynamiclib $3:alog_tag
inj_do_inject() {
   log ""
   if [ -f "$FLAGS/not_injection" ]; then
      log "Pass injection"
      exit 0
   fi
   log "[begin] injecting $2 to $1"

   local lib_path="/system/lib64/$2"

   # fallback to standlone mode
   [ ! -e "$lib_path" ] && lib_path="${MODULE_PATH}${lib_path}"

   magiskpolicy --live "allow surfaceflinger system_lib_file file { open read getattr execute  }" >>"$LOG_FILE"
   magiskpolicy --live "allow surfaceflinger system_data_file file { open read write getattr execute}" >>"$LOG_FILE"
   magiskpolicy --live "allow surfaceflinger system_data_file dir { open read write getattr search }" >>"$LOG_FILE"
   magiskpolicy --live "allow surfaceflinger mcd_data_file dir { open read write getattr search }" >>"$LOG_FILE"

   # try to allow executing dlopen in surfaceflinger
   sh ""$MODULE_PATH"/script/sepolicy.sh" >>"$LOG_FILE"

   sleep 1

   magiskpolicy --live "allow surfaceflinger system_lib_file file { open read getattr execute  }" >>"$LOG_FILE"
   magiskpolicy --live "allow surfaceflinger system_data_file file { open read write getattr execute}" >>"$LOG_FILE"
   magiskpolicy --live "allow surfaceflinger system_data_file dir { open read write getattr search }" >>"$LOG_FILE"
   magiskpolicy --live "allow surfaceflinger mcd_data_file dir { open read write getattr search }" >>"$LOG_FILE"
   sleep 5

   i=1
   "$MODULE_PATH/$INJ_REL/$INJ_NAME" "$lib_path" >>"$LOG_FILE"

   while [ "$?" != "0" ] && [ "$i" -lt 10 ]; do
      i=$i+1
      log "Try add SELinux rule, retry..."
      #(add_selinux "SfAnalysis" "kmsg_SfAnalysis" "5") &
      (add_selinux "surfaceflinger" "kmsg_surfaceflinger" "5") &
      #(add_selinux "uperf" "kmsg_uperf" "5") &
      "$MODULE_PATH/$INJ_REL/$INJ_NAME" "$lib_path" >>"$LOG_FILE"
      logcat -d | grep -i "$3" >>"$LOG_FILE"
      sleep 6
   done
   if [ "$?" != "0" ]; then
      log "Injector failed."
   else
      log "Try set SELinux rule..."
      for i in $(seq 1 10); do
         add_selinux "surfaceflinger" "kmsg_surfaceflinger" "6"
         sleep 6
      done
   fi
   log "[end] injecting $2 to $1"
   log "Set SELinux rule done."
   log ""
}

inj_do_inject "/system/bin/surfaceflinger" "libsfanalysis.so" "SfAnalysis"
