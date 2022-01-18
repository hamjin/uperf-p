DEBUG_FLAG=false
miui_version="$(grep_prop ro.miui.ui.version.name)"
var_soc="$(getprop ro.board.platform)"
model="$(grep_prop ro.product.system.model)"
id="$(grep_prop id $TMPDIR/module.prop)"
var_device="$(getprop ro.product.device)"
var_version="$(grep_prop ro.build.version.release)"
author="$(grep_prop author $TMPDIR/module.prop)"
name="$(grep_prop name $TMPDIR/module.prop)"
description="$(grep_prop description $TMPDIR/module.prop)"
ui_print "- *******************************"
ui_print "- 您的设备名称: $model"
ui_print "- 您的设备: $var_device"
ui_print "- 系统版本: $var_version"
ui_print "- miui版本: $miui_version"
ui_print "- $name    "
ui_print "- 作者：$author"
source $TMPDIR/instruct.sh

initmods() {
  mod_name=""
  mod_install_info=""
  mod_select_yes_text=""
  mod_select_yes_desc=""
  mod_select_no_text=""
  mod_select_no_desc=""
  mod_require_device=""
  mod_require_version=""
  INSTALLED_FUNC="$(trim $INSTALLED_FUNC)"
  MOD_SKIP_INSTALL=false
  cd $TMPDIR/system_modify
}

keytest() {
  ui_print "
- *******************************"
  ui_print "- 音量键测试 -"
  ui_print "  请按下 [音量+] 键："
  ui_print "  无反应或传统模式无法正确安装时，请触摸一下屏幕后继续"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" >$TMPDIR/events) || return 1
  return 0
}

chooseport() {
  while (true); do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" >$TMPDIR/events
    if ($(cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null)); then
      break
    fi
  done
  if ($(cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null)); then
    return 0
  else
    return 1
  fi
}

chooseportold() {
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  $DEBUG_FLAG && ui_print "  DEBUG: chooseportold: $1,$SEL"
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    abort "   未检测到音量键!"
  fi
}

on_install() {
  unzip -o "$ZIPFILE" 'system_modify/*' -d "$TMPDIR/" >&2
  source $TMPDIR/util_funcs.sh
  KEYCHECK=$TMPDIR/keycheck
  chmod 755 $KEYCHECK

  # 测试音量键
  if keytest; then
    VOLKEY_FUNC=chooseport
    ui_print "
- *******************************
"
  else
    VOLKEY_FUNC=chooseportold
    ui_print "
- *******************************"
    ui_print "- 检测到遗留设备！使用旧的 keycheck 方案 -"
    ui_print "- 进行音量键录入 -"
    ui_print "  录入：请按下 [音量+] 键："
    $VOLKEY_FUNC "UP"
    ui_print "  已录入 [音量+] 键。"
    ui_print "  录入：请按下 [音量-] 键："
    $VOLKEY_FUNC "DOWN"
    ui_print "  已录入 [音量-] 键。"
    ui_print "
- *******************************"
  fi

  # 替换文件夹列表
  REPLACE=""
  # 已安装模块
  MODS_SELECTED_YES=""
  MODS_SELECTED_NO=""
  # 加载可用模块
  initmods
  for MOD in $(ls); do
    if [ -f $MOD/mod_info.sh ]; then
      MOD_FILES_DIR="$TMPDIR/system_modify/$MOD/files"
      source $MOD/mod_info.sh
      $DEBUG_FLAG && ui_print "  DEBUG: load $MOD"
      $DEBUG_FLAG && ui_print "  DEBUG: mod's name: $mod_name"
      $DEBUG_FLAG && ui_print "  DEBUG: mod's device requirement: $mod_require_device"
      $DEBUG_FLAG && ui_print "  DEBUG: mod's version requirement: $mod_require_version"

      if [ -z $mod_require_device ]; then
        mod_require_device=$var_device
        $DEBUG_FLAG && ui_print "  DEBUG: replace mod's device requirement: $mod_require_device"
      fi
      if [ -z $mod_require_version ]; then
        mod_require_version=$var_version
        $DEBUG_FLAG && ui_print "  DEBUG: replace mod's version requirement: $mod_require_version"
      fi

      if $MOD_SKIP_INSTALL; then
        ui_print "  跳过[$mod_name]安装"
        initmods
        continue
      fi

      if [ "$(echo $var_device | egrep $mod_require_device)" = "" ]; then
        ui_print "   [$mod_name]不支持你的设备。"
      elif [ "$(echo $var_version | egrep $mod_require_version)" = "" ]; then
        ui_print "   [$mod_name]不支持你的系统版本。"
      else

        ui_print "     ————————安装【$mod_name】
        "
        ui_print "-️--
————介绍: $mod_install_desc
---"
        ui_print "
- - ️️$mod_install_info 🚦-"
        ui_print "   [音量+]：$mod_select_yes_text"
        ui_print "   [音量-]：$mod_select_no_text"

        if $VOLKEY_FUNC; then
          ui_print "
———————————
- 已选择[$mod_select_yes_text]。
———————————
        "
          mod_install_yes
          run_result=$?
          if [ $run_result -eq 0 ]; then
            MODS_SELECTED_YES="$MODS_SELECTED_YES ($MOD)"
            INSTALLED_FUNC="$mod_select_yes_desc $INSTALLED_FUNC"
          else
            ui_print "   失败。错误: $run_result"
          fi

        else
          ui_print "
——————————
已选择[$mod_select_no_text]。
——————————
        "
          mod_install_no
          run_result=$?
          if [ $run_result -eq 0 ]; then
            MODS_SELECTED_NO="$MODS_SELECTED_NO ($MOD)"
            INSTALLED_FUNC="$mod_select_no_desc $INSTALLED_FUNC"
          else
            ui_print "   失败。错误: $run_result"
          fi
        fi
      fi
    else
      $DEBUG_FLAG && ui_print "  DEBUG: could not found $MOD's mod_info.sh"
    fi
    initmods
  done

  if [ -z "$INSTALLED_FUNC" ]; then
    ui_print "—— 未安装任何功能 即将退出安装...
    " && abort
  fi
}
