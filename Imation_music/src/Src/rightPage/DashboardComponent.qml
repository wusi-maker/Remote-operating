import QtQuick 2.15
import QtQuick.Controls 2.15
import "../style"


Item {
    id: dashboardRoot
    
    // 可配置的属性接口
    property real currentValue: 0
    property real maxValue: 200
    property real minValue: 0
    property string unit: "Km/h"
    property color primaryColor: "#00ff00"
    property color backgroundColor: "#333333"
    property real dashboardWidth: (dashboardRadius +22+(-6)+15+30)*2   // 基于半径动态计算宽度
    property real dashboardHeight: (dashboardRadius +22+(-6)+15+30)*2  // 基于半径动态计算高度
    
    // 新增可配置属性
    property real startAngle: 140          // 仪表盘起始角度
    property real totalAngle: 260          // 仪表盘总角度范围
    property int scaleCount: 10            // 长刻度数量
    property bool showUnit: true           // 是否显示单位
    property bool autoScaleValue: true     // 是否自动计算刻度值为整数
    property real initialValue: 0          // 指针初始值（影响指针初始角度和进度圆弧显示）
    property real dashboardRadius: 120    // 仪表盘半径 - 控制仪表盘圆弧的半径大小
    property real centerBackgroundSize: 200   // 中心背景大小 - 控制中心数值显示区域的大小
    property string fontFamily: "Arial"      // 字体族 - 控制仪表盘文字的字体样式
    property string labelText: "仪表盘"       // 标签文本 - 显示在仪表盘下方的说明文字
    property real valueFontSize: 40           // 中心数值字体大小 - 控制仪表盘中心数值显示的字体大小
    
    // 内部计算属性
    property real valueRatio: (currentValue - minValue) / (maxValue - minValue) // 当前数值对应旋转角度
    property real initialValueRatio: (initialValue - minValue) / (maxValue - minValue) // 初始值对应旋转角度
    property real angleRange: totalAngle  // 总角度范围（使用可配置的totalAngle）
    property real endAngle: startAngle + totalAngle  // 结束角度
    property real currentAngle: startAngle + valueRatio * angleRange
    property real initialAngle: startAngle + initialValueRatio * angleRange  // 初始值对应的角度
    property bool hasProgress: Math.abs(currentValue - initialValue) > 0.01  // 是否有进度变化
    
    // 暴露刻度盘相关计算值，供外部访问
    property real btm_r: dashboardRadius - 22 // 底部圆弧半径
    property real btm_lineWidth: 6 // 底部圆弧线宽
    property real dial_addR: 15 // 刻度盘额外半径
    property real dial_longLen: 30 // 长刻度线长度
    property real textRadius: btm_r + btm_lineWidth + dial_addR + dial_longLen + 5 // 文本半径
    
    // 刻度值计算属性
    property real scaleStep: autoScaleValue ? Math.ceil((maxValue - minValue) / scaleCount) : (maxValue - minValue) / scaleCount
    property real adjustedMaxValue: autoScaleValue ? minValue + (scaleStep * scaleCount) : maxValue
    
    // 信号定义
    signal valueChanged(real newValue)
    signal clicked()
    
    // 函数：计算特定角度的文本坐标
    function getTextCoordinates(angle) {
        var angleRad = angle / 180 * Math.PI
        var x = (width/2) + textRadius * Math.cos(angleRad)
        var y = (height/2) + textRadius * Math.sin(angleRad)
        return {x: x, y: y}
    }
    
    // 函数：获取刻度值对应的角度
    function getAngleForValue(value) {
        var valueRatio = (value - minValue) / (maxValue - minValue)
        return startAngle + valueRatio * angleRange
    }
    
    // 指针属性
    property bool showPointer: true                    // 是否显示指针
    property real pointerLength: 110                   // 指针长度
    property real pointerWidth: 30                     // 指针宽度（加宽）
    property color pointerColor: "red"          // 指针颜色
    
    width: dashboardWidth
    height: dashboardHeight
    
    // 仪表盘Canvas绘制组件 - 包含进度圆弧和刻度线
    Canvas {
        id: dashboardCanvas
        anchors.fill: parent
        z: 2  // 在指针上方
        
        // 内部属性 - 仪表盘几何参数定义
        property real btm_r: dashboardRoot.dashboardRadius    // 底层圆弧半径 - 定义仪表盘背景轨道的半径大小
        property real top_r: dashboardRoot.dashboardRadius    // 顶层圆弧半径 - 定义进度指示器的半径大小
        property real btm_lineWidth: 22             // 底层圆弧线宽 - 背景轨道的宽度，影响仪表盘的视觉厚度
        property real top_lineWidth: 10             // 顶层圆弧线宽 - 进度指示器的宽度，通常比背景轨道细
        property real dial_lineWidth: 3             // 刻度线宽度 - 长短刻度线的线条粗细
        property real dial_longLen: 15              // 长刻度线长度 - 主要刻度标记的径向长度
        property real dial_shortLen: 8              // 短刻度线长度 - 次要刻度标记的径向长度
        property real dial_addR: -6                 // 刻度线径向偏移 - 负值表示向圆心方向偏移，调整刻度线位置
        property int dial_longNum: dashboardRoot.scaleCount  // 长刻度线数量 - 使用可配置的刻度数量
        property int dial_shortPerLong: 3           // 每个长刻度间隔的短刻度数量
        property real btm_startAngle: dashboardRoot.startAngle  // 底层圆弧起始角度
        property real btm_endAngle: dashboardRoot.endAngle      // 底层圆弧结束角度 - 使用计算的结束角度
        property real top_startAngle: dashboardRoot.hasProgress ? 
            (dashboardRoot.currentValue >= dashboardRoot.initialValue ? dashboardRoot.initialAngle : dashboardRoot.currentAngle) : 
            dashboardRoot.startAngle  // 顶层圆弧起始角度 - 根据数值变化方向确定起始点
        property real top_endAngle: dashboardRoot.hasProgress ? 
            (dashboardRoot.currentValue >= dashboardRoot.initialValue ? dashboardRoot.currentAngle : dashboardRoot.initialAngle) : 
            dashboardRoot.startAngle  // 顶层圆弧结束角度 - 根据数值变化方向确定结束点
        property color btm_backgroundColor: dashboardRoot.backgroundColor  // 底层圆弧颜色
        property color top_backgroundColor: dashboardRoot.primaryColor     // 顶层圆弧颜色
        property color dial_color: "#75777f"          // 刻度线颜色
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            // 画背景圆弧
            ctx.lineWidth = btm_lineWidth
            ctx.strokeStyle = btm_backgroundColor
            ctx.beginPath()
            ctx.arc(width/2, height/2, btm_r, (btm_startAngle/180*Math.PI), (btm_endAngle/180*Math.PI))
            ctx.stroke()
            
            // 画顶层圆弧（进度指示）- 只有当存在进度变化时才绘制
            if (dashboardRoot.hasProgress) {
                ctx.lineWidth = top_lineWidth
                ctx.strokeStyle = top_backgroundColor
                ctx.beginPath()
                ctx.arc(width/2, height/2, top_r, (top_startAngle/180*Math.PI), (top_endAngle/180*Math.PI))
                ctx.stroke()
            }
            
            // 画大刻度盘和刻度值
            ctx.lineWidth = dial_lineWidth
            ctx.strokeStyle = dial_color
            ctx.beginPath()
            ctx.arc(width/2, height/2, btm_r+btm_lineWidth+dial_addR, (btm_startAngle/180*Math.PI), (btm_endAngle/180*Math.PI))
            //  整体角度/长刻度线数量=每个长刻度线段对应旋转角度
            var tmp_step = (btm_endAngle-btm_startAngle)/dial_longNum
            for(var i=btm_startAngle; i<btm_endAngle+tmp_step; i+=tmp_step) {
                var tmp_x = (width/2)+(btm_r+btm_lineWidth+dial_addR)*Math.cos(i/180*Math.PI)
                var tmp_y = (height/2)+(btm_r+btm_lineWidth+dial_addR)*Math.sin(i/180*Math.PI)
                ctx.moveTo(tmp_x, tmp_y)
                // 绘制长刻度线
                ctx.lineTo(tmp_x+dial_longLen*Math.cos(i/180*Math.PI), tmp_y+(dial_longLen*Math.sin(i/180*Math.PI)))
                
                // 绘制刻度值 - 使用新的刻度计算逻辑
                var scaleIndex = (i - btm_startAngle) / tmp_step
                var scaleValue = dashboardRoot.minValue + (scaleIndex * dashboardRoot.scaleStep)
                // 根据数值范围智能格式化刻度值
                var formattedScaleValue
                if (dashboardRoot.autoScaleValue) {
                    // 对于整数范围，显示整数
                    formattedScaleValue = Math.round(scaleValue).toString()
                } else {
                    // 对于小数范围，根据步长决定小数位数
                    var range = Math.abs(dashboardRoot.maxValue - dashboardRoot.minValue)
                    if (range <= 10) {
                        // 小范围显示一位小数
                        formattedScaleValue = scaleValue.toFixed(1)
                    } else if (range <= 100) {
                        // 中等范围显示整数或一位小数
                        formattedScaleValue = (scaleValue % 1 === 0) ? scaleValue.toString() : scaleValue.toFixed(1)
                    } else {
                        // 大范围显示整数
                        formattedScaleValue = Math.round(scaleValue).toString()
                    }
                }
                
                // 计算刻度值位置（在刻度线外侧）
                var textRadius = btm_r + btm_lineWidth + dial_addR + dial_longLen + 5
                var text_x = (width/2) + textRadius * Math.cos(i/180*Math.PI)
                var text_y = (height/2) + textRadius * Math.sin(i/180*Math.PI)
                
                // 设置文本样式
                 ctx.font = "bold 15px " + dashboardRoot.fontFamily
                 // 根据刻度值设置颜色 - 基于整个数值范围的相对计算
                 var range = dashboardRoot.maxValue - dashboardRoot.minValue
                 var lowWarningThreshold = dashboardRoot.minValue + range * 0.2
                 var highWarningThreshold = dashboardRoot.minValue + range * 0.8
                 if (scaleValue >= highWarningThreshold) {
                     ctx.fillStyle = "yellow" // 高值警告区域
                 } else if (scaleValue <= lowWarningThreshold) {
                     ctx.fillStyle = "yellow" // 低值警告区域
                 } else {
                     ctx.fillStyle = "white" // 正常区域
                 }
                ctx.textAlign = "center"
                ctx.textBaseline = "middle"
                
                // 保存当前状态
                ctx.save()
                // 移动到文本位置
                ctx.translate(text_x, text_y)
                // 旋转文本角度（使文本与刻度线垂直）
                ctx.rotate((i + 90) * Math.PI / 180)
                // 绘制文本
                ctx.fillText(formattedScaleValue, 0, 0)
                // 恢复状态
                ctx.restore()
            }
            ctx.stroke()
            
            // 绘制短刻度线
            ctx.lineWidth = dial_lineWidth
            ctx.strokeStyle = dial_color
            ctx.beginPath()
            
            // 计算短刻度线的角度步长
            var short_step = tmp_step / (dial_shortPerLong + 1)
            
            // 遍历每个长刻度间隔
            for(var longIndex = 0; longIndex < dial_longNum; longIndex++) {
                var longAngleStart = btm_startAngle + longIndex * tmp_step
                var longAngleEnd = btm_startAngle + (longIndex + 1) * tmp_step
                
                // 在每个长刻度间隔中绘制短刻度线
                for(var shortIndex = 1; shortIndex <= dial_shortPerLong; shortIndex++) {
                    var shortAngle = longAngleStart + shortIndex * short_step
                    
                    // 计算短刻度线起始位置
                    var short_start_x = (width/2) + (btm_r + btm_lineWidth + dial_addR) * Math.cos(shortAngle/180*Math.PI)
                    var short_start_y = (height/2) + (btm_r + btm_lineWidth + dial_addR) * Math.sin(shortAngle/180*Math.PI)
                    
                    // 计算短刻度线结束位置
                    var short_end_x = short_start_x + dial_shortLen * Math.cos(shortAngle/180*Math.PI)
                    var short_end_y = short_start_y + dial_shortLen * Math.sin(shortAngle/180*Math.PI)
                    
                    // 绘制短刻度线
                    ctx.moveTo(short_start_x, short_start_y)
                    ctx.lineTo(short_end_x, short_end_y)
                }
            }
            ctx.stroke()
            
        }
        
        // 监听属性变化并重绘
        Connections {
            target: dashboardRoot
            function onCurrentValueChanged() { dashboardCanvas.requestPaint() }
            function onInitialValueChanged() { dashboardCanvas.requestPaint() }
            function onPrimaryColorChanged() { dashboardCanvas.requestPaint() }
            function onBackgroundColorChanged() { dashboardCanvas.requestPaint() }
            function onMaxValueChanged() { dashboardCanvas.requestPaint() }
            function onMinValueChanged() { dashboardCanvas.requestPaint() }
        }
    }
    
    // 中心圆形背景
    Rectangle {
        id: centerBackground
        anchors.centerIn: parent
        width: dashboardRoot.dashboardRadius*2-30
        height: width
        radius: width / 2
        // color:dashboardRoot.backgroundColor
        color: "#13131a"
        border.color: dashboardRoot.primaryColor
        border.width: 2
        // border.color: dashboardRoot.primaryColor
        // border.width: 2
        z: 20  // 设置最高层级，覆盖所有组件
        
        // 科技圆框显示，作为中心背景的子元素
        Image {
            id: techCircle
            source: "qrc:/Resource/rightelement/science_famework.svg"
            width: textRadius * 2 + 40 // 刻度值位置的直径 + 30像素的额外边距
            height: textRadius * 2 + 40 // 刻度值位置的直径 + 30像素的额外边距
            sourceSize: Qt.size(width, height)
            anchors.centerIn: parent // 以父元素为锚点居中
            opacity: 1
            z: -1 // 设置为负值，确保显示在背景后面
        }
    }
    
    // 标签矩形 - 显示在中心圆形下方
    Rectangle {
        id: labelBackground
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: centerBackground.bottom
        anchors.topMargin: 40
        width: 150
        height: 50
        radius: height / 2
        color: "#13131a" // 使用不透明的背景色，与centerBackground相同
        border.width: 1
        border.color: Theme.boardColor
        z: 20
        
        Text {
            anchors.centerIn: parent
            text: dashboardRoot.labelText
            color: dashboardRoot.primaryColor
            font.pixelSize: 16
            font.family: dashboardRoot.fontFamily
        }
    }
    
    // 中心数值显示 - 覆盖指针
    Text {
        id: valueDisplay
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -10
        text: dashboardRoot.currentValue.toFixed(1)
        font.weight: Font.ExtraBold
        font.pixelSize: dashboardRoot.valueFontSize
        font.bold: true
        font.family: dashboardRoot.fontFamily
        horizontalAlignment: Text.AlignHCenter
        color: dashboardRoot.primaryColor
        z: 21  // 设置最高层级，覆盖所有组件
    }
    
    // 单位显示
    Label {
        id: unitLabel
        anchors.top: valueDisplay.bottom
        anchors.horizontalCenter: valueDisplay.horizontalCenter
        anchors.topMargin: 5
        text: dashboardRoot.unit
        font.pointSize: 11
        font.bold: true
        visible: dashboardRoot.showUnit  // 使用可配置的单位显示控制
        // 动态调整颜色，根据数值的大小动态变化
        color: dashboardRoot.primaryColor
        z: 21  // 设置最高层级，覆盖所有组件
    }
    
    // 三角形指针 - 放在底部，被数值显示覆盖
    Canvas {
        id: pointerCanvas
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        visible: dashboardRoot.showPointer
        z: 10  // 设置层级在底部
        
        onPaint: {
            if (!dashboardRoot.showPointer) return
            
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            // 设置指针样式
            ctx.fillStyle = dashboardRoot.pointerColor
            ctx.strokeStyle = dashboardRoot.pointerColor
            ctx.lineWidth = 1
            
            // 计算中心点和指针参数
            var centerX = width / 2
            var centerY = height / 2
            var pointerRadius = dashboardCanvas.btm_r + dashboardCanvas.top_lineWidth  // 底盘半径+进度厚度
            var angleRad = dashboardRoot.currentAngle * Math.PI / 180  // 使用currentAngle
            
            // 三角形顶点（指针尖端）
            var tipX = centerX + pointerRadius * Math.cos(angleRad)
            var tipY = centerY + pointerRadius * Math.sin(angleRad)
            
            // 三角形底边两个顶点
            var baseAngle1 = angleRad + Math.PI / 2
            var baseAngle2 = angleRad - Math.PI / 2
            var baseRadius = dashboardRoot.pointerWidth / 2
            
            var base1X = centerX + baseRadius * Math.cos(baseAngle1)
            var base1Y = centerY + baseRadius * Math.sin(baseAngle1)
            var base2X = centerX + baseRadius * Math.cos(baseAngle2)
            var base2Y = centerY + baseRadius * Math.sin(baseAngle2)
            
            // 绘制三角形指针
            ctx.beginPath()
            ctx.moveTo(tipX, tipY)
            ctx.lineTo(base1X, base1Y)
            ctx.lineTo(base2X, base2Y)
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
            
            // 绘制中心圆点
            ctx.beginPath()
            ctx.arc(centerX, centerY, dashboardRoot.pointerWidth, 0, 2 * Math.PI)
            ctx.fill()
        }
        
        // 监听属性变化并重绘
        Connections {
            target: dashboardRoot
            function onCurrentValueChanged() { pointerCanvas.requestPaint() }
            function onInitialValueChanged() { pointerCanvas.requestPaint() }
            function onPointerColorChanged() { pointerCanvas.requestPaint() }
            function onShowPointerChanged() { pointerCanvas.requestPaint() }
        }
    }
    
    // 刻度标签已在Canvas中直接绘制，支持文本旋转
    
    // 鼠标点击区域
    MouseArea {
        anchors.fill: parent
        onClicked: dashboardRoot.clicked()
    }
    
    // 监听currentValue变化并发出信号
    onCurrentValueChanged: {
        valueChanged(currentValue)
    }
    
    // 公共方法
    function setValue(newValue) {
        var maxValueToUse = autoScaleValue ? adjustedMaxValue : maxValue
        if (newValue >= minValue && newValue <= maxValueToUse) {
            currentValue = newValue
        }
    }
    
    function setRange(min, max) {
        minValue = min
        maxValue = max
    }
    
    function setColors(primary, background) {
        primaryColor = primary
        backgroundColor = background
    }
    
    function setAngleRange(start, total) {
        startAngle = start
        totalAngle = total
    }
    
    function setScaleCount(count) {
        scaleCount = count
    }
    
    function setInitialValue(value) {
        if (value >= minValue && value <= maxValue) {
            initialValue = value
        }
    }
    
    function setDashboardRadius(radius) {
        dashboardRadius = radius
    }
    
    function setCenterBackgroundSize(size) {
        centerBackgroundSize = size
    }
}
