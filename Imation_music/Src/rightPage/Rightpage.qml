import QtQuick 2.15
import QtQuick.Controls
import "../title"
Rectangle{
    id:rightrect
    Row{
        Item {
            height: 30
            width: 140
            anchors.verticalCenter: parent.verticalCenter
            Row{
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Rectangle{
                    id:diologRect
                    width: 25
                    height: width
                    radius:width/2
                    color:"#2d2d37"
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/Resource/title/user.svg"
                        sourceSize: Qt.size(25,25)
                    }
                }

                // 未登录文本
                Text {
                    id: loaderrorText
                    text: qsTr("未登录")
                    color:"#75777f"
                    font.pixelSize: 14
                    font.family: "微软雅黑 Light"
                    anchors.verticalCenter: diologRect.verticalCenter
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            loaderrorText.color="white"

                        }
                        onExited: {
                            loaderrorText.color="#75777f"
                        }
                    }
                }

                // 会员标识，使用一个抽象属性Item，实际上就是一个隐形的小方框用于固定多个组件在一定范围内
                Item{
                    height: diologRect.height
                    width: loaderrorText.width*1.2
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle{
                        id:viprect
                        width:parent.width
                        height: 12
                        radius:width/2
                        color:"#dadada"
                        anchors.left: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        Label{
                            text:"VIP开通"
                            anchors.left: parent.left
                            anchors.leftMargin: parent.radius*2+5
                            color:"#f8f9f9"

                        }
                    }

                }



            }
        }
    }

    // 最大最小化
    MinAndMax{
        id:minMax
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 60
    }
}
