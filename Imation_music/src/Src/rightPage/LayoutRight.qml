import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15
// 步骤1，现在需要引入第三方库的文件中导入
import FluentUI
import "../style"
import "../title"
import "../commonUI"


Rectangle {
    id: rightrect
    
    // 使用主题背景色
    color: Theme.backgroundColor
    property var rootWindow: null
    
    // 监听全局车辆ID变化
    property string currentVehicleId: rootWindow ? rootWindow.currentVehicleId : ""
    
    // 当车辆ID变化时的监听器
    onCurrentVehicleIdChanged: {
        console.log("LayoutRight: 车辆ID已更新为:", currentVehicleId)
    }
    
    // 根据车辆ID生成标题的函数
    function getVehicleTitle(vehicleId) {
        console.log("getVehicleTitle called with:", vehicleId)
        if (vehicleId === "") {
            return "系统状态监控"
        }
        return "车辆ID:" + vehicleId
    }

    
    // 顶部区域 - 使用FluAppBar
    FluAppBar {
        id: topArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        title: rightrect.getVehicleTitle(rightrect.currentVehicleId)  // 使用本地车辆ID属性
        titleFontSize: 25  // 设置标题字体大小
        showDark: true
        showClose: true
        showMinimize: true
        showMaximize: true
        showStayTop: true
        titleVisible: true  // 显示标题
        textColor: Theme.primaryTextColor
        iconSize: 35
        // 自定义用户信息区域
        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.layoutStandardbuttons.left
            anchors.rightMargin: 20
            spacing: 15
            
            // 用户信息组件
            UserConfigsetting {
                id: otherRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
            }
        }
    }
    
    // 分割线
    Rectangle {
        id: separatorLine
        anchors.top: topArea.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        height: 1
        color: Theme.progressColor
    }
        // 主页组件
    HomePage {
        id: homePageComponent
        // 其布局根据页面大小变化
        anchors.top: separatorLine.bottom
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
    
    // 主布局容器
    GridLayout {
        id: mainGrid
        anchors.top: separatorLine.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 30
        columns: 2
        rows: 2
        columnSpacing: 30
        rowSpacing: 30
        visible: rootWindow.showMapPage

        
        // 左上角 - 视频显示区域
        Rectangle {
            id: dashboardArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 400
            Layout.minimumHeight: 250
            color: Theme.labledBackColor
            // color:"#00ffff"
            radius: 10
            border.color: "#00ffff"
            border.width: 5
            Canvas{
                anchors.fill: parent
                property int cornerLength: 40
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    
                    // 设置覆盖颜色为背景色
                    ctx.fillStyle = "#1a1a1a"  // 与主背景色一致
                    
                    // 覆盖上边（除了两个角）
                    ctx.fillRect(cornerLength, 0, width - 2 * cornerLength, parent.border.width)
                    
                    // 覆盖下边（除了两个角）
                    ctx.fillRect(cornerLength, height - parent.border.width, width - 2 * cornerLength, parent.border.width)
                    
                    // 覆盖左边（除了两个角）
                    ctx.fillRect(0, cornerLength, parent.border.width, height - 2 * cornerLength)
                    
                    // 覆盖右边（除了两个角）
                    ctx.fillRect(width - parent.border.width, cornerLength, parent.border.width, height - 2 * cornerLength)
                }
            }
            
            Column {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5
                
                // 车辆摄像头视频区域
                Rectangle {
                    id: vehicleCameraBackground
                    width: parent.width
                    height: parent.height - 30-5
                    color: "#1a1a1a"
                    border.color: "#333"
                    border.width: 2
                    radius: 8



                    // 自定义属性
                    property bool isRecording: false
                    property string videoSource: ""

                    // 渐变背景
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#1a1a1a" }
                        GradientStop { position: 1.0; color: "#0d0d0d" }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 20

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "📹"
                            color: "#666666"
                            font.pixelSize: 48
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "车辆摄像头视频"
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "等待视频流..."
                            color: "#888888"
                            font.pixelSize: 12
                        }
                    }

                    // 简化的控制按钮
                    Row {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 20
                        spacing: 15

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: vehicleCameraBackground.isRecording ? "#ff4444" : "#4CAF50"
                            border.color: "white"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: vehicleCameraBackground.isRecording ? "⏹" : "⏺"
                                color: "white"
                                font.pixelSize: 16
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    vehicleCameraBackground.isRecording = !vehicleCameraBackground.isRecording;
                                    console.log("录制状态切换:", vehicleCameraBackground.isRecording);
                                }
                            }
                        }

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#2196F3"
                            border.color: "white"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "📷"
                                color: "white"
                                font.pixelSize: 14
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("拍照");
                                }
                            }
                        }
                    }
                }
                
                // 底部标题栏
                Rectangle {
                    width: parent.width
                    height: 30
                    color: Theme.labledBackColor
                    radius: 5
                    
                    Text {
                        
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        text: "实时视频"
                        color: Theme.primaryTextColor
                        font.pixelSize: 15
                        font.bold: true
                    }
                }
            }
        }
        
        // 右上角矩形 - 地图显示区域
        Rectangle {
            id: topRightRect
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 250
            color: Theme.labledBackColor
            radius: 10
            border.color: Theme.checkedIconColor
            border.width: 0
            opacity: 0.95  // 设置透明度
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                // 标题区域
                Text {
                    id: mapTitle
                    text: "地图数据"
                    font.family: "Arial"
                    font.pixelSize: 25
                    font.bold: true
                    color: Theme.primaryTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                // 分割线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.progressColor
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                }
                
                // 地图容器
                Rectangle {
                    id: mapContainer
                    width: parent.width 
                    height: parent.height - 50  // 减去标题和分割线的高度
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.color: "#333"
                    border.width: 2
                    radius: 8
                    color: "transparent"
                    
                    Map {
                        id: item_map
                        anchors.fill: parent
                        anchors.margins: 2
                        opacity: 0.99

                        plugin: Plugin{
                            locales: "zh-CN"
                            name: "osm"
                            PluginParameter {
                                name: "osm.mapping.providersrepository.address"
                                value: "http://maps-redirect.qt.io/osm/5.8/"
                            }
                            // 切换暗黑地图瓦片
                            PluginParameter {
                                name: "osm.mapping.custom.host"
                                value: "https://a.tile.openstreetmap.org/" // 修改这里切换瓦片源
                            }
                            
                            PluginParameter {
                                name: "osm.mapping.custom.mapcopyright"
                                value: "© OpenStreetMap contributors"
                            }
                            PluginParameter {
                                name: "osm.mapping.highdpi_tiles"
                                value: "true"  // 启用高清瓦片
                            }
                            PluginParameter {
                                name: "osm.mapping.max_zoom"
                                value: "20"    // 明确设置最大缩放级别
                            }   
                        }

                        center: QtPositioning.coordinate(centerLat, centerLon)
                        zoomLevel: mapZoomReset
                        maximumZoomLevel: 20
                        minimumZoomLevel: 3
                        color: "green"
                        activeMapType: supportedMapTypes.length > 0 ? supportedMapTypes[supportedMapTypes.length - 1] : null

                        property real mapZoomReset : 15
                        property var mouseCoord : center
                        property real centerLat : 30.23388667
                        property real centerLon : 120.04296818

                        property var mapMarkers: []
                        property var pathCoordinates: []
                        property var connectionLines: []
                        property int maxlineNum: 10

                        Component {
                            id: markerComponent
                            MapQuickItem {
                                property real lat: 0
                                property real lng: 0
                                coordinate: QtPositioning.coordinate(lat, lng)
                                anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                                sourceItem: Rectangle {
                                    width: 30
                                    height: width
                                    radius: width/2
                                    color: "yellow"
                                    border.color: "orange"
                                    border.width: 2
                                    opacity: 0.8
                                }
                            }
                        }

                        Component {
                            id: lineComponent
                            MapPolyline {
                                property real lat1: 0
                                property real lng1: 0
                                property real lat2: 0
                                property real lng2: 0
                                line.width: 3
                                line.color: "red"
                                opacity: 0.7
                                path: [
                                    QtPositioning.coordinate(lat1, lng1),
                                    QtPositioning.coordinate(lat2, lng2)
                                ]
                            }
                        }

                        MapQuickItem {
                            coordinate: QtPositioning.coordinate(30.23388667, 120.04296818)
                            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                            sourceItem: Rectangle {
                                width: 25
                                height: 25
                                radius: 12
                                color: "blue"
                                border.color: "darkblue"
                                border.width: 2
                                opacity: 0.9

                                Text {
                                    anchors.centerIn: parent
                                    text: "1"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MapQuickItem {
                            coordinate: QtPositioning.coordinate(30.25000000, 120.06000000)
                            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                            sourceItem: Rectangle {
                                width: 25
                                height: 25
                                radius: 12
                                color: "green"
                                border.color: "darkgreen"
                                border.width: 2
                                opacity: 0.9

                                Text {
                                    anchors.centerIn: parent
                                    text: "2"
                                    color: "white"
                                    font.bold: true
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MapPolyline {
                            line.color: "red"
                            opacity: 0.7
                            path: [
                                QtPositioning.coordinate(30.23388667, 120.04296818),
                                QtPositioning.coordinate(30.25000000, 120.06000000)
                            ]
                        }

                        Rectangle{
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: 5
                            height: infoColumn.height + 20
                            width: infoColumn.width + 20
                            radius: 5
                            color: "black"
                            opacity: 0.85
                            border.color: "#4CAF50"
                            border.width: 1

                            Column {
                                id: infoColumn
                                x: 10
                                y: 10
                                spacing: 5

                                Text{
                                    color: "white"
                                    font.pixelSize: 12
                                    font.bold: true
                                    text: "缩放: " + Math.floor(item_map.zoomLevel)
                                }

                                Text{
                                    color: "white"
                                    font.pixelSize: 10
                                    text: "纬度: " + item_map.mouseCoord.latitude.toFixed(6) + "°"
                                }

                                Text{
                                    color: "white"
                                    font.pixelSize: 10
                                    text: "经度: " + item_map.mouseCoord.longitude.toFixed(6) + "°"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            property bool isDragging: false
                            property point lastPanPoint

                            onPressed: {
                                isDragging = false;
                                lastPanPoint = Qt.point(mouse.x, mouse.y);
                                mouse.accepted = true;
                            }

                            onPositionChanged: {
                                if (pressed) {
                                    var currentPoint = Qt.point(mouse.x, mouse.y);
                                    var deltaX = currentPoint.x - lastPanPoint.x;
                                    var deltaY = currentPoint.y - lastPanPoint.y;

                                    if (Math.abs(deltaX) > 5 || Math.abs(deltaY) > 5) {
                                        isDragging = true;

                                        var startCoord = item_map.toCoordinate(lastPanPoint);
                                        var endCoord = item_map.toCoordinate(currentPoint);

                                        var newLat = item_map.center.latitude + (startCoord.latitude - endCoord.latitude);
                                        var newLon = item_map.center.longitude + (startCoord.longitude - endCoord.longitude);

                                        item_map.center = QtPositioning.coordinate(newLat, newLon);
                                        lastPanPoint = currentPoint;
                                    }
                                }
                            }

                            onClicked: {
                                if (!isDragging) {
                                    var coord = item_map.toCoordinate(Qt.point(mouse.x, mouse.y));
                                    item_map.mouseCoord = coord;
                                }
                                mouse.accepted = true;
                                focus = true;
                            }

                            onWheel: {
                                var delta = wheel.angleDelta.y / 120; // 标准滚轮增量
                                var newZoomLevel = item_map.zoomLevel + delta;
                                
                                // 限制缩放范围
                                if (newZoomLevel >= item_map.minimumZoomLevel && newZoomLevel <= 20) {
                                    item_map.zoomLevel = newZoomLevel;
                                }
                                
                                wheel.accepted = true;
                            }
                        }
                    }
                }
            }
        }
        
        // 左下角矩形 - 仪表盘区域
        Rectangle {
            id: bottomLeftRect
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 150
            color: Theme.labledBackColor
            radius: 10
            border.color: Theme.checkedIconColor
            border.width: 0
            opacity: 0.95  // 设置透明度
            
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                // 标题区域
                Text {
                    id:dashboardtitle
                    text: "仪表盘显示"
                    font.family: "Arial"
                    font.pixelSize: 25
                    font.bold: true
                    color: Theme.primaryTextColor
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
                
                // 分割线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.progressColor
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                }
                
                // 内部仪表盘组件
                CombinedDashboardLayout {
                    width: parent.width
                    height: parent.height - 40  // 减去标题和分割线的高度
                    color: "transparent"  // 设置为透明，显示父Rectangle的背景
                }
            }
        }
        
        // 右下角矩形
        Rectangle {
            id: bottomRightRect
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 150
            color: Theme.labledBackColor
            radius: 10
            border.color: Theme.checkedIconColor
            border.width: 0
            
            // 数据列表
            DataListView {
                anchors.fill: parent
                anchors.margins: 10
                anchors.bottomMargin: 120  // 为底部按钮留出空间
            }
            
            // 底部按钮区域
            Row {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 15
                spacing: 30
                
                // 刷新数据按钮
                Rectangle {
                    width: 200
                    height: 60
                    radius: height / 2  // 胶囊形状
                    color:"white"
                    border.color: Theme.boardColor
                    border.width: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "刷新数据"
                        color: "black"
                        font.pixelSize: 20
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("刷新数据按钮被点击")
                            // 这里可以添加刷新数据的逻辑
                        }
                        onPressed: {
                            parent.color = Qt.darker(Theme.labledBackColor, 1.2)
                        }
                        onReleased: {
                            parent.color = Theme.labledBackColor
                        }
                    }
                }
                
                // 导出数据按钮
                Rectangle {
                    width: 200
                    height: 60
                    radius: height / 2  // 胶囊形状
                    color:"white"
                    border.color: Theme.boardColor
                    border.width: 2
                    
                    Text {
                        anchors.centerIn: parent
                        text: "导出数据"
                        color: "black"
                        font.pixelSize: 20
                        font.bold: true
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("导出数据按钮被点击")
                            // 这里可以添加导出数据的逻辑
                        }
                        onPressed: {
                            parent.color = Qt.darker(Theme.labledBackColor, 1.2)
                        }
                        onReleased: {
                            parent.color = Theme.labledBackColor
                        }
                    }
                }
            }
        }
        }
}
