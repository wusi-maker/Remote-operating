import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Basic
// 搜索框
Row{
    id:searchRow
    property alias searchText: searchFidld.text


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
        placeholderText: qsTr("搜索...")
        placeholderTextColor: "#a0a0a0"
        font.pixelSize: 16
        leftPadding: 40
        rightPadding: 40  // 预留清除按钮空间
        selectionColor: "#4a90e2"
        selectedTextColor: "#ffffff"

        onActiveFocusChanged: {
            if(activeFocus){
                searchpop.open()
            }else{
                // searchpop.close()
            }
        }

        // 控制输入框的形状
        background: Rectangle{
            // 外部矩形
            anchors.fill: parent
            radius:4
            gradient: Gradient {
                GradientStop {
                    position: 0.00;
                    color: "#21283d";
                }
                GradientStop {
                    position: 1.00;
                    color: "#382635";
                }
            }
            Rectangle{
                // 内部矩形
                id:innerRect
                anchors.fill: parent
                anchors.margins: 1
                property real gradientStopPos: 1
                gradient: Gradient{
                    orientation: Gradient.Horizontal
                    GradientStop{color:"#1a1d29";position:0}
                    GradientStop{color:"#241c26";position:innerRect.gradientStopPos}
                }
            }
            Image {
                id: serchtion
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
                source: "qrc:/Resource/title/search.svg"
                sourceSize: Qt.size(25,25)
            }
            // 子空间可以访问到父控件已经兄弟控件
            MouseArea{
                anchors.fill: parent
                onClicked:  {
                    // innerRect.gradientStopPos=0
                    searchFidld.forceActiveFocus()
                    searchpop.open()
                }
            }

        }
    }
    Popup{
        id:searchpop
        width: parent.width
        height:800
        y:searchFidld.height+10
        visible: false
        // closePolicy:CloseOnPressOutside
        background: Rectangle{
            anchors.fill: parent
            radius:4
            color:"#75757f"
            Item {
                id: historItem
                anchors.left: parent.left

            }

        }

    }

    Rectangle{
        id:soundHounRect
        height: backgroundRect.height
        width: height
        radius: 4
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
