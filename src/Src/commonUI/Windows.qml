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
}
