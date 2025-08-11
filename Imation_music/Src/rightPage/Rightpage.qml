import QtQuick 2.15

Rectangle{
    id:rightrect
    Rectangle{
        color:"transparent"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

        height: 60
        Row{
            id:closeRow
            spacing: 15
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 0.02*Window.width
            Image {
                id: miniImg
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/Resource/title/minimize.svg"
                sourceSize: Qt.size(20,20)

                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    opacity: miniMouse.containsMouse ? 0.6 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    id: miniMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showMinimized()  // 注意：Window应改为root
                }
            }
            Rectangle{
                id:miniRect
                width: 20
                height: 2
                anchors.verticalCenter: parent.verticalCenter
                color:"#75777f"
                // 鼠标悬浮事件
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        miniRect.color="white"
                    }
                    onExited: {
                        miniRect.color="#75777f"
                    }
                    onClicked: {
                        root.showMinimized()
                    }
                }
            }
            Rectangle{
                id:maxRect
                width: 20
                height: width
                radius: 2
                border.width: 2
                border.color: "#75777f"
                anchors.verticalCenter: parent.verticalCenter
                color:"transparent"
                // 鼠标悬浮事件
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        maxRect.border.color="white"
                    }
                    onExited: {
                        maxRect.border.color="#75777f"
                    }
                    onClicked: {
                        root.showFullScreen()
                    }
                }
            }
            Image {
                id: closeImg
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/Resource/title/close.svg"
                sourceSize: Qt.size(20,20)

                Rectangle {
                    anchors.fill: parent
                    color: "white"
                    opacity: closeMouse.containsMouse ? 0.6 : 0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.quit()  // 注意：Window应改为root
                }
            }
        }
    }

}
