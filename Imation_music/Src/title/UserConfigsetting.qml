import QtQuick 2.15
import QtQuick.Controls

Row{
    Item{
        height: 30
        width: 150
        anchors.verticalCenter: parent.verticalCenter
        // vip视图
        Row{
            spacing: 15
            Rectangle{
                id:userImage
                width: 25
                height: width
                radius: width/2
                color:"#2d2d37"
                Image {
                    source: "qrc:/Resource/title/user.svg"
                    sourceSize: Qt.size(25,25)
                }
            }

            Text {
                id: loadText
                text:"未登录"
                color:"#75777f"
                font.pixelSize: 14
                font.family: "微软雅黑 Light"
                anchors.verticalCenter: userImage.verticalCenter
                MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        loadText.color="white"
                    }
                    onExited: {
                        loadText.color="#75777f"
                    }
                }
            }

            Item{
                height: userImage.height
                width: loadText.width
                anchors.verticalCenter: parent.verticalCenter
                Rectangle{
                    id:vipRect
                    width:parent.width+5
                    height: 12
                    radius: height/2
                    color:"#dadada"
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    Label{
                        text:"VIP开通"
                        anchors.left: parent.left
                        anchors.leftMargin: parent.radius*2+5
                        color:"#f8f9f9"
                        font.pixelSize: parent.height/2+2
                        font.family: "微软雅黑 Light"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Rectangle{
                    id:bgBordRect
                    width:vipRect.height+4
                    height: width
                    radius:width
                    color:"#13131a"
                    border.width: 2
                    border.color: "#dadada"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

        }
    }
    // 图标展示
    Image {
        id: loginImage
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/Resource/title/pointDown.svg"
        sourceSize: Qt.size(25,25)
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                loginImage.source="qrc:/Resource/title/pointWhite.svg"
                // loginImage.sourceSize=Qt.size(25,25)
            }
            onExited: {
                loginImage.source="qrc:/Resource/title/pointDown.svg"

            }
        }
    }

    Image {
        id: peopleImage
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/Resource/title/user.svg"
        sourceSize: Qt.size(25,25)
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                peopleImage.source="qrc:/Resource/title/pointWhite.svg"
                // loginImage.sourceSize=Qt.size(25,25)
            }
            onExited: {
                peopleImage.source="qrc:/Resource/title/user.svg"

            }
        }
    }

    Image {
        id: configImage
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/Resource/title/config.svg"
        sourceSize: Qt.size(25,25)
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                configImage.source="qrc:/Resource/title/pointWhite.svg"
                // loginImage.sourceSize=Qt.size(25,25)
            }
            onExited: {
                configImage.source="qrc:/Resource/title/config.svg"

            }
        }
    }



}

