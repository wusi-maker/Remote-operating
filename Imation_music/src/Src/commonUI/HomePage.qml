import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../Network"
import "../style"
import "../rightPage"

Rectangle {
    id: homePage
    color: "transparent"

    // 主布局 - 改为RowLayout
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 40

        // 左侧矩形 - 显示原始数据流
        Rectangle {
            Layout.preferredWidth: 1000  // 固定宽度
            Layout.preferredHeight: parent.height - 100  // 比parent.height小一点
            Layout.alignment: Qt.AlignVCenter
            color: "#1a1a1a"  // 深化背景色
            border.color: "#00ffff"
            border.width: 5
            radius: 10

            Canvas{
                    anchors.fill: parent
                    property int cornerLength: 40
                    
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        
                        // 设置覆盖颜色为背景色
                        ctx.fillStyle = "#1a1a1a"  // 与主背景色一致
                        
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

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                // 标题区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "transparent"  // 标题背景色
                    radius: 8
                    border.color: "#555555"
                    border.width: 0
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 5
                        
                        Text {
                            text: "数据接收记录"
                            color: "#ffffff"
                            font.pixelSize: 30
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        // 标题下的数据统计
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 40
                            
                            Text {
                                text: "总记录: " + (rawDataModel ? rawDataModel.count : 0)
                                color: "#00BCD4"
                                font.pixelSize: 15
                            }
                            
                            Text {
                                text: "连接状态: " + connectionStatusText
                                color: connectionStatusColor
                                font.pixelSize: 15
                                
                                property string connectionStatusText: {
                                    if (SharedNetworkConnection.isConnected) {
                                        return "已连接"
                                    } else if (connectDataBtn.isConnecting) {
                                        return "连接中..."
                                    } else {
                                        return "未连接"
                                    }
                                }
                                
                                property color connectionStatusColor: {
                                    if (SharedNetworkConnection.isConnected) {
                                        return "#00ff88"  // 绿色 - 已连接
                                    } else if (connectDataBtn.isConnecting) {
                                        return "#ffaa00"  // 橙色 - 连接中
                                    } else {
                                        return "#ff6666"  // 红色 - 未连接
                                    }
                                }
                            }
                            
                            Text {
                                text: "系统状态: " + (startSystemBtn.isRunning ? "运行中" : "已停止")
                                color: startSystemBtn.isRunning ? "#00ff88" : "#ff6666"
                                font.pixelSize: 15
                            }
                        }
                    }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: dataListView
                        model: rawDataModel
                        delegate: Rectangle {
                            id: dataItem
                            width: dataListView.width
                            // 根据数据长度动态计算高度：基础高度70px + 数据长度影响的额外高度
                            height: {
                                var baseHeight = 70
                                var dataLength = model.data ? model.data.length : 0
                                var extraHeight = 0
                                
                                // 根据数据长度分级增加高度
                                if (dataLength > 200) {
                                    extraHeight = 250  // 长数据：额外250px
                                } else if (dataLength > 100) {
                                    extraHeight = 180  // 中等数据：额外180px
                                } else if (dataLength > 50) {
                                    extraHeight = 100  // 较长数据：额外100px
                                }
                                
                                return baseHeight + extraHeight
                            }
                            color: index % 2 === 0 ? "#252525" : "#2a2a2a"  // 交替背景色，深化
                            border.color: "#444444"
                            border.width: 1
                            radius: 4
                            
                            // 鼠标悬停放大效果
                            scale: mouseArea.containsMouse ? 1.02 : 1.0
                            
                            // 添加缩放动画
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                            
                            // 鼠标交互区域
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                // 双击弹出对话框
                                onDoubleClicked: {
                                    copyDialog.dataContent = model.data || "无数据"
                                    copyDialog.open()
                                }
                            }
                            
                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                
                                // 主要信息行
                                Row {
                                    width: parent.width
                                    spacing: 20
                                    
                                    Text {
                                        text: "长度: " + (model.data ? model.data.length : 0)
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    Text {
                                        text: "ID: " + (model.id || index)
                                        color: "#00BCD4"
                                        font.pixelSize: 14
                                    }
                                    
                                    Text {
                                        text: "时间: " + (model.timestamp || "未知")
                                        color: "#ffaa00"
                                        font.pixelSize: 14
                                    }
                                }
                                
                                // JSON数据内容预览区域 - 移除滚动条，直接显示
                                Text {
                                    width: parent.width
                                    height: parent.height - 35  // 减去上方信息行的高度
                                    text: "数据: " + (model.data || "无数据")
                                    color: "#e0e0e0"  // 提升文本亮度
                                    font.pixelSize: 18  // 进一步增大字体从16px到18px
                                    font.family: "Consolas, Monaco, 'Courier New', monospace"  // 使用等宽字体便于阅读JSON
                                    font.weight: Font.Medium  // 增加字体粗细
                                    wrapMode: Text.Wrap  // 允许换行
                                    lineHeight: 1.2  // 增加行间距提升可读性
                                    clip: true  // 裁剪超出部分
                                    verticalAlignment: Text.AlignTop  // 顶部对齐
                                }
                            }
                        }
                        
                        // 新数据提示区域
                        header: Rectangle {
                            width: dataListView.width
                            height: newDataVisible ? 60 : 0
                            color: "#444444"  // 较深色背景
                            visible: newDataVisible
                            
                            property bool newDataVisible: false
                            property string newDataLength: ""
                            property string newDataId: ""
                            property string newDataTime: ""
                            
                            Row {
                                anchors.centerIn: parent
                                spacing: 20
                                
                                Text {
                                    text: "新数据 - 长度: " + parent.parent.newDataLength
                                    color: "#00BCD4"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "ID: " + parent.parent.newDataId
                                    color: "#00BCD4"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "时间: " + parent.parent.newDataTime
                                    color: "#00BCD4"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                            
                            // 自动隐藏新数据提示
                            Timer {
                                id: hideTimer
                                interval: 3000
                                onTriggered: parent.newDataVisible = false
                            }
                            
                            function showNewData(length, id, time) {
                                newDataLength = length
                                newDataId = id
                                newDataTime = time
                                newDataVisible = true
                                hideTimer.restart()
                            }
                        }
                    }
                }
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
                    height: parent.height * 0.6  // 自适应高度，占右侧面板60%
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
                    // 系统状态显示层
                    Column {
                        width: parent.width - 30
                        height: parent.height - 30
                        x: 15
                        y: 15
                        spacing: 0
                        
                        Text {
                            text: "系统状态"
                            color: "#00ffff"
                            font.pixelSize: 20
                            font.bold: true
                        }
                        
                        // 仪表盘和按键组合Item
                        Item {
                            id: dashboardButtonGroup
                            width: parent.width
                            height: 200
                            anchors.top: parent.top
                            anchors.topMargin: 50
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
                            
                            // 三个功能按钮 - 与仪表盘真正水平对齐
                            Item {
                                id: buttonContainer
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: dashboardContainer.verticalCenter  // 与仪表盘垂直居中对齐
                                width: 140
                                height: dashboardContainer.height  // 与仪表盘高度一致 (242px)
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    border.color: "#555555"  // 添加边框以便调试查看实际大小
                                    border.width: 0
                                }
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 15
                                    
                                    // 启动系统按钮
                                    Rectangle {
                                        id: startSystemBtn
                                        width: parent.width
                                        height: (parent.height - 30) / 3  // 平均分配高度，减去间距和边距
                                        radius: 25
                                        color: startSystemBtn.isRunning ? "#00BCD4" : "#888888"
                                        border.color: "#666666"
                                        border.width: 2
                                        
                                        property bool isRunning: false
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: startSystemBtn.isRunning ? "停止系统" : "启动系统"
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                parent.isRunning = !parent.isRunning
                                                console.log("系统状态:", parent.isRunning ? "运行中" : "已停止")
                                                
                                                // 启动系统时自动连接网络
                                                if (parent.isRunning) {
                                                    console.log("启动系统，开始连接网络...")
                                                    SharedNetworkConnection.connectToServer()
                                                } else {
                                                    console.log("停止系统，断开网络连接...")
                                                    SharedNetworkConnection.disconnectFromServer()
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 连接数据按钮
                                    Rectangle {
                                        id: connectDataBtn
                                        width: parent.width
                                        height: (parent.height - 30) / 3  // 平均分配高度，减去间距和边距
                                        radius: 25
                                        color: connectDataBtn.isConnected ? "#00BCD4" : "#888888"
                                        border.color: "#666666"
                                        border.width: 2
                                        
                                        property bool isConnected: false
                                        property bool isConnecting: false
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: connectDataBtn.isConnected ? "断开连接" : "连接数据"
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if (parent.isConnected) {
                                                    console.log("断开数据连接")
                                                    parent.isConnecting = false
                                                    SharedNetworkConnection.disconnectFromServer()
                                                } else if (!parent.isConnecting) {
                                                    console.log("连接数据")
                                                    parent.isConnecting = true
                                                    SharedNetworkConnection.connectToServer()
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 清空数据按钮
                                    Rectangle {
                                        id: clearDataBtn
                                        width: parent.width
                                        height: (parent.height - 30) / 3  // 平均分配高度，减去间距和边距
                                        radius: 25
                                        color: "#888888"
                                        border.color: "#666666"
                                        border.width: 2
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "清空数据"
                                            color: "#ffffff"
                                            font.pixelSize: 14
                                            font.bold: true
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onPressed: {
                                                parent.color = "#00BCD4"
                                            }
                                            onReleased: {
                                                parent.color = "#888888"
                                            }
                                            onClicked: {
                                                console.log("清空数据")
                                                // 清空rawDataModel中的所有数据
                                                rawDataModel.clear()
                                                // 重置数据包计数器
                                                dataPacketCount = 0
                                                console.log("已清空所有数据，当前记录数:", rawDataModel.count)
                                            }
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
                            anchors.bottom: valueDisplayGroup.top
                            anchors.bottomMargin: 10
                            
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
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin:10
                            
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
                }

                // 拓扑模式面板
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
    property bool systemRunning: SharedNetworkConnection.isConnected
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
            if (displayData.length > 200) {
                displayData = displayData.substring(0, 200) + "..."
            }
        } catch (e) {
            // 如果不是JSON格式，保持原样
            if (data.length > 200) {
                displayData = data.substring(0, 200) + "..."
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
        target: SharedNetworkConnection.networkConnection
        
        // 监听数据接收信号
        function onDataReceived(data) {
            console.log("HomePage接收到数据:", data)
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
}

