# 安装时显示的模块名称
mod_name="开启sdcardfs-优化存储"
# 模块介绍
mod_install_desc="开启sdcardfs-优化存储"
# 安装时显示的提示
mod_install_info="是否安装[$mod_name]"
# 按下[音量+]选择的功能提示
mod_select_yes_text="安装$mod_name"
# 按下[音量+]后加入module.prop的内容
mod_select_yes_desc="[$mod_select_yes_text]"
# 按下[音量-]选择的功能提示
mod_select_no_text="不安装$mod_name"
MODDIR=${0%/*}
# 按下[音量+]时执行的函数
# 如果不需要，请保留函数结构和return 0
mod_install_yes() {
    cat $MOD_FILES_DIR/sdcardfs.prop >>$MODDIR/common/system.prop
    return 0
}

mod_install_no() {
    return 0
}
