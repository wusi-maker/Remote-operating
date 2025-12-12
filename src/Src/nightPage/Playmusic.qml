import QtQuick 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: bottomRect
    width: parent.width
    height: 120  // 调整高度以容纳图标
    
    // 引用根窗口以便访问isSimpleMode属性
    property var rootWindow: null
    color: "transparent"
    
    // 鼠标拖动逻辑
    MouseArea {
        anchors.fill: parent
        property point dragStartPos: Qt.point(0, 0)
        
        onPressed: (mouse) => {
            dragStartPos = Qt.point(mouse.x, mouse.y)
            console.log("底部窗口拖动开始:", dragStartPos)
        }

        onPositionChanged: (mouse) => {
            if (pressed && bottomRect.rootWindow) {
                bottomRect.rootWindow.x += mouse.x - dragStartPos.x
                bottomRect.rootWindow.y += mouse.y - dragStartPos.y
            }
        }
        
        // 允许子组件接收鼠标事件
        propagateComposedEvents: true
    }
    
    // 底部图标容器
    Rectangle {
        id: iconContainer
        width: 240  // 容纳三个图标的宽度
        height: 60
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.bottomMargin: 20
        color: "transparent"
        
        // 三个图标的水平布局
        RowLayout {
            anchors.fill: parent
            spacing: 60  // 图标间距
            
            // 第一个图标占位符
            Rectangle {
                id: icon1
                width: 60
                height: 60
                radius: 30  // 圆形
                color: mouseArea1.pressed ? "#505050" : (mouseArea1.containsMouse ? "#909090" : "#808080")
                border.width: (bottomRect.rootWindow && bottomRect.rootWindow.showHomePage) ? 2 : 0
                border.color: "lightgreen"
                Layout.alignment: Qt.AlignCenter
                
                // 鼠标交互区域
                MouseArea {
                    id: mouseArea1
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Icon 1 clicked")
                        
                        // 显示主页模式
                        if (bottomRect.rootWindow) {
                            bottomRect.rootWindow.showHomePage = true
                            bottomRect.rootWindow.showMapPage = false
                            bottomRect.rootWindow.isSimpleMode = false
                            console.log("Icon 1 clicked - 显示主页")
                        } else {
                            console.log("无法访问rootWindow对象")
                        }
                    }
                }
            }
            
            // 第二个图标占位符
            Rectangle {
                id: icon2
                width: 60
                height: 60
                radius: 30  // 圆形
                color: mouseArea2.pressed ? "#505050" : (mouseArea2.containsMouse ? "#909090" : "#808080")
                border.width: (bottomRect.rootWindow && bottomRect.rootWindow.showMapPage) ? 2 : 0
                border.color: "lightgreen"
                Layout.alignment: Qt.AlignCenter
                
                // 鼠标交互区域
                MouseArea {
                    id: mouseArea2
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Icon 2 clicked - 显示地图和仪表盘")
                        // 显示地图和仪表盘模式
                        if (bottomRect.rootWindow) {
                            bottomRect.rootWindow.showHomePage = false
                            bottomRect.rootWindow.showMapPage = true
                            bottomRect.rootWindow.isSimpleMode = false
                            console.log("Icon 2 clicked - 显示地图和仪表盘")
                        } else {
                            console.log("无法访问rootWindow对象")
                        }
                    }
                }
            }
            
            // 第三个图标占位符
            Rectangle {
                id: icon3
                width: 60
                height: 60
                radius: 30  // 圆形
                color: mouseArea3.pressed ? "#505050" : (mouseArea3.containsMouse ? "#909090" : "#808080")
                border.width: (bottomRect.rootWindow && bottomRect.rootWindow.isSimpleMode) ? 2 : 0
                border.color: "lightgreen"
                Layout.alignment: Qt.AlignCenter
                
                // 鼠标交互区域
                MouseArea {
                    id: mouseArea3
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        console.log("Icon 3 clicked - 切换简洁模式")
                        // 切换简洁模式
                        if (bottomRect.rootWindow) {
                            bottomRect.rootWindow.showHomePage = false
                            bottomRect.rootWindow.showMapPage = false
                            bottomRect.rootWindow.isSimpleMode = true
                            console.log("Icon 3 clicked - 切换简洁模式")
                        } else {
                            console.log("无法访问rootWindow对象")
                        }
                    }
                }
            }
        }
    }
}
