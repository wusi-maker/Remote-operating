// Main.qml
import QtQuick 2.15
import QtQuick.Window 2.15
import "./Src/leftPage"
import "./Src/rightPage"
import "./Src/nightPage"
import "./Src/commonUI"
Windows {
    id: root
    width: 1317
    height: 933
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

