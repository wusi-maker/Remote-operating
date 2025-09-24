import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI

FluPopup {
    id: vehicleDataPopup
    
    // 弹出框属性
    implicitWidth: 1200
    implicitHeight: 800
    
    // 车辆数据属性
    property var vehicleData: []
    property var selectedVehicles: [true, true, true, true, true, true] // 默认全选6辆车
    
    // 信号
    signal applyClicked()
    signal cancelClicked()
    
    // 标题
    property string title: "车辆队列数据分析"
    
    Rectangle {
        anchors.fill: parent
        color: FluTheme.dark ? "#2b2b2b" : "#ffffff"
        radius: 8
        border.color: FluTheme.dark ? "#404040" : "#e0e0e0"
        border.width: 1
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // // 标题栏
            // Rectangle {
            //     width: parent.width
            //     height: 50
            //     color: FluTheme.dark ? "#1e1e1e" : "#f5f5f5"
            //     radius: 6
            //     border.color: FluTheme.dark ? "#333333" : "#cccccc"
            //     border.width: 1
                
            //     FluText {
            //         anchors.centerIn: parent
            //         text: vehicleDataPopup.title
            //         font.pixelSize: 18
            //         font.bold: true
            //         textColor: FluTheme.dark ? "#ffffff" : "#0078d4"
            //     }
            // }
            
            // 车辆选择区域
            Rectangle {
                width: parent.width
                height: 80
                color: FluTheme.dark ? "#1e1e1e" : "#f9f9f9"
                radius: 6
                border.color: FluTheme.dark ? "#333333" : "#cccccc"
                border.width: 1
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    FluText {
                        text: "选择要显示的车辆："
                        font.pixelSize: 14
                        font.bold: true
                        textColor: FluTheme.dark ? "#e0e0e0" : "#333333"
                    }
                    
                    Row {
                        spacing: 20
                        
                        Repeater {
                            model: 6
                            FluCheckBox {
                                id: vehicleCheckBox
                                text: "车辆 " + (index + 1)
                                checked: vehicleDataPopup.selectedVehicles[index]
                                textColor: FluTheme.dark ? "#e0e0e0" : "#333333"
                                font.pixelSize: 12
                                
                                onCheckedChanged: {
                                    var newSelection = vehicleDataPopup.selectedVehicles.slice()
                                    newSelection[index] = checked
                                    vehicleDataPopup.selectedVehicles = newSelection
                                    updateCurveData()
                                }
                            }
                        }
                    }
                }
            }
            
            // 曲线显示区域
            Rectangle {
                width: parent.width
                height: parent.height - 200 // 为标题、选择区域和按钮留出空间
                color: FluTheme.dark ? "#1a1a1a" : "#ffffff"
                radius: 6
                border.color: FluTheme.dark ? "#333333" : "#cccccc"
                border.width: 1
                
                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    columns: 2
                    rows: 2
                    columnSpacing: 10
                    rowSpacing: 10
                    
                    // 队列速度曲线
                    CurveComponent {
                        id: speedCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "队列速度曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "速度 (km/h)"
                        curveColor: "#3498db"
                        showSineWave: false
                        curveType:"line"
                        autoScaleY: true
                        maxDataPoints: 50
                    }
                    
                    // 队列间距误差曲线
                    CurveComponent {
                        id: distanceErrorCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "队列间距误差曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "误差 (m)"
                        curveColor: "#e74c3c"
                        showSineWave: false
                        curveType:"line"

                        autoScaleY: true
                        maxDataPoints: 50
                    }
                    
                    // 队列受攻击强度
                    CurveComponent {
                        id: attackIntensityCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "队列受攻击强度"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "攻击强度"
                        curveColor: "#f39c12"
                        showSineWave: false
                        curveType:"line"
                        autoScaleY: true
                        maxDataPoints: 50
                    }
                    
                    // 队列间距曲线
                    CurveComponent {
                        id: distanceCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "队列间距曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "间距 (m)"
                        curveColor: "#2ecc71"
                        showSineWave: false
                        curveType:"line"
                        autoScaleY: true
                        maxDataPoints: 50
                    }
                }
            }
            
            // 按钮区域
            Rectangle {
                width: parent.width
                height: 50
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    FluButton {
                        text: "应用"
                        width: 100
                        height: 35
                        onClicked: {
                            vehicleDataPopup.applyClicked()
                            updateCurveData()
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#2980b9" : "#3498db"
                            radius: 6
                            border.color: "#2980b9"
                            border.width: 1
                        }
                        
                        contentItem: FluText {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    FluButton {
                        text: "取消"
                        width: 100
                        height: 35
                        onClicked: {
                            vehicleDataPopup.cancelClicked()
                            vehicleDataPopup.close()
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#7f8c8d" : "#95a5a6"
                            radius: 6
                            border.color: "#7f8c8d"
                            border.width: 1
                        }
                        
                        contentItem: FluText {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
    
    // 公开方法
    function updateCurveData() {
        // 清空现有数据
        speedCurve.clearDataPoints()
        distanceErrorCurve.clearDataPoints()
        attackIntensityCurve.clearDataPoints()
        distanceCurve.clearDataPoints()
        
        // 模拟数据更新（实际使用时应该从vehicleData中获取真实数据）
        for (var i = 0; i < 6; i++) {
            if (selectedVehicles[i]) {
                // 为每辆选中的车辆添加模拟数据
                for (var t = 0; t < 20; t++) {
                    var time = t * 0.5
                    
                    // 队列速度数据（模拟）
                    var speed = 60 + Math.sin(time * 0.1 + i) * 10 + Math.random() * 5
                    speedCurve.addDataPoint(time, speed)
                    
                    // 队列间距误差数据（模拟）
                    var distanceError = Math.sin(time * 0.15 + i * 0.5) * 2 + Math.random() * 1
                    distanceErrorCurve.addDataPoint(time, distanceError)
                    
                    // 攻击强度数据（模拟）
                    var attackIntensity = Math.max(0, Math.sin(time * 0.2 + i * 0.3) * 50 + Math.random() * 20)
                    attackIntensityCurve.addDataPoint(time, attackIntensity)
                    
                    // 队列间距数据（模拟）
                    var distance = 20 + Math.sin(time * 0.08 + i * 0.2) * 5 + Math.random() * 2
                    distanceCurve.addDataPoint(time, distance)
                }
            }
        }
    }
    
    function setVehicleData(data) {
        vehicleData = data
        updateCurveData()
    }
    
    function showPopup() {
        updateCurveData()
        open()
    }
    
    // 组件完成时初始化数据
    Component.onCompleted: {
        updateCurveData()
    }
}