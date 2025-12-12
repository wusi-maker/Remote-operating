import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../style"

Rectangle {
    id: root
    color: "transparent"
    
    // 接收外部传入的数据模型
    property var dataModel: [
        {"name": "orientation.x", "value": "0.0"},
        {"name": "orientation.y", "value": "0.0"},
        {"name": "orientation.z", "value": "0.0"},
        {"name": "orientation.w", "value": "0.0"},
        {"name": "angular_velocity.x", "value": "0.0"},
        {"name": "angular_velocity.y", "value": "0.0"},
        {"name": "angular_velocity.z", "value": "0.0"},
        {"name": "linear_acceleration.x", "value": "0.0"},
        {"name": "linear_acceleration.y", "value": "0.0"},
        {"name": "linear_acceleration.z", "value": "0.0"},
        {"name": "motor_rpm_avg", "value": "0"},
        {"name": "steering_angle", "value": "0"},
        {"name": "linear_velocity", "value": "0"},
        {"name": "battery_level", "value": "0"},
        {"name": "odometry.angular_z", "value": "0"},
        {"name": "odometry.position.x", "value": "0"},
        {"name": "odometry.position.y", "value": "0"},
        {"name": "gps.latitude", "value": "0"},
        {"name": "gps.longitude", "value": "0"}
    ]
    
    ListView {
        id: listView
        anchors.fill: parent
        anchors.margins: 10
        anchors.rightMargin: 20  // 为滚动条预留空间
        model: root.dataModel
        spacing: 5
        
        delegate: Rectangle {
            width: listView.width
            height: 50
            color: index % 2 === 0 ? Theme.labledBackColor : Qt.darker(Theme.labledBackColor, 1.1)
            radius: 5
            border.color: Theme.checkedIconColor
            border.width: 0
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10
                
                Text {
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width * 0.4
                    text: modelData.name
                    color: Theme.primaryTextColor
                    font.pixelSize: 20
                    font.bold: true
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                }
                
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Theme.progressColor
                    opacity: 0.5
                }
                
                Text {
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width * 0.6
                    text: modelData.value
                    color: Theme.primaryTextColor
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            active: true
            policy: ScrollBar.AsNeeded
            width: 8
            
            contentItem: Rectangle {
                implicitWidth: 8
                implicitHeight: 100
                radius: width / 2
                color: scrollBar.pressed ? Theme.checkedIconColor : Qt.rgba(0.28, 0.62, 0.92, 0.3)
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            background: Rectangle {
                implicitWidth: 8
                implicitHeight: 100
                radius: width / 2
                color: "transparent"  // 背景透明，不再使用白色
                opacity: 0.1
            }
        }
    }
}