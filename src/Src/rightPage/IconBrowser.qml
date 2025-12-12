import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI

ScrollView {
    id: root
    
    property var iconList: [
        {name: "Settings", code: 0xe713},
        {name: "People", code: 0xe716},
        {name: "Contact", code: 0xe77b},
        {name: "ChevronDown", code: 0xe70d},
        {name: "ChevronDownSmall", code: 0xe96e},
        {name: "Search", code: 0xe721},
        {name: "Add", code: 0xe710},
        {name: "Delete", code: 0xe74d},
        {name: "Edit", code: 0xe70f},
        {name: "Save", code: 0xe74e},
        {name: "Cancel", code: 0xe711},
        {name: "More", code: 0xe712},
        {name: "Video", code: 0xe714},
        {name: "Mail", code: 0xe715},
        {name: "Phone", code: 0xe717},
        {name: "Camera", code: 0xe722},
        {name: "Send", code: 0xe724},
        {name: "Share", code: 0xe72d},
        {name: "Lock", code: 0xe72e},
        {name: "Refresh", code: 0xe72c},
        {name: "Back", code: 0xe72b},
        {name: "Forward", code: 0xe72a},
        {name: "Home", code: 0xe80f},
        {name: "Folder", code: 0xe8b7},
        {name: "Document", code: 0xe8a5},
        {name: "Picture", code: 0xe8b9},
        {name: "Music", code: 0xe8d6},
        {name: "Download", code: 0xe896},
        {name: "Upload", code: 0xe898},
        {name: "Copy", code: 0xe8c8},
        {name: "Cut", code: 0xe8c6},
        {name: "Print", code: 0xe749},
        {name: "Wifi", code: 0xe701},
        {name: "Bluetooth", code: 0xe702},
        {name: "Battery", code: 0xe850},
        {name: "Volume", code: 0xe767},
        {name: "Brightness", code: 0xe706},
        {name: "Calendar", code: 0xe787},
        {name: "Clock", code: 0xe917},
        {name: "Globe", code: 0xe774},
        {name: "Heart", code: 0xeb51},
        {name: "Star", code: 0xe734},
        {name: "Flag", code: 0xe7c1},
        {name: "Warning", code: 0xe7ba},
        {name: "Error", code: 0xe783},
        {name: "Info", code: 0xf167},
        {name: "CheckMark", code: 0xe73e},
        {name: "Close", code: 0xe8bb}
    ]
    
    Column {
        width: root.width
        spacing: 20
        
        Text {
            text: "FluentUI 图标浏览器"
            font.pixelSize: 24
            font.bold: true
            color: FluTheme.dark ? "#FFFFFF" : "#000000"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Text {
            text: "点击图标复制代码到剪贴板"
            font.pixelSize: 14
            color: FluTheme.dark ? "#CCCCCC" : "#666666"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        GridLayout {
            width: parent.width
            columns: Math.floor(width / 200)
            columnSpacing: 10
            rowSpacing: 10
            
            Repeater {
                model: root.iconList
                
                Rectangle {
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 120
                    color: mouseArea.containsMouse ? (FluTheme.dark ? "#404040" : "#F0F0F0") : "transparent"
                    border.color: FluTheme.dark ? "#606060" : "#E0E0E0"
                    border.width: 1
                    radius: 8
                    
                    Column {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        FluIcon {
                            iconSource: modelData.code
                            iconSize: 32
                            iconColor: FluTheme.dark ? "#FFFFFF" : "#000000"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: modelData.name
                            font.pixelSize: 12
                            font.bold: true
                            color: FluTheme.dark ? "#FFFFFF" : "#000000"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "0x" + modelData.code.toString(16).toUpperCase()
                            font.pixelSize: 10
                            color: FluTheme.dark ? "#CCCCCC" : "#666666"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            // 复制代码到剪贴板
                            var code = "iconSource: " + modelData.code + "  // " + modelData.name
                            // 这里可以添加复制到剪贴板的功能
                            console.log("复制代码: " + code)
                        }
                    }
                    
                    // 悬停提示
                    FluTooltip {
                        visible: mouseArea.containsMouse
                        text: "点击复制: iconSource: " + modelData.code
                    }
                }
            }
        }
    }
}