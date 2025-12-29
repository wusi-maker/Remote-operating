import QtQuick 2.15
import QtQuick.Shapes 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs

Item {
    id: root
    
    // 公开属性
    property color curveColor: "#3498db" // 保留用于向后兼容
    property real curveWidth: 2
    property var dataPoints: [] // 保留用于向后兼容
    // 多曲线数据结构：[{name: "曲线1", color: "#3498db", width: 2, data: [{x:0, y:0}], type: "smooth"}]
    property var curves: []
    // 选择贝塞尔曲线"smooth"或是直线连接"line"
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
    property bool showLegend: true // 是否显示图例
    property string legendPosition: "topRight" // 图例位置："topLeft", "topRight", "bottomLeft", "bottomRight"
    property bool showTitle: true
    property bool showAxisLabels: true
    property bool showTicks: true
    property bool showDataPoints: false
    property int plotMargin: 50
    property int plotTopMargin: 70
    
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
        interval: 33
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
        anchors.margins: root.plotMargin
        anchors.topMargin: root.plotTopMargin
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
        anchors.margins: root.plotMargin
        anchors.topMargin: root.plotTopMargin
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            if (root.showSineWave) {
                ctx.strokeStyle = root.curveColor
                ctx.lineWidth = root.curveWidth
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                
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
            
            var yMin = root.yMin
            var yMax = root.yMax
            if (root.autoScaleY) {
                var allYValues = []
                if (root.curves.length > 0) {
                    for (var ci = 0; ci < root.curves.length; ci++) {
                        var c = root.curves[ci]
                        if (c && c.data && c.data.length > 0) {
                            for (var di = 0; di < c.data.length; di++) {
                                allYValues.push(c.data[di].y)
                            }
                        }
                    }
                } else if (root.dataPoints.length > 0) {
                    for (var dpi = 0; dpi < root.dataPoints.length; dpi++) {
                        allYValues.push(root.dataPoints[dpi].y)
                    }
                }
                if (allYValues.length > 0) {
                    var minY = Math.min.apply(Math, allYValues)
                    var maxY = Math.max.apply(Math, allYValues)
                    var padding = (maxY - minY) * 0.1
                    yMin = minY - padding
                    yMax = maxY + padding
                    root.yMin = yMin
                    root.yMax = yMax
                }
            }
            
            for (var curveIndex = 0; curveIndex < root.curves.length; curveIndex++) {
                var curve = root.curves[curveIndex]
                if (!curve || !curve.data || curve.data.length < 2) continue
                
                ctx.strokeStyle = curve.color || "#3498db"
                ctx.lineWidth = curve.width || 2
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                
                ctx.beginPath()
                var total = curve.data.length
                var displayCount = Math.min(total, root.maxDataPoints)
                var startIndex = Math.max(0, total - displayCount)
                for (var i = startIndex; i < total; i++) {
                    var point = curve.data[i]
                    var px = ((i - startIndex) / Math.max(displayCount - 1, 1)) * width
                    var py = height - ((point.y - yMin) / (yMax - yMin)) * height
                    
                    if (i === startIndex) {
                        ctx.moveTo(px, py)
                    } else {
                        var curveType = curve.type || root.curveType
                        if (curveType === "smooth") {
                            var prevPoint = curve.data[i-1]
                            var prevPx = (((i-1) - startIndex) / Math.max(displayCount - 1, 1)) * width
                            var prevPy = height - ((prevPoint.y - yMin) / (yMax - yMin)) * height
                            var cpx = (prevPx + px) / 2
                            var cpy = (prevPy + py) / 2
                            ctx.quadraticCurveTo(cpx, cpy, px, py)
                        } else {
                            ctx.lineTo(px, py)
                        }
                    }
                }
                ctx.stroke()
                
                if (root.showDataPoints) {
                    ctx.fillStyle = curve.color || "#3498db"
                    for (var j = startIndex; j < total; j++) {
                        var dp = curve.data[j]
                        var dpx = ((j - startIndex) / Math.max(displayCount - 1, 1)) * width
                        var dpy = height - ((dp.y - yMin) / (yMax - yMin)) * height
                        ctx.beginPath()
                        ctx.arc(dpx, dpy, 3, 0, 2 * Math.PI)
                        ctx.fill()
                    }
                }
            }
            
            if (root.dataPoints.length > 1) {
                ctx.strokeStyle = root.curveColor
                ctx.lineWidth = root.curveWidth
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                
                ctx.beginPath()
                var dpTotal = root.dataPoints.length
                var dpDisplayCount = Math.min(dpTotal, root.maxDataPoints)
                var dpStartIndex = Math.max(0, dpTotal - dpDisplayCount)
                for (var i2 = dpStartIndex; i2 < dpTotal; i2++) {
                    var point2 = root.dataPoints[i2]
                    var px2 = ((i2 - dpStartIndex) / Math.max(dpDisplayCount - 1, 1)) * width
                    var py2 = height - ((point2.y - yMin) / (yMax - yMin)) * height
                    
                    if (i2 === dpStartIndex) {
                        ctx.moveTo(px2, py2)
                    } else {
                        if (root.curveType === "smooth") {
                            var prevPoint2 = root.dataPoints[i2-1]
                            var prevPx2 = (((i2-1) - dpStartIndex) / Math.max(dpDisplayCount - 1, 1)) * width
                            var prevPy2 = height - ((prevPoint2.y - yMin) / (yMax - yMin)) * height
                            var cpx2 = (prevPx2 + px2) / 2
                            var cpy2 = (prevPy2 + py2) / 2
                            ctx.quadraticCurveTo(cpx2, cpy2, px2, py2)
                        } else {
                            ctx.lineTo(px2, py2)
                        }
                    }
                }
                ctx.stroke()
                
                if (root.showDataPoints) {
                    ctx.fillStyle = root.curveColor
                    for (var j2 = dpStartIndex; j2 < dpTotal; j2++) {
                        var dp2 = root.dataPoints[j2]
                        var dpx2 = ((j2 - dpStartIndex) / Math.max(dpDisplayCount - 1, 1)) * width
                        var dpy2 = height - ((dp2.y - yMin) / (yMax - yMin)) * height
                        ctx.beginPath()
                        ctx.arc(dpx2, dpy2, 3, 0, 2 * Math.PI)
                        ctx.fill()
                    }
                }
                
                if (root.dataPoints.length > 0) {
                    ctx.save()
                    var lastPoint = root.dataPoints[root.dataPoints.length - 1]
                    var textCenter = latestValueDisplay.mapToItem(curveCanvas,
                        latestValueDisplay.width/2,
                        latestValueDisplay.height/2)
                    ctx.strokeStyle = "#95a5a6"
                    ctx.lineWidth = 1 // 更细的线更美观
                    ctx.setLineDash([5, 3]) // 优化虚线样式
                    var lastPx = (root.dataPoints.length - 1) * (width / Math.max(root.dataPoints.length - 1, 1))
                    var dataPointY = height - ((lastPoint.y - yMin) / (yMax - yMin)) * height
                    ctx.beginPath()
                    ctx.moveTo(lastPx, dataPointY) // 从数据点开始
                    ctx.lineTo(0, dataPointY) // 水平连接到右边缘y轴处
                    ctx.stroke()
                    ctx.restore()
                }
            }
        }
    }
    
    // 标题
    TextInput {
        id: titleInput
        visible: root.showTitle
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        text: root.chartTitle
        font.pixelSize: 12
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
        visible: root.showAxisLabels
        anchors.right: gridCanvas.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin:5
        text: root.yAxisLabel
        font.pixelSize: 12
        color: "#bdc3c7"
        rotation: -90
        transformOrigin: Item.Center
    }
    
    // X轴标签
    Text {
        visible: root.showAxisLabels
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
            visible: root.showTicks
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
    
    // 图例组件
    Rectangle {
        id: legend
        visible: root.showLegend && root.curves.length > 0
        width: legendColumn.width + 20
        height: legendColumn.height + 20
        color: "transparent"
        border.color: "#2c3e50"
        border.width: 0
        radius: 5
        opacity: 0.9
        
        // 根据legendPosition属性设置位置
        anchors {
            top: root.legendPosition.indexOf("top") >= 0 ? parent.top : undefined
            bottom: root.legendPosition.indexOf("bottom") >= 0 ? parent.bottom : undefined
            left: root.legendPosition.indexOf("Left") >= 0 ? parent.left : undefined
            right: root.legendPosition.indexOf("Right") >= 0 ? parent.right : undefined
            topMargin: 0
            bottomMargin: 10
            leftMargin: 10
            rightMargin: 0
        }
        //  根据curves传入的数据进行数据标注
        Column {
            id: legendColumn
            anchors.centerIn: parent
            spacing: 5
            
            Repeater {
                model: root.curves
                
                Row {
                    spacing: 8
                    
                    // 颜色指示器
                    Rectangle {
                        width: 16
                        height: 2
                        color: modelData.color || "#3498db"
                        radius: 1.5
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    // 曲线名称
                    Text {
                        text: modelData.name || ("曲线 " + (index + 1))
                        color: "#ecf0f1"
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        
        // 鼠标悬停效果
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.opacity = 1.0
            onExited: parent.opacity = 0.9
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
    
    // === 多曲线支持方法 ===
    
    // 添加新曲线
    function addCurve(name, color, width, type) {
        var newCurves = root.curves.slice()
        newCurves.push({
            name: name || ("曲线 " + (newCurves.length + 1)),
            color: color || "#3498db",
            width: width || 2,
            type: type || root.curveType,
            data: []
        })
        root.curves = newCurves
        updateCurve()
        return newCurves.length - 1 // 返回曲线索引
    }
    
    // 向指定曲线添加数据点
    function addDataPointToCurve(curveIndex, x, y) {
        if (curveIndex < 0 || curveIndex >= root.curves.length) {
            console.warn("曲线索引无效：" + curveIndex)
            return false
        }
        
        // 数据验证
        if (root.enableDataValidation) {
            if (isNaN(y) || y < root.dataValidationMin || y > root.dataValidationMax) {
                console.warn("数据点被丢弃：Y值 " + y + " 超出有效范围")
                return false
            }
            if (isNaN(x)) {
                console.warn("数据点被丢弃：X值无效 " + x)
                return false
            }
        }
        
        var newCurves = root.curves.slice()
        var curve = Object.assign({}, newCurves[curveIndex])
        curve.data = curve.data.slice()
        curve.data.push({x: x, y: y})
        
        // 内存管理
        if (curve.data.length > root.maxMemoryDataPoints) {
            curve.data = curve.data.slice(-root.maxMemoryDataPoints)
        }
        
        newCurves[curveIndex] = curve
        root.curves = newCurves
        updateCurve()
        return true
    }
    
    // 移除曲线
    function removeCurve(curveIndex) {
        if (curveIndex < 0 || curveIndex >= root.curves.length) {
            console.warn("曲线索引无效：" + curveIndex)
            return false
        }
        
        var newCurves = root.curves.slice()
        newCurves.splice(curveIndex, 1)
        root.curves = newCurves
        updateCurve()
        return true
    }
    
    // 清空指定曲线的数据
    function clearCurveData(curveIndex) {
        if (curveIndex < 0 || curveIndex >= root.curves.length) {
            console.warn("曲线索引无效：" + curveIndex)
            return false
        }
        
        var newCurves = root.curves.slice()
        var curve = Object.assign({}, newCurves[curveIndex])
        curve.data = []
        newCurves[curveIndex] = curve
        root.curves = newCurves
        updateCurve()
        return true
    }
    
    // 清空所有曲线数据
    function clearAllCurves() {
        var newCurves = root.curves.slice()
        for (var i = 0; i < newCurves.length; i++) {
            var curve = Object.assign({}, newCurves[i])
            curve.data = []
            newCurves[i] = curve
        }
        root.curves = newCurves
        updateCurve()
    }
    
    // 获取曲线信息
    function getCurveInfo(curveIndex) {
        if (curveIndex < 0 || curveIndex >= root.curves.length) {
            return null
        }
        var curve = root.curves[curveIndex]
        return {
            name: curve.name,
            color: curve.color,
            width: curve.width,
            type: curve.type,
            dataCount: curve.data ? curve.data.length : 0
        }
    }
    
    // 获取所有曲线信息
    function getAllCurvesInfo() {
        var info = []
        for (var i = 0; i < root.curves.length; i++) {
            info.push(getCurveInfo(i))
        }
        return info
    }
    
    // === 向后兼容的旧方法 ===
    
    // 将外部数据进行显示（向后兼容）
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
    onCurvesChanged: updateCurve()
    onCurveTypeChanged: forceUpdateCurve() // 曲线类型变化需要立即更新
    onAmplitudeChanged: updateCurve()
    onFrequencyChanged: updateCurve()
    onShowSineWaveChanged: forceUpdateCurve() // 显示模式变化需要立即更新
}
