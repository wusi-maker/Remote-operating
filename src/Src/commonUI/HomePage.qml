import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0
import "../Network"
import "../style"
import "../rightPage"

Rectangle {
    id: homePage
    color: "transparent"

    // 监听全局网络连接的数据更新
    Connections {
        target: SharedNetworkConnection
        
        // 监听数据更新信号
        function onDataUpdated(jsonData, rawData) {
            console.log("HomePage: 接收到全局数据更新")
            
            // 使用车辆数据处理器处理数据
            if (jsonData && jsonData.hunterID) {
                vehicleDataProcessor.preprocessRawData(rawData)
            }
        }
        
        // 监听车辆特定数据
        function onVehicleDataReceived(hunterID, vehicleData) {
            console.log("HomePage: 接收到车辆数据 -", hunterID)
            
            // 处理车辆数据
            var rawData = JSON.stringify(vehicleData)
            vehicleDataProcessor.preprocessRawData(rawData)
        }
    }

    // 车辆数据模型实例 - 用于处理原始车辆状态数据
    VehicleDataModel {
        id: vehicleDataProcessor
        
        // 数据预处理函数 - 简化版本
        function preprocessRawData(rawJsonData) {
            try {
                // 更新模型数据
                var success = updateFromJSON(rawJsonData)
                
                if (success) {
                    console.log("车辆数据预处理完成:", hunterID)
                    return true
                } else {
                    console.error("车辆数据更新失败")
                    return false
                }
            } catch (error) {
                console.error("数据预处理错误:", error)
                return false
            }
        }
        
        // 重置处理器数据
        function resetProcessor() {
            reset()
            console.log("车辆数据处理器已重置")
        }
    }

    // 示例车辆表格数据
    property var vehicleTableData: [
        {
            vehicleId: "V001",
            vehicleNumber: "CAR-001",
            senderDeviceId: "DEV-S001",
            receiverDeviceId: "DEV-R001",
            targetSpeed: "60",
            currentSpeed: "58.5",
            avgSpeedError: "1.2",
            maxSpeedError: "3.5",
            targetDistance: "50",
            avgDistanceError: "2.1",
            maxDistanceError: "5.8",
            trackingPerformance: "良好",
            attackStatus: "正常",
            attackType: "无",
            attackDuration: "0"
        },
        {
            vehicleId: "V002",
            vehicleNumber: "CAR-002",
            senderDeviceId: "DEV-S002",
            receiverDeviceId: "DEV-R002",
            targetSpeed: "65",
            currentSpeed: "63.2",
            avgSpeedError: "1.8",
            maxSpeedError: "4.2",
            targetDistance: "45",
            avgDistanceError: "1.9",
            maxDistanceError: "4.5",
            trackingPerformance: "优秀",
            attackStatus: "正常",
            attackType: "无",
            attackDuration: "0"
        },
        {
            vehicleId: "V003",
            vehicleNumber: "CAR-003",
            senderDeviceId: "DEV-S003",
            receiverDeviceId: "DEV-R003",
            targetSpeed: "55",
            currentSpeed: "52.8",
            avgSpeedError: "2.5",
            maxSpeedError: "6.1",
            targetDistance: "55",
            avgDistanceError: "3.2",
            maxDistanceError: "7.8",
            trackingPerformance: "一般",
            attackStatus: "受攻击",
            attackType: "欺骗攻击",
            attackDuration: "15s"
        },
        {
            vehicleId: "V004",
            vehicleNumber: "CAR-004",
            senderDeviceId: "DEV-S004",
            receiverDeviceId: "DEV-R004",
            targetSpeed: "70",
            currentSpeed: "68.9",
            avgSpeedError: "1.1",
            maxSpeedError: "2.8",
            targetDistance: "40",
            avgDistanceError: "1.5",
            maxDistanceError: "3.2",
            trackingPerformance: "优秀",
            attackStatus: "正常",
            attackType: "无",
            attackDuration: "0"
        },
        {
            vehicleId: "V005",
            vehicleNumber: "CAR-005",
            senderDeviceId: "DEV-S005",
            receiverDeviceId: "DEV-R005",
            targetSpeed: "62",
            currentSpeed: "59.7",
            avgSpeedError: "2.8",
            maxSpeedError: "5.5",
            targetDistance: "48",
            avgDistanceError: "2.7",
            maxDistanceError: "6.1",
            trackingPerformance: "良好",
            attackStatus: "受攻击",
            attackType: "干扰攻击",
            attackDuration: "8s"
        }
    ]

    // 主布局 - 改为RowLayout
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // 左侧矩形 - 显示车辆拓扑
        Rectangle {
            Layout.preferredWidth: 1000  // 固定宽度
            Layout.preferredHeight: parent.height  // 比parent.height小一点
            Layout.alignment: Qt.AlignVCenter
            color: "transparent"  // 深化背景色
            border.color: "#1a1a1a"
            border.width: 2
            radius: 10

            
                    // 左侧区域 - 分为上下两部分
            Item {
                id: leftColumn
                anchors.fill: parent
                
                
                // 左上车辆网络拓扑图面板
                Item {
                    id: vehicleTopologyArea
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * 0.35
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "#1a1a1a"
                        border.color: "#555555"
                        border.width: 0
                        radius: 8
                    
                        // Canvas覆盖层，用于遮盖边界只保留四角
                        Canvas {
                            anchors.fill: parent
                            property int cornerLength: 40
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                
                                // 设置覆盖颜色为背景色
                                ctx.fillStyle = "#0a0e1a"  // 与主背景色一致
                                
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
                    
                        Column {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            // 拓扑图标题栏
                            Rectangle {
                                width: parent.width
                                height: 30
                                color: "#1E1E1E"
                                
                                // 标题 - 居左
                                FluText {
                                    text: "车辆网络拓扑图"
                                    font.pixelSize: 24
                                    font.bold: true
                                    textColor: FluTheme.dark ? "white" : "#0078D4"
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                // 拓扑模式选择下拉框
                                ComboBox {
                                    id: modeSelector
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 120
                                    height: 30
                                    
                                    model: ["Mode 1", "Mode 2", "Mode 3", "Mode 4", "Mode 5", "Mode 6", "Mode 7", "Mode 8"]
                                    currentIndex: 0
                                    // 设置背景
                                    background: Rectangle {
                                        color: "#21262d"
                                        border.color: "#30363d"
                                        border.width: 1
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: modeSelector.displayText
                                        color: "#f0f6fc"
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 10
                                    }
                                    
                                    popup: Popup {
                                        y: modeSelector.height
                                        width: modeSelector.width
                                        height: contentItem.implicitHeight
                                        padding: 1
                                        
                                        background: Rectangle {
                                            color: "#21262d"
                                            border.color: "#30363d"
                                            border.width: 1
                                            radius: 4
                                        }
                                        
                                        contentItem: ListView {
                                            clip: true
                                            implicitHeight: contentHeight
                                            model: modeSelector.popup.visible ? modeSelector.delegateModel : null
                                            currentIndex: modeSelector.highlightedIndex
                                            
                                            delegate: ItemDelegate {
                                                width: modeSelector.width
                                                height: 30
                                                
                                                background: Rectangle {
                                                    color: parent.hovered ? "#30363d" : "transparent"
                                                    radius: 2
                                                }
                                                
                                                contentItem: Text {
                                                    text: modelData
                                                    color: "#f0f6fc"
                                                    font.pixelSize: 12
                                                    verticalAlignment: Text.AlignVCenter
                                                    leftPadding: 10
                                                }
                                            }
                                        }
                                    }
                                    
                                    onCurrentIndexChanged: {
                                        var modeKey = "mode" + (currentIndex + 1)
                                        techDashboard.topologyMode = modeKey
                                        vehicleTopologyCanvas.switchMode(modeKey)
                                    }
                                }
                            }
                            
                            // 车辆拓扑Canvas区域
                            Rectangle {
                                id:topplogyMap
                                width: parent.width
                                height: parent.height-30
                                color: "transparent"
                                border.color: "#30363d"
                                border.width: 0
                                radius: 5
                                
                                Canvas {
                                    id: vehicleTopologyCanvas
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    
                                    // 动画控制属性
                                    property bool isAnimating: false
                                    property real animProgress: 1.0  // 1.0=完全显示, 0.0=完全透明
                                    
                                    // 模式切换入口函数
                                    function switchMode(newMode) {
                                        if (isAnimating) return;
                                        console.log("model Changed", newMode)
                                        isAnimating = true
                                        fadeOutTimer.start()
                                    }
                                    
                                    // 淡出动画 - 使用定时器实现慢慢淡出
                                    Timer {
                                        id: fadeOutTimer
                                        interval: 10
                                        repeat: true
                                        property real step: 0.05
                                        onTriggered: {
                                            vehicleTopologyCanvas.animProgress -= step
                                            if (vehicleTopologyCanvas.animProgress <= 0.0) {
                                                vehicleTopologyCanvas.animProgress = 0.0
                                                stop()
                                                vehicleTopologyCanvas.updateTopologyData()
                                                fadeInTimer.start()
                                            }
                                        }
                                    }
                                    
                                    // 淡入动画 - 使用定时器实现慢慢淡入
                                    Timer {
                                        id: fadeInTimer
                                        interval: 10
                                        repeat: true
                                        property real step: 0.05
                                        onTriggered: {
                                            vehicleTopologyCanvas.animProgress += step
                                            if (vehicleTopologyCanvas.animProgress >= 1.0) {
                                                vehicleTopologyCanvas.animProgress = 1.0
                                                stop()
                                                vehicleTopologyCanvas.isAnimating = false
                                            }
                                        }
                                    }
                                    
                                    // 淡出动画
                                    NumberAnimation {
                                        id: fadeOutAnim
                                        target: vehicleTopologyCanvas
                                        property: "animProgress"
                                        from: 1.0; to: 0.0
                                        duration: 200
                                        onFinished: {
                                            updateTopologyData()
                                            fadeInAnim.start()
                                        }
                                    }
                                    
                                    // 淡入动画
                                    NumberAnimation {
                                        id: fadeInAnim
                                        target: vehicleTopologyCanvas
                                        property: "animProgress"
                                        from: 0.0; to: 1.0
                                        duration: 200
                                        onFinished: isAnimating = false
                                    }
                                    

                                    
                                    // 8种拓扑模式配置
                                    property var topologyModes: {
                                        "mode1": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 1, to: 0}, {from: 2, to: 1}, {from: 3, to: 2}, {from: 4, to: 3}, {from: 5, to: 4}],
                                            bezierConnections: []
                                        },
                                        "mode2": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 1, to: 0}, {from: 2, to: 1}, {from: 3, to: 2}, {from: 4, to: 3}, {from: 5, to: 4}],
                                            bezierConnections: [{from: 5, to: 2}]
                                        },
                                        "mode3": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 1, to: 0}, {from: 2, to: 1}, {from: 3, to: 2}, {from: 4, to: 3}, {from: 5, to: 4}],
                                            bezierConnections: [{from: 4, to: 2}]
                                        },
                                        "mode4": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 1, to: 0}, {from: 2, to: 1}, {from: 3, to: 2}, {from: 4, to: 3}, {from: 5, to: 4}],
                                            bezierConnections: [{from: 4, to: 2},{from:5,to:2}]
                                        },
                                        "mode5": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 1, to: 0}, {from: 2, to: 1}, {from: 3, to: 2}, {from: 4, to: 3}, {from: 5, to: 4}],
                                            bezierConnections: [{from: 1, to: 2}]
                                        },
                                        "mode6": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 1, to: 0}, {from: 2, to: 1}, {from: 3, to: 2}, {from: 4, to: 3}, {from: 5, to: 4}],
                                            bezierConnections: [{from: 1, to: 2}, {from: 5, to: 2}]
                                        },
                                        "mode7": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                            bezierConnections: [{from: 2, to: 1}, {from: 2, to: 4}]
                                        },
                                        "mode8": {
                                            positions: [
                                                {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height*0.6, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height*0.6, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height*0.6, id: "i"},
                                                {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height*0.6, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height*0.6, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height*0.6, id: "0"}
                                            ],
                                            connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                            bezierConnections: [{from: 2, to: 1}, {from: 2, to: 4}, {from: 2, to: 5}]
                                        }
                                    }

                                    function updateTopologyData() {
                                        // 更新数据但不立即重绘
                                        var currentMode = topologyModes[techDashboard.topologyMode]
                                        if (currentMode) {
                                            vehiclePositions = currentMode.positions || []
                                            connections = currentMode.connections || []
                                            bezierConnections = currentMode.bezierConnections || []
                                        } else {
                                            console.warn("Unknown topology mode:", techDashboard.topologyMode)
                                            vehiclePositions = []
                                            connections = []
                                            bezierConnections = []
                                        }
                                        requestPaint() // 手动触发重绘
                                    }
                                    
                                    // 使用属性绑定而不是事件处理器
                                    property var vehiclePositions: (topologyModes[techDashboard.topologyMode] && topologyModes[techDashboard.topologyMode].positions) ? topologyModes[techDashboard.topologyMode].positions : []
                                    property var connections: (topologyModes[techDashboard.topologyMode] && topologyModes[techDashboard.topologyMode].connections) ? topologyModes[techDashboard.topologyMode].connections : []
                                    property var bezierConnections: (topologyModes[techDashboard.topologyMode] && topologyModes[techDashboard.topologyMode].bezierConnections) ? topologyModes[techDashboard.topologyMode].bezierConnections : []
                                    
                                    property bool imageLoaded: false
                                    
                                    Component.onCompleted: {
                                        imageLoaded = true
                                        requestPaint()
                                    }
                                    
                                    // 监听属性变化，确保重绘
                                    onVehiclePositionsChanged: requestPaint()
                                    onConnectionsChanged: {
                                        // 模式切换时启动动画
                                        if (!isAnimating) {
                                            switchMode(techDashboard.topologyMode)
                                        }
                                    }
                                    onBezierConnectionsChanged: {
                                        // 贝塞尔连接变化时也启动动画
                                        if (!isAnimating) {
                                            switchMode(techDashboard.topologyMode)
                                        }
                                    }
                                    
                                    // 监听animProgress变化，触发重绘
                                    onAnimProgressChanged: requestPaint()
                                    
                                    // 将图标绘制到指定中心点，保持尺寸
                                    function drawImageCentered(ctx, image, centerX, centerY, width, height) {
                                        var drawX = centerX - width / 2
                                        var drawY = centerY - height / 2
                                        ctx.drawImage(image, drawX, drawY, width, height)
                                    }
                                    
                                    // 使用字体图标绘制车辆图标
                                    function drawVehicleIcon(ctx, vehicleType, centerX, centerY, size, isHovered) {
                                        // 等待字体加载完成后再设置字体
                                        if (iconFontLoader.status === FontLoader.Ready) {
                                            ctx.font = size + "px '" + iconFontLoader.name + "'"
                                        } else {
                                            // 字体未加载完成时使用备用方案
                                            ctx.font = size + "px Arial"
                                        }
                                        ctx.textAlign = "center"
                                        ctx.textBaseline = "middle"
                                        
                                        // 根据车辆类型选择图标和颜色
                                        var iconCode, fillColor
                                        switch(vehicleType) {
                                            case 'i':
                                                iconCode = 0xEC81  // 蓝色侧视车辆图标编码 (PoliceCar)
                                                fillColor = isHovered ? "#4da6ff" : "#0080ff"
                                                break
                                            case '0':
                                                iconCode = 0xEC81  // 黑色侧视车辆图标编码 (PoliceCar)
                                                fillColor = isHovered ? "#333333" : "#000000"
                                                break
                                            default:
                                                iconCode = 0xEC81  // 默认侧视车辆图标编码 (PoliceCar)
                                                fillColor = isHovered ? "#ffffff" : "#cccccc"
                                                break
                                        }
                                        
                                        // 绘制图标
                                        ctx.fillStyle = fillColor
                                        if (iconFontLoader.status === FontLoader.Ready) {
                                            // 使用字体图标
                                            ctx.fillText(String.fromCharCode(iconCode), centerX, centerY)
                                        } else {
                                            // 备用方案：绘制简单的圆形
                                            ctx.beginPath()
                                            ctx.arc(centerX, centerY, size/2, 0, 2 * Math.PI)
                                            ctx.fill()
                                        }
                                    }
                                    
                                    // FontLoader加载字体文件
                                    FontLoader {
                                        id: iconFontLoader
                                        source: "qrc:/qt/qml/FluentUI/Font/FluentIcons.ttf"
                                    }
                                    
                                    // 绘制箭头，避开车辆图标
                                    function drawArrow(ctx, start, end, arrowSize) {
                                        arrowSize = arrowSize || 10
                                        var angle = Math.atan2(end.y - start.y, end.x - start.x)
                                        
                                        // 调整箭头终点位置，避开车辆图标的不透明圆形（半径25px）
                                        var backgroundRadius = 35
                                        var adjustedEndX = end.x - backgroundRadius * Math.cos(angle)
                                        var adjustedEndY = end.y - backgroundRadius * Math.sin(angle)
                                        
                                        ctx.beginPath()
                                        ctx.moveTo(adjustedEndX, adjustedEndY)
                                        ctx.lineTo(
                                            adjustedEndX - arrowSize * Math.cos(angle - Math.PI/6),
                                            adjustedEndY - arrowSize * Math.sin(angle - Math.PI/6)
                                        )
                                        ctx.moveTo(adjustedEndX, adjustedEndY)
                                        ctx.lineTo(
                                            adjustedEndX - arrowSize * Math.cos(angle + Math.PI/6),
                                            adjustedEndY - arrowSize * Math.sin(angle + Math.PI/6)
                                        )
                                        ctx.stroke()
                                    }
                                    
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        
                                        // 绘制直线连接
                                        ctx.strokeStyle = "rgba(0, 255, 255, " + animProgress + ")"
                                        
                                        for (var i = 0; i < connections.length; i++) {
                                            var conn = connections[i]
                                            // 根据序号确定需要连接的是哪几个坐标
                                            var fromPos = vehiclePositions[conn.from]
                                            var toPos = vehiclePositions[conn.to]
                                            
                                            // 检查是否为悬停的线段，调整线宽
                                            var isHoveredLine = (mouseArea.hoveredLineIndex === i)
                                            ctx.lineWidth = isHoveredLine ? 10 : 6  // 悬停时线宽为4，正常时为2
                                            
                                            ctx.beginPath()
                                            ctx.moveTo(fromPos.x + 15, fromPos.y + 15) // 车辆图标中心
                                            ctx.lineTo(toPos.x + 15, toPos.y + 15)
                                            ctx.stroke()
                                            
                                            // 绘制箭头
                                            drawArrow(ctx, 
                                                {x: fromPos.x + 15, y: fromPos.y + 15}, 
                                                {x: toPos.x + 15, y: toPos.y + 15}, 
                                                8
                                            )
                                        }
                                        
                                        // 绘制贝塞尔曲线连接
                                        ctx.strokeStyle = "rgba(255, 102, 0, " + animProgress + ")"
                                        
                                        for (var j = 0; j < bezierConnections.length; j++) {
                                            var bezConn = bezierConnections[j]
                                            var fromPos = vehiclePositions[bezConn.from]
                                            var toPos = vehiclePositions[bezConn.to]
                                            
                                            // 根据悬停状态设置线宽
                                            var isHoveredBezier = (mouseArea.hoveredBezierIndex === j)
                                            ctx.lineWidth = isHoveredBezier ? 10 : 6  // 悬停时线宽为5，正常时为3
                                            
                                            // 计算控制点（在两点中间上方形成弧形）
                                            // 其X坐标为起始点和终点的中点，同时Y坐标为起始点的Y坐标减去一个固定值
                                            var midX = (fromPos.x + toPos.x) / 2
                                            var controlY = fromPos.y - midX*0.5  // 控制点在上方80像素
                                            
                                            ctx.beginPath()
                                            ctx.moveTo(fromPos.x + 15, fromPos.y + 15)
                                            ctx.quadraticCurveTo(midX, controlY, toPos.x + 15, toPos.y + 15)
                                            ctx.stroke()
                                            
                                            // 计算贝塞尔曲线末端的切线角度并绘制箭头
                                            var t = 0.95  // 接近终点的参数
                                            var dx = 2 * (1 - t) * (midX - (fromPos.x + 15)) + 2 * t * ((toPos.x + 15) - midX)
                                            var dy = 2 * (1 - t) * (controlY - (fromPos.y + 15)) + 2 * t * ((toPos.y + 15) - controlY)
                                            var angle = Math.atan2(dy, dx)
                                            
                                            // 调整箭头终点位置，避开车辆图标的不透明圆形（半径25px）
                                            var backgroundRadius = 35
                                            var adjustedEndX = (toPos.x + 15) - backgroundRadius * Math.cos(angle)
                                            var adjustedEndY = (toPos.y + 15) - backgroundRadius * Math.sin(angle)
                                            
                                            ctx.beginPath()
                                            ctx.moveTo(adjustedEndX, adjustedEndY)
                                            ctx.lineTo(
                                                adjustedEndX - 8 * Math.cos(angle - Math.PI/6),
                                                adjustedEndY - 8 * Math.sin(angle - Math.PI/6)
                                            )
                                            ctx.moveTo(adjustedEndX, adjustedEndY)
                                            ctx.lineTo(
                                                adjustedEndX - 8 * Math.cos(angle + Math.PI/6),
                                                adjustedEndY - 8 * Math.sin(angle + Math.PI/6)
                                            )
                                            ctx.stroke()
                                        }
                                        
                                        // 绘制车辆图标和编号
                                        for (var j = 0; j < vehiclePositions.length; j++) {
                                            var pos = vehiclePositions[j]
                                            
                                            // 检查是否为悬停的车辆
                                            var isHovered = (mouseArea.hoveredVehicleIndex === j)
                                            var vehicleSize = isHovered ? 80 : 70  // 字体图标大小
                                            var backgroundRadius = isHovered ? 50 : 30  // 背景圆也相应放大
                                            
                                            // 绘制不透明背景圆形，遮挡连线
                                            ctx.fillStyle = "#1a1a1a"  // 与Canvas背景色一致
                                            ctx.beginPath()
                                            ctx.arc(pos.x + 15, pos.y + 15, backgroundRadius, 0, 2 * Math.PI)
                                            ctx.fill()
                                            
                                            // 使用字体图标绘制车辆
                                            drawVehicleIcon(ctx, pos.id, pos.x + 15, pos.y + 15, vehicleSize, isHovered)
                                            
                                            // 绘制车辆编号
                                            ctx.fillStyle = isHovered ? "#ffff00" : "white"  // 悬停时使用黄色
                                            ctx.font = isHovered ? "bold 30px Arial" : "bold 25px Arial"  // 悬停时字体更大
                                            ctx.textAlign = "center"
                                            ctx.fillText(pos.id.toString(), pos.x + 15, pos.y + vehicleSize)
                                        }
                                    }
                                    
                                    // 鼠标点击事件
                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        property int hoveredVehicleIndex: -1
                                        property int hoveredLineIndex: -1
                                        property int hoveredBezierIndex: -1
                                        
                                        onClicked: {
                                            var clickDetected = false
                                            
                                            // 检测点击的车辆
                                            for (var i = 0; i < parent.vehiclePositions.length; i++) {
                                                var pos = parent.vehiclePositions[i]
                                                var dx = mouseX - (pos.x + 15)
                                                var dy = mouseY - (pos.y + 15)
                                                var distance = Math.sqrt(dx * dx + dy * dy)
                                                
                                                if (distance <= 20) {
                                                    console.log("点击了车辆", pos.id)
                                                    clickDetected = true
                                                    break
                                                }
                                            }
                                            
                                            // 如果没有点击到车辆，检测直线连接
                                            if (!clickDetected) {
                                                for (var i = 0; i < parent.connections.length; i++) {
                                                    var conn = parent.connections[i]
                                                    var fromPos = parent.vehiclePositions[conn.from]
                                                    var toPos = parent.vehiclePositions[conn.to]
                                                    
                                                    // 计算点到直线的距离
                                                    var lineStartX = fromPos.x + 15
                                                    var lineStartY = fromPos.y + 15
                                                    var lineEndX = toPos.x + 15
                                                    var lineEndY = toPos.y + 15
                                                    
                                                    var A = lineEndY - lineStartY
                                                    var B = lineStartX - lineEndX
                                                    var C = lineEndX * lineStartY - lineStartX * lineEndY
                                                    
                                                    var distance = Math.abs(A * mouseX + B * mouseY + C) / Math.sqrt(A * A + B * B)
                                                    
                                                    // 检查点击位置是否在线段范围内
                                                    var dotProduct = (mouseX - lineStartX) * (lineEndX - lineStartX) + (mouseY - lineStartY) * (lineEndY - lineStartY)
                                                    var lineLength = (lineEndX - lineStartX) * (lineEndX - lineStartX) + (lineEndY - lineStartY) * (lineEndY - lineStartY)
                                                    var projection = dotProduct / lineLength
                                                    
                                                    if (distance <= 5 && projection >= 0 && projection <= 1) {
                                                        console.log("点击了直线连接：", conn.from, "->", conn.to)
                                                        clickDetected = true
                                                        break
                                                    }
                                                }
                                            }
                                            
                                            // 如果没有点击到直线，检测贝塞尔曲线
                                            if (!clickDetected) {
                                                for (var i = 0; i < parent.bezierConnections.length; i++) {
                                                    var bezConn = parent.bezierConnections[i]
                                                    var fromPos = parent.vehiclePositions[bezConn.from]
                                                    var toPos = parent.vehiclePositions[bezConn.to]
                                                    
                                                    var A_x = fromPos.x + 15
                                                    var A_y = fromPos.y + 15
                                                    var B_x = toPos.x + 15
                                                    var B_y = toPos.y + 15
                                                    var midX = (A_x + B_x) / 2
                                                    var C_x = midX
                                                    var C_y = A_y - midX * 0.5
                                                    
                                                    // 采样：将贝塞尔曲线拆分为10段直线
                                                    var points = []
                                                    for (var t = 0; t <= 1; t += 0.1) {
                                                        var x = (1 - t) * (1 - t) * A_x + 2 * (1 - t) * t * C_x + t * t * B_x
                                                        var y = (1 - t) * (1 - t) * A_y + 2 * (1 - t) * t * C_y + t * t * B_y
                                                        points.push({x: x, y: y})
                                                    }
                                                    
                                                    // 逐段检测直线
                                                    for (var j = 0; j < points.length - 1; j++) {
                                                        var P1 = points[j]
                                                        var P2 = points[j + 1]
                                                        var dx = mouseX - P1.x
                                                        var dy = mouseY - P1.y
                                                        var len = Math.sqrt((P2.x - P1.x) * (P2.x - P1.x) + (P2.y - P1.y) * (P2.y - P1.y))
                                                        
                                                        if (len > 0) {
                                                            var dot = (dx * (P2.x - P1.x) + dy * (P2.y - P1.y)) / len
                                                            var projX = P1.x + dot * (P2.x - P1.x) / len
                                                            var projY = P1.y + dot * (P2.y - P1.y) / len
                                                            var dist = Math.sqrt((mouseX - projX) * (mouseX - projX) + (mouseY - projY) * (mouseY - projY))
                                                            
                                                            if (dist <= 5 && dot >= 0 && dot <= len) {
                                                                console.log("点击了贝塞尔曲线段：", bezConn.from, "->", bezConn.to)
                                                                clickDetected = true
                                                                break
                                                            }
                                                        }
                                                    }
                                                    
                                                    if (clickDetected) break
                                                }
                                            }
                                        }
                                        
                                        onPositionChanged: {
                                            // 检测鼠标悬停的车辆
                                            var newHoveredVehicleIndex = -1
                                            for (var i = 0; i < parent.vehiclePositions.length; i++) {
                                                var pos = parent.vehiclePositions[i]
                                                var dx = mouseX - (pos.x + 15)
                                                var dy = mouseY - (pos.y + 15)
                                                var distance = Math.sqrt(dx * dx + dy * dy)
                                                
                                                if (distance <= 30) {
                                                    newHoveredVehicleIndex = i
                                                    break
                                                }
                                            }
                                            
                                            // 如果没有悬停在车辆上，检测线段悬停
                                            var newHoveredLineIndex = -1
                                            if (newHoveredVehicleIndex === -1) {
                                                for (var i = 0; i < parent.connections.length; i++) {
                                                    var conn = parent.connections[i]
                                                    var fromPos = parent.vehiclePositions[conn.from]
                                                    var toPos = parent.vehiclePositions[conn.to]
                                                    
                                                    // 计算点到直线的距离
                                                    var lineStartX = fromPos.x + 15
                                                    var lineStartY = fromPos.y + 15
                                                    var lineEndX = toPos.x + 15
                                                    var lineEndY = toPos.y + 15
                                                    
                                                    var A = lineEndY - lineStartY
                                                    var B = lineStartX - lineEndX
                                                    var C = lineEndX * lineStartY - lineStartX * lineEndY
                                                    
                                                    var distance = Math.abs(A * mouseX + B * mouseY + C) / Math.sqrt(A * A + B * B)
                                                    
                                                    // 检查鼠标位置是否在线段范围内
                                                    var dotProduct = (mouseX - lineStartX) * (lineEndX - lineStartX) + (mouseY - lineStartY) * (lineEndY - lineStartY)
                                                    var lineLength = (lineEndX - lineStartX) * (lineEndX - lineStartX) + (lineEndY - lineStartY) * (lineEndY - lineStartY)
                                                    var projection = dotProduct / lineLength
                                                    
                                                    if (distance <= 8 && projection >= 0 && projection <= 1) {
                                                        newHoveredLineIndex = i
                                                        break
                                                    }
                                                }
                                            }
                                            
                                            // 如果没有悬停在车辆或直线上，检测贝塞尔曲线
                                            var newHoveredBezierIndex = -1
                                            if (newHoveredVehicleIndex === -1 && newHoveredLineIndex === -1) {
                                                for (var i = 0; i < parent.bezierConnections.length; i++) {
                                                    var bezConn = parent.bezierConnections[i]
                                                    var fromPos = parent.vehiclePositions[bezConn.from]
                                                    var toPos = parent.vehiclePositions[bezConn.to]
                                                    
                                                    var A_x = fromPos.x + 15
                                                    var A_y = fromPos.y + 15
                                                    var B_x = toPos.x + 15
                                                    var B_y = toPos.y + 15
                                                    var midX = (A_x + B_x) / 2
                                                    var C_x = midX
                                                    var C_y = A_y - midX * 0.5
                                                    
                                                    // 采样：将贝塞尔曲线拆分为10段直线
                                                    var found = false
                                                    for (var t = 0; t < 1 && !found; t += 0.1) {
                                                        var t1 = t
                                                        var t2 = Math.min(t + 0.1, 1)
                                                        
                                                        // 计算两个采样点
                                                        var x1 = (1-t1)*(1-t1)*A_x + 2*(1-t1)*t1*C_x + t1*t1*B_x
                                                        var y1 = (1-t1)*(1-t1)*A_y + 2*(1-t1)*t1*C_y + t1*t1*B_y
                                                        var x2 = (1-t2)*(1-t2)*A_x + 2*(1-t2)*t2*C_x + t2*t2*B_x
                                                        var y2 = (1-t2)*(1-t2)*A_y + 2*(1-t2)*t2*C_y + t2*t2*B_y
                                                        
                                                        // 计算点到线段的距离
                                                        var segA = y2 - y1
                                                        var segB = x1 - x2
                                                        var segC = x2 * y1 - x1 * y2
                                                        
                                                        var segDistance = Math.abs(segA * mouseX + segB * mouseY + segC) / Math.sqrt(segA * segA + segB * segB)
                                                        
                                                        // 检查鼠标位置是否在线段范围内
                                                        var segDotProduct = (mouseX - x1) * (x2 - x1) + (mouseY - y1) * (y2 - y1)
                                                        var segLineLength = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
                                                        var segProjection = segDotProduct / segLineLength
                                                        
                                                        if (segDistance <= 8 && segProjection >= 0 && segProjection <= 1) {
                                                            newHoveredBezierIndex = i
                                                            found = true
                                                        }
                                                    }
                                                    
                                                    if (found) break
                                                }
                                            }
                                            
                                            // 更新悬停状态
                                            var needsRepaint = false
                                            if (newHoveredVehicleIndex !== hoveredVehicleIndex) {
                                                hoveredVehicleIndex = newHoveredVehicleIndex
                                                needsRepaint = true
                                            }
                                            if (newHoveredLineIndex !== hoveredLineIndex) {
                                                hoveredLineIndex = newHoveredLineIndex
                                                needsRepaint = true
                                            }
                                            if (newHoveredBezierIndex !== hoveredBezierIndex) {
                                                hoveredBezierIndex = newHoveredBezierIndex
                                                needsRepaint = true
                                            }
                                            
                                            if (needsRepaint) {
                                                parent.requestPaint() // 触发重绘
                                            }
                                        }
                                        
                                        onExited: {
                                            var needsRepaint = false
                                            if (hoveredVehicleIndex !== -1) {
                                                hoveredVehicleIndex = -1
                                                needsRepaint = true
                                            }
                                            if (hoveredLineIndex !== -1) {
                                                hoveredLineIndex = -1
                                                needsRepaint = true
                                            }
                                            if (hoveredBezierIndex !== -1) {
                                                hoveredBezierIndex = -1
                                                needsRepaint = true
                                            }
                                            if (needsRepaint) {
                                                parent.requestPaint() // 触发重绘
                                            }
                                        }
                                    }
                                }
                                
                                // 预导入的车辆图片（已不再使用，保留作为备用）
                                /*
                                Image {
                                    id: sourceImage
                                    source: "qrc:/Resource/rightelement/icon_car_withe.png"
                                    visible: false
                                    cache: true
                                    smooth: true
                                    antialiasing: true
                                }
                                Image{
                                    id: masterImage
                                    source: "qrc:/Resource/rightelement/icon_car.png"
                                    visible: false
                                    cache: true
                                    smooth: true
                                    antialiasing: true
                                }
                                Image{
                                    id: objImage
                                    source: "qrc:/Resource/rightelement/icon_car_blue.png"
                                    visible: false
                                    cache: true
                                    smooth: true
                                    antialiasing: true
                                }
                                */
                            }
                        }
                    }
                }
                
                // 底部图表区域（左：自定义曲线图，右：FluChart柱状图）
                Row {
                    id: chartsRow
                    anchors.top: vehicleTopologyArea.bottom
                    anchors.topMargin: 20
                    anchors.margins: 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * 0.25
                    spacing: 10

                    // 左侧：自定义曲线图
                    CurveComponent {
                        id: topologyCurve
                        width: chartsRow.width * 0.5 - chartsRow.spacing
                        height: chartsRow.height
                        chartTitle: "网络性能曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "吞吐量 (MB/s)"
                        curveColor: "#3498db"
                        showSineWave: false
                        curveType: "line"
                        autoScaleY: true
                        maxDataPoints: 50
                        
                        // 示例数据
                        dataPoints: [
                            {x: 0, y: 12}, {x: 1, y: 19}, {x: 2, y: 8},
                            {x: 3, y: 15}, {x: 4, y: 11}, {x: 5, y: 17}
                        ]
                    }

                    // 右侧：FluentUI 柱状图（加背景与栅格）
                    Item {
                        id: barChartContainer
                        width: chartsRow.width * 0.5 - chartsRow.spacing/2
                        height: chartsRow.height

                        Rectangle {
                            anchors.fill: parent
                            color: "#0f1624"            // 深色背景
                            border.color: "#30363d"
                            border.width: 1
                            radius: 8
                        }

                        FluChart {
                            id: barChart
                            anchors.fill: parent
                            anchors.margins: 8
                            chartType: "bar"
                            chartData: {
                                "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                                "datasets": [
                                    {
                                        "label": "车辆数",
                                        "data": [12, 19, 3, 5, 2, 3, 7],
                                        "backgroundColor": "rgba(91, 143, 249, 0.65)",
                                        "borderColor": "rgba(91, 143, 249, 1)",
                                        "borderWidth": 1,
                                        "barPercentage": 0.6,
                                        "categoryPercentage": 0.7
                                    }
                                ]
                            }
                            chartOptions: {
                                "responsive": true,
                                "maintainAspectRatio": false,
                                "layout": {"padding": 8},
                                "legend": {"display": true, "position": "top", "labels": {"fontColor": "#f0f6fc"}},
                                "title": {"display": true, "text": "每周车辆统计", "fontColor": "#f0f6fc", "fontSize": 14},
                                "scales": {
                                    "xAxes": [{
                                        "gridLines": {"display": true, "color": "rgba(48, 54, 61, 0.55)", "lineWidth": 1},
                                        "ticks": {"fontColor": "#94a3b8"}
                                    }],
                                    "yAxes": [{
                                        "gridLines": {"display": true, "color": "rgba(48, 54, 61, 0.55)", "lineWidth": 1},
                                        "ticks": {"beginAtZero": true, "fontColor": "#94a3b8"}
                                    }]
                                },
                                "elements": {"rectangle": {"borderWidth": 1}}
                            }
                        }
                    }
                }

                // 左下拓扑数据详情区域
                Item {
                    id: topologyDataArea
                    anchors.top: chartsRow.bottom
                    anchors.topMargin: 20
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 0
                        // 标题栏 - 标题居左，按钮居右，垂直居中对齐
                        Rectangle {
                            id: titleBar
                            width: parent.width
                            height: 60
                            color: FluTheme.dark ? "#1E1E1E" : "#F5F5F5"
                            border.color: FluTheme.dark ? "#333333" : "#CCCCCC"
                            border.width: 1
                            radius: 8
                            
                            // 双击检测区域
                            MouseArea {
                                anchors.fill: parent
                                onDoubleClicked: {
                                    vehicleDataPopup.showPopup()
                                }
                            }
                            
                            // 标题 - 居左
                            FluText {
                                text: "车辆网络拓扑设置"
                                font.pixelSize: 24
                                font.bold: true
                                textColor: FluTheme.dark ? "white" : "#0078D4"
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            // 单选按钮区域 - 居右
                            Row {
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 30
                                
                                FluRadioButton {
                                    id: manualModeRadio
                                    text: "手动切换拓扑"
                                    checked: true
                                    textColor: FluTheme.dark ? "#E0E0E0" : "#333333"
                                    font.pixelSize: 14
                                    font.bold: true
                                    ButtonGroup.group: topologyModeGroup
                                    
                                    // 添加悬停效果
                                    hoverEnabled: true
                                    background: Rectangle {
                                        color: parent.hovered ? (FluTheme.dark ? "#2A2A2A" : "#F0F0F0") : "transparent"
                                        radius: 6
                                        border.color: parent.checked ? (FluTheme.dark ? "#00D4FF" : "#0078D4") : "transparent"
                                        border.width: parent.checked ? 0 : 0
                                    }
                                }
                                
                                FluRadioButton {
                                    id: autoModeRadio
                                    text: "自动切换拓扑"
                                    textColor: FluTheme.dark ? "#E0E0E0" : "#333333"
                                    font.pixelSize: 14
                                    font.bold: true
                                    // 通过banging到同一组来实现
                                    ButtonGroup.group: topologyModeGroup
                                    
                                    // 添加悬停效果
                                    hoverEnabled: true
                                    background: Rectangle {
                                        color: parent.hovered ? (FluTheme.dark ? "#2A2A2A" : "#F0F0F0") : "transparent"
                                        radius: 6
                                        border.color: parent.checked ? (FluTheme.dark ? "#00D4FF" : "#0078D4") : "transparent"
                                        border.width: parent.checked ? 0 : 0
                                    }
                                }
                            }
                        }

                        
                        // 表格区域
                        FluTableView {
                            id: vehicleDataTable
                            width: parent.width
                            height: parent.height - titleBar.height  // 为标题和按钮留出空间
                            
                            // 自定义行高度提供器
                            rowHeightProvider: function(row) {
                                return 45  // 增加行高度
                            }
                            
                            // 设置表格背景色和边框，避免夜间模式覆盖问题
                            color: FluTheme.dark ? "#1a1a1a" : "#ffffff"
                            borderColor: FluTheme.dark ? "#3A3A3A" : "#e0e0e0"
                            selectedColor: FluTheme.dark ? Qt.rgba(0.27, 0.61, 0.95, 0.3) : Qt.rgba(0.27, 0.61, 0.95, 0.2)
                            
                            columnSource: [
                                {
                                    title: "车辆ID",
                                    dataIndex: "vehicleId",
                                    width: 80
                                },
                                {
                                    title: "车辆编号",
                                    dataIndex: "vehicleNumber",
                                    width: 100
                                },
                                {
                                    title: "发出消息设备ID",
                                    dataIndex: "senderDeviceId",
                                    width: 120
                                },
                                {
                                    title: "接收数据设备ID",
                                    dataIndex: "receiverDeviceId",
                                    width: 120
                                },
                                {
                                    title: "设定速度",
                                    dataIndex: "targetSpeed",
                                    width: 80
                                },
                                {
                                    title: "当前速度",
                                    dataIndex: "currentSpeed",
                                    width: 80
                                },
                                {
                                    title: "平均速度误差",
                                    dataIndex: "avgSpeedError",
                                    width: 100
                                },
                                {
                                    title: "最大速度误差",
                                    dataIndex: "maxSpeedError",
                                    width: 100
                                },
                                {
                                    title: "设定与前车间距",
                                    dataIndex: "targetDistance",
                                    width: 110
                                },
                                {
                                    title: "平均间距误差",
                                    dataIndex: "avgDistanceError",
                                    width: 100
                                },
                                {
                                    title: "最大间距误差",
                                    dataIndex: "maxDistanceError",
                                    width: 100
                                },
                                {
                                    title: "跟踪性能",
                                    dataIndex: "trackingPerformance",
                                    width: 80
                                },
                                {
                                    title: "受攻击情况",
                                    dataIndex: "attackStatus",
                                    width: 90
                                },
                                {
                                    title: "攻击类型",
                                    dataIndex: "attackType",
                                    width: 80
                                },
                                {
                                    title: "攻击持续时长",
                                    dataIndex: "attackDuration",
                                    width: 100
                                }
                            ]
                            
                            dataSource: vehicleTableData
                        }
                    }
                    
                    // ButtonGroup for radio buttons
                    ButtonGroup {
                        id: topologyModeGroup
                    }
                }
            }






        }

        // 数据详情弹窗
        DataDetailPopup {
            id: dataPopup
            dataModel: rawDataModel
            title: "原始数据详情"
            
            onCloseClicked: {
                console.log("数据详情弹窗关闭")
            }
        }

        // 数据复制对话框
        Dialog {
            id: copyDialog
            title: "数据内容"
            width: 600
            height: 400
            modal: true
            anchors.centerIn: parent
            
            // 设置对话框背景为暗黑色
            background: Rectangle {
                color: "#1a1a1a"
                border.color: "#00ffff"
                border.width: 0
                radius: 10
            }
            
            property string dataContent: ""
            
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                radius: 8
                border.color: "#555555"
                border.width: 0
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    // 标题
                    Text {
                        text: "数据内容 (双击文本区域可全选)"
                        color: "#ffffff"
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // 数据显示区域
                    ScrollView {
                        width: parent.width
                        height: parent.height - 80
                        clip: true
                        
                        TextArea {
                            id: dataTextArea
                            text: copyDialog.dataContent
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.family: "Consolas, Monaco, 'Courier New', monospace"
                            wrapMode: TextArea.Wrap
                            selectByMouse: true
                            readOnly: true
                            background: Rectangle {
                                color: "#1a1a1a"
                                border.color: "#444444"
                                border.width: 1
                                radius: 4
                            }
                            
                            // 双击全选
                            MouseArea {
                                anchors.fill: parent
                                onDoubleClicked: {
                                    dataTextArea.selectAll()
                                }
                                onPressed: mouse.accepted = false
                            }
                        }
                    }
                    
                    // 按钮区域
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 15
                        
                        Button {
                            text: "全选"
                            onClicked: dataTextArea.selectAll()
                            background: Rectangle {
                                color: parent.pressed ? "#00BCD4" : "#555555"
                                radius: 6
                                border.color: "#777777"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font.pixelSize: 20
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Button {
                            text: "关闭"
                            onClicked: copyDialog.close()
                            background: Rectangle {
                                color: parent.pressed ? "#ff6666" : "#555555"
                                radius: 6
                                border.color: "#777777"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font.pixelSize: 20
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }

        // 右侧矩形 - 显示TechDashboard内容
        Rectangle {
            Layout.fillWidth: true  // 宽度随页面变化
            Layout.fillHeight: true  // 高度为parent.height
            color: "#1a1a1a"  // 与LayoutRight一致的背景色
            border.color: "#00ffff"
            border.width: 0
            radius: 10
            
          
            
            // TechDashboard内容
            Column {
                width: parent.width
                height: parent.height
                spacing: 20
 
                // 系统状态面板
                Rectangle {
                    id:systempanel
                    width: parent.width
                    height: parent.height * 0.7  // 扩展高度，占右侧面板75%
                    color: "transparent"
                    border.color: "#00ffff"
                    border.width: 4
                    radius: 10
                    
                    // Canvas覆盖层，用于遮盖边界只保留四角
                    Canvas {
                        anchors.fill: parent
                        property int cornerLength: 40
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            
                            // 设置覆盖颜色为背景色
                            ctx.fillStyle = "#0a0e1a"  // 与主背景色一致
                            
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
                    
                    // 标题栏和状态显示组合Item
                    Item {
                        id: titleStatusGroup
                        width: parent.width
                        height: 100  // 固定高度为标题和状态显示预留空间
                        anchors.top: parent.top
                        anchors.topMargin: 15
                        
                        Column {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 15
                            
                            // 标题
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "系统状态"
                                color: "#00ffff"
                                font.pixelSize: 24
                                font.bold: true
                            }
                            
                            // 状态信息
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 40
                                
                                Text {
                                    id: connectionStatusText
                                    text: "连接状态: " + getConnectionStatusText()
                                    color: getConnectionStatusColor()
                                    font.pixelSize: 16
                                    
                                    function getConnectionStatusText() {
                                        if (SharedNetworkConnection.isConnected) {
                                            return "已连接"
                                        } else if (connectDataBtn && connectDataBtn.isConnecting) {
                                            return "连接中..."
                                        } else {
                                            return "未连接"
                                        }
                                    }
                                    
                                    function getConnectionStatusColor() {
                                        if (SharedNetworkConnection.isConnected) {
                                            return "#00ff88"  // 绿色 - 已连接
                                        } else if (connectDataBtn && connectDataBtn.isConnecting) {
                                            return "#ffaa00"  // 橙色 - 连接中
                                        } else {
                                            return "#ff6666"  // 红色 - 未连接
                                        }
                                    }
                                }
                                
                                Text {
                                    text: "系统状态: " + (startSystemBtn && startSystemBtn.isRunning ? "运行中" : "已停止")
                                    color: startSystemBtn && startSystemBtn.isRunning ? "#00ff88" : "#ff6666"
                                    font.pixelSize: 16
                                }
                                
                                Text {
                                    text: "数据量: " + dataPacketCount
                                    color: "#00ffff"
                                    font.pixelSize: 16
                                }
                            }
                        }
                    }
                                 
                    // 仪表盘和按键组合Item
                    Item {
                        id: dashboardButtonGroup
                        width: parent.width
                        height: 200
                        anchors.top: titleStatusGroup.bottom
                        anchors.topMargin: 15
                        // 仪表盘容器 - 根据实际渲染尺寸调整
                        Rectangle {
                            id: dashboardContainer
                            anchors.right: buttonContainer.left
                            anchors.rightMargin: 10

                            anchors.verticalCenter: parent.verticalCenter
                            // 仪表盘实际尺寸：(dashboardRadius + 22 + (-6) + 15 + 30) * 2 = (60+22-6+15+30)*2 = 242px
                            width: 242
                            height: 242
                            color: "transparent"
                            border.color: "#555555"  // 添加边框以便调试查看实际大小
                            border.width: 0
                            
                            // 仪表盘
                            DashboardComponent {
                                id: dashboard
                                anchors.centerIn: parent  // 在容器中居中
                                
                                // 半圆仪表盘配置
                                startAngle: 140
                                totalAngle: 260
                                primaryColor: "#00BCD4"
                                backgroundColor: "#333333"
                                
                                // 仪表盘数值
                                currentValue: 75
                                maxValue: 100
                                minValue: 0
                                unit: "%"
                                
                                // 显示配置
                                dashboardRadius: 60
                                showPointer: true
                                pointerColor: "#00BCD4"
                                labelText: "丢包率"
                            }
                        }
                        
                        // 四个功能按钮 - 与仪表盘真正水平对齐
                        Item {
                            id: buttonContainer
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: dashboardContainer.verticalCenter  // 与仪表盘垂直居中对齐
                            width: 140
                            height: dashboardContainer.height  // 与仪表盘高度一致 (242px)
                            

                            
                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10
                                
                                // 启动系统按钮
                                FluFilledButton {
                                    id: startSystemBtn
                                    width: parent.width
                                    height: (parent.height - 30) / 4  // 平均分配高度给4个按钮
                                    text: startSystemBtn.isRunning ? "停止系统" : "启动系统"
                                    
                                    property bool isRunning: false
                                    
                                    onClicked: {
                                        isRunning = !isRunning
                                        console.log("系统状态:", isRunning ? "运行中" : "已停止")
                                        
                                        // 启动系统时自动连接网络
                                        if (isRunning) {
                                            console.log("启动系统，开始连接网络...")
                                             SharedNetworkConnection.connectToServer("120.26.31.3", 7777)
                                        } else {
                                            console.log("停止系统，断开网络连接...")
                                            SharedNetworkConnection.disconnectFromServer()
                                        }
                                    }
                                }
                                
                                // 连接数据按钮
                                FluFilledButton {
                                    id: connectDataBtn
                                    width: parent.width
                                    // radius: 15
                                    height: (parent.height - 30) / 4  // 平均分配高度给4个按钮
                                    text: getConnectButtonText()
                                    // 需要进行空值验证然后再进行判断，否则就会出现undefined变量的情况
                                    property bool isConnecting: false
                                    property bool isConnected: SharedNetworkConnection ? SharedNetworkConnection.isConnected : false
                                    
                                    function getConnectButtonText() {
                                        if (isConnected) {
                                            return "断开连接"
                                        } else if (isConnecting) {
                                            return "连接中..."
                                        } else {
                                            return "连接数据"
                                        }
                                    }
                                    
                                    onClicked: {
                                        if (isConnected) {
                                            console.log("断开数据连接")
                                            isConnecting = false
                                            SharedNetworkConnection.disconnectFromServer()
                                        } else if (!isConnecting) {
                                            console.log("连接数据")
                                            isConnecting = true
                                            SharedNetworkConnection.connectToServer("120.26.31.3", 7777)
                                        }
                                    }
                                    
                                    // 监听连接状态变化
                                    Connections {
                                        target: SharedNetworkConnection ? SharedNetworkConnection.networkConnection : null
                                        function onNetworkConnectionChanged(connected) {
                                            connectDataBtn.isConnected = connected
                                            if (connected) {
                                                connectDataBtn.isConnecting = false
                                            }
                                        }
                                    }
                                }
                                
                                // 清空数据按钮
                                FluFilledButton {
                                    id: clearDataBtn
                                    width: parent.width
                                    height: (parent.height - 30) / 4  // 平均分配高度给4个按钮
                                    text: "清空数据"
                                    
                                    onClicked: {
                                        console.log("清空数据")
                                        // 清空rawDataModel中的所有数据
                                        rawDataModel.clear()
                                        // 重置数据包计数器
                                        dataPacketCount = 0
                                        console.log("已清空所有数据，当前记录数:", rawDataModel.count)
                                    }
                                }
                                
                                // 详细数据按钮
                                FluFilledButton {
                                    id: detailDataBtn
                                    width: parent.width
                                    height: (parent.height - 30) / 4  // 平均分配高度给4个按钮
                                    text: "详细数据"
                                    
                                    onClicked: {
                                        console.log("打开详细数据")
                                        dataPopup.open()
                                    }
                                }
                            }
                        }
                    }
                    
                    // 进度条组
                    Item {
                        id: progressGroup
                        width: parent.width
                        height: 140
                        anchors.top: dashboardButtonGroup.bottom
                        anchors.topMargin: 50
                        
                        Column {
                            anchors.fill: parent
                            spacing: 10
                            
                            Row {
                                width: parent.width * 0.8
                                height: 40
                                spacing: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Image {
                                    width: 40
                                    height: 40
                                    source: "qrc:/Resource/Leftelement/car.svg"
                                    fillMode: Image.PreserveAspectFit
                                    sourceSize: Qt.size(width, height)
                                }
                                
                                ProgressBarComponent {
                                    width: parent.width - 70
                                    height: 40
                                    title: "连接数量"
                                    currentValue: 80
                                    maxValue: 100
                                    barHeight: 12
                                    fontSize: 15
                                    unit: "%"
                                    baseColor: "#00BCD4"
                                }
                            }
                            Row {
                                width: parent.width * 0.8
                                height: 40
                                spacing: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Image {
                                    width: 40
                                    height: 40
                                    source: "qrc:/Resource/Leftelement/car.svg"
                                    fillMode: Image.PreserveAspectFit
                                    sourceSize: Qt.size(width, height)
                                }
                                ProgressBarComponent {
                                    width: parent.width - 70
                                    height: 40
                                    title: "CPU使用率"
                                    currentValue: 45
                                    maxValue: 100
                                    barHeight: 12
                                    fontSize: 15
                                    unit: "%"
                                    baseColor: "#00BCD4"
                                }
                            }
                            Row {
                                width: parent.width * 0.8
                                height: 40
                                spacing: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Image {
                                    width: 40
                                    height: 40
                                    source: "qrc:/Resource/Leftelement/car.svg"
                                    fillMode: Image.PreserveAspectFit
                                    sourceSize: Qt.size(width, height)
                                }
                                ProgressBarComponent {
                                    width: parent.width - 70
                                    height: 40
                                    title: "内存使用率"
                                    currentValue: 65
                                    maxValue: 100
                                    barHeight: 12
                                    fontSize: 15
                                    unit: "%"
                                    baseColor: "#00BCD4"
                                }
                            }
                        }
                    }
                    
                    // 数值显示组
                    Item {
                        id: valueDisplayGroup
                        width: parent.width
                        height: 80
                        anchors.top: progressGroup.bottom
                        anchors.topMargin: 20
                        
                        Column {
                            anchors.fill: parent
                            spacing: 15
                            
                            // 数值行
                            Row {
                                width: parent.width
                                height: 30
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Text {
                                    width: (parent.width - 20) / 3
                                    text: "1024"
                                    color: "#00BCD4"
                                    font.pixelSize: 20
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Rectangle {
                                    width: 2
                                    height: parent.height
                                    color: "#333333"
                                }
                                
                                Text {
                                    width: (parent.width - 20) / 3
                                    text: "45.2"
                                    color: "#00BCD4"
                                    font.pixelSize: 20
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Rectangle {
                                    width: 2
                                    height: parent.height
                                    color: "#333333"
                                }
                                
                                Text {
                                    width: (parent.width - 20) / 3
                                    text: "8.5GB"
                                    color: "#00BCD4"
                                    font.pixelSize: 20
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                            
                            // 介绍行
                            Row {
                                width: parent.width
                                height: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Text {
                                    width: (parent.width - 20) / 3
                                    text: "连接设备数"
                                    color: "#888888"
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Rectangle {
                                    width: 2
                                    height: parent.height
                                    color: "#333333"
                                }
                                
                                Text {
                                    width: (parent.width - 20) / 3
                                    text: "CPU使用率"
                                    color: "#888888"
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                
                                Rectangle {
                                    width: 2
                                    height: parent.height
                                    color: "#333333"
                                }
                                
                                Text {
                                    width: (parent.width - 20) / 3
                                    text: "内存使用量"
                                    color: "#888888"
                                    font.pixelSize: 20
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }

                }
                

                // 粒子交互面板
                Rectangle {
                    id:splitopanel
                    width: parent.width
                    height: parent.height - systempanel.height - 40  // 占用系统面板剩余的父组件高度
                    anchors.bottom : parent.bottom
                    // anchors.bottomMargin:10
                    color: "transparent"
                    border.color: "#00ffff"
                    border.width: 4
                    radius: 10
                    
                    // // Canvas覆盖层，用于遮盖边界只保留四角
                    Canvas {
                        anchors.fill: parent
                        property int cornerLength: 40
                        
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            
                            // 设置覆盖颜色为背景色
                            ctx.fillStyle = "#0a0e1a"  // 与主背景色一致
                            
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
                    Column {
                        width: parent.width - 30
                        height: parent.height - 30
                        x: 15
                        y: 15
                        spacing: 10
                        
                        Text {
                            text: "粒子交互"
                            color: "#00ffff"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        
                        // 粒子动画Canvas
                        Canvas {
                            id: particleCanvas
                            width: splitopanel.width - 30  // 使用Rectangle宽度减去margins
                            height: splitopanel.height - 70  // 使用Rectangle高度减去margins和标题高度
                            
                            property var particles: []
                            property real maxDistance: 120  // 最大连线距离
                            property real particleRadius: 6  // 粒子半径
                            property int particleCount: 20   // 粒子数量
                            
                            // 初始化粒子
                            Component.onCompleted: {
                                
                                initParticles()
                                animationTimer.start()
                                console.log("Canvas size - x:",width,"y:",height)
                            }
                            
                            function initParticles() {
                                particles = []
                                for(var i = 0; i < particleCount; i++) {
                                    var particle = {
                                        x: Math.random() * width,   // 完整画布宽度范围 [0, width]
                                        y: Math.random() * height,  // 完整画布高度范围 [0, height]
                                        
                                        vx: (Math.random() - 0.5) * 2,  // x方向速度 (-1 到 1)
                                        vy: (Math.random() - 0.5) * 2   // y方向速度 (-1 到 1)
                                    }
                                    particles.push(particle)
                                }
                            }
                            
                            function updateParticles() {
                                for(var i = 0; i < particles.length; i++) {
                                    var particle = particles[i]
                                    
                                    // 更新位置
                                    particle.x += particle.vx * 0.3  // 假设16ms刷新间隔
                                    particle.y += particle.vy * 0.3
                                    
                                    // 边界碰撞检测和反弹
                                    if(particle.x <= particleRadius || particle.x >= width - particleRadius) {
                                        particle.vx = -particle.vx
                                        particle.x = Math.max(particleRadius, Math.min(width - particleRadius, particle.x))
                                    }
                                    
                                    if(particle.y <= particleRadius || particle.y >= height - particleRadius) {
                                        particle.vy = -particle.vy
                                        particle.y = Math.max(particleRadius, Math.min(height - particleRadius, particle.y))
                                    }
                                }
                            }
                            
                            onPaint: {
                                var ctx = getContext("2d")
                                
                                // 清空画布
                                ctx.clearRect(0, 0, width, height)
                                
                                // 绘制粒子之间的连线并处理碰撞
                                for(var i = 0; i < particles.length; i++) {
                                    for(var j = i + 1; j < particles.length; j++) {
                                        var p1 = particles[i]
                                        var p2 = particles[j]
                                        
                                        // 计算距离
                                        var distance = Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2))
                                        
                                        // // 粒子碰撞检测：当距离小于粒子半径时，速度反转
                                        // if(distance < particleRadius * 2) {
                                        //     p1.vx = -p1.vx
                                        //     p1.vy = -p1.vy
                                        //     p2.vx = -p2.vx
                                        //     p2.vy = -p2.vy
                                        // }
                                        
                                        // 如果距离小于最大距离，绘制连线
                                        if(distance < maxDistance) {
                                            // 根据距离计算透明度（距离越近透明度越高）
                                            var opacity = 1 - (distance / maxDistance)
                                            
                                            ctx.strokeStyle = "rgba(255, 255, 255, " + opacity + ")"
                                            ctx.lineWidth = 1
                                            ctx.beginPath()
                                            ctx.moveTo(p1.x, p1.y)
                                            ctx.lineTo(p2.x, p2.y)
                                            ctx.stroke()
                                        }
                                    }
                                }
                                
                                // 绘制粒子
                                ctx.fillStyle = "white"
                                for(var k = 0; k < particles.length; k++) {
                                    var particle = particles[k]
                                    ctx.beginPath()
                                    ctx.arc(particle.x, particle.y, particleRadius, 0, 2 * Math.PI)
                                    ctx.fill()
                                }
                            }
                            
                            // 动画定时器
                            Timer {
                                id: animationTimer
                                interval: 16  // 约60FPS
                                repeat: true
                                onTriggered: {
                                    particleCanvas.updateParticles()
                                    particleCanvas.requestPaint()
                                }
                            }
                        }
                    }
                }
            }
    
        
        }
    }


    // 原始数据模型
    ListModel {
        id: rawDataModel
    }

    // 系统状态属性
    property bool systemRunning: SharedNetworkConnection ? SharedNetworkConnection.isConnected : false
    property int dataPacketCount: 0
    property string topologyMode: "点对点"

    // 添加数据到模型的函数
    function addDataToModel(data) {
        var displayData = data
        var fullDisplayData = data
        
        // 尝试解析并格式化JSON数据
        try {
            var jsonObj = JSON.parse(data)
            // 如果解析成功，重新格式化为带缩进的JSON
            displayData = JSON.stringify(jsonObj, null, 2)
            fullDisplayData = displayData
            
            // 如果格式化后的数据太长，截取前部分用于预览
            if (displayData.length > 500) {
                displayData = displayData.substring(0, 500) + "..."
            }
        } catch (e) {
            // 如果不是JSON格式，保持原样
            if (data.length > 500) {
                displayData = data.substring(0, 500) + "..."
                fullDisplayData = data
            }
        }
        
        rawDataModel.append({
            timestamp: new Date().toLocaleTimeString(),
            data: displayData,
            fullData: fullDisplayData,
            id: dataPacketCount + 1
        })
        
        // 限制列表长度，避免内存过度使用
        if (rawDataModel.count > 1000) {
            rawDataModel.remove(0, rawDataModel.count - 1000)
        }
        
        dataPacketCount++
        
        // 显示新数据提示
        if (dataListView.header && dataListView.header.showNewData) {
            dataListView.header.showNewData(
                data.length.toString(),
                (dataPacketCount).toString(),
                new Date().toLocaleTimeString()
            )
        }
        
        console.log("已添加新数据到模型，当前记录数:", rawDataModel.count)
    }

    // 详情对话框
    Dialog {
        id: detailDialog
        title: "数据详情"
        width: 600
        height: 400
        modal: true
        anchors.centerIn: parent
        
        property string detailData: ""
        property string detailTimestamp: ""
        
        function showDetailData(data, timestamp) {
            detailData = data
            detailTimestamp = timestamp
            open()
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            Text {
                text: "时间戳: " + detailDialog.detailTimestamp
                font.bold: true
                color: "#D4D4D4"
            }
            

        }
    }

    // 组件初始化时添加示例数据
    Component.onCompleted: {
        // 添加各种类型的示例JSON数据
        var sampleData = [
            {
                "timestamp": new Date().toLocaleString(),
                "data": JSON.stringify({
                    "type": "vehicle_status",
                    "vehicle_id": "V001",
                    "status": {
                        "online": true,
                        "battery": 85,
                        "speed": 45.2,
                        "location": {
                            "latitude": 39.9042,
                            "longitude": 116.4074
                        }
                    },
                    "sensors": {
                        "imu": {
                            "orientation": {
                                "x": -0.002025764096641,
                                "y": -0.000879475945456,
                                "z": -0.722080384192152,
                                "w": -0.691805607019687
                            },
                            "angular_velocity": {
                                "x": -0.001476267818361,
                                "y": -0.000433212844654,
                                "z": 0.000519316177815
                            },
                            "linear_acceleration": {
                                "x": -0.018532451242208,
                                "y": -0.031285967677831,
                                "z": -9.769591331481934
                            }
                        },
                        "gps": {
                            "latitude": 39.9042,
                            "longitude": 116.4074,
                            "altitude": 43.2,
                            "accuracy": 3.5
                        }
                    }
                }, null, 8),
                "fullData": JSON.stringify({
                    "type": "vehicle_status",
                    "vehicle_id": "V001",
                    "timestamp": new Date().toISOString(),
                    "status": {
                        "online": true,
                        "battery": 85,
                        "speed": 45.2,
                        "location": {
                            "latitude": 39.9042,
                            "longitude": 116.4074
                        }
                    },
                    "sensors": {
                        "imu": {
                            "orientation": {
                                "x": -0.002025764096641,
                                "y": -0.000879475945456,
                                "z": -0.722080384192152,
                                "w": -0.691805607019687
                            },
                            "angular_velocity": {
                                "x": -0.001476267818361,
                                "y": -0.000433212844654,
                                "z": 0.000519316177815
                            },
                            "linear_acceleration": {
                                "x": -0.018532451242208,
                                "y": -0.031285967677831,
                                "z": -9.769591331481934
                            }
                        },
                        "gps": {
                            "latitude": 39.9042,
                            "longitude": 116.4074,
                            "altitude": 43.2,
                            "accuracy": 3.5
                        }
                    },
                    "diagnostics": {
                        "engine_temp": 85.5,
                        "oil_pressure": 2.3,
                        "fuel_level": 78.2,
                        "error_codes": []
                    }
                }, null, 8)
            },
            {
                "timestamp": new Date(Date.now() - 5000).toLocaleString(),
                "data": JSON.stringify({
                    "type": "network_status",
                    "connection": {
                        "status": "connected",
                        "signal_strength": -45,
                        "bandwidth": 1024,
                        "latency": 12
                    },
                    "statistics": {
                        "packets_sent": 15420,
                        "packets_received": 15380,
                        "packet_loss": 0.26,
                        "uptime": 3600
                    }
                }, null, 8),
                "fullData": JSON.stringify({
                    "type": "network_status",
                    "timestamp": new Date(Date.now() - 5000).toISOString(),
                    "connection": {
                        "status": "connected",
                        "signal_strength": -45,
                        "bandwidth": 1024,
                        "latency": 12,
                        "protocol": "TCP",
                        "encryption": "TLS 1.3"
                    },
                    "statistics": {
                        "packets_sent": 15420,
                        "packets_received": 15380,
                        "packet_loss": 0.26,
                        "uptime": 3600,
                        "data_transferred": 2048576
                    }
                }, null, 8)
            },
            {
                "timestamp": new Date(Date.now() - 10000).toLocaleString(),
                "data": JSON.stringify({
                    "type": "system_alert",
                    "level": "warning",
                    "message": "CPU使用率过高",
                    "details": {
                        "cpu_usage": 89.5,
                        "memory_usage": 76.2,
                        "disk_usage": 45.8,
                        "processes": [
                            {"name": "vehicle_monitor", "cpu": 25.3, "memory": 512},
                            {"name": "data_processor", "cpu": 18.7, "memory": 256},
                            {"name": "network_handler", "cpu": 12.1, "memory": 128}
                        ]
                    }
                }, null, 8),
                "fullData": JSON.stringify({
                    "type": "system_alert",
                    "timestamp": new Date(Date.now() - 10000).toISOString(),
                    "level": "warning",
                    "message": "CPU使用率过高",
                    "details": {
                        "cpu_usage": 89.5,
                        "memory_usage": 76.2,
                        "disk_usage": 45.8,
                        "temperature": 68.5,
                        "processes": [
                            {"name": "vehicle_monitor", "cpu": 25.3, "memory": 512, "pid": 1234},
                            {"name": "data_processor", "cpu": 18.7, "memory": 256, "pid": 1235},
                            {"name": "network_handler", "cpu": 12.1, "memory": 128, "pid": 1236}
                        ],
                        "recommendations": [
                            "检查vehicle_monitor进程",
                            "考虑增加系统内存",
                            "优化数据处理算法"
                        ]
                    }
                }, null, 8)
            }
        ]
        
        // 将示例数据添加到模型中
        for (var i = 0; i < sampleData.length; i++) {
            rawDataModel.append(sampleData[i])
        }
        
        console.log("已添加", sampleData.length, "条示例JSON数据")
    }
    
    // 监听SharedNetworkConnection的信号
    Connections {
        target: SharedNetworkConnection ? SharedNetworkConnection.networkConnection : null
        
        // 监听数据接收信号
        function onDataReceived(data) {
            // console.log("HomePage接收到数据:", data)
            addDataToModel(data)
        }
        
        // 监听连接状态变化
        function onNetworkConnectionChanged(connected) {
            console.log("网络连接状态变化:", connected)
            // 更新连接按钮状态
            connectDataBtn.isConnected = connected
            // 连接成功或失败时，清除连接中状态
            if (connected || !connected) {
                connectDataBtn.isConnecting = false
            }
        }
        
        // 监听状态变化
        function onStatusChanged(status) {
            console.log("网络状态:", status)
        }
    }

    // 车辆数据弹出框
    VehicleDataPopup {
        id: vehicleDataPopup
    }
}

