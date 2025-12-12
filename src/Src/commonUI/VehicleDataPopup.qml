import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI

/*
车辆队列数据分析弹出框

功能说明：
- 显示5辆车的实时数据曲线（car1-car5）
- 支持从CSV文件加载真实数据
- 提供车辆选择功能，可选择显示哪些车辆的数据

CSV数据格式要求：
timestamp,carSN,speed,acceleration,position_x,position_y,steering,current_topology,attack_type,attack_target
13:10.3,car1,2,0.2,0,0,0,1,none,none

使用方法：
1. 加载CSV数据：
   vehicleDataPopup.parseAndLoadCSVData(csvContent)

2. 或者通过文件路径加载（需要C++后端支持）：
   vehicleDataPopup.loadCSVFile("C:/Users/19798/Downloads/vehicle_status_20251113_191310.csv")

3. 更新曲线显示：
   vehicleDataPopup.updateCurveData()

曲线说明：
- 队列速度曲线：显示car1-car5的速度变化（多曲线）
- 队列间距误差曲线：显示间距误差（基于position_y）
- 队列受攻击强度：显示攻击强度（基于attack_type）
- 队列间距曲线：显示车辆间距（基于position_x）
*/

FluPopup {
    id: vehicleDataPopup
    
    // 弹出框属性
    implicitWidth: 1200
    implicitHeight: 800
    
    // 车辆数据属性
    property var vehicleData: []
    property var selectedVehicles: [true, true, true, true, true] // 默认全选5辆车（car1-car5）
    
    // CSV数据缓存
    property var csvData: []
    property var vehicleNames: ["car1", "car2", "car3", "car4", "car5"]
    
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
                            model: 5 // 只显示car1-car5
                            FluCheckBox {
                                id: vehicleCheckBox
                                text: "car" + (index + 1)
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
                    
                    // 车辆速度曲线（多曲线显示）
                    CurveComponent {
                        id: speedCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "车辆速度曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "速度 (m/s)"
                        showSineWave: false
                        curveType: "line"
                        autoScaleY: true
                        maxDataPoints: 50
                        showLegend: true
                        legendPosition: "topRight"
                        
                        // 初始化为空，数据将通过updateCurveData函数动态加载
                        curves: []
                    }
                    
                    // 车辆加速度曲线（多曲线显示）
                    CurveComponent {
                        id: distanceErrorCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "车辆加速度曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "加速度 (m/s²)"
                        showSineWave: false
                        curveType: "line"
                        autoScaleY: true
                        maxDataPoints: 50
                        showLegend: true
                        legendPosition: "topRight"
                        
                        // 初始化为空，数据将通过updateCurveData函数动态加载
                        curves: []
                    }
                    
                    // 车间距曲线（多曲线显示）
                    CurveComponent {
                        id: attackIntensityCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "车间距曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "间距 (m)"
                        showSineWave: false
                        curveType: "line"
                        autoScaleY: true
                        maxDataPoints: 50
                        showLegend: true
                        legendPosition: "topRight"
                        
                        // 初始化为空，数据将通过updateCurveData函数动态加载
                        curves: []
                    }
                    
                    // 车辆位置Y曲线（多曲线显示）
                    CurveComponent {
                        id: distanceCurve
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        chartTitle: "车辆位置Y曲线"
                        xAxisLabel: "时间 (s)"
                        yAxisLabel: "位置Y (m)"
                        showSineWave: false
                        curveType: "line"
                        autoScaleY: true
                        maxDataPoints: 50
                        showLegend: true
                        legendPosition: "topRight"
                        
                        // 初始化为空，数据将通过updateCurveData函数动态加载
                        curves: []
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
    
    // CSV数据解析函数（支持制表符和逗号分隔）
    function parseCSVData(csvContent) {
        var lines = csvContent.trim().split('\n')
        if (lines.length < 2) return []
        
        var data = []
        // 检测分隔符类型（制表符或逗号）
        var delimiter = lines[0].includes('\t') ? '\t' : ','
        var headers = lines[0].split(delimiter).map(h => h.trim())
        
        for (var i = 1; i < lines.length; i++) {
            var values = lines[i].split(delimiter).map(v => v.trim())
            if (values.length >= headers.length) {
                var row = {}
                for (var j = 0; j < headers.length; j++) {
                    row[headers[j]] = values[j]
                }
                data.push(row)
            }
        }
        return data
    }
    
    // 从CSV数据生成曲线数据
    function generateCurveDataFromCSV() {
        if (csvData.length === 0) return
        
        // 按车辆分组数据
        var vehicleDataMap = {}
        for (var i = 0; i < vehicleNames.length; i++) {
            vehicleDataMap[vehicleNames[i]] = []
        }
        
        // 解析时间戳并转换为秒
        for (var i = 0; i < csvData.length; i++) {
            var row = csvData[i]
            var carSN = row.carSN || row.carSN
            var timestamp = row.timestamp || row.timestamp
            
            if (vehicleDataMap[carSN]) {
                // 解析时间戳 (格式: 13:10.3 -> 转换为秒)
                var timeParts = timestamp.split(':')
                var timeInSeconds = 0
                if (timeParts.length === 2) {
                    var minutes = parseInt(timeParts[0]) || 0
                    var seconds = parseFloat(timeParts[1]) || 0
                    timeInSeconds = minutes * 60 + seconds
                }
                
                vehicleDataMap[carSN].push({
                    time: timeInSeconds,
                    speed: parseFloat(row.speed) || 0,
                    acceleration: parseFloat(row.acceleration) || 0,
                    position_x: parseFloat(row.position_x) || 0,
                    position_y: parseFloat(row.position_y) || 0,
                    steering: parseFloat(row.steering) || 0,
                    attack_type: row.attack_type || "none",
                    attack_target: row.attack_target || "none"
                })
            }
        }
        
        // 生成速度曲线数据（多曲线）
        var speedCurves = []
        var colors = ["#3498db", "#e74c3c", "#2ecc71", "#f39c12", "#9b59b6"]
        
        for (var i = 0; i < vehicleNames.length; i++) {
            var vehicleName = vehicleNames[i]
            var vehicleData = vehicleDataMap[vehicleName]
            
            if (vehicleData.length > 0 && selectedVehicles[i]) {
                var curveData = []
                for (var j = 0; j < vehicleData.length; j++) {
                    curveData.push({
                        x: vehicleData[j].time,
                        y: vehicleData[j].speed
                    })
                }
                
                speedCurves.push({
                    name: vehicleName + "速度",
                    color: colors[i % colors.length],
                    width: 2,
                    type: "line",
                    data: curveData
                })
            }
        }
        
        // 更新速度曲线
        speedCurve.curves = speedCurves
        
        // 生成加速度曲线数据（多曲线）
        var accelerationCurves = []
        for (var i = 0; i < vehicleNames.length; i++) {
            var vehicleName = vehicleNames[i]
            var vehicleData = vehicleDataMap[vehicleName]
            
            if (vehicleData.length > 0 && selectedVehicles[i]) {
                var curveData = []
                for (var j = 0; j < vehicleData.length; j++) {
                    curveData.push({
                        x: vehicleData[j].time,
                        y: vehicleData[j].acceleration
                    })
                }
                
                accelerationCurves.push({
                    name: vehicleName + "加速度",
                    color: colors[i % colors.length],
                    width: 2,
                    type: "line",
                    data: curveData
                })
            }
        }
        distanceErrorCurve.curves = accelerationCurves
        
        // 生成车间距曲线数据（4条曲线：car1-car2, car2-car3, car3-car4, car4-car5）
        var distanceCurves = []
        var distancePairs = [
            {from: "car1", to: "car2", name: "car1-car2间距"},
            {from: "car2", to: "car3", name: "car2-car3间距"},
            {from: "car3", to: "car4", name: "car3-car4间距"},
            {from: "car4", to: "car5", name: "car4-car5间距"}
        ]
        
        for (var i = 0; i < distancePairs.length; i++) {
            var pair = distancePairs[i]
            var fromData = vehicleDataMap[pair.from]
            var toData = vehicleDataMap[pair.to]
            
            if (fromData.length > 0 && toData.length > 0) {
                var curveData = []
                var minLength = Math.min(fromData.length, toData.length)
                
                for (var j = 0; j < minLength; j++) {
                    var distance = Math.abs(toData[j].position_x - fromData[j].position_x)
                    curveData.push({
                        x: fromData[j].time,
                        y: distance
                    })
                }
                
                distanceCurves.push({
                    name: pair.name,
                    color: colors[i % colors.length],
                    width: 2,
                    type: "line",
                    data: curveData
                })
            }
        }
        attackIntensityCurve.curves = distanceCurves
        
        // 生成位置Y曲线数据（多曲线）
        var positionYCurves = []
        for (var i = 0; i < vehicleNames.length; i++) {
            var vehicleName = vehicleNames[i]
            var vehicleData = vehicleDataMap[vehicleName]
            
            if (vehicleData.length > 0 && selectedVehicles[i]) {
                var curveData = []
                for (var j = 0; j < vehicleData.length; j++) {
                    curveData.push({
                        x: vehicleData[j].time,
                        y: vehicleData[j].position_y
                    })
                }
                
                positionYCurves.push({
                    name: vehicleName + "位置Y",
                    color: colors[i % colors.length],
                    width: 2,
                    type: "line",
                    data: curveData
                })
            }
        }
        distanceCurve.curves = positionYCurves
    }
    
    // 公开方法
    function updateCurveData() {
        // 只使用CSV数据生成曲线
        if (csvData.length > 0) {
            generateCurveDataFromCSV()
        }
        // 如果没有CSV数据，不显示任何曲线
    }
    

    
    function setVehicleData(data) {
        vehicleData = data
        updateCurveData()
    }
    
    // 加载CSV文件数据
    function loadCSVFile(filePath) {
        // 由于QML无法直接访问文件系统，这里提供一个接口
        // 实际使用时需要通过C++后端或其他方式加载CSV内容
        console.log("CSV文件加载接口，文件路径:", filePath)
        console.log("请通过C++后端或其他方式加载CSV文件内容，然后调用parseAndLoadCSVData(csvContent)")
    }
    
    // 解析并加载CSV数据内容
    function parseAndLoadCSVData(csvContent) {
        csvData = parseCSVData(csvContent)
        console.log("成功加载CSV数据，记录数:", csvData.length)
        updateCurveData()
    }
    
    function showPopup() {
        updateCurveData()
        open()
    }
    
    // 组件完成时初始化数据
    Component.onCompleted: {
        // 加载示例CSV数据（实际使用时应该加载真实CSV文件）
        loadSampleCSVData()
        updateCurveData()
    }
    
    // 加载示例CSV数据（用于演示）
    function loadSampleCSVData() {
        // 基于您提供的示例数据格式创建样本数据
        var sampleCSVContent = `timestamp	carSN	speed	acceleration	position_x	position_y	steering	current_topology	attack_type	attack_target
34:28.9	car1	2	0.2	0	0	0	1	none	none
34:28.9	car2	2.0938	2.9375	-12	0	0	1	none	none
34:28.9	car3	2.2	5	-24	0	0	1	none	none
34:28.9	car4	2.1	5	-36	0	0	1	none	none
34:28.9	car5	2	5	-48	0	0	1	none	none
34:29.1	car1	2	0.2	29.913	85.075	0	4	none	none
34:29.1	car2	1.594	-5	27.91	85.075	0	4	none	none
34:29.1	car3	1.7	-5	24.91	85.075	0	4	none	none
34:29.1	car4	1.6	-5	21.91	84.875	0	4	none	none
34:29.1	car5	1.5	-5	19.71	85.275	0	4	none	none
34:29.2	car1	2	0.2	29.945	85.075	0	1	none	none
34:29.2	car2	1.594	-5	27.928	85.075	0	1	none	none
34:29.2	car3	1.7	-5	24.928	85.075	0	1	none	none
34:29.2	car4	1.6	-5	21.928	84.875	0	1	none	none
34:29.2	car5	1.5	-5	19.728	85.275	0	1	none	none
34:29.3	car1	2	0.2	30.025	85.075	0	1	none	none
34:29.3	car2	1.094	-5	27.993	85.075	0	1	none	none
34:29.3	car3	1.2	-5	24.993	85.075	0	1	none	none
34:29.3	car4	1.1	-5	21.993	84.875	0	1	none	none
34:29.3	car5	1	-5	19.793	85.275	0	1	none	none
34:29.4	car1	2	0.2	30.15	85.075	0	1	none	none
34:29.4	car2	0.594	-5	28.103	85.075	0	1	none	none
34:29.4	car3	0.7	-5	25.103	85.075	0	1	none	none
34:29.4	car4	0.6	-5	22.103	84.875	0	1	none	none
34:29.4	car5	0.5	-5	19.903	85.275	0	1	none	none
34:29.5	car1	2	0.2	30.318	85.075	0	1	none	none
34:29.5	car2	0.094	-5	28.226	85.075	0	1	none	none
34:29.5	car3	0.2	-5	25.235	85.075	0	1	none	none
34:29.5	car4	0.1	-5	22.23	84.875	0	1	none	none
34:29.5	car5	0	-5	20.025	85.275	0	1	none	none
34:29.6	car1	2	0.2	30.526	85.075	0	4	none	none
34:29.6	car2	0	-5	28.317	85.075	0	4	none	none
34:29.6	car3	0	-5	25.354	85.075	0	4	none	none
34:29.6	car4	0	-5	22.34	84.875	0	4	none	none
34:29.6	car5	0	-5	20.13	85.275	0	4	none	none
34:29.7	car1	2	0.2	30.75	85.075	0	4	none	none
34:29.7	car2	0	-5	28.371	85.075	0	4	none	none
34:29.7	car3	0	-5	25.436	85.075	0	4	none	none
34:29.7	car4	0	-5	22.414	84.875	0	4	none	none
34:29.7	car5	0	-5	20.199	85.275	0	4	none	none
34:29.9	car1	2	0.2	30.942	85.075	0	4	none	none
34:29.9	car2	0	-5	28.388	85.075	0	4	none	none
34:29.9	car3	0	-5	25.476	85.075	0	4	none	none
34:29.9	car4	0	-5	22.446	84.875	0	4	none	none
34:29.9	car5	0	-5	20.228	85.275	0	4	none	none
34:30.0	car1	2	0.2	31.135	85.075	0	1	none	none
34:30.0	car2	0	-5	28.395	85.075	0	1	none	none
34:30.0	car3	0	-5	25.491	85.075	0	1	none	none
34:30.0	car4	0	-5	22.458	84.875	0	1	none	none
34:30.0	car5	0	-5	20.237	85.275	0	1	none	none
34:30.1	car1	2	0.2	31.329	85.075	0	1	none	none
34:30.1	car2	0	-5	28.399	85.075	0	1	none	none
34:30.1	car3	0	-5	25.497	85.075	0	1	none	none
34:30.1	car4	0	-5	22.462	84.875	0	1	none	none
34:30.1	car5	0	-5	20.241	85.275	0	1	none	none
34:30.2	car1	2	0.2	31.562	85.075	0	1	none	none
34:30.2	car2	0	-5	28.4	85.075	0	1	none	none
34:30.2	car3	0	-5	25.499	85.075	0	1	none	none
34:30.2	car4	0	-5	22.465	84.875	0	1	none	none
34:30.2	car5	0	-5	20.243	85.275	0	1	none	none
34:30.3	car1	2	0.2	31.795	85.075	0	1	none	none
34:30.3	car2	0	-5	28.402	85.075	0	1	none	none
34:30.3	car3	0	-5	25.499	85.075	0	1	none	none
34:30.3	car4	0	-5	22.468	84.875	0	1	none	none
34:30.3	car5	0	-5	20.244	85.275	0	1	none	none
34:30.4	car1	2	0.2	31.989	85.075	0	1	none	none
34:30.4	car2	0	-5	28.402	85.075	0	1	none	none
34:30.4	car3	0	-5	25.499	85.075	0	1	none	none
34:30.4	car4	0	-5	22.47	84.875	0	1	none	none
34:30.4	car5	0	-5	20.243	85.275	0	1	none	none
34:30.5	car1	2	0.2	32.183	85.075	0	1	none	none
34:30.5	car2	0	-5	28.402	85.075	0	1	none	none
34:30.5	car3	0	-5	25.499	85.075	0	1	none	none
34:30.5	car4	0	-5	22.472	84.875	0	1	none	none
34:30.5	car5	0	-5	20.244	85.275	0	1	none	none
34:30.6	car1	2	0.2	32.377	85.075	0	1	none	none
34:30.6	car2	0	-5	28.403	85.075	0	1	none	none
34:30.6	car3	0	-5	25.499	85.075	0	1	none	none
34:30.6	car4	0	-5	22.472	84.875	0	1	none	none
34:30.6	car5	0	-5	20.245	85.275	0	1	none	none
34:30.7	car1	2	0.2	32.61	85.075	0	1	none	none
34:30.7	car2	0	-5	28.403	85.075	0	1	none	none
34:30.7	car3	0	-5	25.495	85.075	0	1	none	none
34:30.7	car4	0	-5	22.472	84.875	0	1	none	none
34:30.7	car5	0	-5	20.245	85.275	0	1	none	none
34:30.8	car1	2	0.2	32.804	85.075	0	1	none	none
34:30.8	car2	0	-5	28.403	85.075	0	1	none	none
34:30.8	car3	0	-5	25.493	85.075	0	1	none	none
34:30.8	car4	0	-5	22.472	84.875	0	1	none	none
34:30.8	car5	0	-5	20.246	85.275	0	1	none	none
34:30.9	car1	2	0.2	32.998	85.075	0	1	none	none
34:30.9	car2	0	-5	28.401	85.075	0	1	none	none
34:30.9	car3	0	-5	25.492	85.075	0	1	none	none
34:30.9	car4	0	-5	22.472	84.875	0	1	none	none
34:30.9	car5	0	-5	20.247	85.275	0	1	none	none
34:31.1	car1	2	0.2	33.193	85.075	0	1	none	none
34:31.1	car2	0	-5	28.399	85.075	0	1	none	none
34:31.1	car3	0	-5	25.49	85.075	0	1	none	none
34:31.1	car4	0	-5	22.471	84.875	0	1	none	none
34:31.1	car5	0	-5	20.247	85.275	0	1	none	none
34:31.2	car1	2	0.2	33.503	85.075	0	1	none	none
34:31.2	car2	0	-5	28.398	85.075	0	1	none	none
34:31.2	car3	0	-5	25.485	85.075	0	1	none	none
34:31.2	car4	0	-5	22.469	84.875	0	1	none	none
34:31.2	car5	0	-5	20.248	85.275	0	1	none	none
34:31.3	car1	2	0.2	33.698	85.075	0	1	none	none
34:31.3	car2	0	-5	28.395	85.075	0	1	none	none
34:31.3	car3	0	-5	25.484	85.075	0	1	none	none
34:31.3	car4	0	-5	22.467	84.875	0	1	none	none
34:31.3	car5	0	-5	20.248	85.275	0	1	none	none
34:31.4	car1	2	0.2	33.892	85.075	0	1	none	none
34:31.4	car2	0	-5	28.393	85.075	0	1	none	none
34:31.4	car3	0	-5	25.483	85.075	0	1	none	none
34:31.4	car4	0	-5	22.466	84.875	0	1	none	none
34:31.4	car5	0	-5	20.249	85.275	0	1	none	none
34:31.5	car1	2	0.2	34.125	85.075	0	1	none	none
34:31.5	car2	0	-5	28.392	85.075	0	1	none	none
34:31.5	car3	0	-5	25.483	85.075	0	1	none	none
34:31.5	car4	0	-5	22.466	84.875	0	1	none	none
34:31.5	car5	0	-5	20.252	85.275	0	1	none	none
34:31.6	car1	2	0.2	34.319	85.075	0	1	none	none
34:31.6	car2	0	-5	28.392	85.075	0	1	none	none
34:31.6	car3	0	-5	25.482	85.075	0	1	none	none
34:31.6	car4	0	-5	22.465	84.875	0	1	none	none
34:31.6	car5	0	-5	20.253	85.275	0	1	none	none
34:31.7	car1	2	0.2	34.552	85.075	0	1	none	none
34:31.7	car2	0	-5	28.392	85.075	0	1	none	none
34:31.7	car3	0	-5	25.482	85.075	0	1	none	none
34:31.7	car4	0	-5	22.465	84.875	0	1	none	none
34:31.7	car5	0	-5	20.254	85.275	0	1	none	none
34:31.8	car1	2	0.2	34.746	85.075	0	1	none	none
34:31.8	car2	0	-5	28.393	85.075	0	1	none	none
34:31.8	car3	0	-5	25.482	85.075	0	1	none	none
34:31.8	car4	0	-5	22.464	84.875	0	1	none	none
34:31.8	car5	0	-5	20.254	85.275	0	1	none	none
34:31.9	car1	2	0.2	34.94	85.075	0	1	none	none
34:31.9	car2	0	-5	28.393	85.075	0	1	none	none
34:31.9	car3	0	-5	25.481	85.075	0	1	none	none
34:31.9	car4	0	-5	22.465	84.875	0	1	none	none
34:31.9	car5	0	-5	20.253	85.275	0	1	none	none
34:32.0	car1	2	0.2	35.135	85.075	0	1	none	none
34:32.0	car2	0	-5	28.392	85.075	0	1	none	none
34:32.0	car3	0	-5	25.48	85.075	0	1	none	none
34:32.0	car4	0	-5	22.465	84.875	0	1	none	none
34:32.0	car5	0	-5	20.254	85.275	0	1	none	none
34:32.1	car1	2	0.2	35.329	85.075	0	1	none	none
34:32.1	car2	0	-5	28.391	85.075	0	1	none	none
34:32.1	car3	0	-5	25.48	85.075	0	1	none	none
34:32.1	car4	0	-5	22.465	84.875	0	1	none	none
34:32.1	car5	0	-5	20.254	85.275	0	1	none	none
34:32.2	car1	2	0.2	35.601	85.075	0	1	none	none
34:32.2	car2	0	-5	28.391	85.075	0	1	none	none
34:32.2	car3	0	-5	25.479	85.075	0	1	none	none
34:32.2	car4	0	-5	22.465	84.875	0	1	none	none
34:32.2	car5	0	-5	20.255	85.275	0	1	none	none
34:32.4	car1	2	0.2	35.795	85.075	0	1	none	none
34:32.4	car2	0	-5	28.391	85.075	0	1	none	none
34:32.4	car3	0	-5	25.479	85.075	0	1	none	none
34:32.4	car4	0	-5	22.465	84.875	0	1	none	none
34:32.4	car5	0	-5	20.255	85.275	0	1	none	none
34:32.5	car1	2	0.2	36.028	85.075	0	1	none	none
34:32.5	car2	0	-4.819	28.392	85.075	0	1	none	none
34:32.5	car3	0	-5	25.479	85.075	0	1	none	none
34:32.5	car4	0	-5	22.465	84.875	0	1	none	none
34:32.5	car5	0	-5	20.255	85.275	0	1	none	none
34:32.6	car1	2	0.2	36.222	85.075	0	1	none	none
34:32.6	car2	0	-4.2273	28.392	85.075	0	1	none	none
34:32.6	car3	0	-5	25.48	85.075	0	1	none	none
34:32.6	car4	0	-5	22.465	84.875	0	1	none	none
34:32.6	car5	0	-5	20.254	85.275	0	1	none	none
34:32.7	car1	2	0.2	36.455	85.075	0	1	none	none
34:32.7	car2	0	-3.5959	28.389	85.075	0	1	none	none
34:32.7	car3	0	-5	25.479	85.075	0	1	none	none
34:32.7	car4	0	-5	22.466	84.875	0	1	none	none
34:32.7	car5	0	-5	20.255	85.275	0	1	none	none
34:32.8	car1	2	0.2	36.649	85.075	0	1	none	none
34:32.8	car2	0	-2.8247	28.385	85.075	0	1	none	none
34:32.8	car3	0	-5	25.479	85.075	0	1	none	none
34:32.8	car4	0	-5	22.466	84.875	0	1	none	none
34:32.8	car5	0	-5	20.255	85.275	0	1	none	none
34:32.9	car1	2	0.2	36.882	85.075	0	1	none	none
34:32.9	car2	0	-1.5362	28.383	85.075	0	1	none	none
34:32.9	car3	0	-5	25.479	85.075	0	1	none	none
34:32.9	car4	0	-5	22.465	84.875	0	1	none	none
34:32.9	car5	0	-5	20.255	85.275	0	1	none	none
34:33.0	car1	2	0.2	37.077	85.075	0	1	none	none
34:33.0	car2	0	-1.0588	28.382	85.075	0	1	none	none
34:33.0	car3	0	-5	25.479	85.075	0	1	none	none
34:33.0	car4	0	-5	22.465	84.875	0	1	none	none
34:33.0	car5	0	-5	20.256	85.275	0	1	none	none
34:33.1	car1	2	0.2	37.31	85.075	0	1	none	none
34:33.1	car2	0.0456	0.3761	28.382	85.075	0	1	none	none
34:33.1	car3	0	-5	25.483	85.075	0	1	none	none
34:33.1	car4	0	-5	22.465	84.875	0	1	none	none
34:33.1	car5	0	-5	20.258	85.275	0	1	none	none
34:33.2	car1	2	0.2	37.543	85.075	0	1	none	none
34:33.2	car2	0.2056	1.5964	28.383	85.075	0	1	none	none
34:33.2	car3	0	-5	25.484	85.075	0	1	none	none
34:33.2	car4	0	-5	22.465	84.875	0	1	none	none
34:33.2	car5	0	-5	20.258	85.275	0	1	none	none
34:33.4	car1	2	0.2	37.737	85.075	0	1	none	none
34:33.4	car2	0.4381	2.3211	28.388	85.075	0	1	none	none
34:33.4	car3	0	-5	25.485	85.075	0	1	none	none
34:33.4	car4	0	-5	22.465	84.875	0	1	none	none
34:33.4	car5	0	-5	20.258	85.275	0	1	none	none
34:33.5	car1	2	0.2	37.97	85.075	0	1	none	none
34:33.5	car2	0.4859	2.7988	28.402	85.075	0	1	none	none
34:33.5	car3	0	-5	25.486	85.075	0	1	none	none
34:33.5	car4	0	-5	22.466	84.875	0	1	none	none
34:33.5	car5	0	-5	20.259	85.275	0	1	none	none
34:33.6	car1	2	0.2	38.164	85.075	0	4	none	none
34:33.6	car2	0.8049	3.1889	28.427	85.075	0	4	none	none
34:33.6	car3	0	-5	25.487	85.075	0	4	none	none
34:33.6	car4	0	-5	22.466	84.875	0	4	none	none
34:33.6	car5	0	-5	20.259	85.275	0	4	none	none
34:33.7	car1	2	0.2	38.358	85.075	0	4	none	none
34:33.7	car2	0.8304	3.4439	28.467	85.075	0	4	none	none
34:33.7	car3	0	-5	25.488	85.075	0	4	none	none
34:33.7	car4	0	-5	22.466	84.875	0	4	none	none
34:33.7	car5	0	-5	20.259	85.275	0	4	none	none
34:33.8	car1	2	0.2	38.592	85.075	0	4	none	none
34:33.8	car2	1.1388	3.3377	28.532	85.075	0	4	none	none
34:33.8	car3	0	-5	25.488	85.075	0	4	none	none
34:33.8	car4	0	-5	22.466	84.875	0	4	none	none
34:33.8	car5	0	-5	20.259	85.275	0	4	none	none
34:33.9	car1	2	0.2	38.786	85.075	0	4	none	none
34:33.9	car2	1.4352	2.9616	28.603	85.075	0	4	none	none
34:33.9	car3	0	-5	25.489	85.075	0	4	none	none
34:33.9	car4	0	-5	22.466	84.875	0	4	none	none
34:33.9	car5	0	-5	20.26	85.275	0	4	none	none
34:34.0	car1	2	0.2	38.98	85.075	0	4	none	none
34:34.0	car2	1.445	3.0597	28.695	85.075	0	4	none	none
34:34.0	car3	0	-5	25.489	85.075	0	4	none	none
34:34.0	car4	0	-5	22.466	84.875	0	4	none	none
34:34.0	car5	0	-5	20.26	85.275	0	4	none	none
34:34.1	car1	2	0.2	39.213	85.075	0	4	none	none
34:34.1	car2	1.6776	2.4259	28.838	85.074	0	4	none	none
34:34.1	car3	0	-5	25.49	85.075	0	4	none	none
34:34.1	car4	0	-5	22.467	84.875	0	4	none	none
34:34.1	car5	0	-5	20.259	85.275	0	4	none	none
34:34.2	car1	2	0.2	39.407	85.075	0	4	none	none
34:34.2	car2	1.8537	1.7566	28.973	85.074	0	4	none	none
34:34.2	car3	0	-5	25.49	85.075	0	4	none	none
34:34.2	car4	0	-5	22.468	84.875	0	4	none	none
34:34.2	car5	0	-5	20.259	85.275	0	4	none	none
34:34.3	car1	2	0.2	39.64	85.075	0	4	none	none
34:34.3	car2	1.8628	1.8479	29.125	85.074	0	4	none	none
34:34.3	car3	0	-5	25.49	85.075	0	4	none	none
34:34.3	car4	0	-5	22.468	84.875	0	4	none	none
34:34.3	car5	0	-5	20.26	85.275	0	4	none	none
34:34.4	car1	2	0.2	39.873	85.075	0	1	none	none
34:34.4	car2	1.9768	1.1384	29.36	85.073	0	1	none	none
34:34.4	car3	0	-5	25.491	85.075	0	1	none	none
34:34.4	car4	0	-5	22.468	84.875	0	1	none	none
34:34.4	car5	0	-5	20.26	85.275	0	1	none	none
34:34.6	car1	2	0.2	40.067	85.075	0	1	none	none
34:34.6	car2	2.0341	0.5714	29.538	85.073	0	1	none	none
34:34.6	car3	0	-5	25.491	85.075	0	1	none	none
34:34.6	car4	0	-5	22.466	84.875	0	1	none	none
34:34.6	car5	0	-5	20.261	85.275	0	1	none	none
34:34.7	car1	2	0.2	40.262	85.075	0	1	none	none
34:34.7	car2	2.0524	0.1842	29.726	85.073	0	1	none	none
34:34.7	car3	0	-5	25.491	85.075	0	1	none	none
34:34.7	car4	0	-5	22.464	84.875	0	1	none	none
34:34.7	car5	0	-5	20.262	85.275	0	1	none	none
34:34.8	car1	2	0.2	40.495	85.075	0	1	none	none
34:34.8	car2	2.0479	-0.0409	29.959	85.073	0	1	none	none
34:34.8	car3	0	-5	25.491	85.075	0	1	none	none
34:34.8	car4	0	-5	22.46	84.875	0	1	none	none
34:34.8	car5	0	-5	20.263	85.275	0	1	none	none
34:34.9	car1	2	0.2	40.689	85.075	0	1	none	none
34:34.9	car2	2.0338	-0.1416	30.156	85.072	0	1	none	none
34:34.9	car3	0	-5	25.491	85.075	0	1	none	none
34:34.9	car4	0	-5	22.458	84.875	0	1	none	none
34:34.9	car5	0	-5	20.264	85.275	0	1	none	none
34:35.0	car1	2	0.2	40.922	85.075	0	4	none	none
34:35.0	car2	2.0435	-0.0446	30.355	85.072	0	4	none	none
34:35.0	car3	0	-5	25.491	85.075	0	4	none	none
34:35.0	car4	0	-5	22.458	84.875	0	4	none	none
34:35.0	car5	0	-5	20.264	85.275	0	4	none	none
34:35.1	car1	2	0.2	41.116	85.075	0	4	none	none
34:35.1	car2	2.0297	-0.1328	30.592	85.072	0	4	none	none
34:35.1	car3	0	-5	25.492	85.075	0	4	none	none
34:35.1	car4	0	-5	22.459	84.875	0	4	none	none
34:35.1	car5	0	-5	20.265	85.275	0	4	none	none
34:35.2	car1	2	0.2	41.31	85.075	0	1	none	none
34:35.2	car2	2.0153	-0.1468	30.79	85.072	0	1	none	none
34:35.2	car3	0	-5	25.492	85.075	0	1	none	none
34:35.2	car4	0	-5	22.459	84.875	0	1	none	none
34:35.2	car5	0	-5	20.264	85.275	0	1	none	none
34:35.3	car1	2	0.2	41.505	85.075	0	1	none	none
34:35.3	car2	2.0162	-0.1376	30.988	85.072	0	1	none	none
34:35.3	car3	0	-5	25.491	85.075	0	1	none	none
34:35.3	car4	0	-5	22.46	84.875	0	1	none	none
34:35.3	car5	0	-5	20.264	85.275	0	1	none	none
34:35.4	car1	2	0.2	41.738	85.075	0	1	none	none
34:35.4	car2	2.0057	-0.103	31.223	85.071	0	1	none	none
34:35.4	car3	0	-5	25.491	85.075	0	1	none	none
34:35.4	car4	0	-5	22.461	84.875	0	1	none	none
34:35.4	car5	0	-5	20.264	85.275	0	1	none	none
34:35.5	car1	2	0.2	41.932	85.075	0	1	none	none
34:35.5	car2	2.0003	-0.0574	31.419	85.071	0	1	none	none
34:35.5	car3	0	-5	25.491	85.075	0	1	none	none
34:35.5	car4	0	-5	22.461	84.875	0	1	none	none
34:35.5	car5	0	-5	20.264	85.275	0	1	none	none
34:35.6	car1	2	0.2	42.165	85.075	0	1	none	none
34:35.6	car2	2.0015	-0.0447	31.653	85.071	0	1	none	none
34:35.6	car3	0	-5	25.491	85.075	0	1	none	none
34:35.6	car4	0	-5	22.46	84.875	0	1	none	none
34:35.6	car5	0	-5	20.264	85.275	0	1	none	none
34:35.7	car1	2	0.2	42.359	85.075	0	1	none	none
34:35.7	car2	2.0021	0.0012	31.848	85.071	0	1	none	none
34:35.7	car3	0	-5	25.491	85.075	0	1	none	none
34:35.7	car4	0	-5	22.458	84.875	0	1	none	none
34:35.7	car5	0	-5	20.264	85.275	0	1	none	none
34:35.9	car1	2	0.2	42.592	85.075	0	1	none	none
34:35.9	car2	2.0054	0.0341	32.081	85.07	0	1	none	none
34:35.9	car3	0	-5	25.491	85.075	0	1	none	none
34:35.9	car4	0	-5	22.457	84.875	0	1	none	none
34:35.9	car5	0	-5	20.264	85.275	0	1	none	none
34:36.0	car1	2	0.2	42.787	85.075	0	1	none	none
34:36.0	car2	2.0104	0.0535	32.276	85.07	0	1	none	none
34:36.0	car3	0	-5	25.491	85.075	0	1	none	none
34:36.0	car4	0	-5	22.457	84.875	0	1	none	none
34:36.0	car5	0	-5	20.264	85.275	0	1	none	none
34:36.1	car1	2	0.2	43.02	85.075	0	1	none	none
34:36.1	car2	2.0161	0.0614	32.509	85.07	0	1	none	none
34:36.1	car3	0	-5	25.491	85.075	0	1	none	none
34:36.1	car4	0	-5	22.457	84.875	0	1	none	none
34:36.1	car5	0	-5	20.264	85.275	0	1	none	none
34:36.2	car1	2	0.2	43.214	85.075	0	1	none	none
34:36.2	car2	2.0217	0.0566	32.705	85.07	0	1	none	none
34:36.2	car3	0	-5	25.491	85.075	0	1	none	none
34:36.2	car4	0	-5	22.457	84.875	0	1	none	none
34:36.2	car5	0	-5	20.265	85.275	0	1	none	none
34:36.3	car1	2	0.2	43.447	85.075	0	4	none	none
34:36.3	car2	2.0319	0.1585	32.9	85.069	0	4	none	none
34:36.3	car3	0	-4.4868	25.491	85.075	0	4	none	none
34:36.3	car4	0	-5	22.458	84.875	0	4	none	none
34:36.3	car5	0	-5	20.265	85.275	0	4	none	none
34:36.4	car1	2	0.2	43.641	85.075	0	4	none	none
34:36.4	car2	2.0396	0.0757	33.136	85.069	0	4	none	none
34:36.4	car3	0	-3.6539	25.491	85.075	0	4	none	none
34:36.4	car4	0	-5	22.458	84.875	0	4	none	none
34:36.4	car5	0	-5	20.265	85.275	0	4	none	none
34:36.5	car1	2	0.2	43.874	85.075	0	4	none	none
34:36.5	car2	2.0488	0.1678	33.333	85.069	0	4	none	none
34:36.5	car3	0	-3.0917	25.49	85.075	0	4	none	none
34:36.5	car4	0	-5	22.457	84.875	0	4	none	none
34:36.5	car5	0	-5	20.265	85.275	0	4	none	none
34:36.6	car1	2	0.2	44.068	85.075	0	4	none	none
34:36.6	car2	2.0526	0.0358	33.57	85.068	0	4	none	none
34:36.6	car3	0	-1.8823	25.489	85.075	0	4	none	none
34:36.6	car4	0	-5	22.457	84.875	0	4	none	none
34:36.6	car5	0	-5	20.264	85.275	0	4	none	none
34:36.7	car1	2	0.2	44.263	85.075	0	1	none	none
34:36.7	car2	2.0491	-0.0392	33.769	85.068	0	1	none	none
34:36.7	car3	0	-0.7708	25.488	85.075	0	1	none	none
34:36.7	car4	0	-5	22.458	84.875	0	1	none	none
34:36.7	car5	0	-5	20.264	85.275	0	1	none	none
34:36.8	car1	2	0.2	44.496	85.075	0	4	none	none
34:36.8	car2	2.0517	0.0274	33.968	85.068	0	4	none	none
34:36.8	car3	0.0373	0.3131	25.488	85.075	0	4	none	none
34:36.8	car4	0	-5	22.458	84.875	0	4	none	none
34:36.8	car5	0	-5	20.264	85.275	0	4	none	none
34:36.9	car1	2	0.2	44.69	85.075	0	4	none	none
34:36.9	car2	2.0471	-0.0488	34.207	85.068	0	4	none	none
34:36.9	car3	0.1678	1.3076	25.491	85.075	0	4	none	none
34:36.9	car4	0	-5	22.459	84.875	0	4	none	none
34:36.9	car5	0	-5	20.264	85.275	0	4	none	none
34:37.0	car1	2	0.2	44.923	85.075	0	4	none	none
34:37.0	car2	2.0565	0.0449	34.406	85.068	0	4	none	none
34:37.0	car3	0.2205	1.845	25.495	85.075	0	4	none	none
34:37.0	car4	0	-5	22.46	84.875	0	4	none	none
34:37.0	car5	0	-5	20.263	85.275	0	4	none	none
34:37.2	car1	2	0.2	45.117	85.075	0	4	none	none
34:37.2	car2	2.051	-0.0599	34.645	85.067	0	4	none	none
34:37.2	car3	0.4904	2.6937	25.505	85.075	0	4	none	none
34:37.2	car4	0	-5	22.46	84.875	0	4	none	none
34:37.2	car5	0	-5	20.263	85.275	0	4	none	none
34:37.3	car1	2	0.2	45.311	85.075	0	1	none	none
34:37.3	car2	2.0505	-0.0647	34.844	85.067	0	1	none	none
34:37.3	car3	0.5266	3.0555	25.522	85.075	0	1	none	none
34:37.3	car4	0	-5	22.46	84.875	0	1	none	none
34:37.3	car5	0	-5	20.262	85.275	0	1	none	none
34:37.4	car1	2	0.2	45.545	85.075	0	1	none	none
34:37.4	car2	2.0394	-0.1063	35.083	85.067	0	1	none	none
34:37.4	car3	0.872	3.45	25.561	85.075	0	1	none	none
34:37.4	car4	0	-5	22.459	84.875	0	1	none	none
34:37.4	car5	0	-5	20.262	85.275	0	1	none	none
34:37.5	car1	2	0.2	45.739	85.075	0	1	none	none
34:37.5	car2	2.0286	-0.1042	35.282	85.067	0	1	none	none
34:37.5	car3	1.1946	3.2265	25.607	85.075	0	1	none	none
34:37.5	car4	0	-5	22.459	84.875	0	1	none	none
34:37.5	car5	0	-5	20.262	85.275	0	1	none	none
34:37.6	car1	2	0.2	45.972	85.075	0	1	none	none
34:37.6	car2	2.0207	-0.0825	35.52	85.066	0	1	none	none
34:37.6	car3	1.47	2.7503	25.69	85.075	0	1	none	none
34:37.6	car4	0	-5	22.459	84.875	0	1	none	none
34:37.6	car5	0	-5	20.262	85.275	0	1	none	none
34:37.7	car1	2	0.2	46.166	85.075	0	1	none	none
34:37.7	car2	2.0159	-0.051	35.717	85.066	0	1	none	none
34:37.7	car3	1.6825	2.1248	25.787	85.075	0	1	none	none
34:37.7	car4	0	-5	22.459	84.875	0	1	none	none
34:37.7	car5	0	-5	20.262	85.275	0	1	none	none
34:37.8	car1	2	0.2	46.36	85.075	0	1	none	none
34:37.8	car2	2.0139	-0.0209	35.914	85.066	0	1	none	none
34:37.8	car3	1.8343	1.513	25.907	85.075	0	1	none	none
34:37.8	car4	0	-5	22.459	84.875	0	1	none	none
34:37.8	car5	0	-5	20.263	85.275	0	1	none	none
34:37.9	car1	2	0.2	46.593	85.075	0	1	none	none
34:37.9	car2	2.0144	0.0038	36.149	85.066	0	1	none	none
34:37.9	car3	1.9346	1.0063	26.084	85.075	0	1	none	none
34:37.9	car4	0	-5	22.459	84.875	0	1	none	none
34:37.9	car5	0	-5	20.262	85.275	0	1	none	none
34:38.0	car1	2	0.2	46.788	85.075	0	1	none	none
34:38.0	car2	2.0164	0.0235	36.345	85.065	0	1	none	none
34:38.0	car3	1.9946	0.5958	26.252	85.075	0	1	none	none
34:38.0	car4	0	-5	22.459	84.875	0	1	none	none
34:38.0	car5	0	-5	20.262	85.275	0	1	none	none
34:38.1	car1	2	0.2	47.021	85.075	0	1	none	none
34:38.1	car2	2.0196	0.0363	36.579	85.065	0	1	none	none
34:38.1	car3	2.0069	0.1187	26.47	85.075	0	1	none	none
34:38.1	car4	0	-5	22.459	84.875	0	1	none	none
34:38.1	car5	0	-5	20.262	85.275	0	1	none	none
34:38.2	car1	2	0.2	47.215	85.075	0	1	none	none
34:38.2	car2	2.0238	0.0383	36.775	85.065	0	1	none	none
34:38.2	car3	1.9945	-0.1253	26.66	85.075	0	1	none	none
34:38.2	car4	0	-5	22.46	84.875	0	1	none	none
34:38.2	car5	0	-5	20.262	85.275	0	1	none	none
34:38.4	car1	2	0.2	47.215	85.075	0	1	none	none
34:38.4	car2	2.0279	0.0406	36.775	85.065	0	1	none	none
34:38.4	car3	1.9736	-0.2093	26.66	85.075	0	1	none	none
34:38.4	car4	0	-5	22.46	84.875	0	1	none	none
34:38.4	car5	0	-5	20.262	85.275	0	1	none	none
34:38.5	car1	2	0.2	47.215	85.075	0	1	none	none
34:38.5	car2	2.0321	0.0424	36.775	85.065	0	1	none	none
34:38.5	car3	1.9542	-0.1935	26.66	85.075	0	1	none	none
34:38.5	car4	0	-5	22.46	84.875	0	1	none	none
34:38.5	car5	0	-5	20.262	85.275	0	1	none	none
34:38.6	car1	2	0.2	47.215	85.075	0	1	none	none
34:38.6	car2	2.0365	0.0436	36.775	85.065	0	1	none	none
34:38.6	car3	1.9411	-0.1312	26.66	85.075	0	1	none	none
34:38.6	car4	0	-5	22.46	84.875	0	1	none	none
34:38.6	car5	0	-5	20.262	85.275	0	1	none	none
34:38.7	car1	2	0.2	47.215	85.075	0	1	none	none
34:38.7	car2	2.0409	0.0441	36.775	85.065	0	1	none	none
34:38.7	car3	1.9351	-0.0599	26.66	85.075	0	1	none	none
34:38.7	car4	0	-5	22.46	84.875	0	1	none	none
34:38.7	car5	0	-5	20.262	85.275	0	1	none	none
34:38.8	car1	2	0.2	47.836	85.075	0	1	none	none
34:38.8	car2	2.0261	0.0607	37.403	85.064	0	1	none	none
34:38.8	car3	2.0013	-0.057	27.28	85.075	0	1	none	none
34:38.8	car4	0	-5	22.458	84.875	0	1	none	none
34:38.8	car5	0	-5	20.268	85.275	0	1	none	none
34:38.9	car1	2	0.2	48.07	85.075	0	1	none	none
34:38.9	car2	2.0324	0.0644	37.639	85.064	0	1	none	none
34:38.9	car3	1.9898	-0.112	27.512	85.075	0	1	none	none
34:38.9	car4	0	-5	22.458	84.875	0	1	none	none
34:38.9	car5	0	-5	20.272	85.275	0	1	none	none
34:39.0	car1	2	0.2	48.303	85.075	0	1	none	none
34:39.0	car2	2.0374	0.0544	37.875	85.064	0	1	none	none
34:39.0	car3	1.9802	-0.0983	27.745	85.074	0	1	none	none
34:39.0	car4	0	-5	22.457	84.875	0	1	none	none
34:39.0	car5	0	-5	20.273	85.275	0	1	none	none
34:39.1	car1	2	0.2	48.536	85.075	0	4	none	none
34:39.1	car2	2.0508	0.1377	38.072	85.063	0	4	none	none
34:39.1	car3	1.9795	-0.0051	27.939	85.074	0	4	none	none
34:39.1	car4	0	-5	22.457	84.875	0	4	none	none
34:39.1	car5	0	-5	20.273	85.275	0	4	none	none
34:39.2	car1	2	0.2	48.73	85.075	0	4	none	none
34:39.2	car2	2.0558	0.0476	38.31	85.063	0	4	none	none
34:39.2	car3	1.9825	0.0252	28.17	85.074	0	4	none	none
34:39.2	car4	0	-5	22.457	84.875	0	4	none	none
34:39.2	car5	0	-5	20.274	85.275	0	4	none	none
34:39.4	car1	2	0.2	48.963	85.075	0	4	none	none
34:39.4	car2	2.0646	0.0862	38.509	85.063	0	4	none	none
34:39.4	car3	1.9926	0.1061	28.362	85.074	0	4	none	none
34:39.4	car4	0	-5	22.457	84.875	0	4	none	none
34:39.4	car5	0	-5	20.274	85.275	0	4	none	none
34:39.5	car1	2	0.2	49.235	85.075	0	4	none	none
34:39.5	car2	2.0627	-0.0228	38.828	85.062	0	4	none	none
34:39.5	car3	2.0035	0.1055	28.67	85.074	0	4	none	none
34:39.5	car4	0	-5	22.456	84.875	0	4	none	none
34:39.5	car5	0	-5	20.275	85.275	0	4	none	none
34:39.6	car1	2	0.2	49.429	85.075	0	1	none	none
34:39.6	car2	2.0552	-0.0776	39.028	85.062	0	1	none	none
34:39.6	car3	2.0122	0.0919	28.864	85.074	0	1	none	none
34:39.6	car4	0	-5	22.457	84.875	0	1	none	none
34:39.6	car5	0	-5	20.275	85.275	0	1	none	none
34:39.7	car1	2	0.2	49.662	85.075	0	4	none	none
34:39.7	car2	2.0556	0.0057	39.228	85.062	0	4	none	none
34:39.7	car3	2.0237	0.1167	29.058	85.074	0	4	none	none
34:39.7	car4	0	-5	22.458	84.875	0	4	none	none
34:39.7	car5	0	-5	20.276	85.275	0	4	none	none
34:39.8	car1	2	0.2	49.857	85.075	0	4	none	none
34:39.8	car2	2.0503	-0.0569	39.468	85.062	0	4	none	none
34:39.8	car3	2.0307	0.0665	29.292	85.074	0	4	none	none
34:39.8	car4	0	-5	22.459	84.875	0	4	none	none
34:39.8	car5	0	-5	20.276	85.275	0	4	none	none
34:39.9	car1	2	0.2	50.09	85.075	0	1	none	none
34:39.9	car2	2.0495	-0.0647	39.708	85.061	0	1	none	none
34:39.9	car3	2.031	0.0696	29.527	85.074	0	1	none	none
34:39.9	car4	0	-5	22.459	84.875	0	1	none	none
34:39.9	car5	0	-5	20.276	85.275	0	1	none	none
34:40.0	car1	2	0.2	50.323	85.075	0	4	none	none
34:40.0	car2	2.0509	0.0089	39.907	85.061	0	4	none	none
34:40.0	car3	2.0385	0.0754	29.724	85.074	0	4	none	none
34:40.0	car4	0	-5	22.46	84.875	0	4	none	none
34:40.0	car5	0	-5	20.277	85.275	0	4	none	none
34:40.2	car1	2	0.2	50.517	85.075	0	4	none	none
34:40.2	car2	2.0451	-0.0589	40.146	85.061	0	4	none	none
34:40.2	car3	2.0396	0.0165	29.961	85.074	0	4	none	none
34:40.2	car4	0	-4.4838	22.46	84.875	0	4	none	none
34:40.2	car5	0	-5	20.277	85.275	0	4	none	none
34:40.3	car1	2	0.2	50.711	85.075	0	1	none	none
34:40.3	car2	2.0368	-0.0816	40.345	85.061	0	1	none	none
34:40.3	car3	2.0377	-0.0226	30.159	85.074	0	1	none	none
34:40.3	car4	0	-3.731	22.461	84.875	0	1	none	none
34:40.3	car5	0	-5	20.278	85.275	0	1	none	none
34:40.4	car1	2	0.2	50.944	85.075	0	1	none	none
34:40.4	car2	2.0293	-0.0771	40.583	85.06	0	1	none	none
34:40.4	car3	2.0334	-0.0459	30.396	85.074	0	1	none	none
34:40.4	car4	0	-2.7748	22.462	84.875	0	1	none	none
34:40.4	car5	0	-5	20.279	85.275	0	1	none	none
34:40.5	car1	2	0.2	51.139	85.075	0	1	none	none
34:40.5	car2	2.0236	-0.0539	40.781	85.06	0	1	none	none
34:40.5	car3	2.0276	-0.0539	30.594	85.074	0	1	none	none
34:40.5	car4	0	-1.8103	22.462	84.875	0	1	none	none
34:40.5	car5	0	-5	20.278	85.275	0	1	none	none
34:40.6	car1	2	0.2	51.372	85.075	0	1	none	none
34:40.6	car2	2.024	-0.05	41.018	85.06	0	1	none	none
34:40.6	car3	2.0276	-0.0536	30.831	85.074	0	1	none	none
34:40.6	car4	0	-1.1952	22.461	84.875	0	1	none	none
34:40.6	car5	0	-5	20.278	85.275	0	1	none	none
34:40.7	car1	2	0.2	51.566	85.075	0	1	none	none
34:40.7	car2	2.0217	-0.0225	41.215	85.06	0	1	none	none
34:40.7	car3	2.023	-0.0504	31.028	85.074	0	1	none	none
34:40.7	car4	0	0.0766	22.459	84.876	0	1	none	none
34:40.7	car5	0	-5	20.277	85.275	0	1	none	none
34:40.8	car1	2	0.2	51.799	85.075	0	1	none	none
34:40.8	car2	2.0219	-0.0013	41.451	85.059	0	1	none	none
34:40.8	car3	2.0192	-0.038	31.264	85.074	0	1	none	none
34:40.8	car4	0.128	1.2805	22.458	84.876	0	1	none	none
34:40.8	car5	0	-5	20.276	85.275	0	1	none	none
34:40.9	car1	2	0.2	51.993	85.075	0	1	none	none
34:40.9	car2	2.0234	0.0142	41.647	85.059	0	1	none	none
34:40.9	car3	2.0167	-0.0229	31.461	85.074	0	1	none	none
34:40.9	car4	0.335	2.0695	22.461	84.876	0	1	none	none
34:40.9	car5	0	-5	20.276	85.275	0	1	none	none
34:41.0	car1	2	0.2	52.188	85.075	0	1	none	none
34:41.0	car2	2.0239	0.0193	41.844	85.059	0	1	none	none
34:41.0	car3	2.0174	-0.016	31.657	85.074	0	1	none	none
34:41.0	car4	0.3761	2.4807	22.468	84.875	0	1	none	none
34:41.0	car5	0	-5	20.274	85.275	0	1	none	none
34:41.1	car1	2	0.2	52.382	85.075	0	1	none	none
34:41.1	car2	2.0259	0.0293	42.04	85.059	0	1	none	none
34:41.1	car3	2.017	0	31.853	85.074	0	1	none	none
34:41.1	car4	0.6188	2.838	22.489	84.875	0	1	none	none
34:41.1	car5	0	-5	20.272	85.275	0	1	none	none
34:41.2	car1	2	0.2	52.615	85.075	0	1	none	none
34:41.2	car2	2.0292	0.0324	42.276	85.058	0	1	none	none
34:41.2	car3	2.0189	0.0187	32.088	85.074	0	1	none	none
34:41.2	car4	0.9261	3.0712	22.525	84.875	0	1	none	none
34:41.2	car5	0	-5	20.272	85.275	0	1	none	none
34:41.3	car1	2	0.2	52.809	85.075	0	1	none	none
34:41.3	car2	2.0319	0.0294	42.473	85.058	0	1	none	none
34:41.3	car3	2.0221	0.0309	32.284	85.074	0	1	none	none
34:41.3	car4	1.2118	2.8579	22.573	84.874	0	1	none	none
34:41.3	car5	0	-5	20.272	85.275	0	1	none	none
34:41.4	car1	2	0.2	53.042	85.075	0	4	none	none
34:41.4	car2	2.0441	0.1211	42.67	85.058	0	4	none	none
34:41.4	car3	2.0306	0.0858	32.48	85.074	0	4	none	none
34:41.4	car4	1.4558	2.4383	22.647	84.873	0	4	none	none
34:41.4	car5	0	-5	20.272	85.275	0	4	none	none
34:41.6	car1	2	0.2	53.236	85.075	0	4	none	none
34:41.6	car2	2.0484	0.0444	42.906	85.058	0	4	none	none
34:41.6	car3	2.0369	0.0592	32.716	85.074	0	4	none	none
34:41.6	car4	1.6494	1.9341	22.77	84.872	0	4	none	none
34:41.6	car5	0	-5	20.272	85.275	0	4	none	none
34:41.7	car1	2	0.2	53.431	85.075	0	1	none	none
34:41.7	car2	2.0477	-0.0035	43.105	85.057	0	1	none	none
34:41.7	car3	2.0412	0.0416	32.913	85.073	0	1	none	none
34:41.7	car4	1.7909	1.419	22.899	84.87	0	1	none	none
34:41.7	car5	0	-5	20.271	85.275	0	1	none	none
34:41.8	car1	2	0.2	53.664	85.075	0	4	none	none
34:41.8	car2	2.055	0.0702	43.303	85.057	0	4	none	none
34:41.8	car3	2.0485	0.075	33.11	85.073	0	4	none	none
34:41.8	car4	1.8905	0.9947	23.047	84.869	0	4	none	none
34:41.8	car5	0	-5	20.272	85.275	0	4	none	none
34:41.9	car1	2	0.2	53.858	85.075	0	4	none	none
34:41.9	car2	2.0539	-0.0114	43.542	85.057	0	4	none	none
34:41.9	car3	2.0523	0.0326	33.348	85.073	0	4	none	none
34:41.9	car4	1.9532	0.6218	23.249	84.866	0	4	none	none
34:41.9	car5	0	-5	20.272	85.275	0	4	none	none
34:42.0	car1	2	0.2	54.052	85.075	0	1	none	none
34:42.0	car2	2.0488	-0.052	43.741	85.057	0	1	none	none
34:42.0	car3	2.0522	0.0021	33.547	85.073	0	1	none	none
34:42.0	car4	1.9876	0.3459	23.427	84.864	0	1	none	none
34:42.0	car5	0	-5	20.272	85.275	0	1	none	none
34:42.1	car1	2	0.2	54.285	85.075	0	1	none	none
34:42.1	car2	2.0481	-0.059	43.981	85.056	0	1	none	none
34:42.1	car3	2.0519	-0.001	33.786	85.073	0	1	none	none
34:42.1	car4	1.9915	0.385	23.65	84.862	0	1	none	none
34:42.1	car5	0	-5	20.272	85.275	0	1	none	none
34:42.2	car1	2	0.2	54.48	85.075	0	1	none	none
34:42.2	car2	2.0411	-0.0692	44.18	85.056	0	1	none	none
34:42.2	car3	2.0495	-0.0249	33.985	85.073	0	1	none	none
34:42.2	car4	2.0117	0.1971	23.841	84.86	0	1	none	none
34:42.2	car5	0	-5	20.273	85.275	0	1	none	none
34:42.3	car1	2	0.2	54.713	85.075	0	4	none	none
34:42.3	car2	2.0509	0.0287	44.379	85.056	0	4	none	none
34:42.3	car3	2.0541	0.0212	34.184	85.073	0	4	none	none
34:42.3	car4	2.0163	0.2428	24.033	84.858	0	4	none	none
34:42.3	car5	0	-5	20.273	85.275	0	4	none	none
34:42.4	car1	2	0.2	54.907	85.075	0	4	none	none
34:42.4	car2	2.0476	-0.0341	44.617	85.056	0	4	none	none
34:42.4	car3	2.0518	-0.0215	34.423	85.073	0	4	none	none
34:42.4	car4	2.0243	0.0825	24.266	84.855	0	4	none	none
34:42.4	car5	0	-5	20.273	85.275	0	4	none	none
34:42.5	car1	2	0.2	55.101	85.075	0	1	none	none
34:42.5	car2	2.0472	-0.0381	44.816	85.055	0	1	none	none
34:42.5	car3	2.0514	-0.0256	34.623	85.073	0	1	none	none
34:42.5	car4	2.0241	0.0809	24.461	84.853	0	1	none	none
34:42.5	car5	0	-5	20.273	85.275	0	1	none	none
34:42.6	car1	2	0.2	55.334	85.075	0	4	none	none
34:42.6	car2	2.0503	0.0325	45.015	85.055	0	4	none	none
34:42.6	car3	2.0511	0.0006	34.822	85.073	0	4	none	none
34:42.6	car4	2.0273	0.0331	24.657	84.851	0	4	none	none
34:42.6	car5	0	-5	20.273	85.275	0	4	none	none
34:42.7	car1	2	0.2	55.529	85.075	0	4	none	none
34:42.7	car2	2.0461	-0.039	45.254	85.055	0	4	none	none
34:42.7	car3	2.0478	-0.0325	35.061	85.073	0	4	none	none
34:42.7	car4	2.023	-0.0404	24.893	84.848	0	4	none	none
34:42.7	car5	0	-5	20.273	85.275	0	4	none	none
34:42.8	car1	2	0.2	55.723	85.075	0	1	none	none
34:42.8	car2	2.0392	-0.0684	45.453	85.055	0	1	none	none
34:42.8	car3	2.0432	-0.0482	35.26	85.073	0	1	none	none
34:42.8	car4	2.0165	-0.065	25.089	84.846	0	1	none	none
34:42.8	car5	0	-5	20.272	85.275	0	1	none	none
34:43.0	car1	2	0.2	55.956	85.075	0	1	none	none
34:43.0	car2	2.0321	-0.0694	45.691	85.054	0	1	none	none
34:43.0	car3	2.0374	-0.0561	35.499	85.073	0	1	none	none
34:43.0	car4	2.0106	-0.0642	25.325	84.843	0	1	none	none
34:43.0	car5	0	-5	20.272	85.275	0	1	none	none
34:43.1	car1	2	0.2	56.15	85.075	0	1	none	none
34:43.1	car2	2.0266	-0.0538	45.889	85.054	0	1	none	none
34:43.1	car3	2.0315	-0.0545	35.697	85.073	0	1	none	none
34:43.1	car4	2.0059	-0.0515	25.521	84.841	0	1	none	none
34:43.1	car5	0	-5	20.272	85.275	0	1	none	none
34:43.2	car1	2	0.2	56.345	85.075	0	1	none	none
34:43.2	car2	2.0238	-0.0321	46.087	85.054	0	1	none	none
34:43.2	car3	2.0265	-0.0446	35.895	85.073	0	1	none	none
34:43.2	car4	2.0029	-0.0314	25.716	84.839	0	1	none	none
34:43.2	car5	0	-5	20.272	85.275	0	1	none	none
34:43.3	car1	2	0.2	56.578	85.075	0	1	none	none
34:43.3	car2	2.0228	-0.0116	46.323	85.054	0	1	none	none
34:43.3	car3	2.0226	-0.0336	36.132	85.073	0	1	none	none
34:43.3	car4	2.0017	-0.0126	25.95	84.836	0	1	none	none
34:43.3	car5	0	-5	20.271	85.275	0	1	none	none
34:43.4	car1	2	0.2	56.772	85.075	0	1	none	none
34:43.4	car2	2.0233	0.0033	46.52	85.054	0	1	none	none
34:43.4	car3	2.0209	-0.021	36.329	85.073	0	1	none	none
34:43.4	car4	2.0022	0.0016	26.145	84.834	0	1	none	none
34:43.4	car5	0	-5	20.27	85.275	0	1	none	none
34:43.5	car1	2	0.2	57.004	85.075	0	4	none	none
34:43.5	car2	2.0341	0.1106	46.716	85.053	0	4	none	none
34:43.5	car3	2.025	0.0403	36.525	85.073	0	4	none	none
34:43.5	car4	2.0082	0.0616	26.339	84.832	0	4	none	none
34:43.5	car5	0	-5	20.27	85.275	0	4	none	none
34:43.6	car1	2	0.2	57.198	85.072	0	4	none	none
34:43.6	car2	2.0384	0.0443	46.952	85.053	0	4	none	none
34:43.6	car3	2.0277	0.0267	36.761	85.073	0	4	none	none
34:43.6	car4	2.0122	0.0423	26.572	84.829	0	4	none	none
34:43.6	car5	0	-5	20.27	85.275	0	4	none	none
34:43.7	car1	2	0.2	57.353	85.07	0	1	none	none
34:43.7	car2	2.0381	0.0412	47.11	85.053	0	1	none	none
34:43.7	car3	2.0281	0.0313	36.918	85.073	0	1	none	none
34:43.7	car4	2.0125	0.0452	26.728	84.827	0	1	none	none
34:43.7	car5	0	-5	20.27	85.275	0	1	none	none
34:43.8	car1	2	0.2	57.626	85.067	0	1	none	none
34:43.8	car2	2.0377	-0.003	47.387	85.053	0	1	none	none
34:43.8	car3	2.0309	0.0294	37.193	85.073	0	1	none	none
34:43.8	car4	2.0166	0.0365	27.001	84.824	0	1	none	none
34:43.8	car5	0	-5	20.271	85.275	0	1	none	none
34:43.9	car1	2	0.2	57.822	85.066	0	1	none	none
34:43.9	car2	2.0382	0.0024	47.584	85.052	0	1	none	none
34:43.9	car3	2.0313	0.0327	37.39	85.073	0	1	none	none
34:43.9	car4	2.0171	0.0412	27.197	84.822	0	1	none	none
34:43.9	car5	0	-5	20.271	85.275	0	1	none	none
34:44.0	car1	2	0.2	58.053	85.062	0	1	none	none
34:44.0	car2	2.0355	-0.0247	47.822	85.052	0	1	none	none
34:44.0	car3	2.0335	0.0254	37.627	85.073	0	1	none	none
34:44.0	car4	2.0209	0.0385	27.431	84.819	0	1	none	none
34:44.0	car5	0	-5	20.271	85.275	0	1	none	none
34:44.1	car1	2	0.2	58.248	85.062	0	1	none	none
34:44.1	car2	2.0321	-0.029	48.02	85.052	0	1	none	none
34:44.1	car3	2.0355	0.0152	37.824	85.073	0	1	none	none
34:44.1	car4	2.0246	0.0362	27.627	84.817	0	1	none	none
34:44.1	car5	0	-4.7996	20.272	85.275	0	1	none	none
34:44.2	car1	2	0.2	58.442	85.063	0	1	none	none
34:44.2	car2	2.0298	-0.0217	48.217	85.052	0	1	none	none
34:44.2	car3	2.0355	0.0055	38.021	85.073	0	1	none	none
34:44.2	car4	2.0281	0.0313	27.823	84.815	0	1	none	none
34:44.2	car5	0	-4.21	20.273	85.275	0	1	none	none
34:44.3	car1	2	0.2	58.676	85.063	0	1	none	none
34:44.3	car2	2.0289	-0.011	48.454	85.051	0	1	none	none
34:44.3	car3	2.0349	-0.0009	38.258	85.072	0	1	none	none
34:44.3	car4	2.0306	0.0257	28.059	84.812	0	1	none	none
34:44.3	car5	0	-3.3035	20.272	85.275	0	1	none	none
34:44.5	car1	2	0.2	58.872	85.064	0	1	none	none
34:44.5	car2	2.0294	0.0044	48.651	85.051	0	1	none	none
34:44.5	car3	2.0346	-0.0038	38.456	85.072	0	1	none	none
34:44.5	car4	2.0331	0.0215	28.256	84.81	0	1	none	none
34:44.5	car5	0	-2.3587	20.273	85.275	0	1	none	none
34:44.6	car1	2	0.2	59.066	85.067	0	1	none	none
34:44.6	car2	2.0295	0.0049	48.849	85.051	0	1	none	none
34:44.6	car3	2.0346	-0.004	38.654	85.072	0	1	none	none
34:44.6	car4	2.0333	0.0226	28.453	84.808	0	1	none	none
34:44.6	car5	0	-1.8492	20.272	85.275	0	1	none	none
34:44.7	car1	2	0.2	59.3	85.07	0	1	none	none
34:44.7	car2	2.0307	0.0172	49.085	85.051	0	1	none	none
34:44.7	car3	2.0345	-0.0052	38.891	85.072	0	1	none	none
34:44.7	car4	2.0347	0.0166	28.69	84.805	0	1	none	none
34:44.7	car5	0	-0.8226	20.271	85.275	0	1	none	none
34:44.8	car1	2	0.2	59.494	85.071	0	1	none	none
34:44.8	car2	2.0332	0.0218	49.282	85.05	0	1	none	none
34:44.8	car3	2.034	-0.0002	39.088	85.072	0	1	none	none
34:44.8	car4	2.036	0.0104	28.887	84.803	0	1	none	none
34:44.8	car5	0.0413	0.4529	20.27	85.275	0	1	none	none
34:44.9	car1	2	0.2	59.727	85.071	0	4	none	none
34:44.9	car2	2.0431	0.1209	49.479	85.05	0	4	none	none
34:44.9	car3	2.0388	0.048	39.286	85.072	0	4	none	none
34:44.9	car4	2.0411	0.0607	29.084	84.801	0	4	none	none
34:44.9	car5	0.0936	0.9763	20.27	85.275	0	4	none	none
34:45.0	car1	2	0.2	59.921	85.072	0	4	none	none
34:45.0	car2	2.0478	0.0478	49.716	85.05	0	4	none	none
34:45.0	car3	2.0418	0.0282	39.523	85.072	0	4	none	none
34:45.0	car4	2.0433	0.0233	29.322	84.798	0	4	none	none
34:45.0	car5	0.3076	2.226	20.274	85.275	0	4	none	none
34:45.1	car1	2	0.2	60.116	85.072	0	1	none	none
34:45.1	car2	2.048	-0.0001	49.915	85.05	0	1	none	none
34:45.1	car3	2.044	0.0196	39.721	85.072	0	1	none	none
34:45.1	car4	2.0434	0.0042	29.52	84.796	0	1	none	none
34:45.1	car5	0.5906	2.8255	20.279	85.275	0	1	none	none
34:45.2	car1	2	0.2	60.349	85.072	0	1	none	none
34:45.2	car2	2.0453	-0.0266	50.153	85.049	0	1	none	none
34:45.2	car3	2.045	0.0097	39.959	85.072	0	1	none	none
34:45.2	car4	2.0426	-0.0045	29.758	84.793	0	1	none	none
34:45.2	car5	0.8918	3.0076	20.304	85.275	0	1	none	none
34:45.3	car1	2	0.2	60.543	85.072	0	1	none	none
34:45.3	car2	2.0414	-0.0359	50.352	85.049	0	1	none	none
34:45.3	car3	2.045	0.0003	40.157	85.072	0	1	none	none
34:45.3	car4	2.0423	-0.0071	29.956	84.791	0	1	none	none
34:45.3	car5	1.1715	2.7951	20.347	85.275	0	1	none	none
34:45.4	car1	2	0.2	60.737	85.072	0	1	none	none
34:45.4	car2	2.0379	-0.0314	50.55	85.049	0	1	none	none
34:45.4	car3	2.0438	-0.0117	40.356	85.072	0	1	none	none
34:45.4	car4	2.0415	-0.0052	30.154	84.789	0	1	none	none
34:45.4	car5	1.1897	2.9773	20.412	85.275	0	1	none	none
34:45.5	car1	2	0.2	60.97	85.072	0	4	none	none
34:45.5	car2	2.0453	0.0731	50.749	85.049	0	4	none	none
34:45.5	car3	2.0471	0.0312	40.554	85.072	0	4	none	none
34:45.5	car4	2.0461	0.0411	30.353	84.787	0	4	none	none
34:45.5	car5	1.4489	2.589	20.498	85.275	0	4	none	none
34:45.6	car1	2	0.2	61.165	85.072	0	4	none	none
34:45.6	car2	2.0464	0.0138	50.986	85.048	0	4	none	none
34:45.6	car3	2.0474	0.0039	40.792	85.072	0	4	none	none
34:45.6	car4	2.0472	0.0121	30.59	84.784	0	4	none	none
34:45.6	car5	1.6536	2.0465	20.626	85.275	0	4	none	none
34:45.7	car1	2	0.2	61.359	85.072	0	1	none	none
34:45.7	car2	2.0439	-0.0207	51.185	85.048	0	1	none	none
34:45.7	car3	2.046	-0.0098	40.991	85.072	0	1	none	none
34:45.7	car4	2.0464	-0.006	30.789	84.782	0	1	none	none
34:45.7	car5	1.8029	1.4887	20.751	85.275	0	1	none	none
34:45.8	car1	2	0.2	61.553	85.072	0	1	none	none
34:45.8	car2	2.0436	-0.0239	51.384	85.048	0	1	none	none
34:45.8	car3	2.0459	-0.0109	41.19	85.072	0	1	none	none
34:45.8	car4	2.0462	-0.0077	30.988	84.78	0	1	none	none
34:45.8	car5	1.8053	1.5133	20.899	85.275	0	1	none	none
34:46.0	car1	2	0.2	61.786	85.072	0	1	none	none
34:46.0	car2	2.0399	-0.0406	51.622	85.048	0	1	none	none
34:46.0	car3	2.044	-0.0197	41.428	85.072	0	1	none	none
34:46.0	car4	2.0442	-0.018	31.226	84.777	0	1	none	none
34:46.0	car5	1.905	0.9995	21.096	85.275	0	1	none	none
34:46.1	car1	2	0.2	62.058	85.072	0	4	none	none
34:46.1	car2	2.0455	0.0552	51.86	85.047	0	4	none	none
34:46.1	car3	2.0461	0.0208	41.667	85.072	0	4	none	none
34:46.1	car4	2.0468	0.028	31.464	84.774	0	4	none	none
34:46.1	car5	1.9672	0.6225	21.302	85.275	0	4	none	none
34:46.2	car1	2	0.2	62.291	85.072	0	4	none	none
34:46.2	car2	2.0447	-0.0129	52.138	85.047	0	4	none	none
34:46.2	car3	2.0452	-0.0078	41.945	85.072	0	4	none	none
34:46.2	car4	2.0465	-0.0047	31.742	84.771	0	4	none	none
34:46.2	car5	1.9988	0.3184	21.557	85.275	0	4	none	none
34:46.4	car1	2	0.2	62.602	85.072	0	1	none	none
34:46.4	car2	2.0401	-0.0494	52.455	85.047	0	1	none	none
34:46.4	car3	2.0426	-0.0239	42.262	85.072	0	1	none	none
34:46.4	car4	2.0563	0.1031	32.021	84.768	0	1	none	none
34:46.4	car5	2.0207	0.2174	21.822	85.275	0	1	none	none
34:46.5	car1	2	0.2	62.874	85.072	0	1	none	none
34:46.5	car2	2.0396	-0.0538	52.733	85.046	0	1	none	none
34:46.5	car3	2.0421	-0.0288	42.541	85.072	0	1	none	none
34:46.5	car4	2.0465	0.0046	32.338	84.765	0	1	none	none
34:46.5	car5	2.0163	0.1727	22.13	85.275	0	1	none	none
34:46.7	car1	2	0.2	63.185	85.072	0	1	none	none
34:46.7	car2	2.033	-0.0701	53.051	85.046	0	1	none	none
34:46.7	car3	2.038	-0.0395	42.858	85.072	0	1	none	none
34:46.7	car4	2.0424	-0.0363	32.657	84.761	0	1	none	none
34:46.7	car5	2.0231	0.071	22.443	85.276	0	1	none	none
34:46.8	car1	2	0.2	63.418	85.072	0	1	none	none
34:46.8	car2	2.0268	-0.062	53.288	85.046	0	1	none	none
34:46.8	car3	2.0334	-0.0464	43.096	85.072	0	1	none	none
34:46.8	car4	2.0364	-0.0561	32.896	84.758	0	1	none	none
34:46.8	car5	2.0239	0.0094	22.677	85.276	0	1	none	none
34:46.9	car1	2	0.2	63.651	85.072	0	1	none	none
34:46.9	car2	2.0323	0.0534	53.486	85.045	0	1	none	none
34:46.9	car3	2.0334	0.0037	43.294	85.071	0	1	none	none
34:46.9	car4	2.0351	-0.0094	33.094	84.756	0	1	none	none
34:46.9	car5	2.0261	0.0206	22.874	85.276	0	1	none	none
34:47.0	car1	2	0.2	63.885	85.072	0	1	none	none
34:47.0	car2	2.0324	0.0043	53.762	85.045	0	1	none	none
34:47.0	car3	2.0314	-0.0157	43.571	85.071	0	1	none	none
34:47.0	car4	2.0318	-0.0323	33.371	84.753	0	1	none	none
34:47.0	car5	2.024	-0.0204	23.148	85.276	0	1	none	none
34:47.2	car1	2	0.2	64.118	85.072	0	1	none	none
34:47.2	car2	2.03	-0.0204	53.999	85.045	0	1	none	none
34:47.2	car3	2.0291	-0.0187	43.807	85.071	0	1	none	none
34:47.2	car4	2.028	-0.0403	33.608	84.75	0	1	none	none
34:47.2	car5	2.0203	-0.0373	23.384	85.276	0	1	none	none
34:47.3	car1	2	0.2	64.351	85.072	0	1	none	none
34:47.3	car2	2.0275	-0.0253	54.235	85.045	0	1	none	none
34:47.3	car3	2.0271	-0.0192	44.044	85.071	0	1	none	none
34:47.3	car4	2.0243	-0.0374	33.845	84.748	0	1	none	none
34:47.3	car5	2.0161	-0.0389	23.62	85.276	0	1	none	none
34:47.4	car1	2	0.2	64.545	85.072	0	1	none	none
34:47.4	car2	2.0249	-0.0212	54.433	85.044	0	1	none	none
34:47.4	car3	2.0255	-0.0154	44.241	85.071	0	1	none	none
34:47.4	car4	2.0212	-0.0278	34.042	84.746	0	1	none	none
34:47.4	car5	2.0128	-0.0315	23.816	85.276	0	1	none	none
34:47.5	car1	2	0.2	64.739	85.072	0	1	none	none
34:47.5	car2	2.024	-0.0095	54.629	85.044	0	1	none	none
34:47.5	car3	2.0247	-0.0132	44.438	85.071	0	1	none	none
34:47.5	car4	2.0193	-0.0166	34.239	84.743	0	1	none	none
34:47.5	car5	2.0109	-0.0207	24.012	85.276	0	1	none	none
34:47.6	car1	2	0.2	64.973	85.072	0	1	none	none
34:47.6	car2	2.0244	-0.006	54.866	85.044	0	1	none	none
34:47.6	car3	2.0251	-0.0092	44.674	85.071	0	1	none	none
34:47.6	car4	2.0199	-0.0105	34.474	84.741	0	1	none	none
34:47.6	car5	2.0114	-0.016	24.247	85.276	0	1	none	none
34:47.7	car1	2	0.2	65.167	85.072	0	1	none	none
34:47.7	car2	2.0249	0.0086	55.062	85.044	0	1	none	none
34:47.7	car3	2.0245	-0.005	44.871	85.071	0	1	none	none
34:47.7	car4	2.0203	0.0029	34.67	84.738	0	1	none	none
34:47.7	car5	2.011	0.0002	24.442	85.276	0	1	none	none
34:47.8	car1	2	0.2	65.361	85.072	0	1	none	none
34:47.8	car2	2.0266	0.0164	55.259	85.043	0	1	none	none
34:47.8	car3	2.025	-0.0004	45.068	85.071	0	1	none	none
34:47.8	car4	2.0211	0.0109	34.867	84.736	0	1	none	none
34:47.8	car5	2.0122	0.012	24.638	85.276	0	1	none	none
34:47.9	car1	2	0.2	65.594	85.072	0	1	none	none
34:47.9	car2	2.0268	0.0184	55.495	85.043	0	1	none	none
34:47.9	car3	2.0251	0.0013	45.304	85.071	0	1	none	none
34:47.9	car4	2.0214	0.0144	35.102	84.734	0	1	none	none
34:47.9	car5	2.0127	0.0171	24.872	85.276	0	1	none	none
34:48.0	car1	2	0.2	65.789	85.072	0	1	none	none
34:48.0	car2	2.0293	0.0234	55.692	85.043	0	1	none	none
34:48.0	car3	2.0262	0.0115	45.5	85.071	0	1	none	none
34:48.0	car4	2.0231	0.0212	35.298	84.731	0	1	none	none
34:48.0	car5	2.0159	0.0287	25.067	85.276	0	1	none	none
34:48.1	car1	2	0.2	66.022	85.072	0	1	none	none
34:48.1	car2	2.0314	0.0237	55.928	85.043	0	1	none	none
34:48.1	car3	2.0278	0.0178	45.736	85.071	0	1	none	none
34:48.1	car4	2.0252	0.0224	35.534	84.729	0	1	none	none
34:48.1	car5	2.0194	0.0339	25.302	85.276	0	1	none	none
34:48.2	car1	2	0.2	66.216	85.072	0	1	none	none
34:48.2	car2	2.0332	0.0219	56.125	85.042	0	1	none	none
34:48.2	car3	2.03	0.0204	45.933	85.071	0	1	none	none
34:48.2	car4	2.0274	0.0242	35.73	84.726	0	1	none	none
34:48.2	car5	2.0227	0.0366	25.497	85.276	0	1	none	none
34:48.3	car1	2	0.2	66.41	85.072	0	1	none	none
34:48.3	car2	2.0349	0.0187	56.322	85.042	0	1	none	none
34:48.3	car3	2.032	0.0204	46.13	85.071	0	1	none	none
34:48.3	car4	2.0294	0.024	35.927	84.724	0	1	none	none
34:48.3	car5	2.0265	0.0352	25.693	85.276	0	1	none	none
34:48.4	car1	2	0.2	66.605	85.072	0	1	none	none
34:48.4	car2	2.0368	0.0176	56.519	85.042	0	1	none	none
34:48.4	car3	2.0341	0.0206	46.327	85.071	0	1	none	none
34:48.4	car4	2.0316	0.0265	36.123	84.722	0	1	none	none
34:48.4	car5	2.0291	0.0307	25.89	85.276	0	1	none	none
34:48.6	car1	2	0.2	66.839	85.072	0	1	none	none
34:48.6	car2	2.0383	0.0126	56.757	85.042	0	1	none	none
34:48.6	car3	2.0361	0.0212	46.564	85.071	0	1	none	none
34:48.6	car4	2.0344	0.0244	36.36	84.719	0	1	none	none
34:48.6	car5	2.0319	0.0289	26.126	85.276	0	1	none	none
34:48.7	car1	2	0.2	67.072	85.068	0	1	none	none
34:48.7	car2	2.0484	0.1142	56.953	85.042	0	1	none	none
34:48.7	car3	2.0409	0.0694	46.761	85.071	0	1	none	none
34:48.7	car4	2.0394	0.0736	36.557	84.717	0	1	none	none
34:48.7	car5	2.037	0.0805	26.322	85.276	0	1	none	none
34:48.8	car1	2	0.2	67.267	85.066	0	1	none	none
34:48.8	car2	2.0522	0.0417	57.19	85.037	0	1	none	none
34:48.8	car3	2.045	0.0401	46.999	85.071	0	1	none	none
34:48.8	car4	2.0433	0.0431	36.794	84.715	0	1	none	none
34:48.8	car5	2.0418	0.0477	26.559	85.276	0	1	none	none
34:48.9	car1	2	0.2	67.5	85.064	0	1	none	none
34:48.9	car2	2.0611	0.0914	57.389	85.035	0	1	none	none
34:48.9	car3	2.0521	0.071	47.197	85.071	0	1	none	none
34:48.9	car4	2.0502	0.0716	36.992	84.712	0	1	none	none
34:48.9	car5	2.0493	0.0732	26.757	85.276	0	1	none	none
34:49.0	car1	2	0.2	67.693	85.062	0	1	none	none
34:49.0	car2	2.0603	-0.0073	57.627	85.032	0	1	none	none
34:49.0	car3	2.0549	0.0295	47.435	85.071	0	1	none	none
34:49.0	car4	2.0527	0.0267	37.23	84.71	0	1	none	none
34:49.0	car5	2.045	0.0302	26.994	85.276	0	1	none	none
34:49.1	car1	2	0.2	67.926	85.057	0	1	none	none
34:49.1	car2	2.0531	-0.0692	57.87	85.028	0	1	none	none
34:49.1	car3	2.0553	0.0031	47.674	85.071	0	1	none	none
34:49.1	car4	2.0531	0.0009	37.468	84.707	0	1	none	none
34:49.1	car5	2.0464	0.0139	27.233	85.276	0	1	none	none
34:49.2	car1	2	0.2	68.122	85.054	0	1	none	none
34:49.2	car2	2.0536	-0.0638	58.068	85.025	0	1	none	none
34:49.2	car3	2.0551	0.0014	47.873	85.071	0	1	none	none
34:49.2	car4	2.0531	0.0015	37.667	84.705	0	1	none	none
34:49.2	car5	2.0467	0.0168	27.431	85.276	0	1	none	none
34:49.3	car1	2	0.2	68.316	85.055	0	1	none	none
34:49.3	car2	2.0449	-0.0813	58.267	85.025	0	1	none	none
34:49.3	car3	2.0527	-0.0235	48.073	85.071	0	1	none	none
34:49.3	car4	2.0516	-0.014	37.867	84.702	0	1	none	none
34:49.3	car5	2.0466	0.0063	27.63	85.277	0	1	none	none
34:49.4	car1	2	0.2	68.55	85.055	0	1	none	none
34:49.4	car2	2.0376	-0.0738	58.507	85.025	0	1	none	none
34:49.4	car3	2.0489	-0.0414	48.312	85.071	0	1	none	none
34:49.4	car4	2.0497	-0.0226	38.106	84.7	0	1	none	none
34:49.4	car5	2.047	0.0002	27.868	85.277	0	1	none	none
34:49.6	car1	2	0.2	68.783	85.055	0	1	none	none
34:49.6	car2	2.0316	-0.064	58.748	85.024	0	1	none	none
34:49.6	car3	2.0441	-0.0488	48.551	85.07	0	1	none	none
34:49.6	car4	2.047	-0.0295	38.345	84.697	0	1	none	none
34:49.6	car5	2.0462	-0.0076	28.107	85.277	0	1	none	none
34:49.7	car1	2	0.2	68.976	85.056	0	1	none	none
34:49.7	car2	2.0272	-0.0475	58.946	85.026	0	1	none	none
34:49.7	car3	2.0388	-0.0521	48.75	85.07	0	1	none	none
34:49.7	car4	2.0436	-0.0339	38.544	84.695	0	1	none	none
34:49.7	car5	2.0447	-0.0129	28.305	85.277	0	1	none	none
34:49.8	car1	2	0.2	69.21	85.059	0	1	none	none
34:49.8	car2	2.0244	-0.0256	59.183	85.029	0	1	none	none
34:49.8	car3	2.0339	-0.0515	48.989	85.07	0	1	none	none
34:49.8	car4	2.0404	-0.0363	38.783	84.692	0	1	none	none
34:49.8	car5	2.0432	-0.0177	28.544	85.277	0	1	none	none
34:49.9	car1	2	0.2	69.404	85.06	0	1	none	none
34:49.9	car2	2.0235	-0.0054	59.38	85.029	0	1	none	none
34:49.9	car3	2.0296	-0.044	49.187	85.07	0	1	none	none
34:49.9	car4	2.0366	-0.0341	38.981	84.69	0	1	none	none
34:49.9	car5	2.041	-0.0202	28.742	85.277	0	1	none	none
34:50.0	car1	2	0.2	69.637	85.061	0	1	none	none
34:50.0	car2	2.0334	0.0938	59.577	85.029	0	1	none	none
34:50.0	car3	2.0345	0.0054	49.385	85.07	0	1	none	none
34:50.0	car4	2.0415	0.0152	39.179	84.688	0	1	none	none
34:50.0	car5	2.0456	0.026	28.941	85.277	0	1	none	none
34:50.1	car1	2	0.2	69.832	85.061	0	1	none	none
34:50.1	car2	2.0365	0.0351	59.813	85.029	0	1	none	none
34:50.1	car3	2.0337	-0.0027	49.621	85.07	0	1	none	none
34:50.1	car4	2.0405	-0.0148	39.417	84.685	0	1	none	none
34:50.1	car5	2.0455	-0.0052	29.179	85.277	0	1	none	none
34:50.2	car1	2	0.2	70.065	85.061	0	1	none	none
34:50.2	car2	2.0453	0.1226	60.011	85.029	0	1	none	none
34:50.2	car3	2.0388	0.0482	49.819	85.07	0	1	none	none
34:50.2	car4	2.0453	0.0333	39.615	84.683	0	1	none	none
34:50.2	car5	2.0503	0.0426	29.377	85.277	0	1	none	none
34:50.3	car1	2	0.2	70.259	85.061	0	1	none	none
34:50.3	car2	2.0458	0.008	60.248	85.028	0	1	none	none
34:50.3	car3	2.0413	0.0234	50.056	85.07	0	1	none	none
34:50.3	car4	2.044	-0.0103	39.853	84.68	0	1	none	none
34:50.3	car5	2.0493	-0.0072	29.616	85.277	0	1	none	none
34:50.4	car1	2	0.2	70.454	85.06	0	1	none	none
34:50.4	car2	2.0448	-0.002	60.447	85.028	0	1	none	none
34:50.4	car3	2.0417	0.0266	50.254	85.07	0	1	none	none
34:50.4	car4	2.0438	-0.012	40.052	84.678	0	1	none	none
34:50.4	car5	2.0491	-0.0086	29.815	85.277	0	1	none	none
34:50.5	car1	2	0.2	70.687	85.06	0	1	none	none
34:50.5	car2	2.0386	-0.0738	60.685	85.027	0	1	none	none
34:50.5	car3	2.0419	0.0092	50.492	85.07	0	1	none	none
34:50.5	car4	2.041	-0.0301	40.29	84.675	0	1	none	none
34:50.5	car5	2.0456	-0.0338	30.053	85.277	0	1	none	none
34:50.7	car1	2	0.2	70.92	85.06	0	1	none	none
34:50.7	car2	2.0275	-0.1147	60.923	85.026	0	1	none	none
34:50.7	car3	2.0411	-0.0095	50.73	85.07	0	1	none	none
34:50.7	car4	2.0377	-0.0333	40.528	84.673	0	1	none	none
34:50.7	car5	2.0413	-0.0474	30.292	85.277	0	1	none	none
34:50.8	car1	2	0.2	71.114	85.059	0	1	none	none
34:50.8	car2	2.0146	-0.1236	61.121	85.026	0	1	none	none
34:50.8	car3	2.038	-0.0299	50.928	85.07	0	1	none	none
34:50.8	car4	2.0351	-0.0289	40.726	84.67	0	1	none	none
34:50.8	car5	2.0361	-0.0486	30.491	85.277	0	1	none	none
34:50.9	car1	2	0.2	71.309	85.059	0	0	dos	car3
34:50.9	car2	2.0038	-0.1115	61.318	85.025	0	0	dos	car3
34:50.9	car3	2.0349	-0.0307	51.126	85.07	0	0	dos	car3
34:50.9	car4	2.0127	-0.2225	40.924	84.668	0	0	dos	car3
34:50.9	car5	1.9864	-0.4958	30.689	85.277	0	0	dos	car3
34:51.0	car1	2	0.2	71.542	85.058	0	0	dos	car3
34:51.0	car2	1.9949	-0.0907	61.553	85.024	0	0	dos	car3
34:51.0	car3	2.0293	-0.0572	51.364	85.07	0	0	dos	car3
34:51.0	car4	1.9857	-0.2732	41.161	84.666	0	0	dos	car3
34:51.0	car5	1.9139	-0.6408	30.926	85.277	0	0	dos	car3
34:51.1	car1	2	0.2	71.736	85.058	0	0	dos	car3
34:51.1	car2	1.9944	-0.0957	61.749	85.024	0	0	dos	car3
34:51.1	car3	2.0284	-0.0662	51.562	85.07	0	0	dos	car3
34:51.1	car4	1.9871	-0.2586	41.357	84.663	0	0	dos	car3
34:51.1	car5	1.9158	-0.6222	31.12	85.277	0	0	dos	car3
34:51.2	car1	2	0.2	71.969	85.057	0	0	dos	car3
34:51.2	car2	1.987	-0.0697	61.982	85.023	0	0	dos	car3
34:51.2	car3	2.0279	-0.0006	51.759	85.07	0	0	dos	car3
34:51.2	car4	1.9642	-0.2278	41.552	84.661	0	0	dos	car3
34:51.2	car5	1.8573	-0.5872	31.309	85.277	0	0	dos	car3
34:51.3	car1	2	0.2	72.202	85.057	0	0	dos	car3
34:51.3	car2	1.9828	-0.0416	62.214	85.022	0	0	dos	car3
34:51.3	car3	2.0186	-0.0942	52.035	85.07	0	0	dos	car3
34:51.3	car4	1.9495	-0.1445	41.822	84.658	0	0	dos	car3
34:51.3	car5	1.8177	-0.4832	31.571	85.277	0	0	dos	car3
34:51.4	car1	2	0.2	72.436	85.056	0	0	dos	car3
34:51.4	car2	1.9815	-0.0154	62.446	85.021	0	0	dos	car3
34:51.4	car3	2.0051	-0.1391	52.271	85.07	0	0	dos	car3
34:51.4	car4	1.9424	-0.076	42.052	84.656	0	0	dos	car3
34:51.4	car5	1.7854	-0.3255	31.79	85.277	0	0	dos	car3
`
        
        parseAndLoadCSVData(sampleCSVContent)
    }
}