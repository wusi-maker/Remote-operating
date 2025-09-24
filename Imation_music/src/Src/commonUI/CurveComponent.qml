import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs

Item {
    id: root
    
    // 公开属性
    property color curveColor: "#3498db"
    property real curveWidth: 2
    property var dataPoints: []
    // 选择贝塞尔曲线“smooth”或是直线连接“line”
    property string curveType: "smooth" // "smooth" 或 "line"
    property real amplitude: 50
    property real frequency: 0.02
    property bool showSineWave: true
    property string chartTitle: "曲线图表"
    property string xAxisLabel: "时间 (s)"
    property string yAxisLabel: "数值"
    property int maxDataPoints: 20 //最大显示的点数限制
    property int maxMemoryDataPoints: 100 //内存中最大保存的数据点数量
    property real yMin: 0
    property real yMax: 100
    property bool autoScaleY: true
    property real dataValidationMin: -1000 //数据有效性检查最小值
    property real dataValidationMax: 1000  //数据有效性检查最大值
    property bool enableDataValidation: true //是否启用数据验证
    
    width: 400
    height: 300
    
    // 性能优化定时器
    Timer {
        id: cleanupTimer
        interval: 5000 // 每5秒检查一次
        running: true
        repeat: true
        onTriggered: {
            root.autoCleanupData()
        }
    }
    
    // 重绘节流定时器
    Timer {
        id: redrawTimer
        interval: 50 // 限制重绘频率为20fps
        running: false
        repeat: false
        onTriggered: {
            curveCanvas.requestPaint()
            gridCanvas.requestPaint()
        }
    }
    
    // 背景
    Rectangle {
        anchors.fill: parent
        color: "#2b2b2b"
        border.color: "#34495e"
        border.width: 1
        radius: 8
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                contextDialog.open()
            }
        }
    }
    
    // 网格线
    Canvas {
        id: gridCanvas
        anchors.fill: parent
        anchors.margins: 50
        anchors.topMargin: 70
        anchors.centerIn: parent
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            ctx.strokeStyle = "#34495e"
            ctx.lineWidth = 1
            
            // 垂直网格线
            for (var x = 0; x <= width; x += width / 10) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }
            
            // 水平网格线
            for (var y = 0; y <= height; y += height / 8) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }
    }
    
    // 曲线绘制
    Canvas {
        id: curveCanvas
        anchors.fill: parent
        anchors.margins: 50
        anchors.topMargin: 70
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            ctx.strokeStyle = root.curveColor
            ctx.lineWidth = root.curveWidth
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            
            if (root.showSineWave) {
                // 绘制正弦波
                ctx.beginPath()
                for (var x = 0; x < width; x++) {
                    var y = height/2 + Math.sin(x * root.frequency) * root.amplitude
                    if (x === 0) {
                        ctx.moveTo(x, y)
                    } else {
                        ctx.lineTo(x, y)
                    }
                }
                ctx.stroke()
            }
            
            // 绘制自定义数据点
            if (root.dataPoints.length > 1) {
                // 计算Y轴范围
                if (root.autoScaleY) {
                    var minY = Math.min.apply(Math, root.dataPoints.map(function(p) { return p.y }))
                    var maxY = Math.max.apply(Math, root.dataPoints.map(function(p) { return p.y }))
                    var padding = (maxY - minY) * 0.1
                    root.yMin = minY - padding
                    root.yMax = maxY + padding
                }
                
                ctx.beginPath()
                for (var i = 0; i < root.dataPoints.length; i++) {
                    var point = root.dataPoints[i]
                    var px = (i / Math.max(root.dataPoints.length - 1, 1)) * width
                    var py = height - ((point.y - root.yMin) / (root.yMax - root.yMin)) * height
                    
                    if (i === 0) {
                        ctx.moveTo(px, py)
                    } else {
                        if (root.curveType === "smooth") {
                            // 使用二次贝塞尔曲线平滑连接
                            var prevPoint = root.dataPoints[i-1]
                            var prevPx = (prevPoint.x / 100) * width
                            var prevPy = height - (prevPoint.y / 100) * height
                            var cpx = (prevPx + px) / 2
                            var cpy = (prevPy + py) / 2
                            ctx.quadraticCurveTo(cpx, cpy, px, py)
                        } else {
                            ctx.lineTo(px, py)
                        }
                    }
                }
                ctx.stroke()
                
                // 绘制数据点
                ctx.fillStyle = root.curveColor
                for (var j = 0; j < root.dataPoints.length; j++) {
                    var dp = root.dataPoints[j]
                    var dpx = (j / Math.max(root.dataPoints.length - 1, 1)) * width
                    var dpy = height - ((dp.y - root.yMin) / (root.yMax - root.yMin)) * height
                    ctx.beginPath()
                    ctx.arc(dpx, dpy, 3, 0, 2 * Math.PI)
                    ctx.fill()
                }
                
                // === 优化后的连接线绘制 ===
                if (root.dataPoints.length > 0) {
                    // 保存当前绘图状态
                    ctx.save()
                    
                    // 获取最后一个数据点
                    var lastPoint = root.dataPoints[root.dataPoints.length - 1]
                    
                    // 正确计算X坐标（根据数据索引）
                    var lastPx = (root.dataPoints.length - 1) * (width / Math.max(root.dataPoints.length - 1, 1))
                    
                    // 获取文本组件的中心点（转换为Canvas坐标系）
                    var textCenter = latestValueDisplay.mapToItem(curveCanvas,
                        latestValueDisplay.width/2,
                        latestValueDisplay.height/2)
                    
                    // 设置虚线样式
                    ctx.strokeStyle = "#95a5a6"
                    ctx.lineWidth = 1 // 更细的线更美观
                    ctx.setLineDash([5, 3]) // 优化虚线样式
                    
                    // 计算数据点在Canvas中的实际Y坐标
                    var dataPointY = height - ((lastPoint.y - root.yMin) / (root.yMax - root.yMin)) * height
                    
                    // 绘制水平连接线（Y轴坐标保持不变）
                    ctx.beginPath()
                    ctx.moveTo(lastPx, dataPointY) // 从数据点开始
                    ctx.lineTo(0, dataPointY) // 水平连接到右边缘y轴处
                    ctx.stroke()
                    
                    // 恢复原始绘图状态
                    ctx.restore()
                }
            }
        }
    }
    
    // 标题
    TextInput {
        id: titleInput
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        text: root.chartTitle
        font.pixelSize: 16
        font.bold: true
        color: "#ecf0f1"
        horizontalAlignment: Text.AlignHCenter
        selectByMouse: true
        onTextChanged: root.chartTitle = text
        
        Rectangle {
            anchors.fill: parent
            anchors.margins: -5
            color: "transparent"
            border.color: parent.activeFocus ? "#3498db" : "transparent"
            border.width: 1
            radius: 3
        }
    }
    
    // Y轴标签
    Text {
        anchors.right: gridCanvas.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin:10+10
        text: root.yAxisLabel
        font.pixelSize: 12
        color: "#bdc3c7"
        rotation: -90
        transformOrigin: Item.Center
    }
    
    // X轴标签
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        text: root.xAxisLabel
        font.pixelSize: 12
        color: "#bdc3c7"
    }
    
    // Y轴刻度
    Repeater {
        id:tickRectangle
        model: 6
        Text {
            property real yValue: root.yMin + (root.yMax - root.yMin) * (5 - index) / 5
            anchors.right: gridCanvas.left
            anchors.rightMargin: 5
            y: gridCanvas.y + (gridCanvas.height * index / 5) - height/2
            text: yValue.toFixed(1)
            font.pixelSize: 10
            color: "#95a5a6"
        }
    }
    
    // 最新数据点显示
    Text {
        id: latestValueDisplay
        visible: root.dataPoints.length > 0
        anchors.left: gridCanvas.right
        anchors.leftMargin: 5
        y: {
            if (root.dataPoints.length === 0) return 0
            var latestPoint = root.dataPoints[root.dataPoints.length - 1]
            var normalizedY = (latestPoint.y - root.yMin) / (root.yMax - root.yMin)
            return gridCanvas.y + gridCanvas.height * (1 - normalizedY) - height/2
        }
        text: root.dataPoints.length > 0 ? root.dataPoints[root.dataPoints.length - 1].y.toFixed(2) : ""
        color: "#3498db"
        font.pixelSize: 14
        font.bold: true
        
        // 添加文字阴影效果增强可见性
        style: Text.Outline
        styleColor: "#2c3e50"
    }
    
    // X轴刻度
    Repeater {
        model: Math.min(6, root.dataPoints.length)
        Text {
            property int dataIndex: Math.floor(index * (root.dataPoints.length - 1) / Math.max(model - 1, 1))
            anchors.top: gridCanvas.bottom
            anchors.topMargin: 5
            x: gridCanvas.x + (gridCanvas.width * index / Math.max(model - 1, 1)) - width/2
            text: dataIndex < root.dataPoints.length ? dataIndex.toString() : ""
            font.pixelSize: 10
            color: "#95a5a6"
        }
    }
    
    // 弹出对话框
    Dialog {
        id: contextDialog
        title: "数据操作"
        anchors.centerIn: parent
        width: 300
        height: 200
        modal: true
        
        background: Rectangle {
            color: "#34495e"
            border.color: "#2c3e50"
            border.width: 2
            radius: 8
        }
        
        Column {
            anchors.centerIn: parent
            spacing: 20
            
            
            Row {
                spacing: 20
                anchors.horizontalCenter: parent.horizontalCenter
                
                Button {
                    text: "清空数据"
                    onClicked: {
                        root.clearDataPoints()
                        contextDialog.close()
                    }
                    background: Rectangle {
                        color: parent.pressed ? "#c0392b" : "#e74c3c"
                        radius: 5
                    }
                }
                
                Button {
                    text: "保存数据"
                    onClicked: {
                        root.saveDataToFile()
                        contextDialog.close()
                    }
                    background: Rectangle {
                        color: parent.pressed ? "#27ae60" : "#2ecc71"
                        radius: 5
                    }
                }
            }
            
            Button {
                text: "取消"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: contextDialog.close()
                background: Rectangle {
                    color: parent.pressed ? "#7f8c8d" : "#95a5a6"
                    radius: 5
                }
            }
        }
    }
    
    // 公开方法（优化版本，使用节流）
    function updateCurve() {
        if (!redrawTimer.running) {
            redrawTimer.start()
        }
    }
    
    // 立即更新（不使用节流，用于重要更新）
    function forceUpdateCurve() {
        curveCanvas.requestPaint()
        gridCanvas.requestPaint()
    }
    // 将外部数据进行显示
    function addDataPoint(x, y) {
        // 数据验证：检查数据是否在有效范围内
        if (root.enableDataValidation) {
            if (isNaN(y) || y < root.dataValidationMin || y > root.dataValidationMax) {
                console.warn("数据点被丢弃：Y值 " + y + " 超出有效范围 [" + root.dataValidationMin + ", " + root.dataValidationMax + "]")
                return // 丢弃无效数据
            }
            if (isNaN(x)) {
                console.warn("数据点被丢弃：X值无效 " + x)
                return // 丢弃无效数据
            }
        }
        
        var newPoints = root.dataPoints.slice()
        newPoints.push({x: x, y: y})
        
        // 内存管理：限制内存中的最大数据点数量
        if (newPoints.length > root.maxMemoryDataPoints) {
            // 保留最新的数据点，删除最旧的
            newPoints = newPoints.slice(-root.maxMemoryDataPoints)
            console.log("内存优化：数据点数量超过限制，已清理旧数据。当前数据点数量：" + newPoints.length)
        }
        
        root.dataPoints = newPoints
        updateCurve()
    }
    
    function saveDataToFile() {
        var dataStr = "Time,Value\n"
        for (var i = 0; i < root.dataPoints.length; i++) {
            dataStr += i + "," + root.dataPoints[i].y + "\n"
        }
        console.log("数据已保存：\n" + dataStr)
        // 这里可以添加实际的文件保存逻辑
    }
    
    function clearDataPoints() {
        root.dataPoints = []
        updateCurve()
    }
    
    // 自动清理旧数据（当数据点过多时）
    function autoCleanupData() {
        if (root.dataPoints.length > root.maxMemoryDataPoints * 0.8) {
            var keepCount = Math.floor(root.maxMemoryDataPoints * 0.6)
            root.dataPoints = root.dataPoints.slice(-keepCount)
            console.log("自动清理：保留最新 " + keepCount + " 个数据点")
            updateCurve()
        }
    }
    
    // 获取当前内存使用情况
    function getMemoryInfo() {
        return {
            currentDataPoints: root.dataPoints.length,
            maxDataPoints: root.maxDataPoints,
            maxMemoryDataPoints: root.maxMemoryDataPoints,
            memoryUsagePercent: (root.dataPoints.length / root.maxMemoryDataPoints * 100).toFixed(1)
        }
    }
    
    Component.onCompleted: {
        forceUpdateCurve()
        console.log("CurveComponent初始化完成，内存限制：" + root.maxMemoryDataPoints + " 个数据点")
    }
    
    // 属性变化监听（使用节流更新）
    onCurveColorChanged: updateCurve()
    onCurveWidthChanged: updateCurve()
    onDataPointsChanged: updateCurve()
    onCurveTypeChanged: forceUpdateCurve() // 曲线类型变化需要立即更新
    onAmplitudeChanged: updateCurve()
    onFrequencyChanged: updateCurve()
    onShowSineWaveChanged: forceUpdateCurve() // 显示模式变化需要立即更新
}
