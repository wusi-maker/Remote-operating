import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../title"
import "../style"

Rectangle{
    id: leftrect
    color: "#1a1d29"
    // 根窗口引用
    property var rootWindow: null

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10
        
        // 页面标题
        Text {
            text: "遥操作系统"
            color: "#ffffff"
            font.pixelSize: 24
            font.bold: true
            anchors.left: parent.left
        }
        
        // 图片显示区域
        Rectangle {
            width: parent.width
            height: width
            color: "#1a2332"
            border.color: "#00ffff"
            border.width: 1
            radius: 8
            
            // Canvas覆盖层，用于遮盖边界只保留四角
            Canvas {
                anchors.fill: parent
                property int cornerLength: 40
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    
                    // 设置覆盖颜色为背景色
                    ctx.fillStyle = "#1a1d29"  // 与主背景色一致
                    
                    // 覆盖上边（除了两个角）
                    ctx.fillRect(cornerLength, 0, width - 2 * cornerLength, parent.border.width)
                    
                    // 覆盖下边（除了两个角）
                    ctx.fillRect(cornerLength, height - parent.border.width, width - 2 * cornerLength, parent.border.width)
                    
                    // 覆盖左边（除了两个角）
                    ctx.fillRect(0, cornerLength, parent.border.width, height - 2 * cornerLength)
                    
                    // 覆盖右边（除了两个角）
                    ctx.fillRect(width - parent.border.width, cornerLength, parent.border.width, height - 2 * cornerLength)
                }
            }
            
            Image {
                anchors.centerIn: parent
                source: "qrc:/Resource/rightelement/blachuser.svg"
                sourceSize: Qt.size(80, 60)
                fillMode: Image.PreserveAspectFit
            }
        }
        
        // 搜索栏
        Search {
            id: searchComponent
            width: leftrect.width - 20
            height:40
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
        }
        
        // 分割线
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.boardColor
        }
        
        // 车辆设备管理按键
        Rectangle {
            width: parent.width
            height: 50
            color: "transparent"
            
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                
                // 车辆图标占位
                Image {
                    id: vehicleIcon
                    width: 24
                    height: 24
                    source: "qrc:/Resource/Leftelement/car.svg" // 预留图标位置
                    sourceSize: Qt.size(20,20)
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "#4a90e2"
                        radius: 4
                        opacity: 0.3
                        visible: parent.source == "qrc:/Resource/Leftelement/car.svg"
                    }
                }
                
                Text {
                    text: "车辆管理"
                    color: "#ffffff"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            
            // 设备操作按钮
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                
                Rectangle {
                    id: addDeviceBtn
                    width: 80
                    height: 30
                    color: addDeviceMouse.pressed ? "#3a7bc8" : (addDeviceMouse.containsMouse ? "#5ba0f2" : "#4a90e2")
                    radius: 4
                    border.width: 1
                    border.color: "#2b2b31"
                    
                    Text {
                        text: "添加设备"
                        color: "#ffffff"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        id: addDeviceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("添加设备")
                            // TODO: 实现添加设备功能
                        }
                    }
                }
                
                Rectangle {
                    id: deleteDeviceBtn
                    width: 80
                    height: 30
                    color: deleteDeviceMouse.pressed ? "#c83a3a" : (deleteDeviceMouse.containsMouse ? "#f25b5b" : "#e74c3c")
                    radius: 4
                    border.width: 1
                    border.color: "#2b2b31"
                    
                    Text {
                        text: "删除设备"
                        color: "#ffffff"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                    
                    MouseArea {
                        id: deleteDeviceMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            console.log("删除设备")
                            // TODO: 实现删除设备功能
                        }
                    }
                }
            }
        }
        
        // 车辆列表
        ListView {
            id: vehicleListView
            width: parent.width
            height: parent.height - y - 20  // 自适应剩余高度
            clip: true
            spacing: 8
            // 滚动条设计
            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
                
                background: Rectangle {
                    color: "#2b2b31"
                    radius: 4
                }
                
                contentItem: Rectangle {
                    color: "#4a90e2"
                    radius: 4
                }
            }
            // 示例元素数据
            model: ListModel {
                ListElement {
                    vehicleId: "V001"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.101"
                }
                ListElement {
                    vehicleId: "V002"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.102"
                }
                ListElement {
                    vehicleId: "V003"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.103"
                }
                ListElement {
                    vehicleId: "V004"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.104"
                }
                ListElement {
                    vehicleId: "V005"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.105"
                }
            }
            
            delegate: Rectangle {
                width: vehicleListView.width
                height: 120
                color: "#1a1a1a"
                radius: 8
                border.width: 0
                border.color: model.isOnline ? "#27ae60" : "#2b2b31"
                // 点击图标后切换页面逻辑
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#2a2a2a"
                    onExited: parent.color = "#1a1a1a"
                    onClicked: {
                        console.log("点击了车辆: " + model.vehicleId)
                        
                        // 更新全局车辆ID属性
                        if (leftrect.rootWindow) {
                            leftrect.rootWindow.currentVehicleId = model.vehicleId
                            console.log("更新全局车辆ID:", leftrect.rootWindow.currentVehicleId)
                        }
                        
                        
                        // 根据车辆ID实现不同的触发效果
                        // 所有按键按下时都显示地图页面
                        if (leftrect.rootWindow) {
                            leftrect.rootWindow.showMapPage = true
                        }
                        
                        switch(model.vehicleId) {
                            case "V001":
                                console.log("触发V001特殊效果: 显示详细信息"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)

                                // V001按下时显示摄像头，不显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = false
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false


                                }
                                break
                            case "V002":
                                console.log("触发V002特殊效果: 尝试重新连接"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
                                // V002按下时显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = true
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false
                                }
                                break
                            case "V003":
                                console.log("触发V003特殊效果: 显示路径轨迹"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
                                // V003按下时显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = true
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false
                                }
                                break
                            case "V004":
                                console.log("触发V004特殊效果: 远程控制"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
                                // V004按下时显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = true
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false
                                }
                                break
                            case "V005":
                                console.log("触发V005特殊效果: 电量警告"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
                                // V005按下时显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = true
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false
                                }
                                break
                            default:
                                console.log("hello world")
                                break
                        }
                    }
                }
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20
                    
                    // 左侧：状态指示灯和车辆图标
                    Item {
                        width: 70
                        height: parent.height
                        
                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 15
                            
                            // 在线状态指示灯 - 左侧
                            Rectangle {
                                id: carstate
                                width: 12
                                height: 12
                                radius: 6
                                color: model.isOnline ? "#27ae60" : "#7f8c8d"
                                anchors.verticalCenter: parent.verticalCenter
                                // 在线时的闪烁效果
                                SequentialAnimation on opacity {
                                    running: model.isOnline
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 1000 }
                                    NumberAnimation { to: 1.0; duration: 1000 }
                                }
                            }
                            
                            // 车辆图标占位 - 右侧
                            Rectangle {
                                id: vehicleIcon
                                width: 40
                                height: 40
                                color: "#4a90e2"
                                radius: 8
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: 0.3
                                
                                Image {
                                    anchors.fill: parent
                                    source: "" // 预留车辆图标位置
                                    anchors.margins: 8
                                }
                            }
                        }
                    }
                    
                    // 中间：车辆信息
                    Column {
                        width: parent.width - 160
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        
                        // 车辆ID和修改按钮
                        Row {
                            width: parent.width
                            spacing: 10
                            
                            Text {
                                text: "车辆ID: " + model.vehicleId
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Rectangle {
                                width: 60
                                height: 25
                                color: modifyMouse.pressed ? "#8e44ad" : (modifyMouse.containsMouse ? "#a569bd" : "#9b59b6")
                                radius: 4
                                border.width: 1
                                border.color: "#2b2b31"
                                
                                Text {
                                    text: "修改"
                                    color: "#ffffff"
                                    font.pixelSize: 10
                                    anchors.centerIn: parent
                                }
                                
                                MouseArea {
                                    id: modifyMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        console.log("修改车辆ID: " + model.vehicleId)
                                        // TODO: 实现修改车辆ID功能
                                    }
                                }
                            }
                        }
                        
                        // 车辆坐标
                        Row {
                            spacing: 5
                            
                            Image {
                                width: 16
                                height: 16
                                source: "" // 预留坐标图标位置
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#e67e22"
                                    radius: 2
                                    opacity: 0.3
                                    visible: parent.source == ""
                                }
                            }
                            
                            Text {
                                text: "坐标: " + model.coordinate
                                color: "#a0a0a0"
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // 车辆电量
                        Row {
                            spacing: 5
                            
                            Image {
                                width: 16
                                height: 16
                                source: "" // 预留电量图标位置
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: model.battery > 50 ? "#27ae60" : (model.battery > 20 ? "#f39c12" : "#e74c3c")
                                    radius: 2
                                    opacity: 0.3
                                    visible: parent.source == ""
                                }
                            }
                            
                            Text {
                                text: "电量: " + model.battery + "%"
                                color: model.battery > 50 ? "#27ae60" : (model.battery > 20 ? "#f39c12" : "#e74c3c")
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // 车辆速度
                        Row {
                            spacing: 5
                            
                            Image {
                                width: 16
                                height: 16
                                source: "" // 预留速度图标位置
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: "#3498db"
                                    radius: 2
                                    opacity: 0.3
                                    visible: parent.source == ""
                                }
                            }
                            
                            Text {
                                text: "速度: " + model.speed + " km/h"
                                color: "#a0a0a0"
                                font.pixelSize: 12
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    
                    // 右侧：IP地址和状态
                    Column {
                        width: 60
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        // 在线状态滑块
                        Rectangle {
                            width: 50
                            height: 25
                            color: "transparent"
                            
                            Rectangle {
                                id: sliderTrack
                                width: 40
                                height: 20
                                radius: 10
                                color: model.isOnline ? "#27ae60" : "#7f8c8d"
                                anchors.centerIn: parent
                                
                                Rectangle {
                                    id: sliderHandle
                                    width: 16
                                    height: 16
                                    radius: 8
                                    color: "#ffffff"
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: model.isOnline ? parent.width - width - 2 : 2
                                    
                                    Behavior on x {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutCubic
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
