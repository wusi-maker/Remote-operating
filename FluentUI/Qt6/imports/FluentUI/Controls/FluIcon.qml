import QtQuick
import QtQuick.Controls
import FluentUI

// 使用text组件作为基础，加载字体图标。并将图标编码转化为字符显示
Text {
    property int iconSource
    property int iconSize: 20
    property color iconColor: FluTheme.dark ? "#FFFFFF" : "#000000"
    id:control
    font.family: font_loader.name
    font.pixelSize: iconSize
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    color: iconColor
    // 将图标编码转化为字符显示
    text: (String.fromCharCode(iconSource).toString(16))
    opacity: iconSource>0
    FontLoader{
        id: font_loader
        source: "qrc:/qt/qml/FluentUI/Font/FluentIcons.ttf"
    }
}
