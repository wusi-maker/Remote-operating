import QtQuick 2.15
import QtQuick.Controls
import "../title"
Rectangle{
    id:rightrect
    // 搜索框
    Row{
        id:searchRow
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 36
        anchors.verticalCenter: parent.verticalCenter
        Rectangle{
            id:backgroundRect
            width:24
            height: 35
            color: "transparent"
            radius: 4
            border.width: 1
            border.color: "#2b2b31"

            Image {
                id:backimage
                anchors.fill: parent
                source: "qrc:/Resource/title/pointDown.svg"
                rotation: 90
                sourceSize: Qt.size(20,20)
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        backimage.source="qrc:/Resource/title/pointWhite.svg"
                    }
                    onExited: {
                        backimage.source="qrc:/Resource/title/pointDown.svg"
                    }
                }
            }

        }
        TextField{
            id:searchFidld
            height: backgroundRect.height
            width: 240
            // 控制输入框的形状
            background: Rectangle{

            }

        }
        Rectangle{
            id:soundHounRect
            height: backgroundRect.height
            width: height
            color:"#241c26"
            border.color: "#36262f"
            border.width: 1
            Image {
                id:soundimage
                anchors.fill: parent
                source: "qrc:/Resource/title/MicrophoneDaufle.svg"
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        soundimage.source="qrc:/Resource/title/MicrophoneWhite.svg"
                    }
                    onExited: {
                        soundimage.source="qrc:/Resource/title/MicrophoneDaufle.svg"
                    }
                }
            }
        }
    }

    // 用户信息
    UserConfigsetting{
        id:otherRow
        anchors.verticalCenter: minmaxMouse.verticalCenter
        anchors.right: minmaxMouse.left
        anchors.rightMargin: 10
        spacing: 15
    }

    // 最大化最小化
    MinandMax{
        id:minmaxMouse
        width: 180
        color:"transparent"
        anchors.top: parent.top
        anchors.right: parent.right
        // anchors.left: parent.left
        height: 60
    }
}
