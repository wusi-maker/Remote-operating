// Main.qml
import QtQuick 2.15
import QtQuick.Window 2.15
import "./Src/leftPage"
import "./Src/rightPage"
import "./Src/nightPage"
Window {
    id: root
    width: 1317
    height: 933
    visible: true
    title: "无边框窗口示例"
    color: "transparent"  // 关键：实现无边框窗口
    flags: Qt.FramelessWindowHint  // 移除系统边框


    // 鼠标拖动逻辑
    MouseArea {
        anchors.fill: parent
        property point dragStartPos: Qt.point(0, 0)

        onPressed: (mouse) => {
            dragStartPos = Qt.point(mouse.x, mouse.y)
            console.log(dragStartPos)
        }

        onPositionChanged: (mouse) => {
            if (pressed) {
                root.x += mouse.x - dragStartPos.x
                root.y += mouse.y - dragStartPos.y
            }
        }
    }
    // 左边背景矩形
    Leftpage{
        id:leftrect
        width: 255
        anchors.left: parent.left
        anchors.top:parent.top
        anchors.bottom: bottomRect.top
        color:"#1a1a21"
    }
    // 右边背景矩形
    Rightpage{
        id:rightrect
        width:parent.width-leftrect.width
        anchors.right: parent.right
        anchors.top:parent.top
        anchors.bottom: bottomRect.top
        color:"#13131a"
    }
    // 底部窗口
    Playmusic{
        id:bottomRect
        anchors.bottom: parent.bottom
        anchors.right:parent.right
        anchors.left: parent.left
        height: 110
        color:"#2d2d37"
    }





}

