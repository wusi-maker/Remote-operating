import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    id: root
    width: 1317
    height: 933
    visible: true
    title: "无边框窗口示例"
    color: "transparent"  // 关键：实现无边框窗口
    flags: Qt.FramelessWindowHint  // 仅仅在Window类型才有该属性


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
}
