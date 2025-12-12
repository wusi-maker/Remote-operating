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
    
    // 车辆数据模型实例映射 - 为每个车辆ID创建对应的数据模型
    property var vehicleDataModels: ({})
    
    // 定义车辆数据接收信号
    signal vehicleDataReceived(string hunterID)
    
    // 监听全局网络连接的数据更新
    Connections {
        target: SharedNetworkConnection
        
        // 监听车辆特定数据更新
        function onVehicleDataReceived(hunterID, vehicleData) {
            // console.log("Leftpage: 接收到车辆数据更新 -", hunterID)
            // 将数据转换为JSON字符串并更新对应的车辆模型
            var rawData = JSON.stringify(vehicleData)
            // console.log("Leftpage: 接收到车辆数据更新 -", hunterID, "原始数据:", rawData)
            updateVehicleData(hunterID, rawData) 
        }
        
        // 监听通用数据更新
        function onDataUpdated(jsonData, rawData) {
            // console.log("Leftpage: 接收到全局数据更新")
            
            // 处理多车辆状态数据 (MultiHunterStatus)
            if (jsonData && jsonData.DataType === "sensorData" && jsonData.vehicles) {
                var vehicles = jsonData.vehicles;
                for (var i = 0; i < vehicles.length; i++) {
                    var vehicleData = vehicles[i];
                    if (vehicleData.hunterID) {
                        // 批量更新时抑制属性变化通知
                        updateVehicleData(vehicleData.hunterID, vehicleData, true);
                    }
                }
                
                // 批量更新完成后，一次性触发属性变化通知
                var tempModels = vehicleDataModels
                vehicleDataModels = {}
                vehicleDataModels = tempModels
                return;
            }
            
            // 如果数据包含hunterID，更新对应车辆
            if (jsonData && jsonData.hunterID) {
                updateVehicleData(jsonData.hunterID, rawData)
            }
        }
    }

    // 定时检查车辆在线状态
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var model = vehicleListView.model
            for (var i = 0; i < model.count; i++) {
                var vehicleId = model.get(i).vehicleId
                var vehicleModel = vehicleDataModels[vehicleId]
                
                if (vehicleModel) {
                    // 使用模型自带的有效性检查（判断时间戳是否超时）
                    if (!vehicleModel.isDataValid()) {
                        if (model.get(i).isOnline) {
                            model.setProperty(i, "isOnline", false)
                            // console.log("监测到车辆掉线:", vehicleId)
                        }
                    }
                }
            }
        }
    }
    
    // 车辆数据更新函数
    function updateVehicleData(hunterID, jsonData, suppressNotify) {
        console.log("车辆数据预处理完成:", hunterID)
        
        if (vehicleDataModels[hunterID]) {
            var vehicleModel = vehicleDataModels[hunterID]
            if (vehicleModel.updateFromJSON(jsonData)) {
                // 数据更新成功后，强制触发vehicleDataModels属性变化通知
                if (suppressNotify !== true) {
                    var tempModels = vehicleDataModels
                    vehicleDataModels = {}  // 先清空
                    vehicleDataModels = tempModels  // 重新赋值，触发属性变化信号
                }
                
                // 更新车辆列表显示
                updateVehicleListModel(hunterID)
                
                // 发送车辆数据更新信号
                vehicleDataReceived(hunterID)
                
            } else {
                console.error("车辆", hunterID, "数据更新失败")
            }
        } else {
            console.warn("未找到车辆", hunterID, "的数据模型")
        }
    }
    
    // 更新ListModel中车辆状态的函数
    function updateVehicleListModel(hunterID) {
        var model = vehicleListView.model
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).vehicleId === hunterID) {
                var vehicleModel = vehicleDataModels[hunterID]
                if (vehicleModel) {
                    // 更新车辆状态
                    model.setProperty(i, "isOnline", vehicleModel.isDataValid())
                    model.setProperty(i, "coordinate", 
                        vehicleModel.gps.latitude.toFixed(2) + ", " + vehicleModel.gps.longitude.toFixed(2))
                    model.setProperty(i, "speed", parseFloat(vehicleModel.vehicle.linear_velocity))
                    model.setProperty(i, "battery", parseFloat(((Number(vehicleModel.vehicle.battery_level) - 24.5) / (28.5 - 24.5)) * 100))
                    
                    // console.log("更新车辆", hunterID, "在列表中的显示状态")
                } else {
                    // 数据无效时设置为离线
                    model.setProperty(i, "isOnline", false)
                }
                break
            }
        }
    }
    
    // 获取指定车辆的数据模型
    function getVehicleDataModel(vehicleId) {
        return vehicleDataModels[vehicleId] || null
    }
    
    // 获取所有车辆数据模型
    function getAllVehicleDataModels() {
        return vehicleDataModels
    }
    
    // 车辆数据模型实例 - Car1
    VehicleDataModel {
        id: car1DataModel
        Component.onCompleted: {
            vehicleDataModels["Car1"] = car1DataModel
            console.log("Car1数据模型已创建")
        }
    }
    
    // 车辆数据模型实例 - Car2
    VehicleDataModel {
        id: car2DataModel
        Component.onCompleted: {
            vehicleDataModels["Car2"] = car2DataModel
            console.log("Car2数据模型已创建")
        }
    }
    
    // 车辆数据模型实例 - Car3
    VehicleDataModel {
        id: car3DataModel
        Component.onCompleted: {
            vehicleDataModels["Car3"] = car3DataModel
            console.log("Car3数据模型已创建")
        }
    }
    
    // 车辆数据模型实例 - Car4
    VehicleDataModel {
        id: car4DataModel
        Component.onCompleted: {
            vehicleDataModels["Car4"] = car4DataModel
            console.log("Car4数据模型已创建")
        }
    }
    
    // 车辆数据模型实例 - Car5
    VehicleDataModel {
        id: car5DataModel
        Component.onCompleted: {
            vehicleDataModels["Car5"] = car5DataModel
            console.log("Car5数据模型已创建")
        }
    }

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
                    
                    MouseArea {
                        anchors.fill: parent
                        onDoubleClicked: function(mouse) {
                            if (leftrect.rootWindow) {
                                leftrect.rootWindow.currentVehicleId = "TEST_VEHICLE"
                                leftrect.rootWindow.showHomePage=false
                                leftrect.rootWindow.showMapPage = true
                                console.log("双击切换到测试车辆模式: TEST_VEHICLE")
                            }
                        }
                    }

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
                    vehicleId: "Car1"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.101"
                }
                ListElement {
                    vehicleId: "Car2"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.102"
                }
                ListElement {
                    vehicleId: "Car3"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.103"
                }
                ListElement {
                    vehicleId: "Car4"
                    isOnline: false
                    coordinate: "0.0, 0.0"
                    battery: 0
                    speed: 0.0
                    ipAddress: "192.168.1.104"
                }
                ListElement {
                    vehicleId: "Car5"
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
                
                // 直接绑定到 ListModel 角色，无需额外派生数据
                
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
                            case "Car1":
                                console.log("触发Car1特殊效果: 显示详细信息"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)

                                // V001按下时显示摄像头，不显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = false
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false


                                }
                                break
                            case "Car2":
                                console.log("触发Car2特殊效果: 尝试重新连接"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
                                // V002按下时显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = true
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false
                                }
                                break
                            case "Car3":
                                console.log("触发Car3特殊效果: 显示路径轨迹"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
                                // V003按下时显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = true
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false
                                }
                                break
                            case "Car4":
                                console.log("触发Car4特殊效果: 远程控制"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
                                // V004按下时显示曲线图
                                if (leftrect.rootWindow) {
                                    leftrect.rootWindow.showCurvesPage = true
                                    leftrect.rootWindow.isSimpleMode = false
                                    leftrect.rootWindow.showHomePage = false
                                }
                                break
                            case "Car5":
                                console.log("触发Car5特殊效果: 电量警告"+leftrect.rootWindow.showCurvesPage+","+leftrect.rootWindow.showMapPage)
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
                                text: "电量: " + Number(model.battery).toFixed(2) + "%"
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
                                text: "速度: " + Number(model.speed).toFixed(2) + " km/h"
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