import QtQuick 2.15
import QtQuick.Controls 2.15
import "../style"

// 背景Rectangle用来放置四个仪表盘和图标
Rectangle {
    id: dashboardContainer
    // 接收右侧页面传入的车辆数据模型
    property var vehicleDataModel: null
    
     // 动态计算仪表盘半径，根据容器大小调整，最小值为60
    property int dynamicRadius: Math.max(60, Math.min((width - 80) / 8, (height - 40) / 4))
    
    // 使用Row布局四个仪表盘
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 40


        // 第一个 - 车辆行驶速度仪表盘
        Column {
            width: (parent.width - parent.anchors.margins * 2 - parent.spacing * 3) / 4
            height: parent.height - parent.anchors.margins * 2
            spacing: 5
            
            DashboardComponent {
                id: speedDashboard
                anchors.horizontalCenter: parent.horizontalCenter
                currentValue: (vehicleDataModel && vehicleDataModel.vehicle && vehicleDataModel.vehicle.linear_velocity !== undefined)
                              ? Number(vehicleDataModel.vehicle.linear_velocity) : 0
                maxValue: 1.0
                minValue: -1.0
                unit: "m/s"
                primaryColor: Theme.tileColor
                backgroundColor: "#333333"
                startAngle: 140
                totalAngle: 260
                scaleCount: 5
                showUnit: true
                autoScaleValue: false
                initialValue: 0
                dashboardRadius: dashboardContainer.dynamicRadius
                fontFamily: "Arial"
                labelText: "行驶速度"
                valueFontSize: 25
            }
           
        }

        // 第二个 - 车辆转向角度仪表盘
        Column {
            width: (parent.width - parent.anchors.margins * 2 - parent.spacing * 3) / 4
            height: parent.height - parent.anchors.margins * 2
            spacing: 5
            
            DashboardComponent {
                id: steeringAngleDashboard
                anchors.horizontalCenter: parent.horizontalCenter
                currentValue: (vehicleDataModel && vehicleDataModel.vehicle && vehicleDataModel.vehicle.steering_angle !== undefined)
                              ? Number(vehicleDataModel.vehicle.steering_angle)*10 : 0
                maxValue: 20
                minValue: -20
                initialValue: 0
                unit: "°"
                primaryColor: Theme.tileColor
                backgroundColor: "#333333"
                startAngle: 140
                totalAngle: 260
                scaleCount: 9
                showUnit: true
                autoScaleValue: true
                dashboardRadius: dashboardContainer.dynamicRadius
                fontFamily: "Arial"
                labelText: "转向角度"
                valueFontSize: 25
            }
        }

        // 第三个 - 前车间距仪表盘(当目前选择车辆ID不为Car的时候)
        Column {
            width: (parent.width - parent.anchors.margins * 2 - parent.spacing * 3) / 4
            height: parent.height - parent.anchors.margins * 2
            spacing: 5
            
            DashboardComponent {
                id: wheelSpeedDashboard
                anchors.horizontalCenter: parent.horizontalCenter
                currentValue: (vehicleDataModel && vehicleDataModel.vehicle && vehicleDataModel.vehicle.motor_rpm_avg !== undefined)
                              ? Number(vehicleDataModel.vehicle.motor_rpm_avg) : 0
                maxValue: (vehicleDataModel && vehicleDataModel.hunterID !== "Car1") ? 1200 : 1200
                minValue: (vehicleDataModel && vehicleDataModel.hunterID !== "Car1") ? -1200 : -1200
                unit: "RPM"
                primaryColor: Theme.tileColor
                backgroundColor: "#333333"
                startAngle: 140
                totalAngle: 260
                scaleCount: 5
                showUnit: true
                autoScaleValue: true
                initialValue: 0
                dashboardRadius: dashboardContainer.dynamicRadius
                fontFamily: "Arial"
                labelText: (vehicleDataModel && vehicleDataModel.hunterID !== "Car1") ? "轮胎转速" : "轮胎转速"
                valueFontSize: 25
            }
        }

        // 第四个 - 车辆电量仪表盘
        Column {
            width: (parent.width - parent.anchors.margins * 2 - parent.spacing * 3) / 4
            height: parent.height - parent.anchors.margins * 2
            spacing: 5
            
            DashboardComponent {
                id: batteryDashboard
                anchors.horizontalCenter: parent.horizontalCenter
                property real maxbattery: (vehicleDataModel && vehicleDataModel.hunterID !== "Car1") ? 26.5 : 28.5
                property real minbattery: (vehicleDataModel && vehicleDataModel.hunterID !== "Car1") ? 23.5 : 24.5
                currentValue: {
                    if (vehicleDataModel && vehicleDataModel.vehicle && vehicleDataModel.vehicle.battery_level !== undefined) {
                        var batteryLevel = Number(vehicleDataModel.vehicle.battery_level);
                        var percentage = ((batteryLevel - minbattery) / (maxbattery - minbattery)) * 100;
                        if (percentage > 100) return 100;
                        if (percentage < 0) return 0;
                        return percentage;
                    }
                    return 0;
                }
                maxValue: 100.0
                minValue: 0.0
                unit: "%"
                primaryColor: Theme.tileColor
                backgroundColor: "#333333"
                startAngle: 140
                totalAngle: 260
                scaleCount: 5
                showUnit: true
                autoScaleValue: true
                initialValue: 0
                dashboardRadius: dashboardContainer.dynamicRadius
                fontFamily: "Arial"
                labelText: "电池电量"
                valueFontSize: 25
            }
        }
    }

    // // 底部功能图标区域
    // Rectangle {
    //     id: bottomIconArea
    //     anchors.bottom: parent.bottom
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.bottomMargin: 20
    //     width: 600
    //     height: 60
    //     color: "#3a3a3a"
    //     radius: 10

    //     Row {
    //         anchors.centerIn: parent
    //         spacing: 40

    //         // 引擎图标
    //              Rectangle {
    //                  id: engineIcon
    //                  width: 40
    //                  height: 40
    //                  color: engineMouseArea.containsMouse ? "#4a4a4a" : "transparent"
    //                  border.color: engineMouseArea.containsMouse ? "#888888" : "#666666"
    //                  border.width: 2
    //                  radius: 5
                     
    //                  Behavior on color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Behavior on border.color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Text {
    //                      anchors.centerIn: parent
    //                      text: "🔧"
    //                      font.pixelSize: engineMouseArea.pressed ? 18 : 20
    //                      color: engineMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                         
    //                      Behavior on font.pixelSize {
    //                          NumberAnimation { duration: 100 }
    //                      }
                         
    //                      Behavior on color {
    //                          ColorAnimation { duration: 200 }
    //                      }
    //                  }
                     
    //                  MouseArea {
    //                      id: engineMouseArea
    //                      anchors.fill: parent
    //                      hoverEnabled: true
    //                      onClicked: {
    //                          console.log("引擎图标被点击")
    //                      }
    //                  }
    //              }

    //         // 安全带图标
    //              Rectangle {
    //                  id: seatbeltIcon
    //                  width: 40
    //                  height: 40
    //                  color: seatbeltMouseArea.containsMouse ? "#4a4a4a" : "transparent"
    //                  border.color: seatbeltMouseArea.containsMouse ? "#888888" : "#666666"
    //                  border.width: 2
    //                  radius: 5
                     
    //                  Behavior on color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Behavior on border.color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Text {
    //                      anchors.centerIn: parent
    //                      text: "🔒"
    //                      font.pixelSize: seatbeltMouseArea.pressed ? 18 : 20
    //                      color: seatbeltMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                         
    //                      Behavior on font.pixelSize {
    //                          NumberAnimation { duration: 100 }
    //                      }
                         
    //                      Behavior on color {
    //                          ColorAnimation { duration: 200 }
    //                      }
    //                  }
                     
    //                  MouseArea {
    //                      id: seatbeltMouseArea
    //                      anchors.fill: parent
    //                      hoverEnabled: true
    //                      onClicked: {
    //                          console.log("安全带图标被点击")
    //                      }
    //                  }
    //              }

    //         // 灯光图标
    //              Rectangle {
    //                  id: lightIcon
    //                  width: 40
    //                  height: 40
    //                  color: lightMouseArea.containsMouse ? "#4a4a4a" : "transparent"
    //                  border.color: lightMouseArea.containsMouse ? "#888888" : "#666666"
    //                  border.width: 2
    //                  radius: 5
                     
    //                  Behavior on color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Behavior on border.color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Text {
    //                      anchors.centerIn: parent
    //                      text: "💡"
    //                      font.pixelSize: lightMouseArea.pressed ? 18 : 20
    //                      color: lightMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                         
    //                      Behavior on font.pixelSize {
    //                          NumberAnimation { duration: 100 }
    //                      }
                         
    //                      Behavior on color {
    //                          ColorAnimation { duration: 200 }
    //                      }
    //                  }
                     
    //                  MouseArea {
    //                      id: lightMouseArea
    //                      anchors.fill: parent
    //                      hoverEnabled: true
    //                      onClicked: {
    //                          console.log("灯光图标被点击")
    //                      }
    //                  }
    //              }

    //         // 时钟图标
    //              Rectangle {
    //                  id: clockIcon
    //                  width: 40
    //                  height: 40
    //                  color: clockMouseArea.containsMouse ? "#4a4a4a" : "transparent"
    //                  border.color: clockMouseArea.containsMouse ? "#888888" : "#666666"
    //                  border.width: 2
    //                  radius: 5
                     
    //                  Behavior on color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Behavior on border.color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Text {
    //                      anchors.centerIn: parent
    //                      text: "⏰"
    //                      font.pixelSize: clockMouseArea.pressed ? 18 : 20
    //                      color: clockMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                         
    //                      Behavior on font.pixelSize {
    //                          NumberAnimation { duration: 100 }
    //                      }
                         
    //                      Behavior on color {
    //                          ColorAnimation { duration: 200 }
    //                      }
    //                  }
                     
    //                  MouseArea {
    //                      id: clockMouseArea
    //                      anchors.fill: parent
    //                      hoverEnabled: true
    //                      onClicked: {
    //                          console.log("时钟图标被点击")
    //                      }
    //                  }
    //              }

    //         // 电池图标
    //              Rectangle {
    //                  id: batteryIcon
    //                  width: 40
    //                  height: 40
    //                  color: batteryMouseArea.containsMouse ? "#4a4a4a" : "transparent"
    //                  border.color: batteryMouseArea.containsMouse ? "#888888" : "#666666"
    //                  border.width: 2
    //                  radius: 5
                     
    //                  Behavior on color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Behavior on border.color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Text {
    //                      anchors.centerIn: parent
    //                      text: "🔋"
    //                      font.pixelSize: batteryMouseArea.pressed ? 18 : 20
    //                      color: batteryMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                         
    //                      Behavior on font.pixelSize {
    //                          NumberAnimation { duration: 100 }
    //                      }
                         
    //                      Behavior on color {
    //                          ColorAnimation { duration: 200 }
    //                      }
    //                  }
                     
    //                  MouseArea {
    //                      id: batteryMouseArea
    //                      anchors.fill: parent
    //                      hoverEnabled: true
    //                      onClicked: {
    //                          console.log("电池图标被点击")
    //                      }
    //                  }
    //              }

    //         // 温度图标
    //              Rectangle {
    //                  id: temperatureIcon
    //                  width: 40
    //                  height: 40
    //                  color: temperatureMouseArea.containsMouse ? "#4a4a4a" : "transparent"
    //                  border.color: temperatureMouseArea.containsMouse ? "#888888" : "#666666"
    //                  border.width: 2
    //                  radius: 5
                     
    //                  Behavior on color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Behavior on border.color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Text {
    //                      anchors.centerIn: parent
    //                      text: "🌡️"
    //                      font.pixelSize: temperatureMouseArea.pressed ? 18 : 20
    //                      color: temperatureMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                         
    //                      Behavior on font.pixelSize {
    //                          NumberAnimation { duration: 100 }
    //                      }
                         
    //                      Behavior on color {
    //                          ColorAnimation { duration: 200 }
    //                      }
    //                  }
                     
    //                  MouseArea {
    //                      id: temperatureMouseArea
    //                      anchors.fill: parent
    //                      hoverEnabled: true
    //                      onClicked: {
    //                          console.log("温度图标被点击")
    //                      }
    //                  }
    //              }

    //         // 燃油图标
    //              Rectangle {
    //                  id: fuelIcon
    //                  width: 40
    //                  height: 40
    //                  color: fuelMouseArea.containsMouse ? "#4a4a4a" : "transparent"
    //                  border.color: fuelMouseArea.containsMouse ? "#888888" : "#666666"
    //                  border.width: 2
    //                  radius: 5
                     
    //                  Behavior on color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Behavior on border.color {
    //                      ColorAnimation { duration: 200 }
    //                  }
                     
    //                  Text {
    //                      anchors.centerIn: parent
    //                      text: "⛽"
    //                      font.pixelSize: fuelMouseArea.pressed ? 18 : 20
    //                      color: fuelMouseArea.containsMouse ? "#ffffff" : "#cccccc"
                         
    //                      Behavior on font.pixelSize {
    //                          NumberAnimation { duration: 100 }
    //                      }
                         
    //                      Behavior on color {
    //                          ColorAnimation { duration: 200 }
    //                      }
    //                  }
                     
    //                  MouseArea {
    //                      id: fuelMouseArea
    //                      anchors.fill: parent
    //                      hoverEnabled: true
    //                      onClicked: {
    //                          console.log("燃油图标被点击")
    //                      }
    //                  }
    //              }
    //     }
    // }
}


