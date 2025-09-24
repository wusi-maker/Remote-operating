import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    
    // 可配置属性
    property string title: "进度条"
    property real currentValue: 50
    property real minValue: 0
    property real maxValue: 100
    property string unit: "%"
    property int segments: 4  // 分段数量
    property color baseColor: "#00ffff"  // 基础颜色
    property real barHeight: 8
    property real spacing: 2  // 段之间的间距
    property bool enableRandomTest: false  // 是否启用随机测试
    property real fontSize: 12  // 字体大小
    
    // 计算属性
    property real progress: (currentValue - minValue) / (maxValue - minValue)
    property real segmentWidth: (width - (segments - 1) * spacing) / segments
    
    // 计算当前值所在的分段
    property int currentSegment: {
        var normalizedProgress = Math.max(0, Math.min(1, progress))
        var segment = Math.floor(normalizedProgress * segments)
        return Math.min(segment, segments - 1)
    }
    
    // 根据当前分段计算数值颜色
    property color valueColor: {
        if (currentSegment < 0 || segments <= 0) {
            return baseColor
        }
        
        var r = parseInt(baseColor.toString().substr(1, 2), 16)
        var g = parseInt(baseColor.toString().substr(3, 2), 16)
        var b = parseInt(baseColor.toString().substr(5, 2), 16)
        
        // 根据分段位置计算颜色强度
        var intensity = (currentSegment + 1) / segments
        var finalR = Math.floor(r * intensity)
        var finalG = Math.floor(g * intensity)
        var finalB = Math.floor(b * intensity)
        
        return Qt.rgba(finalR / 255, finalG / 255, finalB / 255, 0.8 + intensity * 0.2)
    }
    
    width: 200
    height: 40
    
    // 顶部标题和数值显示
    Row {
        id: headerRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 20
        spacing: 0
        
        // 左侧标题
        Text {
            id: titleText
            text: root.title
            color: "white"
            font.pixelSize: root.fontSize
            verticalAlignment: Text.AlignVCenter
            width: parent.width - valueText.width
        }
        
        // 右侧数值
        Text {
            id: valueText
            text: root.currentValue.toFixed(1) + root.unit
            color: root.valueColor
            font.pixelSize: root.fontSize
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            
            Behavior on color {
                ColorAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
    
    // 进度条容器
    Item {
        id: progressContainer
        anchors.top: headerRow.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.barHeight
        
        // 背景
        Rectangle {
            anchors.fill: parent
            color: "#1a1a1a"
            radius: root.barHeight / 2
            border.color: "#333333"
            border.width: 1
        }
        
        // 分段进度条
        Row {
            id: segmentRow
            anchors.left: parent.left
            anchors.leftMargin: 1
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.spacing
            
            Repeater {
                model: root.segments
                
                Rectangle {
                    id: segment
                    width: root.segmentWidth
                    height: root.barHeight - 2
                    radius: height / 2
                    
                    // 计算当前段的进度
                    property real segmentProgress: {
                        var segmentStart = index / root.segments
                        var segmentEnd = (index + 1) / root.segments
                        
                        if (root.progress <= segmentStart) {
                            return 0
                        } else if (root.progress >= segmentEnd) {
                            return 1
                        } else {
                            return (root.progress - segmentStart) / (segmentEnd - segmentStart)
                        }
                    }
                    
                    // 根据进度和位置计算颜色深度
                    property real colorIntensity: {
                        var baseIntensity = (index + 1) / root.segments  // 基础强度递增
                        return segmentProgress * baseIntensity
                    }
                    
                    // 动态颜色计算
                    color: {
                        if (segmentProgress <= 0) {
                            return "transparent"
                        }
                        
                        var r = parseInt(root.baseColor.toString().substr(1, 2), 16)
                        var g = parseInt(root.baseColor.toString().substr(3, 2), 16)
                        var b = parseInt(root.baseColor.toString().substr(5, 2), 16)
                        
                        // 根据强度调整颜色深度
                        var intensity = Math.min(colorIntensity, 1.0)
                        var finalR = Math.floor(r * intensity)
                        var finalG = Math.floor(g * intensity)
                        var finalB = Math.floor(b * intensity)
                        
                        return Qt.rgba(finalR / 255, finalG / 255, finalB / 255, 0.8 + intensity * 0.2)
                    }
                    
                    // 宽度动画
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    // 进度变化时的宽度调整
                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * segment.segmentProgress
                        height: parent.height
                        radius: parent.radius
                        color: parent.color
                        
                        Behavior on width {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 进度变化动画
    Behavior on progress {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutCubic
        }
    }
    
    // 随机测试定时器
    Timer {
        id: randomTimer
        interval: 2000  // 2秒间隔
        running: root.enableRandomTest
        repeat: true
        onTriggered: {
            // 生成随机值
            var randomValue = root.minValue + Math.random() * (root.maxValue - root.minValue)
            root.currentValue = randomValue
        }
    }
}