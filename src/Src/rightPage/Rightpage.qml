import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import "../title"
import "../commonUI"
Rectangle{
    id:rightrect

    // 引用根窗口以便访问状态变量
    property var rootWindow: null

    
    // 车辆监控数据模型
    property var vehicleData: [
        {id: "V001", name: "车辆001", status: "在线", location: "北京市朝阳区", battery: 85, speed: 45, isOnline: true},
        {id: "V002", name: "车辆002", status: "离线", location: "上海市浦东区", battery: 62, speed: 0, isOnline: false},
        {id: "V003", name: "车辆003", status: "在线", location: "广州市天河区", battery: 91, speed: 32, isOnline: true},
        {id: "V004", name: "车辆004", status: "维修中", location: "深圳市南山区", battery: 0, speed: 0, isOnline: false},
        {id: "V005", name: "车辆005", status: "在线", location: "杭州市西湖区", battery: 78, speed: 28, isOnline: true}
    ]
    
    property int onlineCount: vehicleData.filter(v => v.isOnline).length
    property int totalCount: vehicleData.length
    
    Search{
        id:searchRow
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 36
        anchors.verticalCenter: otherRow.verticalCenter
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
    MinAndMax{
        id:minmaxMouse
        width: 180
        color:"transparent"
        anchors.top: parent.top
        anchors.right: parent.right
        height: 60
    }
    // 组件初始化时输出状态变量
    Component.onCompleted: {
        console.log("showHomePage:", rootWindow.showHomePage)
        console.log("showMapPage:", rootWindow.showMapPage)
    }

    // 监听状态变量变化
    Connections {
        target: rootWindow
        function onShowHomePageChanged() {
            console.log("showHomePage changed to:", rootWindow.showHomePage)
        }
        function onShowMapPageChanged() {
            console.log("showMapPage changed to:", rootWindow.showMapPage)
        }
    }

    // 主页组件
    HomePage {
        id: homePageComponent
        // 其布局根据页面大小变化
        anchors.top: otherRow.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.bottomMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        // 根据控制按钮来设置是否可见

        visible: rootWindow.showHomePage
    }

    // 地图摄像头模块
    Mapandcemera {
        id: mapCameraModule
        anchors.top: otherRow.bottom
        anchors.bottom: dashboardBackground.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        visible: rootWindow.showMapPage
        rootWindow: rightrect.rootWindow  // 传递根窗口引用
    }
    
    CombinedDashboardLayout{
        id: dashboardBackground
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        width: 1600
        height: 400
        color: "#2a2a2a"
        border.color: "#555555"
        border.width: 2
        radius: 15
        visible: rootWindow.showMapPage
    }
    
}
