pragma Singleton // We indicate that this QML Type is a singleton
import QtQuick 2.15

QtObject {
    readonly property bool isDarkMode: true // 默认使用深色模式，适合桌面端应用
    readonly property color footerBackground:"#0E0E0E" // isDarkMode ? "#0E0E0E" : "#FFFFFF"
    readonly property color background: isDarkMode ? "#0E0E0E" : "#F1F1F1"
    readonly property color fontColor: isDarkMode ? "#FFFFFF" : "#0E0E0E"

    /*Dashboard Properties - 适用于桌面端应用的深色主题*/

    readonly property color backgroundColor:"#13131a"  // 主背景色 - 深紫灰色
    readonly property color footerColor:"#201f25"     // 底部区域颜色
    readonly property color forgroundColor:"#201f25"  // 前景色
    readonly property color buttonColor:"#2f2f39"     // 按钮颜色 - 深灰色
    readonly property color labledBackColor:"#1a1a1a" // 标签背景色
    readonly property color checkedIconColor:"#489eeb" // 选中图标颜色 - 蓝色
    readonly property color unCheckedIconColor :"#777781" // 未选中图标颜色 - 灰色
    readonly property color progressColor:"#2f2f39"   // 分割线颜色
    readonly property color tileColor :"#439df3"      // 瓦片颜色 - 亮蓝色
    readonly property color boardColor:"#75777f"      // 边框颜色
    
    /*扩展颜色 - 为桌面端应用添加更多颜色选项*/
    readonly property color primaryColor: "#439df3"    // 主要强调色
    readonly property color secondaryColor: "#489eeb"  // 次要强调色
    readonly property color accentColor: "#0ACF97"    // 强调色 - 绿色
    readonly property color warningColor: "#FF9500"   // 警告色 - 橙色
    readonly property color errorColor: "#FF3B30"     // 错误色 - 红色
    readonly property color successColor: "#34C759"   // 成功色 - 绿色
    
    /*边框和分割线*/
    readonly property color borderColor: "#3A3A3A"    // 边框颜色
    readonly property color dividerColor: "#2A2A2A"   // 分割线颜色
    
    /*文本颜色层级*/
    readonly property color primaryTextColor: "#FFFFFF"   // 主要文本
    readonly property color secondaryTextColor: "#CCCCCC" // 次要文本
    readonly property color tertiaryTextColor: "#999999"  // 三级文本
    readonly property color disabledTextColor: "#666666"  // 禁用文本
    
    /*输入框和控件*/
    readonly property color inputBackground: "#2c2c34"    // 输入框背景
    readonly property color inputBorder: "#3A3A3A"       // 输入框边框
    readonly property color inputFocusBorder: "#439df3"  // 输入框聚焦边框
    
    /*卡片和面板*/
    readonly property color cardBackground: "#201f25"     // 卡片背景
    readonly property color panelBackground: "#17161c"    // 面板背景
    readonly property color modalBackground: "#000000"    // 模态框背景（半透明）
    
    /*阴影*/
    readonly property color shadowColor: "#000000"       // 阴影颜色
    
    /*渐变色定义*/
    readonly property var primaryGradient: ["#439df3", "#489eeb"]
    readonly property var backgroundGradient: ["#17161c", "#201f25"]
}
