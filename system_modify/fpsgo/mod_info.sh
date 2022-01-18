# 安装时显示的模块名称
mod_name="去除FPSGO框架、Eara温控、PerfMgr-SysLimiter、Perfmgr-CPU限制"
# 模块介绍
mod_install_desc="解决MIUIv13的游戏锁核锁帧、低电量调度失效等问题"
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
    return 0
}

mod_install_no() {
    rm $MODDIR/common/FPSGO_Afterboot.sh
    rm $MODDIR/common/FPSGO.sh
    rm $MODDIR/script/FPSGO.sh
    rm $MODDIR/script/FPSGO_Afterboot.sh
    rm -rf $MODDIR/system/vendor/lib/modules
    return 0
}
