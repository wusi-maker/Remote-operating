import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI
import "../rightPage"
import "../title"
import "../style"
import "../Network"


// 科技感仪表盘界面
Rectangle {
    id: techDashboard
    color: Theme.backgroundColor
    
    // 攻击数据模型实例
    AttackDataModel {
        id: attackDataModel
        
        // 在组件完成时初始化车辆参数
        Component.onCompleted: {
            initializeVehicleParameters(vehicleNames)
        }
    }
    
    // 全局车辆名称列表 - 可统一修改和调用
    // 车辆名称和选择状态
    property var vehicleNames: ["Car001", "Car002", "Car003", "Car004", "Car005"]
    property var vehicleSelectionStates: [1, 1, 1, 0, 0] // 1表示勾选，0表示未勾选，默认前3个勾选
    
    // 全局攻击JSON数据存储
    property string globalAttackJsonString: ""
    property var globalAttackJsonData: null
    
    // 根据选择状态动态生成可用车辆列表
    property var globalVehicleNames: {
        var result = []
        for (var i = 0; i < vehicleNames.length; i++) {
            if (vehicleSelectionStates[i] === 1) {
                result.push(vehicleNames[i])
            }
        }
        return result
    }
    
    // 公有属性：拓扑模式
    property string topologyMode: "mode1"
    
    // 多车辆攻击配置相关属性
    property var selectedVehicles: attackDataModel.attackTarget.selectedNodes
    property var selectedAttackModes: [] // 将通过attackComposition动态计算
    property string currentConfigVehicle: selectedVehicles.length > 0 ? selectedVehicles[0] : ""
    
    // 从AttackDataModel获取车辆参数的函数
    function getVehicleParameters(vehicleId) {
        var nodeParams = attackDataModel.getNodeAttackParameters(vehicleId)
        if (nodeParams) {
            return {
                attackType: getAttackTypeIndex(nodeParams.attackType),
                attackMethod: getAttackMethodIndex(nodeParams.attackMethod),
                duration: nodeParams.attackParameters.duration,
                frequency: nodeParams.attackParameters.frequency,
                intensity: nodeParams.attackParameters.intensity,
                range: 50, // 默认值，AttackDataModel中没有此字段
                delay: nodeParams.attackParameters.delayInjection,
                packetLoss: nodeParams.attackParameters.expectedPacketLossRatio * 100
            }
        }
        // 返回默认参数
        return {
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
    
    // 攻击类型映射函数
    function getAttackTypeIndex(attackType) {
        switch(attackType) {
            case "DDoS": return 0
            case "REPLAY": return 1
            case "SPOOFING": return 2
            case "MIXED": return 3
            case "SINGLE": return 0  // 添加SINGLE类型映射
            default: return 0
        }
    }
    
    function getAttackMethodIndex(attackMethod) {
        switch(attackMethod) {
            case "SUSTAINED": return 0
            case "INTERMITTENT": return 1
            case "BURST": return 2
            default: return 0
        }
    }
    
    // JavaScript函数
    function updateSelectedVehicles() {
        var selected = []
        
        // 根据vehicleSelectionStates直接生成选中的车辆列表
        for (var i = 0; i < vehicleNames.length; i++) {
            if (vehicleSelectionStates[i] === 1) {
                selected.push(vehicleNames[i])
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
        var params = getVehicleParameters(vehicleId)
        
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
        if (!currentConfigVehicle) {
            console.log("saveCurrentVehicleParameters: currentConfigVehicle is empty")
            return
        }
        
        console.log("saveCurrentVehicleParameters: currentConfigVehicle =", currentConfigVehicle)
        
        // 获取当前UI控件的值
        var newParams = {
            attackType: attackTypeCombo ? attackTypeCombo.currentIndex : 0,
            attackMethod: attackMethodCombo ? attackMethodCombo.currentIndex : 0,
            duration: durationSlider ? durationSlider.value : 60,
            frequency: frequencySlider ? frequencySlider.value : 10,
            intensity: intensitySlider ? intensitySlider.value : 5,
            range: rangeSlider ? rangeSlider.value : 50,
            delay: delaySlider ? delaySlider.value : 100,
            packetLoss: packetLossSlider ? packetLossSlider.value : 5
        }
        
        console.log("saveCurrentVehicleParameters: newParams =", JSON.stringify(newParams))
        
        // 更新AttackDataModel中的数据
        var nodeParams = attackDataModel.getNodeAttackParameters(currentConfigVehicle)
        if (nodeParams) {
            console.log("saveCurrentVehicleParameters: found nodeParams for", currentConfigVehicle)
            
            // 更新攻击类型
            var attackTypeStr = getAttackTypeString(newParams.attackType)
            attackDataModel.updateNodeAttackParameter(currentConfigVehicle, "attackType", attackTypeStr)
            
            // 更新攻击方法
            var attackMethodStr = getAttackMethodString(newParams.attackMethod)
            attackDataModel.updateNodeAttackParameter(currentConfigVehicle, "attackMethod", attackMethodStr)
            
            // 更新攻击参数 - 逐个更新属性而不是替换整个对象
            for (var i = 0; i < attackDataModel.nodeAttackParameters.count; i++) {
                var item = attackDataModel.nodeAttackParameters.get(i);
                if (item.nodeSelection === currentConfigVehicle) {
                    console.log("saveCurrentVehicleParameters: updating parameters for", currentConfigVehicle, "at index", i)
                    console.log("saveCurrentVehicleParameters: BEFORE update - duration:", item.attackParameters.duration, "delayInjection:", item.attackParameters.delayInjection)
                    
                    // 创建新的攻击参数对象
                    var newAttackParams = {
                        "duration": newParams.duration,
                        "frequency": newParams.frequency,
                        "intensity": newParams.intensity,
                        "delayInjection": newParams.delay,
                        "expectedPacketLossRatio": newParams.packetLoss / 100
                    }
                    
                    // 使用setProperty方法更新整个attackParameters对象
                    attackDataModel.nodeAttackParameters.setProperty(i, "attackParameters", newAttackParams)
                    
                    // 验证更新后的值
                    var updatedItem = attackDataModel.nodeAttackParameters.get(i);
                    console.log("saveCurrentVehicleParameters: AFTER update - duration:", updatedItem.attackParameters.duration, "delayInjection:", updatedItem.attackParameters.delayInjection)
                    console.log("saveCurrentVehicleParameters: updated delayInjection to", newParams.delay)
                    break;
                }
            }
        } else {
            console.log("saveCurrentVehicleParameters: nodeParams not found for", currentConfigVehicle)
        }
    }
    
    // 攻击类型反向映射函数
    function getAttackTypeString(index) {
        switch(index) {
            case 0: return "DDoS"
            case 1: return "REPLAY" // 重放攻击
            case 2: return "SPOOFING"
            case 3: return "MIXED"
            default: return "DDoS"
        }
    }
    
    // 根据攻击目标类型获取攻击类型字符串
    function getAttackTypeByTargetType(targetTypeIndex) {
        switch(targetTypeIndex) {
            case 0: return "SINGLE"  // SINGLE模式
            case 1: return "MULTIPLE" // MULTIPLE模式
            case 2: return "ALL"     // ALL模式
            default: return "SINGLE"
        }
    }
    
    function getAttackMethodString(index) {
        switch(index) {
            case 0: return "SUSTAINED"
            case 1: return "INTERMITTENT"
            case 2: return "BURST"
            default: return "SUSTAINED"
        }
    }
    
    // 更新所有选中车辆的参数（ALL模式）
    function updateAllSelectedVehiclesParameter(paramName, value) {
        for (var i = 0; i < attackDataModel.nodeAttackParameters.count; i++) {
            var item = attackDataModel.nodeAttackParameters.get(i);
            if (vehicleSelectionStates[i] === 1) { // 只更新选中的车辆
                switch(paramName) {
                    case "duration":
                        item.attackParameters.duration = value
                        break
                    case "frequency":
                        item.attackParameters.frequency = value
                        break
                    case "intensity":
                        item.attackParameters.intensity = value
                        break
                    case "range":
                        // range不在attackParameters中，可能需要特殊处理
                        break
                    case "delay":
                        item.attackParameters.delayInjection = value
                        break
                    case "packetLoss":
                        item.attackParameters.expectedPacketLossRatio = value / 100
                        break
                }
            }
        }
    }
    
    function updateSelectedAttackModes() {
        var selected = []
        var attackModes = ["DDoS攻击", "重放攻击", "欺骗攻击"]
        
        // 从AttackDataModel获取当前车辆的攻击组成信息
        if (currentConfigVehicle) {
            var nodeParams = attackDataModel.getNodeAttackParameters(currentConfigVehicle)
            if (nodeParams && nodeParams.attackComposition) {
                var composition = nodeParams.attackComposition
                
                // 根据attackComposition确定选中的攻击模式
                if (composition.ddosEnabled) {
                    selected.push("DDoS攻击")
                }
                if (composition.replayEnabled) {
                    selected.push("重放攻击")
                }
                if (composition.spoofingEnabled) {
                    selected.push("欺骗攻击")
                }
            }
        }
        
        selectedAttackModes = selected
        
        // 更新UI中的复选框状态
        if (mixedAttackSelectionArea && mixedAttackSelectionArea.children.length > 0) {
            var column = mixedAttackSelectionArea.children[0]
            if (column && column.children && column.children.length > 0) {
                for (var i = 0; i < column.children.length && i < attackModes.length; i++) {
                    var checkbox = column.children[i]
                    if (checkbox && checkbox.text && checkbox.checked !== undefined) {
                        checkbox.checked = selected.indexOf(attackModes[i]) !== -1
                    }
                }
            }
        }
        
        // 根据选中的攻击模式更新攻击类型下拉框
        if (attackTypeCombo) {
            if (selected.length === 0) {
                // 没有选中任何攻击模式，保持当前下拉框状态
            } else if (selected.length === 1) {
                // 选中单个攻击模式，下拉框显示对应类型
                var singleAttackIndex = attackModes.indexOf(selected[0])
                if (singleAttackIndex !== -1) {
                    attackTypeCombo.currentIndex = singleAttackIndex
                }
            } else {
                // 选中多个攻击模式，下拉框显示混合攻击
                attackTypeCombo.currentIndex = 3 // 混合攻击是第4个选项（索引3）
            }
        }
        
        console.log("选中的攻击模式:", selected)
    }
    
    // 处理攻击类型下拉框选择变化
    function updateAttackTypeSelection(selectedIndex) {
        var attackModes = ["DDoS攻击", "重放攻击", "欺骗攻击"]
        
        if (!currentConfigVehicle) return
        
        // 更新AttackDataModel中的攻击组成
        var composition = {
            ddosEnabled: false,
            replayEnabled: false,
            spoofingEnabled: false
        }
        
        if (selectedIndex >= 0 && selectedIndex < 3) {
            // 选择了具体的攻击类型，只启用对应的攻击模式
            switch(selectedIndex) {
                case 0: composition.ddosEnabled = true; break
                case 1: composition.replayEnabled = true; break
                case 2: composition.spoofingEnabled = true; break
            }
        } else if (selectedIndex === 3) {
            // 选择了混合攻击，检查当前复选框状态
            if (mixedAttackSelectionArea && mixedAttackSelectionArea.children.length > 0) {
                var column = mixedAttackSelectionArea.children[0]
                if (column && column.children && column.children.length > 0) {
                    var hasChecked = false
                    for (var j = 0; j < column.children.length && j < attackModes.length; j++) {
                        var cb = column.children[j]
                        if (cb && cb.text && cb.checked !== undefined && cb.checked) {
                            hasChecked = true
                            switch(j) {
                                case 0: composition.ddosEnabled = true; break
                                case 1: composition.replayEnabled = true; break
                                case 2: composition.spoofingEnabled = true; break
                            }
                        }
                    }
                    
                    if (!hasChecked) {
                        // 默认选中前两个
                        composition.ddosEnabled = true
                        composition.replayEnabled = true
                        for (var k = 0; k < Math.min(2, column.children.length, attackModes.length); k++) {
                            var defaultCb = column.children[k]
                            if (defaultCb && defaultCb.text && defaultCb.checked !== undefined) {
                                defaultCb.checked = true
                            }
                        }
                    }
                }
            }
        }
        
        // 更新AttackDataModel中的攻击组成
        attackDataModel.updateNodeAttackParameter(currentConfigVehicle, "attackComposition", composition)
        
        // 更新UI中的复选框状态
        if (mixedAttackSelectionArea && mixedAttackSelectionArea.children.length > 0) {
            var column = mixedAttackSelectionArea.children[0]
            if (column && column.children && column.children.length > 0) {
                for (var i = 0; i < column.children.length && i < attackModes.length; i++) {
                    var checkbox = column.children[i]
                    if (checkbox && checkbox.text && checkbox.checked !== undefined) {
                        switch(i) {
                            case 0: checkbox.checked = composition.ddosEnabled; break
                            case 1: checkbox.checked = composition.replayEnabled; break
                            case 2: checkbox.checked = composition.spoofingEnabled; break
                        }
                    }
                }
            }
        }
        
        // 更新selectedAttackModes属性
        updateSelectedAttackModes()
    }

    
    // 设置默认夜间模式
    Component.onCompleted: {
        FluTheme.darkMode = FluThemeType.Dark
    }

    

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
        showStayTop: true
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
    Rectangle {
        id: separatorLine
        anchors.top: topArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        height: 1
        color: Theme.progressColor
    }
    
    // 主要内容区域
    Item {
        id: mainContentArea
        anchors.top: separatorLine.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        
        // 左侧攻击设置区域 - 占据完整高度
        Rectangle {
            id: attackSettingArea
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 20
            width: parent.width * 0.3
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

                // 标签切换区域
                Rectangle {
                    width: parent.width
                    height: parent.height - 50
                    color: "transparent"
                    
                    FluTabView {
                        id: attackTabView
                        anchors.fill: parent
                        addButtonVisibility: false
                        
                        Component.onCompleted: {
                            // 添加车辆攻击标签页
                            appendTab(FluentIcons.Car, "车辆攻击", vehicleAttackPage, {})
                            // 添加传感器攻击标签页
                            appendTab(FluentIcons.Radar, "传感器攻击", sensorAttackPage, {})
                        }
                    }
                    
                    // 车辆攻击页面组件
                    Component {
                        id: vehicleAttackPage
                        
                        // 攻击配置和参数设置（合并后的攻击页面）
                        Rectangle {
                            id: vehicleAttackConfigSection
                            anchors.fill: parent
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
                                  
                                    
                                        // 攻击模式设置部分
                                        Column {
                                            width: parent.width
                                            spacing: 8
                                            
                                        
                                            
                                            // 攻击目标类型选择
                                            Row {
                                                width: parent.width
                                                spacing: 8
                                                Text {
                                                    text: "攻击模式设置"
                                                    color: "#00ffff"
                                                    font.pixelSize: 16
                                                    font.bold: true
                                                    anchors.verticalCenter: parent.verticalCenter

                                                }
                                                Item{
                                                    width: parent.width - 70 - 140 - 180
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
                                                    width: 190
                                                    model: ["SINGLE", "MULTIPLE", "ALL"]
                                                    currentIndex: 0
                                                    onCurrentIndexChanged: {
                                                        if (currentIndex === 1) { // MULTIPLE
                                                            vehicleSelectionArea.visible = true
                                                            currentVehicleTitle.visible = true
                                                        }else if(currentIndex===2) { // ALL
                                                            vehicleSelectionArea.visible = true
                                                            currentVehicleTitle.visible = true
                                                            // 在ALL模式下，选中所有车辆
                                                            for (var i = 0; i < vehicleSelectionArea.children[0].children[1].children[0].count; i++) {
                                                                var checkbox = vehicleSelectionArea.children[0].children[1].children[0].itemAt(i)
                                                                if (checkbox) {
                                                                    checkbox.checked = true
                                                                }
                                                            }
                                                        }
                                                        else {
                                                            vehicleSelectionArea.visible = false
                                                            currentVehicleTitle.visible = true  // 默认开启，因为无论是单个车辆还是所有车辆都需要选择设置的车辆编号
                                                        }
                                                    }
                                                }
                                                
                                            
                                            }
                                            
                                            // 车辆选择区域（仅在MULTIPLE模式下显示）
                                            Rectangle {
                                                id: vehicleSelectionArea
                                                width: parent.width-10
                                                anchors.left: parent.left
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
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        
                                                        Repeater {
                                                            model: vehicleNames
                                                            
                                                            FluCheckBox {
                                                                text: modelData
                                                                // 当选择为ALL的时候直接将状态数组设置为全一
                                                                checked: attackTargetTypeCombo.currentIndex === 2 ? true : (vehicleSelectionStates[index] === 1) // ALL模式下全选，否则根据状态数组
                                                                enabled: attackTargetTypeCombo.currentIndex !== 2 // 在ALL模式下禁用
                                                                onCheckedChanged: {
                                                                    // 在ALL模式下不允许取消勾选
                                                                    if (attackTargetTypeCombo.currentIndex === 2 && !checked) {
                                                                        checked = true
                                                                        return
                                                                    }
                                                                    
                                                                    // 更新车辆选择状态
                                                                    var newStates = vehicleSelectionStates.slice() // 复制数组
                                                                    newStates[index] = checked ? 1 : 0
                                                                    vehicleSelectionStates = newStates
                                                                    
                                                                    // 重新计算globalVehicleNames
                                                                    var result = []
                                                                    for (var i = 0; i < vehicleNames.length; i++) {
                                                                        if (vehicleSelectionStates[i] === 1) {
                                                                            result.push(vehicleNames[i])
                                                                        }
                                                                    }
                                                                    globalVehicleNames = result
                                                                    
                                                                    // 更新选中的车辆列表
                                                                    updateSelectedVehicles()
                                                                    
                                                                    // 如果当前车辆被取消选择，切换到第一个选中的车辆
                                                                    if (!checked && currentConfigVehicle === modelData) {
                                                                        var firstSelected = ""
                                                                        for (var j = 0; j < vehicleNames.length; j++) {
                                                                            if (vehicleSelectionStates[j] === 1) {
                                                                                firstSelected = vehicleNames[j]
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
                                                width: parent.width-10
                                                anchors.left: parent.left
                                                height: visible ? 35 : 0
                                                color: "#333333"
                                                border.color: "#00ffff"
                                                border.width: 1
                                                radius: 4
                                                visible: true
                                                
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
                                            
                                            // 攻击类型和方式水平布局
                                            Row {
                                                width: parent.width
                                                spacing: 10
                                                
                                                // 左侧：攻击类型区域
                                                Column {
                                                    width: (parent.width - parent.spacing) / 2
                                                    spacing: 8
                                                    
                                                    // 攻击类型选择
                                                    Row {
                                                        width: parent.width
                                                        spacing: 8
                                                        
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
                                                                // 控制混合攻击模式选择区域的显示
                                                                mixedAttackSelectionArea.visible = true // 混合攻击是第4个选项（索引3）
                                                                
                                                                // 调用函数处理下拉框选择变化
                                                                updateAttackTypeSelection(currentIndex)
                                                            }
                                                        }
                                                    }
                                                    
                                                    // 混合攻击模式选择区域（仅在选择混合攻击时显示）
                                                    Rectangle {
                                                        id: mixedAttackSelectionArea
                                                        width: parent.width
                                                        height: 100
                                                        color: "transparent"
                                                        border.color: "#555555"
                                                        border.width: 0
                                                        radius: 4
                                                        visible: true
                                                        
                                                        Column {
                                                            // anchors.centerIn: parent
                                                            anchors.right: parent.right
                                                            anchors.top: parent.top
                                                            anchors.rightMargin:0
                                                            anchors.topMargin: 5
                                                            spacing: 8
                                                            
                                                            Repeater {
                                                                model: ["DDoS攻击", "重放攻击", "欺骗攻击"]
                                                                
                                                                FluCheckBox {
                                                                    text: modelData
                                                                    width: 140  // 与攻击类型下拉框保持一致的宽度
                                                                    height: 20  // 设置合适的高度
                                                                    checked: index < 2 // 默认选中前2个
                                                                    onCheckedChanged: {
                                                                        // 更新AttackDataModel中的攻击组合数据
                                                                        var vehicleId = currentConfigVehicle
                                                                        var nodeParam = attackDataModel.getNodeAttackParameters(vehicleId)
                                                                        if (nodeParam) {
                                                                            if (index === 0) { // DDoS攻击
                                                                                nodeParam.attackComposition.ddosEnabled = checked
                                                                            } else if (index === 1) { // 重放攻击
                                                                                nodeParam.attackComposition.replayEnabled = checked
                                                                            } else if (index === 2) { // 欺骗攻击
                                                                                nodeParam.attackComposition.spoofingEnabled = checked
                                                                            }
                                                                            attackDataModel.updateNodeAttackParameter(vehicleId, nodeParam)
                                                                        }
                                                                        
                                                                        // 更新选中的攻击模式列表
                                                                        updateSelectedAttackModes()
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                // 右侧：攻击方式、攻击对象、优先级区域
                                                Column {
                                                    width: (parent.width - parent.spacing) / 2
                                                    spacing: 15
                                                    
                                                    // 攻击方式组
                                                    Row {
                                                        spacing: 8
                                                        
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
                                                    
                                                    // 攻击对象组
                                                    Row {
                                                        spacing: 8
                                                        
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
                                                    }
                                                    
                                                    // 优先级组
                                                    Row {
                                                        spacing: 8
                                                        
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
                                            }
                                        }
                                        
                                        // 高级攻击参数设置部分
                                        Column {
                                            width: parent.width
                                            spacing: 8
                                            
                                            // 当前配置车辆标题，默认关闭
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
                                                            width: 100
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
                                                            if (attackTargetTypeCombo) {
                                                                if (attackTargetTypeCombo.currentIndex === 0) {
                                                                    // SINGLE模式：保存当前车辆参数
                                                                    saveCurrentVehicleParameters()
                                                                } else if (attackTargetTypeCombo.currentIndex === 2) {
                                                                    // ALL模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("duration", value)
                                                                } else if (attackTargetTypeCombo.currentIndex === 1) {
                                                                    // MULTIPLE模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("duration", value)
                                                                }
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
                                                            width: 100
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
                                                            if (attackTargetTypeCombo) {
                                                                if (attackTargetTypeCombo.currentIndex === 0) {
                                                                    // SINGLE模式：保存当前车辆参数
                                                                    saveCurrentVehicleParameters()
                                                                } else if (attackTargetTypeCombo.currentIndex === 2) {
                                                                    // ALL模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("frequency", value)
                                                                } else if (attackTargetTypeCombo.currentIndex === 1) {
                                                                    // MULTIPLE模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("frequency", value)
                                                                }
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
                                                            width: 100
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
                                                            if (attackTargetTypeCombo) {
                                                                if (attackTargetTypeCombo.currentIndex === 0) {
                                                                    // SINGLE模式：保存当前车辆参数
                                                                    saveCurrentVehicleParameters()
                                                                } else if (attackTargetTypeCombo.currentIndex === 2) {
                                                                    // ALL模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("intensity", value)
                                                                } else if (attackTargetTypeCombo.currentIndex === 1) {
                                                                    // MULTIPLE模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("intensity", value)
                                                                }
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
                                                            width: 100
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
                                                            if (attackTargetTypeCombo) {
                                                                if (attackTargetTypeCombo.currentIndex === 0) {
                                                                    // SINGLE模式：保存当前车辆参数
                                                                    saveCurrentVehicleParameters()
                                                                } else if (attackTargetTypeCombo.currentIndex === 2) {
                                                                    // ALL模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("range", value)
                                                                } else if (attackTargetTypeCombo.currentIndex === 1) {
                                                                    // MULTIPLE模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("range", value)
                                                                }
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
                                                            width: 100
                                                            height: 28
                                                            text: delaySlider.value.toString()
                                                            placeholderText: "0-1000"
                                                            validator: IntValidator { bottom: 0; top: 1000 }
                                                            onTextChanged: {
                                                                var newValue = parseInt(text)
                                                                console.log("delayInput text changed:", text, "newValue:", newValue)
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
                                                            console.log("delaySlider value changed:", value)
                                                            delayInput.text = value.toString()
                                                            if (attackTargetTypeCombo) {
                                                                if (attackTargetTypeCombo.currentIndex === 0) {
                                                                    // SINGLE模式：保存当前车辆参数
                                                                    saveCurrentVehicleParameters()
                                                                } else if (attackTargetTypeCombo.currentIndex === 2) {
                                                                    // ALL模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("delayInjection", value)
                                                                } else if (attackTargetTypeCombo.currentIndex === 1) {
                                                                    // MULTIPLE模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("delayInjection", value)
                                                                }
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
                                                            if (attackTargetTypeCombo) {
                                                                if (attackTargetTypeCombo.currentIndex === 0) {
                                                                    // SINGLE模式：保存当前车辆参数
                                                                    saveCurrentVehicleParameters()
                                                                } else if (attackTargetTypeCombo.currentIndex === 2) {
                                                                    // ALL模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("expectedPacketLossRatio", value)
                                                                } else if (attackTargetTypeCombo.currentIndex === 1) {
                                                                    // MULTIPLE模式：更新所有选中车辆的参数
                                                                    updateAllSelectedVehiclesParameter("expectedPacketLossRatio", value)
                                                                }
                                                            }
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
                                                    anchors.right: applyButton.left
                                                    anchors.rightMargin:15  // -(120*2 + 15)/2 = -127.5
                                                    anchors.verticalCenter: applyButton.verticalCenter
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
                                                        
                                                        // 保存重置后的参数到AttackDataModel
                                                        if (attackTargetTypeCombo && attackTargetTypeCombo.currentIndex === 1) {
                                                            saveCurrentVehicleParameters()
                                                        }
                                                    }
                                                }
                                                
                                                FluButton {
                                                    id: applyButton
                                                    text: "应用参数"
                                                    width: 120
                                                    height: 45
                                                    // anchors.left: parent.horizontalCenter
                                                    // anchors.leftMargin: 7.5  // 15/2 = 7.5
                                                    anchors.centerIn: parent
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    normalColor: "#2d5aa0"
                                                    hoverColor: "#3d6bb0"
                                                    onClicked: {
                                                        // 应用当前参数设置
                                                        console.log("应用攻击参数设置")
                                                        
                                                        // 根据攻击目标类型设置攻击类型
                                                        if (attackTargetTypeCombo) {
                                                            var targetType = getAttackTypeByTargetType(attackTargetTypeCombo.currentIndex)
                                                            console.log("设置攻击类型为:", targetType)
                                                            
                                                            if (attackTargetTypeCombo.currentIndex === 0) { // SINGLE模式
                                                                // 更新所有车辆的攻击类型为SINGLE
                                                                for (var i = 0; i < attackDataModel.nodeAttackParameters.count; i++) {
                                                                    attackDataModel.updateNodeAttackParameter(
                                                                        attackDataModel.nodeAttackParameters.get(i).nodeSelection, 
                                                                        "attackType", 
                                                                        "SINGLE"
                                                                    )
                                                                }
                                                                console.log("已将所有车辆攻击类型设置为SINGLE")
                                                            } else if (attackTargetTypeCombo.currentIndex === 1) { // MULTIPLE模式
                                                                // 只更新选中车辆的攻击类型为MULTIPLE
                                                                for (var j = 0; j < vehicleSelectionStates.length; j++) {
                                                                    if (vehicleSelectionStates[j] === 1) {
                                                                        attackDataModel.updateNodeAttackParameter(
                                                                            vehicleNames[j], 
                                                                            "attackType", 
                                                                            "MULTIPLE"
                                                                        )
                                                                    }
                                                                }
                                                                console.log("已将选中车辆攻击类型设置为MULTIPLE")
                                                            } else if (attackTargetTypeCombo.currentIndex === 2) { // ALL模式
                                                                // 更新所有车辆的攻击类型为ALL
                                                                for (var k = 0; k < attackDataModel.nodeAttackParameters.count; k++) {
                                                                    attackDataModel.updateNodeAttackParameter(
                                                                        attackDataModel.nodeAttackParameters.get(k).nodeSelection, 
                                                                        "attackType", 
                                                                        "ALL"
                                                                    )
                                                                }
                                                                console.log("已将所有车辆攻击类型设置为ALL")
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                FluButton {
                                                    text: "导出数据"
                                                    width: 120
                                                    height: 45
                                                    anchors.left: applyButton.right
                                                    anchors.leftMargin: 15  // 120 + 15 + 7.5 = 142.5
                                                    anchors.verticalCenter: applyButton.verticalCenter
                                                    normalColor: "#2d8a50"
                                                    hoverColor: "#3d9a60"
                                                    onClicked: {
                                                        // 根据当前攻击目标类型导出相应的数据
                                                        var jsonData
                                                        var currentMode = getAttackTypeByTargetType(attackTargetTypeCombo.currentIndex)
                                                        
                                                        if (currentMode === "SINGLE") {
                                                            // SINGLE模式：只导出当前选中的车辆
                                                            jsonData = attackDataModel.exportToJSONByMode("SINGLE", [], currentConfigVehicle)
                                                        } else if (currentMode === "MULTIPLE") {
                                                            // MULTIPLE模式：导出所有选中的车辆
                                                            var selectedVehiclesList = []
                                                            for (var i = 0; i < vehicleSelectionStates.length; i++) {
                                                                if (vehicleSelectionStates[i] === 1) {
                                                                    selectedVehiclesList.push(vehicleNames[i])
                                                                }
                                                            }
                                                            jsonData = attackDataModel.exportToJSONByMode("MULTIPLE", selectedVehiclesList, "")
                                                        } else {
                                                            // ALL模式：导出所有车辆
                                                            jsonData = attackDataModel.exportToJSONByMode("ALL", [], "")
                                                        }
                                                        
                                                        var jsonString = JSON.stringify(jsonData, null, 2)
                                                        
                                                        // 存储到全局变量中
                                                        globalAttackJsonString = jsonString
                                                        globalAttackJsonData = jsonData
                                                        
                                                        jsonDataPopup.jsonText = jsonString
                                                        jsonDataPopup.open()
                                                        
                                                        console.log("导出模式:", currentMode)
                                                        console.log("导出的车辆数量:", jsonData.nodeAttackParameters.length)
                                                        console.log("JSON数据已存储到全局变量")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    
                        
                 
                    
                    // 传感器攻击页面组件
                    Component {
                        id: sensorAttackPage
                        
                        // 传感器攻击配置页面
                        Rectangle {
                            id: sensorAttackConfigSection
                            anchors.fill: parent
                            color: "#1a1a1a"
                            border.color: "#555555"
                            border.width: 1
                            radius: 8
                            
                            Flickable {
                                id: sensorAttackFlickable
                                anchors.fill: parent
                                anchors.margins: 12
                                contentHeight: sensorAttackColumn.height
                                boundsBehavior: Flickable.StopAtBounds
                                clip: true
                                ScrollBar.vertical: FluScrollBar {
                                    id: sensorAttackScrollBar
                                }
                                
                                Column {
                                    id: sensorAttackColumn
                                    width: parent.width
                                    spacing: 10
                                    
                                    // 传感器攻击模式设置部分
                                    Column {
                                        width: parent.width
                                        spacing: 8
                                        
                                        // 传感器攻击目标选择
                                        Row {
                                            width: parent.width
                                            spacing: 8
                                            
                                            Text {
                                                text: "传感器攻击设置"
                                                color: "#00ffff"
                                                font.pixelSize: 16
                                                font.bold: true
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            
                                            Item{
                                                width: parent.width - 70 - 140 - 180
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
                                                id: sensorTargetCombo
                                                width: 190
                                                model: ["GPS传感器", "雷达传感器", "摄像头", "激光雷达", "超声波传感器", "所有传感器"]
                                                currentIndex: 0
                                            }
                                        }
                                        
                                        // 攻击顺序设置
                                        Row {
                                            width: parent.width
                                            spacing: 8
                                            
                                            Text {
                                                text: "攻击顺序:"
                                                color: "#ffffff"
                                                font.pixelSize: 13
                                                width: 70
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            
                                            FluComboBox {
                                                id: attackOrderCombo
                                                width: 140
                                                model: ["顺序攻击", "随机攻击", "同时攻击", "优先级攻击"]
                                                currentIndex: 0
                                            }
                                            
                                            Text {
                                                text: "攻击模式:"
                                                color: "#ffffff"
                                                font.pixelSize: 13
                                                width: 70
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            
                                            FluComboBox {
                                                id: sensorAttackModeCombo
                                                width: 140
                                                model: ["数据篡改", "信号干扰", "物理遮挡", "欺骗攻击"]
                                                currentIndex: 0
                                            }
                                        }
                                    }
                                    
                                    // 传感器攻击参数设置
                                    Column {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Text {
                                            text: "传感器攻击参数设置"
                                            color: "#00ffff"
                                            font.pixelSize: 16
                                            font.bold: true
                                        }
                                        
                                        // 攻击强度和持续时间
                                        Row {
                                            width: parent.width
                                            spacing: 15
                                            
                                            // 攻击强度
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
                                                        id: sensorIntensityInput
                                                        width: 100
                                                        height: 28
                                                        text: sensorIntensitySlider.value.toString()
                                                        placeholderText: "1-10"
                                                        validator: IntValidator { bottom: 1; top: 10 }
                                                        onTextChanged: {
                                                            var newValue = parseInt(text)
                                                            if (!isNaN(newValue) && newValue >= 1 && newValue <= 10) {
                                                                sensorIntensitySlider.value = newValue
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
                                                    id: sensorIntensitySlider
                                                    width: parent.width
                                                    from: 1
                                                    to: 10
                                                    value: 5
                                                    stepSize: 1
                                                    onValueChanged: {
                                                        sensorIntensityInput.text = value.toString()
                                                    }
                                                }
                                            }
                                            
                                            // 持续时间
                                            Column {
                                                width: (parent.width - 15) / 2
                                                spacing: 5
                                                
                                                Row {
                                                    width: parent.width
                                                    spacing: 8
                                                    
                                                    Text {
                                                        text: "持续时间:"
                                                        color: "#ffffff"
                                                        font.pixelSize: 12
                                                        width: 60
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                    
                                                    FluTextBox {
                                                        id: sensorDurationInput
                                                        width: 100
                                                        height: 28
                                                        text: sensorDurationSlider.value.toString()
                                                        placeholderText: "5-300"
                                                        validator: IntValidator { bottom: 5; top: 300 }
                                                        onTextChanged: {
                                                            var newValue = parseInt(text)
                                                            if (!isNaN(newValue) && newValue >= 5 && newValue <= 300) {
                                                                sensorDurationSlider.value = newValue
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
                                                    id: sensorDurationSlider
                                                    width: parent.width
                                                    from: 5
                                                    to: 300
                                                    value: 30
                                                    stepSize: 5
                                                    onValueChanged: {
                                                        sensorDurationInput.text = value.toString()
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // 攻击频率和影响范围
                                        Row {
                                            width: parent.width
                                            spacing: 15
                                            
                                            // 攻击频率
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
                                                        id: sensorFrequencyInput
                                                        width: 100
                                                        height: 28
                                                        text: sensorFrequencySlider.value.toString()
                                                        placeholderText: "1-50"
                                                        validator: IntValidator { bottom: 1; top: 50 }
                                                        onTextChanged: {
                                                            var newValue = parseInt(text)
                                                            if (!isNaN(newValue) && newValue >= 1 && newValue <= 50) {
                                                                sensorFrequencySlider.value = newValue
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
                                                    id: sensorFrequencySlider
                                                    width: parent.width
                                                    from: 1
                                                    to: 50
                                                    value: 5
                                                    stepSize: 1
                                                    onValueChanged: {
                                                        sensorFrequencyInput.text = value.toString()
                                                    }
                                                }
                                            }
                                            
                                            // 影响范围
                                            Column {
                                                width: (parent.width - 15) / 2
                                                spacing: 5
                                                
                                                Row {
                                                    width: parent.width
                                                    spacing: 8
                                                    
                                                    Text {
                                                        text: "影响范围:"
                                                        color: "#ffffff"
                                                        font.pixelSize: 12
                                                        width: 60
                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }
                                                    
                                                    FluTextBox {
                                                        id: sensorRangeInput
                                                        width: 100
                                                        height: 28
                                                        text: sensorRangeSlider.value.toString()
                                                        placeholderText: "10-100"
                                                        validator: IntValidator { bottom: 10; top: 100 }
                                                        onTextChanged: {
                                                            var newValue = parseInt(text)
                                                            if (!isNaN(newValue) && newValue >= 10 && newValue <= 100) {
                                                                sensorRangeSlider.value = newValue
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
                                                    id: sensorRangeSlider
                                                    width: parent.width
                                                    from: 10
                                                    to: 100
                                                    value: 50
                                                    stepSize: 5
                                                    onValueChanged: {
                                                        sensorRangeInput.text = value.toString()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 传感器攻击控制按钮区域
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
                                                anchors.right: sensorApplyButton.left
                                                anchors.rightMargin: 15
                                                anchors.verticalCenter: sensorApplyButton.verticalCenter
                                                normalColor: "#2d5aa0"
                                                hoverColor: "#3d6bb0"
                                                onClicked: {
                                                    // 重置传感器攻击参数到默认值
                                                    sensorIntensitySlider.value = 5
                                                    sensorDurationSlider.value = 30
                                                    sensorFrequencySlider.value = 5
                                                    sensorRangeSlider.value = 50
                                                    sensorTargetCombo.currentIndex = 0
                                                    attackOrderCombo.currentIndex = 0
                                                    sensorAttackModeCombo.currentIndex = 0
                                                }
                                            }
                                            
                                            FluButton {
                                                id: sensorApplyButton
                                                text: "应用参数"
                                                width: 120
                                                height: 45
                                                anchors.centerIn: parent
                                                normalColor: "#2d5aa0"
                                                hoverColor: "#3d6bb0"
                                                onClicked: {
                                                    console.log("应用传感器攻击参数设置")
                                                    console.log("攻击目标:", sensorTargetCombo.currentText)
                                                    console.log("攻击顺序:", attackOrderCombo.currentText)
                                                    console.log("攻击模式:", sensorAttackModeCombo.currentText)
                                                    console.log("攻击强度:", sensorIntensitySlider.value)
                                                    console.log("持续时间:", sensorDurationSlider.value)
                                                    console.log("攻击频率:", sensorFrequencySlider.value)
                                                    console.log("影响范围:", sensorRangeSlider.value)
                                                }
                                            }
                                            
                                            FluButton {
                                                text: "导出数据"
                                                width: 120
                                                height: 45
                                                anchors.left: sensorApplyButton.right
                                                anchors.leftMargin: 15
                                                anchors.verticalCenter: sensorApplyButton.verticalCenter
                                                normalColor: "#2d8a50"
                                                hoverColor: "#3d9a60"
                                                onClicked: {
                                                    // 导出传感器攻击配置数据
                                                    var sensorAttackData = {
                                                        "attackType": "SENSOR_ATTACK",
                                                        "target": sensorTargetCombo.currentText,
                                                        "order": attackOrderCombo.currentText,
                                                        "mode": sensorAttackModeCombo.currentText,
                                                        "parameters": {
                                                            "intensity": sensorIntensitySlider.value,
                                                            "duration": sensorDurationSlider.value,
                                                            "frequency": sensorFrequencySlider.value,
                                                            "range": sensorRangeSlider.value
                                                        }
                                                    }
                                                    
                                                    var jsonString = JSON.stringify(sensorAttackData, null, 2)
                                                    jsonDataPopup.jsonText = jsonString
                                                    jsonDataPopup.open()
                                                    
                                                    console.log("传感器攻击数据已导出")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                            // 第二部分：攻击效果监控已迁移到右下角
            }   
        }
        
        // 右侧上半部分区域
        Rectangle {
            id: rightUpperArea
            anchors.left: attackSettingArea.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20
            anchors.leftMargin: 40  // 左侧间距
            height: parent.height * 0.3
            color: "#1a1a1a"
            border.color: "#333333"
            border.width: 1
            radius: 10
            
            // 车辆拓扑Canvas区域
            Canvas {
                id: vehicleTopologyCanvas
                anchors.fill: parent
                anchors.margins: 10
                
                // 模式8的拓扑配置（固定显示）
                property var vehiclePositions: [
                    {x: width/6 * 0.3, y: height*0.6, id: "N"}, 
                    {x: width/6 * 1.3, y: height*0.6, id: "i+1"}, 
                    {x: width/6 * 2.3, y: height*0.6, id: "i"},
                    {x: width/6 * 3.3, y: height*0.6, id: "i-1"}, 
                    {x: width/6 * 4.3, y: height*0.6, id: "i-2"}, 
                    {x: width/6 * 5.3, y: height*0.6, id: "0"}
                ]
                property var connections: [{from: 1, to: 0}, {from: 2, to: 1}, {from: 3, to: 2}, {from: 4, to: 3}, {from: 5, to: 4}]
                property var bezierConnections: [{from: 1, to: 2}, {from: 4, to: 2}, {from: 5, to: 2}]
                
                Component.onCompleted: {
                    requestPaint()
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
                    
                    // 调整箭头终点位置，避开车辆图标的不透明圆形（半径20px）
                    var backgroundRadius = 25
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
                    ctx.strokeStyle = "rgba(0, 255, 255, 1.0)"
                    ctx.lineWidth = 3
                    
                    for (var i = 0; i < connections.length; i++) {
                        var conn = connections[i]
                        var fromPos = vehiclePositions[conn.from]
                        var toPos = vehiclePositions[conn.to]
                        
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
                    ctx.strokeStyle = "rgba(255, 102, 0, 1.0)"
                    ctx.lineWidth = 3
                    
                    for (var j = 0; j < bezierConnections.length; j++) {
                        var bezConn = bezierConnections[j]
                        var fromPos = vehiclePositions[bezConn.from]
                        var toPos = vehiclePositions[bezConn.to]
                        
                        // 计算控制点（在两点中间上方形成弧形）
                        var midX = (fromPos.x + toPos.x) / 2
                        var controlY = fromPos.y - midX*0.3  // 控制点在上方
                        
                        ctx.beginPath()
                        ctx.moveTo(fromPos.x + 15, fromPos.y + 15)
                        ctx.quadraticCurveTo(midX, controlY, toPos.x + 15, toPos.y + 15)
                        ctx.stroke()
                        
                        // 计算贝塞尔曲线末端的切线角度并绘制箭头
                        var t = 0.95  // 接近终点的参数
                        var dx = 2 * (1 - t) * (midX - (fromPos.x + 15)) + 2 * t * ((toPos.x + 15) - midX)
                        var dy = 2 * (1 - t) * (controlY - (fromPos.y + 15)) + 2 * t * ((toPos.y + 15) - controlY)
                        var angle = Math.atan2(dy, dx)
                        
                        // 调整箭头终点位置，避开车辆图标的不透明圆形（半径20px）
                        var backgroundRadius = 25
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
                        var vehicleSize = 50  // 字体图标大小
                        var backgroundRadius = 20  // 背景圆半径
                        
                        // 绘制不透明背景圆形，遮挡连线
                        ctx.fillStyle = "#1a1a1a"  // 与Canvas背景色一致
                        ctx.beginPath()
                        ctx.arc(pos.x + 15, pos.y + 15, backgroundRadius, 0, 2 * Math.PI)
                        ctx.fill()
                        
                        // 使用字体图标绘制车辆
                        drawVehicleIcon(ctx, pos.id, pos.x + 15, pos.y + 15, vehicleSize, false)
                        
                        // 绘制车辆编号
                        ctx.fillStyle = "white"
                        ctx.font = "bold 20px Arial"
                        ctx.textAlign = "center"
                        ctx.fillText(pos.id.toString(), pos.x + 15, pos.y + vehicleSize)
                    }
                }
            }
        }
        
        // 右侧下半部分区域 - 包含攻击效果监控
        Rectangle {
            id: rightLowerArea
            anchors.left: attackSettingArea.right
            anchors.right: parent.right
            anchors.top: rightUpperArea.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 20
            anchors.leftMargin: 40  // 左侧间距
            anchors.topMargin: 40   // 上方间距
            color: "#2a2a2a"
            border.color: "#444444"
            border.width: 1
            radius: 10
            
            // 水平布局 - 左右两个组件
            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 15
                
                // 左侧组件 - 包含表格和柱状图
                Rectangle {
                    id: leftComponent
                    width: (parent.width - parent.spacing) * 0.7
                    height: parent.height
                    color: "transparent"
                    
                    Column {
                        anchors.fill: parent
                        spacing: 15
                        
                        Text {
                            text: "攻击效果监控与分析"
                            color: "#00ffff"
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        // 上层 - 表格水平布局
                        Row {
                            width: parent.width
                            height: (parent.height - 40) * 0.45  // 上层占45%
                            spacing: 15
                            
                            // 攻击任务表格
                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                color: "#1a1a1a"
                                border.color: "#444444"
                                border.width: 1
                                radius: 8
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8
                                    
                                    Text {
                                        text: "攻击任务状态"
                                        color: "#00ffff"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    
                                    FluTableView {
                                        width: parent.width
                                        height: parent.height - 25
                                        borderColor: "transparent"
                                        columnSource: [
                                            {
                                                title: "任务ID",
                                                dataIndex: "taskId",
                                                width: 60
                                            },
                                            {
                                                title: "攻击类型",
                                                dataIndex: "attackType",
                                                width: 80
                                            },
                                            {
                                                title: "目标",
                                                dataIndex: "target",
                                                width: 70
                                            },
                                            {
                                                title: "状态",
                                                dataIndex: "status",
                                                width: 60
                                            },
                                            {
                                                title: "进度",
                                                dataIndex: "progress",
                                                width: 50
                                            }
                                        ]
                                        dataSource: [
                                            {
                                                taskId: "T001",
                                                attackType: "DDoS攻击",
                                                target: "Car001",
                                                status: "执行中",
                                                progress: "85%"
                                            },
                                            {
                                                taskId: "T002",
                                                attackType: "重放攻击",
                                                target: "Car002",
                                                status: "待执行",
                                                progress: "0%"
                                            },
                                            {
                                                taskId: "T003",
                                                attackType: "信号干扰",
                                                target: "GPS传感器",
                                                status: "已完成",
                                                progress: "100%"
                                            },
                                            {
                                                taskId: "T004",
                                                attackType: "数据篡改",
                                                target: "雷达传感器",
                                                status: "执行中",
                                                progress: "45%"
                                            },
                                            {
                                                taskId: "T005",
                                                attackType: "欺骗攻击",
                                                target: "Car003",
                                                status: "暂停",
                                                progress: "30%"
                                            },
                                            {
                                                taskId: "T006",
                                                attackType: "物理遮挡",
                                                target: "摄像头",
                                                status: "失败",
                                                progress: "15%"
                                            }
                                        ]
                                    }
                                }
                            }
                            
                            // 链路状态表格
                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: parent.height
                                color: "#1a1a1a"
                                border.color: "#444444"
                                border.width: 1
                                radius: 8
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 8
                                    
                                    Text {
                                        text: "网络链路影响分析"
                                        color: "#00ffff"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                    
                                    FluTableView {
                                        width: parent.width
                                        height: parent.height - 25
                                        borderColor: "transparent"
                                        columnSource: [
                                            {
                                                title: "链路",
                                                dataIndex: "dataLink",
                                                width: 80
                                            },
                                            {
                                                title: "丢包率",
                                                dataIndex: "packetLoss",
                                                width: 60
                                            },
                                            {
                                                title: "延迟",
                                                dataIndex: "delay",
                                                width: 50
                                            },
                                            {
                                                title: "影响度",
                                                dataIndex: "impact",
                                                width: 60
                                            },
                                            {
                                                title: "恢复时间",
                                                dataIndex: "recovery",
                                                width: 70
                                            }
                                        ]
                                        dataSource: [
                                            {
                                                dataLink: "Car001->Car002",
                                                packetLoss: "5.2%",
                                                delay: "120ms",
                                                impact: "严重",
                                                recovery: "2.5min"
                                            },
                                            {
                                                dataLink: "Car002->Car003",
                                                packetLoss: "3.8%",
                                                delay: "85ms",
                                                impact: "中等",
                                                recovery: "1.8min"
                                            },
                                            {
                                                dataLink: "Car003->Car004",
                                                packetLoss: "1.2%",
                                                delay: "45ms",
                                                impact: "轻微",
                                                recovery: "0.5min"
                                            },
                                            {
                                                dataLink: "Car004->Car005",
                                                packetLoss: "8.7%",
                                                delay: "200ms",
                                                impact: "严重",
                                                recovery: "3.2min"
                                            },
                                            {
                                                dataLink: "GPS->Car001",
                                                packetLoss: "15.3%",
                                                delay: "350ms",
                                                impact: "极严重",
                                                recovery: "5.0min"
                                            },
                                            {
                                                dataLink: "Radar->Car002",
                                                packetLoss: "2.1%",
                                                delay: "30ms",
                                                impact: "轻微",
                                                recovery: "0.3min"
                                            }
                                        ]
                                    }
                                }
                            }
                        }
                        
                        // 下层 - 柱状图
                        Rectangle {
                            width: parent.width
                            height: (parent.height - 40) * 0.55  // 下层占55%
                            color: "#0f1624"
                            border.color: "#30363d"
                            border.width: 1
                            radius: 8
                            
                            Column {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 10
                                
                                Text {
                                    text: "攻击效果统计分析"
                                    color: "#00ffff"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                                
                                // 使用FluChart绘制柱状图
                                FluChart {
                                    id: attackEffectChart
                                    width: parent.width
                                    height: parent.height - 35
                                    chartType: "bar"
                                    chartData: {
                                        "labels": ["DDoS攻击", "重放攻击", "欺骗攻击", "信号干扰", "数据篡改", "物理遮挡", "GPS干扰", "雷达欺骗"],
                                        "datasets": [
                                            {
                                                "label": "攻击成功率(%)",
                                                "data": [85, 65, 78, 45, 72, 38, 82, 56],
                                                "backgroundColor": [
                                                    "rgba(255, 107, 107, 0.8)",
                                                    "rgba(78, 205, 196, 0.8)", 
                                                    "rgba(69, 183, 209, 0.8)",
                                                    "rgba(150, 206, 180, 0.8)",
                                                    "rgba(255, 159, 64, 0.8)",
                                                    "rgba(153, 102, 255, 0.8)",
                                                    "rgba(255, 99, 132, 0.8)",
                                                    "rgba(54, 162, 235, 0.8)"
                                                ],
                                                "borderColor": [
                                                    "rgba(255, 107, 107, 1)",
                                                    "rgba(78, 205, 196, 1)",
                                                    "rgba(69, 183, 209, 1)",
                                                    "rgba(150, 206, 180, 1)",
                                                    "rgba(255, 159, 64, 1)",
                                                    "rgba(153, 102, 255, 1)",
                                                    "rgba(255, 99, 132, 1)",
                                                    "rgba(54, 162, 235, 1)"
                                                ],
                                                "borderWidth": 2,
                                                "barPercentage": 0.8,
                                                "categoryPercentage": 0.9
                                            }
                                        ]
                                    }
                                    chartOptions: {
                                        "responsive": true,
                                        "maintainAspectRatio": false,
                                        "layout": {"padding": 10},
                                        "plugins": {
                                            "backgroundColor": "#1a1a1a"
                                        },
                                        "legend": {
                                            "display": true, 
                                            "position": "top", 
                                            "labels": {
                                                "fontColor": "#f0f6fc",
                                                "fontSize": 12
                                            }
                                        },
                                        "title": {
                                            "display": false
                                        },
                                        "scales": {
                                            "xAxes": [{
                                                "gridLines": {
                                                    "display": true, 
                                                    "color": "rgba(48, 54, 61, 0.7)", 
                                                    "lineWidth": 1
                                                },
                                                "ticks": {
                                                    "fontColor": "#94a3b8",
                                                    "fontSize": 10,
                                                    "maxRotation": 45,
                                                    "minRotation": 0
                                                }
                                            }],
                                            "yAxes": [{
                                                "gridLines": {
                                                    "display": true, 
                                                    "color": "rgba(48, 54, 61, 0.7)", 
                                                    "lineWidth": 1
                                                },
                                                "ticks": {
                                                    "beginAtZero": true, 
                                                    "fontColor": "#94a3b8",
                                                    "fontSize": 11,
                                                    "max": 100,
                                                    "stepSize": 10
                                                }
                                            }]
                                        },
                                        "elements": {
                                            "rectangle": {
                                                "borderWidth": 2
                                            }
                                        },
                                        "tooltips": {
                                            "backgroundColor": "rgba(0, 0, 0, 0.9)",
                                            "titleFontColor": "#ffffff",
                                            "bodyFontColor": "#ffffff",
                                            "borderColor": "#00ffff",
                                            "borderWidth": 1,
                                            "cornerRadius": 6
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 右侧组件 - 整体设置面板
                Rectangle {
                    id: rightComponent
                    width: (parent.width - parent.spacing) * 0.3
                    height: parent.height
                    color: "#1a1a1a"
                    border.color: "#00ffff"
                    border.width: 2
                    radius: 8
                    
                    // 使用Flickable包装Column以支持滚动
                    Flickable {
                        id: settingsPanelFlickable
                        anchors.fill: parent
                        anchors.margins: 15
                        contentHeight: settingsPanelColumn.height
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true
                        ScrollBar.vertical: FluScrollBar {
                            id: settingsPanelScrollBar
                        }
                        
                        Column {
                            id: settingsPanelColumn
                            width: parent.width - 30
                            spacing: 15
                            
                            // 标题区域
                            Rectangle {
                                width: parent.width
                                height: 40
                                color: "transparent"
                                border.color: "#00ffff"
                                border.width: 0
                                radius: 5
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "系统设置面板"
                                    color: "#00ffff"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }

                                                        // 底部攻击控制按钮区域
                            Item {
                                width: parent.width
                                height: 45
                                
                                Row {
                                    width: parent.width
                                    height: parent.height
                                    spacing: 3
                                    
                                    FluToggleButton {
                                        id: startAttackBtn2
                                        text: "启动"
                                        width: (parent.width - 10) / 3
                                        height: parent.height
                                        checked: false
                                        normalColor: "#2d5aa0"
                                        hoverColor: "#3d6bb0"
                                        pressedColor: "#1d4a90"
                                        onClicked: {
                                            if (checked) {
                                                stopAttackBtn2.checked = false
                                                pauseAttackBtn2.checked = false
                                                
                                                // 发送攻击JSON数据到服务器
                                                if (globalAttackJsonString !== "") {
                                                    console.log("启动攻击，发送JSON数据到服务器")
                                                    console.log("发送的JSON数据:", globalAttackJsonString)
                                                    
                                                    // 调用SharedNetworkConnection的发送方法
                                                var success = SharedNetworkConnection.sendJsonData(globalAttackJsonString)
                                                    
                                                    if (success) {
                                                        console.log("攻击数据发送成功")
                                                        // 可以在这里添加成功提示
                                                    } else {
                                                        console.log("攻击数据发送失败")
                                                        // 可以在这里添加失败提示
                                                        checked = false // 发送失败时取消选中状态
                                                    }
                                                } else {
                                                    console.log("没有可发送的攻击数据，请先生成攻击参数")
                                                    checked = false // 没有数据时取消选中状态
                                                }
                                            } else {
                                                console.log("停止攻击")
                                            }
                                        }
                                    }
                                    
                                    FluToggleButton {
                                        id: pauseAttackBtn2
                                        text: "暂停"
                                        width: (parent.width - 6) / 3
                                        height: parent.height
                                        checked: false
                                        normalColor: "#2d5aa0"
                                        hoverColor: "#3d6bb0"
                                        pressedColor: "#1d4a90"
                                        onClicked: {
                                            if (checked) {
                                                startAttackBtn2.checked = false
                                            }
                                        }
                                    }
                                    
                                    FluToggleButton {
                                        id: stopAttackBtn2
                                        text: "停止"
                                        width: (parent.width - 6) / 3
                                        height: parent.height
                                        checked: false
                                        normalColor: "#2d5aa0"
                                        hoverColor: "#3d6bb0"
                                        pressedColor: "#1d4a90"
                                        onClicked: {
                                            if (checked) {
                                                startAttackBtn2.checked = false
                                                pauseAttackBtn2.checked = false
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 攻击模式设置区域
                            Rectangle {
                                width: parent.width
                                height: 220
                                color: "#2a2a2a"
                                border.color: "#444444"
                                border.width: 1
                                radius: 5
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10
                                    
                                    Text {
                                        text: "攻击模式设置"
                                        color: "#00ffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    // 攻击目标类型选择 60
                                    Row {
                                        width: parent.width
                                        spacing: 6
                                        
                                        Text {
                                            text: "攻击目标:"
                                            color: "#ffffff"
                                            font.pixelSize: 11
                                            width: 60
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        FluComboBox {
                                            id: attackTargetTypeCombo2
                                            width: parent.width - 68
                                            height: 28
                                            model: ["SINGLE", "MULTIPLE", "ALL"]
                                            currentIndex: 0
                                            onCurrentIndexChanged: {
                                                if (currentIndex === 1) { // MULTIPLE
                                                    vehicleSelectionArea2.visible = true
                                                    currentVehicleTitle2.visible = true
                                                }else if(currentIndex===2) { // ALL
                                                    vehicleSelectionArea2.visible = true
                                                    currentVehicleTitle2.visible = true
                                                    // 在ALL模式下，选中所有车辆
                                                    for (var i = 0; i < vehicleSelectionArea2.children[0].children[1].children[0].count; i++) {
                                                        var checkbox = vehicleSelectionArea2.children[0].children[1].children[0].itemAt(i)
                                                        if (checkbox) {
                                                            checkbox.checked = true
                                                        }
                                                    }
                                                }
                                                else {
                                                    vehicleSelectionArea2.visible = false
                                                    currentVehicleTitle2.visible = true
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 车辆选择区域（仅在MULTIPLE模式下显示） -80
                                    Rectangle {
                                        id: vehicleSelectionArea2
                                        width: parent.width
                                        height: visible ? 80 : 0
                                        color: "#1a1a1a"
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
                                                font.pixelSize: 11
                                                font.bold: true
                                            }
                                            
                                            Flickable {
                                                id: vehicleSelectionFlickable2
                                                width: parent.width
                                                height: 50
                                                contentHeight: vehicleFlow2.height
                                                boundsBehavior: Flickable.StopAtBounds
                                                clip: true
                                                ScrollBar.vertical: FluScrollBar {
                                                    id: vehicleSelectionScrollBar2
                                                }
                                                
                                                Flow {
                                                    id: vehicleFlow2
                                                    width: parent.width
                                                    spacing: 6
                                                    
                                                    Repeater {
                                                        model: vehicleNames
                                                        
                                                        FluCheckBox {
                                                            text: modelData
                                                            checked: attackTargetTypeCombo2.currentIndex === 2 ? true : (vehicleSelectionStates[index] === 1)
                                                            enabled: attackTargetTypeCombo2.currentIndex !== 2
                                                            onCheckedChanged: {
                                                                if (attackTargetTypeCombo2.currentIndex === 2 && !checked) {
                                                                    checked = true
                                                                    return
                                                                }
                                                                
                                                                var newStates = vehicleSelectionStates.slice()
                                                                newStates[index] = checked ? 1 : 0
                                                                vehicleSelectionStates = newStates
                                                                
                                                                var result = []
                                                                for (var i = 0; i < vehicleNames.length; i++) {
                                                                    if (vehicleSelectionStates[i] === 1) {
                                                                        result.push(vehicleNames[i])
                                                                    }
                                                                }
                                                                globalVehicleNames = result
                                                                updateSelectedVehicles()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 当前配置车辆标题 40
                                    Rectangle {
                                        id: currentVehicleTitle2
                                        width: parent.width
                                        height: visible ? 40 : 0
                                        color: "#333333"
                                        border.color: "#00ffff"
                                        border.width: 0
                                        radius: 4
                                        visible: true
                                        
                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            
                                            Row {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                spacing: 6
                                                
                                                Text {
                                                    text: "当前配置车辆:"
                                                    color: "#ffffff"
                                                    font.pixelSize: 15
                                                    font.bold: true
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                                
                                                FluComboBox {
                                                    id: currentVehicleCombo2
                                                    width: 80
                                                    height: 25
                                                    model: selectedVehicles
                                                    currentIndex: 0
                                                    onCurrentIndexChanged: {
                                                        if (model.length > 0 && currentIndex >= 0) {
                                                            loadVehicleParameters(model[currentIndex])
                                                        }
                                                    }
                                                }
                                                
                                                Text {
                                                    text: "的攻击参数"
                                                    color: "#ffffff"
                                                    font.pixelSize: 15
                                                    font.bold: true
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 网络设置区域
                            Rectangle {
                                width: parent.width
                                height: 160
                                color: "#2a2a2a"
                                border.color: "#444444"
                                border.width: 1
                                radius: 5
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10
                                    
                                    Text {
                                        text: "网络设置"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    // 服务器地址设置
                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        
                                        Text {
                                            text: "服务器地址:"
                                            color: "#cccccc"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }
                                        
                                        FluTextBox {
                                            id: serverAddressInput
                                            width: parent.width - 90
                                            height: 30
                                            placeholderText: "192.168.1.100"
                                            text: "192.168.1.100"
                                        }
                                    }
                                    
                                    // 端口设置
                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        
                                        Text {
                                            text: "端口:"
                                            color: "#cccccc"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }
                                        
                                        FluTextBox {
                                            id: portInput
                                            width: parent.width - 90
                                            height: 30
                                            placeholderText: "8080"
                                            text: "8080"
                                        }
                                    }
                                    
                                    // 自动重连开关
                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        
                                        Text {
                                            text: "自动重连:"
                                            color: "#cccccc"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }
                                        
                                        FluToggleSwitch {
                                            id: autoReconnectSwitch
                                            checked: true
                                        }
                                    }
                                }
                            }
                            
                            // 攻击参数设置区域
                            Rectangle {
                                width: parent.width
                                height: 200
                                color: "#2a2a2a"
                                border.color: "#444444"
                                border.width: 1
                                radius: 5
                                
                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10
                                    
                                    Text {
                                        text: "攻击参数设置"
                                        color: "#ffffff"
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    // 默认攻击强度
                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        
                                        Text {
                                            text: "默认强度:"
                                            color: "#cccccc"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }
                                        
                                        FluTextBox {
                                            id: defaultIntensityInput
                                            width: parent.width - 90
                                            height: 30
                                            placeholderText: "5"
                                            text: "5"
                                        }
                                    }
                                    
                                    // 默认持续时间
                                    Row {
                                        width: parent.width
                                        spacing: 10
                                        
                                        Text {
                                            text: "默认时长:"
                                            color: "#cccccc"
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: 80
                                        }
                                        
                                        FluTextBox {
                                            id: defaultDurationInput
                                            width: parent.width - 90
                                            height: 30
                                            placeholderText: "60"
                                            text: "60"
                                        }
                                    }
                                    Row{
                                        width:parent.width
                                        spacing: 10
                                                                            // 启用日志记录
                                        Row {
                                            width: parent.width/2
                                            spacing: 10
                                            
                                            Text {
                                                text: "日志记录:"
                                                color: "#cccccc"
                                                font.pixelSize: 12
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 80
                                            }
                                            
                                            FluToggleSwitch {
                                                id: enableLoggingSwitch
                                                checked: true
                                            }
                                        }
                                        
                                        // 启用安全模式
                                        Row {
                                            width: parent.width/2
                                            spacing: 10
                                            
                                            Text {
                                                text: "安全模式:"
                                                color: "#cccccc"
                                                font.pixelSize: 12
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 80
                                            }
                                            
                                            FluToggleSwitch {
                                                id: safetyModeSwitch
                                                checked: false
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
    
    // JSON数据弹出框
    FluPopup {
        id: jsonDataPopup
        width: 600
        height: 500
        
        property string jsonText: ""
        
        Rectangle {
            anchors.fill: parent
            color: "#f5f5f5"
            radius: 8
            border.color: "#d0d0d0"
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                // 标题
                Text {
                    text: "导出的JSON数据"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#333333"
                }
                
                // JSON文本显示区域
                Rectangle {
                    width: parent.width
                    height: parent.height - 100
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                    radius: 4
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        TextArea {
                            id: jsonTextArea
                            text: jsonDataPopup.jsonText
                            readOnly: true
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            font.family: "Consolas, Monaco, monospace"
                            font.pixelSize: 12
                            color: "#333333"
                        }
                    }
                }
                
                // 按钮区域
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 15
                    
                    FluButton {
                        text: "复制到剪贴板"
                        width: 120
                        height: 35
                        normalColor: "#2d5aa0"
                        hoverColor: "#3d6bb0"
                        onClicked: {
                            if (typeof Qt !== 'undefined' && Qt.application && Qt.application.clipboard) {
                                Qt.application.clipboard.setText(jsonDataPopup.jsonText)
                                console.log("JSON数据已复制到剪贴板")
                            } else {
                                console.log("剪贴板功能不可用")
                            }
                        }
                    }
                    
                    FluButton {
                        text: "关闭"
                        width: 80
                        height: 35
                        normalColor: "#666666"
                        hoverColor: "#777777"
                        onClicked: {
                            jsonDataPopup.close()
                        }
                    }
                }
            }
        }
    }
    
    // 监听SharedNetworkConnection的信号
    Connections {
        target: SharedNetworkConnection ? SharedNetworkConnection.networkConnection : null
        
        // 监听数据接收信号
        function onDataReceived(data) {
            // console.log("TechDashboard接收到数据:", data)
        }
        
        // 监听网络连接状态变化
        function onNetworkConnectionChanged(connected) {
            console.log("网络连接状态变化:", connected)
        }
        
        // 监听状态变化
        function onStatusChanged(status) {
            console.log("网络状态:", status)
        }
    }
}
