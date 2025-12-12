import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: vehicleDashboardRoot
    width: 1200
    height: 800
    
    // 背景
    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
    }
    
    // 标题
    Text {
        id: titleText
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        text: "车辆监控仪表盘"
        font.pixelSize: 24
        font.bold: true
        color: "white"
    }
    
    // 上层仪表盘容器 - 居中布局
    Item {
        id: topDashboardContainer
        anchors.top: titleText.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: 800
        height: 400
        
        // 车辆行驶速度仪表盘
        DashboardComponent {
            id: speedDashboard
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            currentValue: 0
            maxValue: 3.0
            minValue: -3.0
            unit: "m/s"
            primaryColor: "#00ff41"
            backgroundColor: "#333333"
            startAngle: 140
            totalAngle: 260
            scaleCount: 5
            showUnit: true
            autoScaleValue: false
            initialValue: 0
            dashboardRadius: 120
            
            // 动态数据模拟
            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: {
                    speedDashboard.currentValue = Math.random() * 6.0 - 3.0
                }
            }
        }
        
        // 车辆转向角度仪表盘
        DashboardComponent {
            id: steeringAngleDashboard
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            currentValue: 0
            maxValue: 45
            minValue: -45
            initialValue: 0
            unit: "°"
            primaryColor: "#ff6b35"
            backgroundColor: "#333333"
            startAngle: 180
            totalAngle: 180
            // 长刻度数量
            scaleCount: 9
            showUnit: true
            autoScaleValue: true
            dashboardRadius: 120
            
            // 动态数据模拟
            Timer {
                interval: 1500
                running: true
                repeat: true
                onTriggered: {
                    steeringAngleDashboard.currentValue = Math.random() * 90 - 45
                }
            }
        }
    }
    
    // 中间图标显示区域
    Rectangle {
        id: iconDisplayArea
        anchors.top: topDashboardContainer.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: 600
        height: 80
        color: "#2a2a2a"
        border.color: "#555555"
        border.width: 2
        radius: 10
        
        Row {
            anchors.centerIn: parent
            spacing: 40
            
            // 图标占位1 - 车辆状态
            Rectangle {
                width: 60
                height: 60
                color: "#444444"
                border.color: "#666666"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "车辆\n状态"
                    color: "#888888"
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // 图标占位2 - 引擎状态
            Rectangle {
                width: 60
                height: 60
                color: "#444444"
                border.color: "#666666"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "引擎\n状态"
                    color: "#888888"
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // 图标占位3 - 制动系统
            Rectangle {
                width: 60
                height: 60
                color: "#444444"
                border.color: "#666666"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "制动\n系统"
                    color: "#888888"
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // 图标占位4 - 传动系统
            Rectangle {
                width: 60
                height: 60
                color: "#444444"
                border.color: "#666666"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "传动\n系统"
                    color: "#888888"
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // 图标占位5 - 安全系统
            Rectangle {
                width: 60
                height: 60
                color: "#444444"
                border.color: "#666666"
                border.width: 1
                radius: 8
                
                Text {
                    anchors.centerIn: parent
                    text: "安全\n系统"
                    color: "#888888"
                    font.pixelSize: 10
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    
    // 下层仪表盘容器
    Item {
        id: bottomDashboardContainer
        anchors.top: iconDisplayArea.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: 800
        height: 400
        
        // 车辆轮胎转速仪表盘
        DashboardComponent {
            id: wheelSpeedDashboard
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            currentValue: 0
            maxValue: 500
            minValue: -500
            unit: "RPM"
            primaryColor: "#3498db"
            backgroundColor: "#333333"
            dashboardWidth: 400
            dashboardHeight: 400
            startAngle: 60
            totalAngle: 160
            scaleCount: 5
            showUnit: true
            autoScaleValue: true
            initialValue: 0
            dashboardRadius: 100
            
            // 动态数据模拟
            Timer {
                interval: 1800
                running: true
                repeat: true
                onTriggered: {
                    wheelSpeedDashboard.currentValue = Math.random() * 1000 - 500
                }
            }
        }
        
        // 车辆电量仪表盘
        DashboardComponent {
            id: batteryDashboard
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            currentValue: 75.0
            maxValue: 100.0
            minValue: 0.0
            unit: "%"
            primaryColor: "#e74c3c"
            backgroundColor: "#333333"
            dashboardWidth: 400
            dashboardHeight: 400
            startAngle: 300
            totalAngle: 160
            scaleCount: 5
            showUnit: true
            autoScaleValue: true
            initialValue: 0
            dashboardRadius: 100
            
            // 动态数据模拟
            Timer {
                interval: 3000
                running: true
                repeat: true
                onTriggered: {
                    batteryDashboard.currentValue = Math.random() * 100.0
                }
            }
        }
    }
    
    // 底部说明文字
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        text: "车辆监控系统 - 实时数据显示"
        font.pixelSize: 14
        color: "#888888"
    }
}
