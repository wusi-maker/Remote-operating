import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Basic

// 搜索框组件
Item {
    
    property alias searchText: searchField.text
    
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: "#1a1a1a"
        radius: 4
        
        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 0
            
            TextField {
                id: searchField
                width: parent.width - searchIcon.width - parent.spacing
                height: parent.height
                placeholderText: "设备查找"
                placeholderTextColor: "#a0a0a0"
                color: "#ffffff"
                font.pixelSize: 20
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                selectionColor: "#4a90e2"
                selectedTextColor: "#ffffff"
                
                background: Rectangle {
                    color: "transparent"
                }
                
                onActiveFocusChanged: {
                    if(activeFocus) {
                        searchPopup.open()
                    }
                }
                
                onTextChanged: {
                    if(text.length > 0 && !searchPopup.visible) {
                        searchPopup.open()
                    }
                }
            }
            
            Image {
                id: searchIcon
                width: 30
                height: 30
                anchors.verticalCenter: parent.verticalCenter

                source: "qrc:/Resource/title/search.svg"
                sourceSize: Qt.size(40, 40)
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        searchField.forceActiveFocus()
                        if(!searchPopup.visible) {
                            searchPopup.open()
                        }
                    }
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                searchField.forceActiveFocus()
                if(!searchPopup.visible) {
                    searchPopup.open()
                }
            }
        }
    }
    
    Popup {
        id: searchPopup
        width: searchComponent.width
        height: 350
        y: searchComponent.height + 5
        visible: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        
        background: Rectangle {
            anchors.fill: parent
            radius: 4
            gradient: Gradient {
                GradientStop {
                    position: 0.00
                    color: "#21283d"
                }
                GradientStop {
                    position: 1.00
                    color: "#382635"
                }
            }
            border.width: 1
            border.color: "#2b2b31"
            
            // 内容区域
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 4
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { color: "#1a1d29"; position: 0 }
                    GradientStop { color: "#241c26"; position: 1 }
                }
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    
                    // 搜索历史标题
                    Text {
                        text: "搜索历史"
                        color: "#a0a0a0"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    // 搜索历史列表
                    ListView {
                        id: historyListView
                        width: parent.width
                        height: 130
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {
                            active: true
                            policy: ScrollBar.AsNeeded
                        }
                        
                        model: ListModel {
                            ListElement { text: "周杰伦 - 青花瓷" }
                            ListElement { text: "邓紫棋 - 泡沫" }
                            ListElement { text: "林俊杰 - 江南" }
                            ListElement { text: "陈奕迅 - 十年" }
                            ListElement { text: "薛之谦 - 演员" }
                        }
                        
                        delegate: Rectangle {
                            width: historyListView.width
                            height: 30
                            color: "transparent"
                            radius: 3
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                
                                Image {
                                    width: 16
                                    height: 16
                                    source: "qrc:/Resource/title/search.svg"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: model.text
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#3a3a3a"
                                onExited: parent.color = "transparent"
                                onClicked: {
                                    searchField.text = model.text
                                    searchPopup.close()
                                }
                            }
                        }
                    }
                    
                    // 分隔线
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#2b2b31"
                    }
                    
                    // 热门搜索标题
                    Text {
                        text: "热门搜索"
                        color: "#a0a0a0"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    // 热门搜索列表
                    ListView {
                        id: hotSearchListView
                        width: parent.width
                        height: 130
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar {
                            active: true
                            policy: ScrollBar.AsNeeded
                        }
                        
                        model: ListModel {
                            ListElement { text: "流行音乐"; isHot: true }
                            ListElement { text: "古典音乐"; isHot: false }
                            ListElement { text: "摇滚音乐"; isHot: true }
                            ListElement { text: "民谣音乐"; isHot: false }
                            ListElement { text: "电子音乐"; isHot: true }
                        }
                        
                        delegate: Rectangle {
                            width: hotSearchListView.width
                            height: 30
                            color: "transparent"
                            radius: 3
                            
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8
                                
                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 2
                                    color: model.isHot ? "#ff6b6b" : "#4a90e2"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: model.text
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                
                                Text {
                                    text: model.isHot ? "HOT" : ""
                                    color: "#ff6b6b"
                                    font.pixelSize: 10
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: model.isHot
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.color = "#3a3a3a"
                                onExited: parent.color = "transparent"
                                onClicked: {
                                    searchField.text = model.text
                                    searchPopup.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
