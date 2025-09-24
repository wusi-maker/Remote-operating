import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import "../style"
Button {
    id: control
    property string setIcon : ""
    property bool isGlow: false

    font.pixelSize: 20
    font.family: "Montserrat"
    implicitHeight: 60
    implicitWidth: 150

    Image{
        source: setIcon
        scale: control.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 200; } }
        anchors.centerIn: parent
    }
    // 显示按键文本内容
    contentItem:ColumnLayout{
        visible: !setIcon
        width: parent.width
        height: parent.height
        Label {
            text: control.text
            font:control.font
            color: Theme.primaryTextColor
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }
    }
    // 按键背景，胶囊形状
    background: Rectangle {
        id: backgroundrect
        implicitWidth: control.width
        implicitHeight: control.height
        radius: height / 2
        opacity: control.enabled ? 1 : 0.6
        color: Theme.buttonColor
        Behavior on color {
            ColorAnimation {
                duration: 200;
                easing.type: Easing.Linear;
            }
        }
        // 按键点击效果，用于显示一个从中心往外部扩散的圆
        Rectangle {
            id: indicator
            property int mx
            property int my
            x: mx - width / 2
            y: my - height / 2
            height: width
            radius: width / 2
            color: isGlow ? Qt.lighter(Theme.accentColor) : Qt.lighter(Theme.highlightColor)
        }
    }
    // 鼠标悬停效果
    Rectangle {
        id: mask
        radius: height / 2
        anchors.fill: parent
        visible: false
    }

    OpacityMask {
        anchors.fill: backgroundrect
        source: backgroundrect
        opacity: 0.4
        maskSource: mask
    }



    MouseArea {
        id: mouseArea
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
    }

    ParallelAnimation {
        id: anim
        NumberAnimation {
            target: indicator
            property: 'width'
            from: 0
            to: control.width * 1.5
            duration: 200
        }
        NumberAnimation {
            target: indicator;
            property: 'opacity'
            from: 0.9
            to: 0
            duration: 200
        }
    }

    onPressed: {
        indicator.mx = mouseArea.mouseX
        indicator.my = mouseArea.mouseY
        anim.restart();
    }
}
