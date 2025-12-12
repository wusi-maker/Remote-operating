import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI

Row{

    // vip视图
    Row{
        spacing: 15
        Rectangle{
            id:userImage
            width: 25
            height: width
            radius: width/2
            color:"#2d2d37"
            FluIcon {
                    id: userIcon
                    iconSource: 0xe77b  // Contact icon
                    iconSize: 25
                    iconColor: "#FFFFFF"
                    anchors.centerIn: parent
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

        // Item{
        //     height: userImage.height
        //     width: loadText.width
        //     anchors.verticalCenter: parent.verticalCenter
        //     Rectangle{
        //         id:vipRect
        //         width:parent.width+5
        //         height: 12
        //         radius: height/2
        //         color:"#dadada"
        //         anchors.left: parent.left
        //         anchors.verticalCenter: parent.verticalCenter
        //         Label{
        //             text:"VIP开通"
        //             anchors.left: parent.left
        //             anchors.leftMargin: parent.radius*2+5
        //             color:"#f8f9f9"
        //             font.pixelSize: parent.height/2+2
        //             font.family: "微软雅黑 Light"
        //             anchors.verticalCenter: parent.verticalCenter
        //         }
        //     }
        //     Rectangle{
        //         id:bgBordRect
        //         width:vipRect.height+4
        //         height: width
        //         radius:width
        //         color:"#13131a"
        //         border.width: 2
        //         border.color: "#dadada"
        //         anchors.verticalCenter: parent.verticalCenter
        //     }
        // }

    }
    
    // 图标展示
    FluIcon {
         id: loginImage
         anchors.verticalCenter: parent.verticalCenter
         iconSource: 0xe96e  // ChevronDownSmall icon
         iconSize: 25
         iconColor: "#75777f"
         MouseArea{
             anchors.fill: parent
             hoverEnabled: true
             onEntered: {
                 loginImage.iconColor="#FFFFFF"
             }
             onExited: {
                 loginImage.iconColor="#75777f"
             }
         }
     }

    FluIcon {
         id: peopleImage
         anchors.verticalCenter: parent.verticalCenter
         iconSource: 0xE703  // Contact icon
         iconSize: 25
         iconColor: "#75777f"
         MouseArea{
             anchors.fill: parent
             hoverEnabled: true
             onEntered: {
                 peopleImage.iconColor="#FFFFFF"
             }
             onExited: {
                 peopleImage.iconColor="#75777f"
             }
         }
    }

    FluIcon {
         id: configImage
         anchors.verticalCenter: parent.verticalCenter
         iconSource: 0xe713  // Settings icon
         iconSize: 25
         iconColor: "#75777f"
         MouseArea{
             anchors.fill: parent
             hoverEnabled: true
             onEntered: {
                 configImage.iconColor="#FFFFFF"
             }
             onExited: {
                 configImage.iconColor="#75777f"
             }
         }
     }



}
