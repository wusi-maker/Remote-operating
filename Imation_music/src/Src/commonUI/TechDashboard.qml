import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI
import "../rightPage"
import "../title"
import "../style"


// 科技感仪表盘界面
Rectangle {
    id: techDashboard
    color: Theme.backgroundColor
    
    // 公有属性：拓扑模式
    property string topologyMode: "mode1"
    
    // 多车辆攻击配置相关属性
    property var selectedVehicles: ["Car001", "Car002", "Car003"]
    property string currentConfigVehicle: "Car001"
    property var vehicleParameters: ({
        "Car001": {
            attackType: 0,
            attackMethod: 0,
            duration: 60,
            frequency: 10,
            intensity: 5,
            range: 50,
            delay: 100,
            packetLoss: 5
        },
        "Car002": {
            attackType: 1,
            attackMethod: 1,
            duration: 80,
            frequency: 15,
            intensity: 7,
            range: 60,
            delay: 120,
            packetLoss: 8
        },
        "Car003": {
            attackType: 2,
            attackMethod: 0,
            duration: 45,
            frequency: 8,
            intensity: 4,
            range: 40,
            delay: 90,
            packetLoss: 3
        }
    })
    
    // JavaScript函数
    function updateSelectedVehicles() {
        var selected = []
        var vehicleNames = ["Car001", "Car002", "Car003", "Car004", "Car005"]
        
        // 查找车辆选择区域中的复选框
        if (vehicleSelectionArea && vehicleSelectionArea.children.length > 0) {
            var column = vehicleSelectionArea.children[0]
            if (column && column.children.length > 1) {
                var flow = column.children[1]
                if (flow && flow.children.length > 0) {
                    var repeater = flow.children[0]
                    if (repeater) {
                        for (var i = 0; i < vehicleNames.length; i++) {
                            var checkbox = repeater.itemAt(i)
                            if (checkbox && checkbox.checked) {
                                selected.push(vehicleNames[i])
                            }
                        }
                    }
                }
            }
        }
        
        selectedVehicles = selected
        
        // 更新当前车辆下拉框的模型
        if (currentVehicleCombo) {
            currentVehicleCombo.model = selected
            if (selected.length > 0) {
                // 如果当前配置车辆不在选中列表中，切换到第一个选中的车辆
                if (selected.indexOf(currentConfigVehicle) === -1) {
                    loadVehicleParameters(selected[0])
                } else {
                    // 更新下拉框的当前索引
                    currentVehicleCombo.currentIndex = selected.indexOf(currentConfigVehicle)
                }
            } else {
                currentConfigVehicle = ""
            }
        }
    }
    
    function loadVehicleParameters(vehicleId) {
        if (!vehicleParameters[vehicleId]) {
            // 如果没有该车辆的参数，创建默认参数
            vehicleParameters[vehicleId] = {
                attackType: 0,
                attackMethod: 0,
                duration: 60,
                frequency: 10,
                intensity: 5,
                range: 50,
                delay: 100,
                packetLoss: 5
            }
        }
        
        var params = vehicleParameters[vehicleId]
        
        // 更新UI控件的值
        if (attackTypeCombo) attackTypeCombo.currentIndex = params.attackType
        if (attackMethodCombo) attackMethodCombo.currentIndex = params.attackMethod
        if (durationSlider) durationSlider.value = params.duration
        if (frequencySlider) frequencySlider.value = params.frequency
        if (intensitySlider) intensitySlider.value = params.intensity
        if (rangeSlider) rangeSlider.value = params.range
        if (delaySlider) delaySlider.value = params.delay
        if (packetLossSlider) packetLossSlider.value = params.packetLoss
        
        currentConfigVehicle = vehicleId
    }
    
    function saveCurrentVehicleParameters() {
        if (!currentConfigVehicle) return
        
        vehicleParameters[currentConfigVehicle] = {
            attackType: attackTypeCombo ? attackTypeCombo.currentIndex : 0,
            attackMethod: attackMethodCombo ? attackMethodCombo.currentIndex : 0,
            duration: durationSlider ? durationSlider.value : 60,
            frequency: frequencySlider ? frequencySlider.value : 10,
            intensity: intensitySlider ? intensitySlider.value : 5,
            range: rangeSlider ? rangeSlider.value : 50,
            delay: delaySlider ? delaySlider.value : 100,
            packetLoss: packetLossSlider ? packetLossSlider.value : 5
        }
    }
    
    // 设置默认夜间模式
    Component.onCompleted: {
        FluTheme.darkMode = FluThemeType.Dark
    }
    
    // 车辆表格数据
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
    

    // 顶部区域 - 使用FluAppBar内部构建的最大最小化等等按钮
    FluAppBar {
        id: topArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        title: "车辆网络拓扑"  // 使用本地车辆ID属性
        titleFontSize: 25  // 设置标题字体大小
        showDark: true
        showClose: true
        showMinimize: true
        showMaximize: true
        showStayTop: ture
        titleVisible: true  // 显示标题
        textColor: Theme.primaryTextColor
        iconSize: 35
        // 自定义用户信息区域
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.layoutStandardbuttons.left
            anchors.rightMargin: 20
            spacing: 15
            
            // 用户信息组件
            UserConfigsetting {
                id: otherRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
            }
        }
    }
    
    // 主要内容区域
    Item {
        id: mainContentArea
        anchors.top: topArea.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        
        // 右侧攻击设置区域
        Rectangle {
            id: attackSettingArea
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 520
            color: "#0f0f0f"
            border.color: "#333333"
            border.width: 1
            radius: 10

            // 使用Column垂直布局统一管理所有攻击设置组件
            Column{
                id:contentColumn
                
                anchors.fill: parent
                anchors.margins: 15
                spacing: 12
                
                // 标题区域
                Rectangle {
                    width: parent.width
                    height: 50
                    color: "transparent"
                    border.color: "#00ffff"
                    border.width: 0
                    radius: 8
                    
                    Text {
                        anchors.centerIn: parent
                        text: "车辆队列链路攻击控制台"
                        color: "white"
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                

                // 攻击配置和参数设置（合并后的攻击页面）
                Rectangle {
                    id: attackConfigSection
                    width: parent.width
                    height: parent.height - attackEffectSection.height - 120
                    color: "#1a1a1a"
                    border.color: "#555555"
                    border.width: 1
                    radius: 8
                    
                    Flickable {
                        id: attackConfigFlickable
                        anchors.fill: parent
                        anchors.margins: 12
                        contentHeight: attackConfigColumn.height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true
                        ScrollBar.vertical: FluScrollBar {
                            id: attackConfigScrollBar
                        }
                        
                        Column {
                            id: attackConfigColumn
                            width: parent.width
                            spacing: 10
                        
                        // Text {
                        //     text: "攻击配置和参数设置"
                        //     color: "#00ffff"
                        //     font.pixelSize: 16
                        //     font.bold: true
                        // }
                        
                        // 攻击模式设置部分
                        Column {
                            width: parent.width
                            spacing: 8
                            
                           
                            
                            // 攻击目标类型选择
                            Row {
                                width: parent.width
                                spacing: 15
                                Text {
                                    text: "攻击模式设置"
                                    color: "#00ffff"
                                    font.pixelSize: 16
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter

                                }
                                Item{
                                    width: parent.width - 70 - 140 - 140
                                    height: 35
                                }
                                Text {
                                    text: "攻击目标:"
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    width: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluComboBox {
                                    id: attackTargetTypeCombo
                                    width: 140
                                    model: ["SINGLE", "MULTIPLE", "ALL"]
                                    currentIndex: 0
                                    onCurrentIndexChanged: {
                                        if (currentIndex === 1) { // MULTIPLE
                                            vehicleSelectionArea.visible = true
                                            currentVehicleTitle.visible = true
                                        }else if(currentIndex===2) { // ALL
                                            vehicleSelectionArea.visible = false
                                            currentVehicleTitle.visible = true
                                        }
                                        else {
                                            vehicleSelectionArea.visible = false
                                            currentVehicleTitle.visible = false
                                        }
                                    }
                                }
                                
                               
                            }
                            
                            // 车辆选择区域（仅在MULTIPLE模式下显示）
                            Rectangle {
                                id: vehicleSelectionArea
                                width: parent.width
                                height: visible ? 80 : 0
                                color: "#2a2a2a"
                                border.color: "#555555"
                                border.width: 1
                                radius: 4
                                visible: false
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8
                                    
                                    Text {
                                        text: "选择攻击车辆节点:"
                                        color: "#00ffff"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    
                                    Flow {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Repeater {
                                            model: ["Car001", "Car002", "Car003", "Car004", "Car005"]
                                            
                                            FluCheckBox {
                                                text: modelData
                                                checked: index < 3 // 默认选中前3个
                                                onCheckedChanged: {
                                                    // 更新选中的车辆列表
                                                    updateSelectedVehicles()
                                                    
                                                    // 如果当前车辆被取消选择，切换到第一个选中的车辆
                                                    if (!checked && currentConfigVehicle === modelData) {
                                                        var firstSelected = ""
                                                        for (var i = 0; i < 5; i++) {
                                                            var checkbox = parent.children[i]
                                                            if (checkbox.checked) {
                                                                firstSelected = checkbox.text
                                                                break
                                                            }
                                                        }
                                                        if (firstSelected !== "") {
                                                            loadVehicleParameters(firstSelected)
                                                        }
                                                    }
                                                    
                                                    // 如果是新选中的车辆且当前没有配置车辆，设为当前配置车辆
                                                    if (checked && currentConfigVehicle === "") {
                                                        loadVehicleParameters(modelData)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 当前配置车辆标题
                            Rectangle {
                                id: currentVehicleTitle
                                width: parent.width
                                height: visible ? 35 : 0
                                color: "#333333"
                                border.color: "#00ffff"
                                border.width: 1
                                radius: 4
                                visible: false
                                
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 10
                                    
                                    Text {
                                        text: "当前配置车辆:"
                                        color: "#ffffff"
                                        font.pixelSize: 13
                                        font.bold:true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    
                                    FluComboBox {
                                        id: currentVehicleCombo
                                        width: 120
                                        model: selectedVehicles
                                        currentIndex: 0
                                        onCurrentIndexChanged: {
                                            // 切换车辆时加载对应的参数配置
                                            if (model.length > 0 && currentIndex >= 0) {
                                                loadVehicleParameters(model[currentIndex])
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        text: "的攻击参数"
                                        color: "#ffffff"
                                        font.pixelSize: 13
                                        font.bold: true
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                            
                            // 攻击类型和方式
                            Row {
                                width: parent.width
                                spacing: 15
                                
                                Text {
                                    text: "攻击类型:"
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    width: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluComboBox {
                                    id: attackTypeCombo
                                    width: 140
                                    model: ["DDoS攻击", "重放攻击","欺骗攻击" , "混合攻击" ]
                                    currentIndex: 0
                                    onCurrentIndexChanged: {
                                        if (attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1) {
                                            saveCurrentVehicleParameters()
                                        }
                                    }
                                }
                                
                                Text {
                                    text: "攻击方式:"
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    width: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluComboBox {
                                    id: attackMethodCombo
                                    width: 140
                                    model: ["持续攻击", "间歇攻击", "突发攻击"]
                                    currentIndex: 0
                                    onCurrentIndexChanged: {
                                        if (attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1) {
                                            saveCurrentVehicleParameters()
                                        }
                                    }
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 15
                                
                                Text {
                                    text: "攻击对象:"
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    width: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluComboBox {
                                    id: attackObjectCombo
                                    width: 140
                                    model: ["所有链路", "单独链路", "多条链路"]
                                    currentIndex: 0
                                }

                                Text {
                                    text: "优先级:"
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    width: 70
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluComboBox {
                                    width: 140
                                    model: ["高", "中", "低", "紧急"]
                                    currentIndex: 1
                                }
                            }
                        }
                        
                        // 高级攻击参数设置部分
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            // 当前配置车辆标题
                            Rectangle {
                                width: parent.width
                                height: 35
                                color: "#2a2a2a"
                                border.color: "#444444"
                                border.width: 1
                                radius: 5
                                // visible: attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1 && currentConfigVehicle !== ""
                                visible:false
                                Text {
                                    anchors.centerIn: parent
                                    text: "当前配置车辆: " + currentConfigVehicle
                                    color: "#00ff00"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: "高级攻击参数设置"
                                color: "#00ffff"
                                font.pixelSize: 16
                                font.bold: true
                            }
                            
                            // 攻击时长和频率
                            Row {
                                width: parent.width
                                spacing: 15
                                // 攻击时长
                                Column {
                                    width: (parent.width - 15) / 2
                                    spacing: 5
                                    
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Text {
                                            text: "攻击时长:"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            width: 60
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        FluTextBox {
                                            id: durationInput
                                            width: 70
                                            height: 28
                                            text: durationSlider.value.toString()
                                            placeholderText: "10-300"
                                            validator: IntValidator { bottom: 10; top: 300 }
                                            onTextChanged: {
                                                var newValue = parseInt(text)
                                                if (!isNaN(newValue) && newValue >= 10 && newValue <= 300) {
                                                    durationSlider.value = newValue
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            text: "s"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    FluSlider {
                                        id: durationSlider
                                        width: parent.width
                                        from: 10
                                        to: 300
                                        value: 60
                                        stepSize: 10
                                        onValueChanged: {
                                            durationInput.text = value.toString()
                                            if (attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1) {
                                                saveCurrentVehicleParameters()
                                            }
                                        }
                                    }
                                }
                                // 攻击频率设置
                                Column {
                                    width: (parent.width - 15) / 2
                                    spacing: 5
                                    
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Text {
                                            text: "攻击频率:"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            width: 60
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        FluTextBox {
                                            id: frequencyInput
                                            width: 70
                                            height: 28
                                            text: frequencySlider.value.toString()
                                            placeholderText: "1-100"
                                            validator: IntValidator { bottom: 1; top: 100 }
                                            onTextChanged: {
                                                var newValue = parseInt(text)
                                                if (!isNaN(newValue) && newValue >= 1 && newValue <= 100) {
                                                    frequencySlider.value = newValue
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            text: "次/s"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    FluSlider {
                                        id: frequencySlider
                                        width: parent.width
                                        from: 1
                                        to: 100
                                        value: 10
                                        stepSize: 1
                                        onValueChanged: {
                                            frequencyInput.text = value.toString()
                                            if (attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1) {
                                                saveCurrentVehicleParameters()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 攻击强度和覆盖范围
                            Row {
                                width: parent.width
                                spacing: 15
                                
                                Column {
                                    width: (parent.width - 15) / 2
                                    spacing: 5
                                    
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Text {
                                            text: "攻击强度:"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            width: 60
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        FluTextBox {
                                            id: intensityInput
                                            width: 70
                                            height: 28
                                            text: intensitySlider.value.toString()
                                            placeholderText: "1-10"
                                            validator: IntValidator { bottom: 1; top: 10 }
                                            onTextChanged: {
                                                var newValue = parseInt(text)
                                                if (!isNaN(newValue) && newValue >= 1 && newValue <= 10) {
                                                    intensitySlider.value = newValue
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            text: "级别"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    FluSlider {
                                        id: intensitySlider
                                        width: parent.width
                                        from: 1
                                        to: 10
                                        value: 5
                                        stepSize: 1
                                        onValueChanged: {
                                            intensityInput.text = value.toString()
                                            if (attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1) {
                                                saveCurrentVehicleParameters()
                                            }
                                        }
                                    }
                                }
                                
                                Column {
                                    width: (parent.width - 15) / 2
                                    spacing: 5
                                    
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Text {
                                            text: "覆盖范围:"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            width: 60
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        FluTextBox {
                                            id: rangeInput
                                            width: 70
                                            height: 28
                                            text: rangeSlider.value.toString()
                                            placeholderText: "10-100"
                                            validator: IntValidator { bottom: 10; top: 100 }
                                            onTextChanged: {
                                                var newValue = parseInt(text)
                                                if (!isNaN(newValue) && newValue >= 10 && newValue <= 100) {
                                                    rangeSlider.value = newValue
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            text: "%"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    FluSlider {
                                        id: rangeSlider
                                        width: parent.width
                                        from: 10
                                        to: 100
                                        value: 50
                                        stepSize: 5
                                        onValueChanged: {
                                            rangeInput.text = value.toString()
                                            if (attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1) {
                                                saveCurrentVehicleParameters()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // // 延迟注入和丢包率
                            Row {
                                width: parent.width
                                spacing: 15
                                
                                Column {
                                    width: (parent.width - 15) / 2
                                    spacing: 5
                                    
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Text {
                                            text: "延迟注入:"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            width: 60
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        FluTextBox {
                                            id: delayInput
                                            width: 70
                                            height: 28
                                            text: delaySlider.value.toString()
                                            placeholderText: "0-1000"
                                            validator: IntValidator { bottom: 0; top: 1000 }
                                            onTextChanged: {
                                                var newValue = parseInt(text)
                                                if (!isNaN(newValue) && newValue >= 0 && newValue <= 1000) {
                                                    delaySlider.value = newValue
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            text: "ms"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    FluSlider {
                                        id: delaySlider
                                        width: parent.width
                                        from: 0
                                        to: 1000
                                        value: 100
                                        stepSize: 10
                                        onValueChanged: {
                                            delayInput.text = value.toString()
                                        }
                                    }
                                }
                                
                                Column {
                                    width: (parent.width - 15) / 2
                                    spacing: 5
                                    
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Text {
                                            text: "丢包率:"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            width: 60
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        FluTextBox {
                                            id: packetLossInput
                                            width: 70
                                            height: 28
                                            text: packetLossSlider.value.toString()
                                            placeholderText: "0-50"
                                            validator: IntValidator { bottom: 0; top: 50 }
                                            onTextChanged: {
                                                var newValue = parseInt(text)
                                                if (!isNaN(newValue) && newValue >= 0 && newValue <= 50) {
                                                    packetLossSlider.value = newValue
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            text: "%"
                                            color: "#ffffff"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                    
                                    FluSlider {
                                        id: packetLossSlider
                                        width: parent.width
                                        from: 0
                                        to: 50
                                        value: 5
                                        stepSize: 1
                                        onValueChanged: {
                                            packetLossInput.text = value.toString()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // 链路选择和队列参数
                        Column {
                            width: parent.width
                            spacing: 8
                            
                            Row {
                                width: parent.width
                                spacing: 10
                                
                                Text {
                                    text: "源节点:"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    width: 50
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluTextBox {
                                    width: 80
                                    placeholderText: "V00"
                                    text: "V00"
                                }
                                
                                Text {
                                    text: "目标节点:"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    width: 50
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluTextBox {
                                    width: 80
                                    placeholderText: "V01"
                                    text: "V01"
                                }
                                
                                Text {
                                    text: "队列长度:"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    width: 50
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluTextBox {
                                    width: 60
                                    placeholderText: "5"
                                    text: "5"
                                }
                            }
                            
                            Row {
                                width: parent.width
                                spacing: 15
                                
                                Text {
                                    text: "攻击模式:"
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    width: 80
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluComboBox {
                                    width: 120
                                    model: ["单点攻击", "链式攻击", "广播攻击", "随机攻击"]
                                    currentIndex: 0
                                }
                                
                                FluToggleButton {
                                    text: "智能模式"
                                    width: 100
                                    height: 30
                                    checked: false
                                }
                                
                                FluToggleButton {
                                    text: "隐蔽模式"
                                    width: 100
                                    height: 30
                                    checked: true
                                }
                            }
                        }
                        
                        // 参数控制按钮区域
                        Rectangle {
                            width: parent.width
                            height: 60
                            color: "transparent"
                            border.width: 0
                            
                            Item {
                                width: parent.width
                                height: 50
                                
                                FluButton {
                                    text: "重置参数"
                                    width: 120
                                    height: 45
                                    anchors.left: parent.horizontalCenter
                                    anchors.leftMargin: -127.5  // -(120*2 + 15)/2 = -127.5
                                    anchors.verticalCenter: parent.verticalCenter
                                    normalColor: "#2d5aa0"
                                    hoverColor: "#3d6bb0"
                                    onClicked: {
                                        // 重置所有滑块到默认值
                                        durationSlider.value = 60
                                        frequencySlider.value = 10
                                        intensitySlider.value = 5
                                        rangeSlider.value = 50
                                        delaySlider.value = 100
                                        packetLossSlider.value = 5
                                    }
                                }
                                
                                FluButton {
                                    text: "应用参数"
                                    width: 120
                                    height: 45
                                    anchors.left: parent.horizontalCenter
                                    anchors.leftMargin: 7.5  // 15/2 = 7.5
                                    anchors.verticalCenter: parent.verticalCenter
                                    normalColor: "#2d5aa0"
                                    hoverColor: "#3d6bb0"
                                    onClicked: {
                                        // 应用当前参数设置
                                        console.log("应用攻击参数设置")
                                    }
                                }
                            }
                        }
                    }
                    }
                }
                
                // 第二部分：攻击效果监控
                Rectangle {
                    id: attackEffectSection
                    width: parent.width
                    height: 380
                    color: "#1a1a1a"
                    border.color: "#555555"
                    border.width: 1
                    radius: 8
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8
                        
                        Text {
                            text: "攻击效果监控"
                            color: "#00ffff"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        // 攻击任务表格
                        FluTableView {
                            width: parent.width
                            height: 160
                            borderColor: "transparent"
                            columnSource: [
                                {
                                    title: "任务ID",
                                    dataIndex: "taskId",
                                    width: 80
                                },
                                {
                                    title: "攻击类型",
                                    dataIndex: "attackType",
                                    width: 100
                                },
                                {
                                    title: "目标",
                                    dataIndex: "target",
                                    width: 90
                                },
                                {
                                    title: "状态",
                                    dataIndex: "status",
                                    width: 80
                                },
                                {
                                    title: "持续时长",
                                    dataIndex: "duration",
                                    width: 100
                                }
                            ]
                            dataSource: [
                                {
                                    taskId: "T001",
                                    attackType: "DDoS",
                                    target: "V00->V01",
                                    status: "执行中",
                                    duration: "30s"
                                },
                                {
                                    taskId: "T002",
                                    attackType: "重放",
                                    target: "V02->V03",
                                    status: "待执行",
                                    duration: "60s"
                                },
                                {
                                    taskId: "T003",
                                    attackType: "干扰",
                                    target: "全队列",
                                    status: "已完成",
                                    duration: "45s"
                                }
                            ]
                        }
                        
                        FluTableView {
                            width: parent.width
                            height: 160
                            borderColor: "transparent"
                            columnSource: [
                                {
                                    title: "链路",
                                    dataIndex: "dataLink",
                                    width: 100
                                },
                                {
                                    title: "丢包率",
                                    dataIndex: "packetLoss",
                                    width: 80
                                },
                                {
                                    title: "延迟(ms)",
                                    dataIndex: "delay",
                                    width: 80
                                },
                                {
                                    title: "错误率",
                                    dataIndex: "errorRate",
                                    width: 80
                                },
                                {
                                    title: "攻击类型",
                                    dataIndex: "attackType",
                                    width: 90
                                },
                                {
                                    title: "影响度",
                                    dataIndex: "impact",
                                    width: 80
                                }
                            ]
                            dataSource: [
                                {
                                    dataLink: "V00->V01",
                                    packetLoss: "5.2%",
                                    delay: "125",
                                    errorRate: "2.1%",
                                    attackType: "DDoS",
                                    impact: "严重"
                                },
                                {
                                    dataLink: "V01->V02",
                                    packetLoss: "3.8%",
                                    delay: "89",
                                    errorRate: "1.5%",
                                    attackType: "重放",
                                    impact: "中等"
                                },
                                {
                                    dataLink: "V02->V03",
                                    packetLoss: "1.2%",
                                    delay: "45",
                                    errorRate: "0.8%",
                                    attackType: "干扰",
                                    impact: "轻微"
                                }
                            ]
                        }
                    }
                }
                //  攻击控制按钮区域 - 与标题同级
                Rectangle {
                    width: parent.width
                    height: 40
                    color:"transparent"
                    
                    FluToggleButton {
                        id: startAttackBtn
                        text: "启动攻击"
                        width: 120
                        height: 40
                        // anchors.top:parent.top
                        anchors.left: parent.horizontalCenter
                        anchors.leftMargin: -205  // -(120*3 + 20*2)/2 = -195
                        anchors.verticalCenter: parent.verticalCenter
                        checked: false
                        normalColor: "#2d5aa0"
                        hoverColor: "#3d6bb0"
                        pressedColor: "#1d4a90"
                        onClicked: {
                            if (checked) {
                                stopAttackBtn.checked = false
                                pauseAttackBtn.checked = false
                            }
                        }
                    }
                    
                    FluToggleButton {
                        id: pauseAttackBtn
                        text: "暂停攻击"
                        width: 120
                        height: 40
                        anchors.left: startAttackBtn.right
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        checked: false
                        normalColor: "#2d5aa0"
                        hoverColor: "#3d6bb0"
                        pressedColor: "#1d4a90"
                        onClicked: {
                            if (checked) {
                                startAttackBtn.checked = false
                            }
                        }
                    }
                    
                    FluToggleButton {
                        id: stopAttackBtn
                        text: "停止攻击"
                        width: 120
                        height: 40
                        anchors.left: pauseAttackBtn.right
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        checked: false
                        normalColor: "#2d5aa0"
                        hoverColor: "#3d6bb0"
                        pressedColor: "#1d4a90"
                        onClicked: {
                            if (checked) {
                                startAttackBtn.checked = false
                                pauseAttackBtn.checked = false
                            }
                        }
                    }
                }  
            }
        }
        
        // 左侧区域 - 分为上下两部分
        Item {
            id: leftColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: attackSettingArea.left
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            
            // 左上车辆网络拓扑图面板
            Item {
                id: vehicleTopologyArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height * 0.6
                
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
                            height: parent.height - 70
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
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
                                        ],
                                        connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                        bezierConnections: []
                                    },
                                    "mode2": {
                                        positions: [
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
                                        ],
                                        connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                        bezierConnections: [{from: 2, to: 5}]
                                    },
                                    "mode3": {
                                        positions: [
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
                                        ],
                                        connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                        bezierConnections: [{from: 2, to: 4}]
                                    },
                                    "mode4": {
                                        positions: [
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
                                        ],
                                        connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                        bezierConnections: [{from: 2, to: 4},{from:2,to:5}]
                                    },
                                    "mode5": {
                                        positions: [
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
                                        ],
                                        connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                        bezierConnections: [{from: 2, to: 1}]
                                    },
                                    "mode6": {
                                        positions: [
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
                                        ],
                                        connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                        bezierConnections: [{from: 2, to: 1}, {from: 2, to: 5}]
                                    },
                                    "mode7": {
                                        positions: [
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
                                        ],
                                        connections: [{from: 0, to: 1}, {from: 1, to: 2}, {from: 2, to: 3}, {from: 3, to: 4}, {from: 4, to: 5}],
                                        bezierConnections: [{from: 2, to: 1}, {from: 2, to: 4}]
                                    },
                                    "mode8": {
                                        positions: [
                                            {x: topplogyMap.width/6 * 0.3, y: topplogyMap.height/2, id: "N"}, {x: topplogyMap.width/6 * 1.3, y: topplogyMap.height/2, id: "i+1"}, {x: topplogyMap.width/6 * 2.3, y: topplogyMap.height/2, id: "i"},
                                            {x: topplogyMap.width/6 * 3.3, y: topplogyMap.height/2, id: "i-1"}, {x: topplogyMap.width/6 * 4.3, y: topplogyMap.height/2, id: "i-2"}, {x: topplogyMap.width/6 * 5.3, y: topplogyMap.height/2, id: "0"}
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
                                
                                // 绘制箭头
                                function drawArrow(ctx, start, end, arrowSize) {
                                    arrowSize = arrowSize || 10
                                    var angle = Math.atan2(end.y - start.y, end.x - start.x)
                                    
                                    ctx.beginPath()
                                    ctx.moveTo(end.x, end.y)
                                    ctx.lineTo(
                                        end.x - arrowSize * Math.cos(angle - Math.PI/6),
                                        end.y - arrowSize * Math.sin(angle - Math.PI/6)
                                    )
                                    ctx.moveTo(end.x, end.y)
                                    ctx.lineTo(
                                        end.x - arrowSize * Math.cos(angle + Math.PI/6),
                                        end.y - arrowSize * Math.sin(angle + Math.PI/6)
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
                                        
                                        ctx.beginPath()
                                        ctx.moveTo(toPos.x + 15, toPos.y + 15)
                                        ctx.lineTo(
                                            (toPos.x + 15) - 8 * Math.cos(angle - Math.PI/6),
                                            (toPos.y + 15) - 8 * Math.sin(angle - Math.PI/6)
                                        )
                                        ctx.moveTo(toPos.x + 15, toPos.y + 15)
                                        ctx.lineTo(
                                            (toPos.x + 15) - 8 * Math.cos(angle + Math.PI/6),
                                            (toPos.y + 15) - 8 * Math.sin(angle + Math.PI/6)
                                        )
                                        ctx.stroke()
                                    }
                                    
                                    // 绘制车辆图标和编号
                                    for (var j = 0; j < vehiclePositions.length; j++) {
                                        var pos = vehiclePositions[j]
                                        
                                        // 检查是否为悬停的车辆
                                        var isHovered = (mouseArea.hoveredVehicleIndex === j)
                                        var vehicleSize = isHovered ? 120 : 80  // 字体图标大小
                                        var backgroundRadius = isHovered ? 60 : 30  // 背景圆也相应放大
                                        
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
            
            // 左下拓扑数据详情区域
            Item {
                id: topologyDataArea
                anchors.top: vehicleTopologyArea.bottom
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
    
    // 车辆数据弹出框
    VehicleDataPopup {
        id: vehicleDataPopup
        
        onApplyClicked: {
            console.log("应用车辆数据设置")
        }
        
        onCancelClicked: {
            console.log("取消车辆数据设置")
        }
    }
}
