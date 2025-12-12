import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {

    // 主要仪表盘区域
    Item {
        id: mainDashboardArea
        anchors.fill: parent
        anchors.margins: 20
        
        // 中央主速度表 (0-200 KPH)
        DashboardComponent {
            id: speedometer
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -50
            currentValue: 120
            maxValue: 200
            minValue: 0
            unit: "KPH"
            primaryColor: "#00bfff"  // 蓝色
            backgroundColor: "#333333"
            startAngle: 135
            totalAngle: 270
            scaleCount: 10
            showUnit: true
            autoScaleValue: true
            initialValue: 0
            dashboardRadius: 150
            centerBackgroundSize: 120
            
            // 动态数据模拟
            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: {
                    speedometer.currentValue = Math.random() * 180 + 20
                }
            }
        }
        
        // 左侧转速表 (0-11 RPM x1000)
        DashboardComponent {
            id: tachometer
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 50
            currentValue: 0
            maxValue: 11
            minValue: 0
            unit: "RPM\nx 1000"
            primaryColor: "#00ff41"  // 绿色
            backgroundColor: "#333333"
            startAngle: 135
            totalAngle: 270
            scaleCount: 11
            showUnit: true
            autoScaleValue: true
            initialValue: 0
            dashboardRadius: 100
            centerBackgroundSize: 80
            
            // 动态数据模拟
            Timer {
                interval: 1500
                running: true
                repeat: true
                onTriggered: {
                    tachometer.currentValue = Math.random() * 9 + 1
                }
            }
        }
        
        // 右侧温度表 (50-110°C)
        DashboardComponent {
            id: temperatureGauge
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 50
            currentValue: 110
            maxValue: 110
            minValue: 50
            unit: "°C"
            primaryColor: "#ff4444"  // 红色
            backgroundColor: "#333333"
            startAngle: 135
            totalAngle: 270
            scaleCount: 6
            showUnit: true
            autoScaleValue: true
            initialValue: 90
            dashboardRadius: 100
            centerBackgroundSize: 80
            
            // 动态数据模拟
            Timer {
                interval: 3000
                running: true
                repeat: true
                onTriggered: {
                    temperatureGauge.currentValue = Math.random() * 40 + 70
                }
            }
        }
        
        // 底部功能图标区域
        Row {
            id: iconRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 50
            spacing: 40
            
            // 发动机图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "🔧"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
            
            // 安全带图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "🔒"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
            
            // 大灯图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "💡"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
            
            // 转向灯图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "⬅️"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
            
            // 电池图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "🔋"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
            
            // 胎压图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "⚪"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
            
            // 门锁图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "🚪"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
            
            // 燃油图标
            Rectangle {
                width: 40
                height: 40
                color: "transparent"
                border.color: "#666666"
                border.width: 2
                radius: 5
                
                Text {
                    anchors.centerIn: parent
                    text: "⛽"
                    font.pixelSize: 20
                    color: "#888888"
                }
            }
        }
        
        // 档位显示区域
        Rectangle {
            id: gearDisplay
            anchors.horizontalCenter: speedometer.horizontalCenter
            anchors.top: speedometer.bottom
            anchors.topMargin: 20
            width: 80
            height: 60
            color: "#2a2a2a"
            border.color: "#555555"
            border.width: 2
            radius: 10
            
            Column {
                anchors.centerIn: parent
                spacing: 5
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "GEAR"
                    font.pixelSize: 12
                    color: "#888888"
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "D"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#00ff41"
                }
            }
        }
    }
    
    // 顶部信息栏
    Rectangle {
        id: topInfoBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        color: "#2a2a2a"
        
        Row {
            anchors.centerIn: parent
            spacing: 50
            
            Text {
                text: "ODO: 12,345 km"
                font.pixelSize: 14
                color: "#cccccc"
            }
            
            Text {
                text: "TRIP: 123.4 km"
                font.pixelSize: 14
                color: "#cccccc"
            }
            
            Text {
                text: "AVG: 6.8 L/100km"
                font.pixelSize: 14
                color: "#cccccc"
            }
        }
    }
}
