import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI

FluPopup {
    id: dataDetailPopup
    
    // 弹出框属性
    implicitWidth: 1000
    implicitHeight: 700
    
    // 数据属性
    property alias dataModel: popupDataListView.model
    
    // 信号
    signal closeClicked()
    
    // 标题
    property string title: "数据详情"
    
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
            
            // 标题栏
            Rectangle {
                width: parent.width
                height: 80
                color:"transparent"
                radius: 6
                border.color: FluTheme.dark ? "#333333" : "#cccccc"
                border.width: 0
                
                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    
                    FluText {
                        text: "数据接收记录"
                        color: FluTheme.dark ? "#ffffff" : "#0078d4"
                        font.pixelSize: 24
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                }
            }
            
            // 数据显示区域
            Rectangle {
                width: parent.width
                height: parent.height - 80 - 60 - 30  // 减去标题栏、按钮栏和间距
                color: FluTheme.dark ? "#1e1e1e" : "#f9f9f9"
                radius: 6
                border.color: FluTheme.dark ? "#333333" : "#cccccc"
                border.width: 1
                
                ScrollView {
                    id: dataScrollView
                    anchors.fill: parent
                    anchors.margins: 10
                    clip: true
                    
                    ListView {
                        id: popupDataListView
                        anchors.fill: parent
                        spacing: 2
                        
                        delegate: Rectangle {
                            width: popupDataListView.width
                            height: Math.max(40, dataText.contentHeight + 20)
                            color: {
                                if (mouseArea.containsMouse) {
                                    return FluTheme.dark ? "#404040" : "#e6f3ff"
                                }
                                return index % 2 === 0 ? 
                                    (FluTheme.dark ? "#2d2d2d" : "#f8f8f8") : 
                                    (FluTheme.dark ? "#333333" : "#ffffff")
                            }
                            radius: 4
                            border.color: FluTheme.dark ? "#555555" : "#dddddd"
                            border.width: 1
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 15
                                
                                FluText {
                                    text: "#" + (index + 1)
                                    color: FluTheme.dark ? "#888888" : "#666666"
                                    font.pixelSize: 12
                                    width: 40
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                FluText {
                                    id: dataText
                                    text: model.data || ""
                                    color: FluTheme.dark ? "#ffffff" : "#333333"
                                    font.pixelSize: 13
                                    wrapMode: Text.WordWrap
                                    width: popupDataListView.width - 80
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onDoubleClicked: {
                                    // 双击复制数据
                                    if (model.data) {
                                        copyDialog.textToCopy = model.data
                                        copyDialog.open()
                                    }
                                }
                            }
                        }
                        
                        // 数据更新通知
                        Rectangle {
                            id: popupDataNotification
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 200
                            height: 40
                            color: FluTheme.dark ? "#2d5a2d" : "#d4edda"
                            border.color: FluTheme.dark ? "#4a7c4a" : "#c3e6cb"
                            border.width: 1
                            radius: 20
                            visible: false
                            z: 1000
                            
                            FluText {
                                anchors.centerIn: parent
                                text: "新数据已添加"
                                color: FluTheme.dark ? "#90ee90" : "#155724"
                                font.pixelSize: 12
                                font.bold: true
                            }
                            
                            Timer {
                                id: popupHideTimer
                                interval: 2000
                                onTriggered: popupDataNotification.visible = false
                            }
                        }
                    }
                }
            }
            
            // 底部按钮栏
            Rectangle {
                width: parent.width
                height: 60
                color: "transparent"
                
                Row {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    FluFilledButton {
                        text: "刷新数据"
                        width: 100
                        height: 35
                        onClicked: {
                            // 刷新数据逻辑
                            console.log("刷新数据")
                        }
                    }
                    
                    FluButton {
                        text: "关闭"
                        width: 100
                        height: 35
                        onClicked: {
                            dataDetailPopup.closeClicked()
                            dataDetailPopup.close()
                        }
                    }
                }
            }
        }
    }
    
    // 公开方法
    function showPopup() {
        open()
    }
    
    function addDataNotification() {
        popupDataNotification.visible = true
        popupHideTimer.restart()
    }
}