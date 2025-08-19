import QtQuick 2.15
import QtQuick.Controls
import "../title"
Rectangle{
    id:rightrect
    Search{
        id:searchRow
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 36
        anchors.verticalCenter: otherRow.verticalCenter
    }

    // 用户信息
    UserConfigsetting{
        id:otherRow
        anchors.verticalCenter: minmaxMouse.verticalCenter
        anchors.right: minmaxMouse.left
        anchors.rightMargin: 10
        spacing: 15
    }

    // 最大化最小化
    MinAndMax{
        id:minmaxMouse
        width: 180
        color:"transparent"
        anchors.top: parent.top
        anchors.right: parent.right
        // anchors.left: parent.left
        height: 60
    }
}
