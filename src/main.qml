// Main.qml
import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls
import "./Src/leftPage"
import "./Src/rightPage"
import "./Src/nightPage"
import "./Src/commonUI"
import "./Src/style"
Windows {
    id: root
    width: 1920
    height: 1200
    
    // 全局网络数据存储，供全局qml文件进行数据访问
    property var networkJsonData: ({
        "rawData": "",
        "timestamp": "",
        "connectionStatus": "disconnected",
        "lastUpdateTime": new Date()
    })
    
    // 页面状态管理
    property bool isSimpleMode: true
    // 页面状态控制
    property bool showHomePage: false  // 默认显示主页
    property bool showMapPage: false  // 控制地图摄像头和仪表盘的显示
    property bool showCurvesPage: false  // 控制是否显示曲线图
    
    // 全局车辆ID属性，供所有子组件访问
    property string currentVehicleId: ""
    
    // 左页面引用，供其他组件访问车辆数据模型
    property alias leftPage: leftrect
    // 左边背景矩形
    Leftpage{
        id:leftrect
        width: 360  // 调整宽度以更好地配合底部图标布局
        anchors.left: parent.left
        anchors.top:parent.top
        anchors.bottom: bottomRect.top
        color:"#1a1a1a"
        visible: !root.isSimpleMode  // 简洁模式下隐藏
        rootWindow: root  // 传递根窗口引用
    }
    // 右边背景矩形
    LayoutRight{
        id:rightrect
        width:parent.width-leftrect.width
        anchors.right: parent.right
        anchors.top:parent.top
        anchors.bottom: bottomRect.top
        visible: !root.isSimpleMode  // 简洁模式下隐藏
        rootWindow: root  // 传递根窗口引用
    }
    
    // 简洁模式下的居中图标
    // 科技感仪表盘界面
    TechDashboard {
        id: techDashboard
        width: parent.width
        height: parent.height-bottomRect.height
        anchors.bottom: bottomRect.top
        visible: root.isSimpleMode  // 简洁模式下显示
    }
    
    // 底部窗口
    Playmusic{
        id:bottomRect
        anchors.bottom: parent.bottom
        anchors.right:parent.right
        anchors.left: parent.left
        radius: 6
        height: 120  // 调整为与playmusic.qml中的高度一致

        color:"#2d2d37"
        rootWindow: root  // 设置根窗口引用
    }



}




// file - main.qml
/*******************
import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Controls 2.0
import "./Src/rightPage"
Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello qt")

    Mycar {
        id: speed_car
        x: 175
        y: 93
        width: 291
        height: 238
        dial_addR: -6
        dial_longNum: 10
        dial_longLen: 15
        dial_lineWidth: 3
        btm_lineWidth: 22
        top_lineWidth: 10
        top_endAngle: slider.value*1.3+140
        top_startAngle: 140
        btm_endAngle: 400
        btm_startAngle: 140
        btm_r: 120
        top_r: 120

        Text {
            id: speed
            x: 104
            y: 116
            width: 89
            height: 44
            text: slider.value
            style: Text.Normal
            font.weight: Font.ExtraBold
            font.capitalization: Font.MixedCase
            font.pixelSize: 40
            font.bold: true
            font.family: "Verdana"
            horizontalAlignment: Text.AlignHCenter
                }

        Label {
            id: speed_label
            x: 131
            y: 154
            width: 45
            height: 30
            text: qsTr("Km/h")
            font.pointSize: 11
            font.bold: true
            verticalAlignment: Text.AlignBottom
        }

        Label {
            id: label1
            x: 8
            y: 235
            width: 23
            height: 25
            text: qsTr("0")
            font.weight: Font.Normal
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 14
        }

        Label {
            id: label2
            x: 263
            y: 235
            width: 33
            height: 25
            text: qsTr("200")
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 14
            font.weight: Font.Normal
        }

        Label {
            id: label3
            x: -28
            y: 172
            width: 23
            height: 25
            text: qsTr("20")
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 14
            font.weight: Font.Normal
        }
    }

    Switch {
        id: sth
        x: 501
        y: 10
        text: "Wifi"

        onClicked: {
            if(sth.position) {
                speed_car.top_lineWidth = speed_car.btm_lineWidth;
            } else {
                speed_car.top_lineWidth = 10
            }
        }
    }

    Slider {
        id: slider
        x: 220
        y: 367
        font.pointSize: 14
        stepSize: 1
        to: 200
        from: 0
        value: 0

        onValueChanged: {
            if(value<60) {
                speed.color = "black"
            }
            else if(value<120) {
                speed.color = "#f2ac28"
            }
            else {
                speed.color = "red"
            }
            speed_label.color = speed.color
        }
    }

    Label {
        id: label4
        x: 466
        y: 264
        width: 42
        height: 25
        text: qsTr("180")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    Label {
        id: label5
        x: 146
        y: 192
        width: 23
        height: 25
        text: qsTr("40")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    Label {
        id: label6
        x: 476
        y: 192
        width: 23
        height: 25
        text: qsTr("160")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    Label {
        id: label7
        x: 172
        y: 123
        width: 23
        height: 25
        text: qsTr("60")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    Label {
        id: label8
        x: 445
        y: 123
        width: 35
        height: 25
        text: qsTr("140")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    Label {
        id: label9
        x: 236
        y: 73
        width: 23
        height: 25
        text: qsTr("80")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    Label {
        id: label10
        x: 382
        y: 72
        width: 36
        height: 25
        text: qsTr("120")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    Label {
        id: label11
        x: 310
        y: 62
        width: 23
        height: 25
        text: qsTr("100")
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: 14
        font.weight: Font.Normal
    }

    // 初始化SharedNetworkConnection单例
    Component.onCompleted: {
        console.log("Main.qml: 初始化SharedNetworkConnection")
        // SharedNetworkConnection作为单例会自动初始化
    }

}

