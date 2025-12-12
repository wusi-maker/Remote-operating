import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15
import QtMultimedia
// import VideoStream 1.0
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
    
    // 车辆数据模型访问属性 - 通过rootWindow获取leftPage的数据模型
    property var vehicleDataModels: rootWindow && rootWindow.leftPage ? 
        rootWindow.leftPage.getAllVehicleDataModels() : ({})
    
    // 监听vehicleDataModels变化（仅日志与可选打印，依赖属性绑定自动刷新）
    onVehicleDataModelsChanged: {
        console.log("LayoutRight: vehicleDataModels发生变化:", vehicleDataModels)
        console.log("LayoutRight: vehicleDataModels对象键:", Object.keys(vehicleDataModels))
        printCurrentVehicleData()
    }

    // 存储当前的视频数据 (已移除，不再存储大数据对象)
    // property var currentVideoData: null

    // 测试数据模型
    VehicleDataModel {
        id: testVehicleDataModel
        testFlag: true
        hunterID: "TEST_VEHICLE"
        dataType: "hunterStatus"
        timestamp: Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss.zzz")
        
        Component.onCompleted: {
            gps.latitude = 39.9042
            gps.longitude = 116.4074
            vehicle.linear_velocity = 0.0
        }
    }
    
    // 获取当前选中车辆的数据模型
    property var currentVehicleDataModel: {
        if (currentVehicleId === testVehicleDataModel.hunterID) {
            return testVehicleDataModel
        }
        return vehicleDataModels[currentVehicleId] || null
    }
    
    
    // 打印当前车辆数据的函数
    function printCurrentVehicleData() {

        if (currentVehicleDataModel ) {
            console.log("=== 当前车辆", currentVehicleId, "数据模型详细信息 ===")
            console.log("基本信息:")
            console.log("  dataType:", currentVehicleDataModel.dataType)
            console.log("  hunterID:", currentVehicleDataModel.hunterID)
            console.log("  timestamp:", currentVehicleDataModel.timestamp)
            
            console.log("IMU数据:")
            console.log("  orientation: x=" + currentVehicleDataModel.imu.orientation.x + 
                       ", y=" + currentVehicleDataModel.imu.orientation.y + 
                       ", z=" + currentVehicleDataModel.imu.orientation.z + 
                       ", w=" + currentVehicleDataModel.imu.orientation.w)
            console.log("  angular_velocity: x=" + currentVehicleDataModel.imu.angular_velocity.x + 
                       ", y=" + currentVehicleDataModel.imu.angular_velocity.y + 
                       ", z=" + currentVehicleDataModel.imu.angular_velocity.z)
            console.log("  linear_acceleration: x=" + currentVehicleDataModel.imu.linear_acceleration.x + 
                       ", y=" + currentVehicleDataModel.imu.linear_acceleration.y + 
                       ", z=" + currentVehicleDataModel.imu.linear_acceleration.z)
            
            console.log("车辆数据:")
            console.log("  motor_rpm_avg:", currentVehicleDataModel.vehicle.motor_rpm_avg)
            console.log("  steering_angle:", currentVehicleDataModel.vehicle.steering_angle)
            console.log("  linear_velocity:", currentVehicleDataModel.vehicle.linear_velocity)
            console.log("  battery_level:", currentVehicleDataModel.vehicle.battery_level)
            
            console.log("里程计数据:")
            console.log("  angular_z:", currentVehicleDataModel.odometry.angular_z)
            console.log("  position: x=" + currentVehicleDataModel.odometry.position.x + 
                       ", y=" + currentVehicleDataModel.odometry.position.y)
            
            console.log("GPS数据:")
            console.log("  latitude:", currentVehicleDataModel.gps.latitude)
            console.log("  longitude:", currentVehicleDataModel.gps.longitude)
            console.log("  altitude:", currentVehicleDataModel.gps.altitude)
            console.log("  gps_local_x:", currentVehicleDataModel.gps.local_pose.x)
            console.log("  gps_local_y:", currentVehicleDataModel.gps.local_pose.y)
            console.log("  gps_local_z:", currentVehicleDataModel.gps.local_pose.z)

            console.log("=== 车辆", currentVehicleId, "数据打印完成 ===")
        } else {
            console.log("当前车辆", currentVehicleId, "数据无效或不存在")
        }
    }

    // 处理传入的GPS数据并更新轨迹
    function processIncomingData() {
        if (!currentVehicleDataModel) return;
        
        var lat = currentVehicleDataModel.gps.latitude;
        var lon = currentVehicleDataModel.gps.longitude;
        
        // 有效性判断：不为零且整数部分满足条件
        if (lat !== 0 && Math.floor(lat) === 30 && Math.floor(lon) === 120) {
             currentVehicleDataModel.addClickedPoint(lat, lon);
        }
    }

    Connections {
        target: currentVehicleDataModel ? currentVehicleDataModel.gps : null
        function onLatitudeChanged() { processIncomingData() }
        function onLongitudeChanged() { processIncomingData() }
    }
    
    // 获取指定车辆的数据模型
    function getVehicleDataModel(vehicleId) {
        if (rootWindow && rootWindow.leftPage) {
            return rootWindow.leftPage.getVehicleDataModel(vehicleId)
        }
        return null
    }
    
    // 获取当前车辆的详细数据列表（用于DataListView）
    function getCurrentVehicleDetailData() {
        if (currentVehicleDataModel) {
            return [
                {"name": "orientation.x", "value": currentVehicleDataModel.imu.orientation.x.toFixed(12)},
                {"name": "orientation.y", "value": currentVehicleDataModel.imu.orientation.y.toFixed(12)},
                {"name": "orientation.z", "value": currentVehicleDataModel.imu.orientation.z.toFixed(12)},
                {"name": "orientation.w", "value": currentVehicleDataModel.imu.orientation.w.toFixed(12)},
                {"name": "angular_velocity.x", "value": currentVehicleDataModel.imu.angular_velocity.x.toFixed(12)},
                {"name": "angular_velocity.y", "value": currentVehicleDataModel.imu.angular_velocity.y.toFixed(12)},
                {"name": "angular_velocity.z", "value": currentVehicleDataModel.imu.angular_velocity.z.toFixed(12)},
                {"name": "linear_acceleration.x", "value": currentVehicleDataModel.imu.linear_acceleration.x.toFixed(12)},
                {"name": "linear_acceleration.y", "value": currentVehicleDataModel.imu.linear_acceleration.y.toFixed(12)},
                {"name": "linear_acceleration.z", "value": currentVehicleDataModel.imu.linear_acceleration.z.toFixed(12)},
                {"name": "motor_rpm_avg", "value": (currentVehicleDataModel.vehicle.motor_rpm_avg !== undefined ? currentVehicleDataModel.vehicle.motor_rpm_avg.toString() : "N/A")},
                {"name": "steering_angle", "value": (currentVehicleDataModel.vehicle.steering_angle !== undefined ? currentVehicleDataModel.vehicle.steering_angle.toString() : "N/A")},
                {"name": "linear_velocity", "value": (currentVehicleDataModel.vehicle.linear_velocity !== undefined ? currentVehicleDataModel.vehicle.linear_velocity.toString() : "N/A")},
                {"name": "battery_level", "value": (currentVehicleDataModel.vehicle.battery_level !== undefined ? currentVehicleDataModel.vehicle.battery_level.toString() : "N/A")},
                {"name": "odometry.angular_z", "value": (currentVehicleDataModel.odometry.angular_z !== undefined ? currentVehicleDataModel.odometry.angular_z.toString() : "N/A")},
                {"name": "odometry.position.x", "value": (currentVehicleDataModel.odometry.position.x !== undefined ? currentVehicleDataModel.odometry.position.x.toString() : "N/A")},
                {"name": "odometry.position.y", "value": (currentVehicleDataModel.odometry.position.y !== undefined ? currentVehicleDataModel.odometry.position.y.toString() : "N/A")},
                {"name": "gps.latitude", "value": (currentVehicleDataModel.gps.latitude !== undefined ? currentVehicleDataModel.gps.latitude.toString() : "N/A")},
                {"name": "gps.longitude", "value": (currentVehicleDataModel.gps.longitude !== undefined ? currentVehicleDataModel.gps.longitude.toString() : "N/A")}
            ]
        }
        // 返回默认的空数据
        return [
            {"name": "orientation.x", "value": "0.0"},
            {"name": "orientation.y", "value": "0.0"},
            {"name": "orientation.z", "value": "0.0"},
            {"name": "orientation.w", "value": "0.0"},
            {"name": "angular_velocity.x", "value": "0.0"},
            {"name": "angular_velocity.y", "value": "0.0"},
            {"name": "angular_velocity.z", "value": "0.0"},
            {"name": "linear_acceleration.x", "value": "0.0"},
            {"name": "linear_acceleration.y", "value": "0.0"},
            {"name": "linear_acceleration.z", "value": "0.0"},
            {"name": "motor_rpm_avg", "value": "0"},
            {"name": "steering_angle", "value": "0"},
            {"name": "linear_velocity", "value": "0"},
            {"name": "battery_level", "value": "0"},
            {"name": "odometry.angular_z", "value": "0"},
            {"name": "odometry.position.x", "value": "0"},
            {"name": "odometry.position.y", "value": "0"},
            {"name": "gps.latitude", "value": "0"},
            {"name": "gps.longitude", "value": "0"}
        ]
    }
    
    // 根据车辆ID生成标题的函数
    function getVehicleTitle(vehicleId) {
        console.log("getVehicleTitle called with:", vehicleId)
        if (vehicleId === "") {
            return "系统状态监控"
        }
        
        // 如果有数据模型，显示更详细的信息
        var dataModel = getVehicleDataModel(vehicleId)
        if (dataModel ) {
            return "车辆ID:" + vehicleId 
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
                Local_AreaVideo {
                    id: localVideo
                    width: parent.width
                    height: parent.height - 35 - 40 // 预留40px给控制栏
                    shouldShow: rightrect.currentVehicleId === "Car1"
                }
                
                // 视频控制栏
                Rectangle {
                    width: parent.width
                    height: 35
                    color: "transparent"
                    
                    Row {
                        anchors.centerIn: parent
                        spacing: 20
                        
                        // 播放/暂停按钮
                        FluIconButton {
                            iconSource: localVideo.isPlaying ? FluentIcons.Pause : FluentIcons.Play
                            text: localVideo.isPlaying ? "暂停" : "播放"
                            radius: 15
                            width: 30
                            height: 30
                            iconSize: 15
                            onClicked: {
                                if (localVideo.isPlaying) {
                                    localVideo.pauseStream()
                                } else {
                                    localVideo.playStream()
                                }
                            }
                        }
                        
                        // 录制按钮
                        FluIconButton {
                            iconSource: FluentIcons.Video
                            text: "录制"
                            // 修复 Theme.iconColor 未定义的错误，改为使用 unCheckedIconColor
                            color: localVideo.isRecording ? "#ff4d4f" : Theme.unCheckedIconColor
                            radius: 15
                            width: 30
                            height: 30
                            iconSize: 15
                            onClicked: {
                                localVideo.toggleRecording()
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
                            line.width: 2
                            line.color: "#FF5722"
                            opacity: 0.7
                            path: {
                                var coords = []
                                if (currentVehicleDataModel && currentVehicleDataModel.clickedPoints) {
                                    for (var i = 0; i < currentVehicleDataModel.clickedPoints.length; i++) {
                                        var p = currentVehicleDataModel.clickedPoints[i];
                                        coords.push(QtPositioning.coordinate(p.latitude, p.longitude));
                                    }
                                }
                                return coords;
                            }
                        }

                        // 仅显示最新的点击点（其他点通过MapPolyline连接）
                        MapQuickItem {
                            property var points: currentVehicleDataModel ? currentVehicleDataModel.clickedPoints : []
                            property var lastPoint: points.length > 0 ? points[points.length - 1] : null

                            visible: lastPoint !== null
                            coordinate: lastPoint ? QtPositioning.coordinate(lastPoint.latitude, lastPoint.longitude) : QtPositioning.coordinate(0, 0)
                            anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)

                            sourceItem: Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: "#FF5722" // 鲜艳的橙色
                                border.color: "white"
                                border.width: 2

                                Text {
                                    anchors.centerIn: parent
                                    text: currentVehicleDataModel && currentVehicleDataModel.clickedPoints ? currentVehicleDataModel.clickedPoints.length.toString() : ""
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                        }

                        // 数据显示窗口
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

                            onPressed: (mouse)=> {
                                isDragging = false;
                                lastPanPoint = Qt.point(mouse.x, mouse.y);
                                mouse.accepted = true;
                            }

                            onPositionChanged: (mouse)=> {
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

                            onClicked: (mouse)=> {
                                if (!isDragging) {
                                    var coord = item_map.toCoordinate(Qt.point(mouse.x, mouse.y));
                                    item_map.mouseCoord = coord;
                                    
                                    // 添加点到当前车辆的数据模型中（仅针对测试数据模型）
                                    if (currentVehicleDataModel && currentVehicleDataModel.testFlag) {
                                        currentVehicleDataModel.addClickedPoint(coord.latitude, coord.longitude);
                                        console.log("已添加点击点(测试):", coord.latitude, coord.longitude);
                                    } else {
                                        console.log("当前非测试模式或模型不存在，忽略点击添加点操作");
                                    }
                                }
                                mouse.accepted = true;
                                focus = true;
                            }

                            onWheel: (wheel)=> {
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
                    vehicleDataModel: rightrect.currentVehicleDataModel
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
                id: dataListView
                anchors.fill: parent
                anchors.margins: 10
                anchors.bottomMargin: 120  // 为底部按钮留出空间
                dataModel: rightrect.getCurrentVehicleDetailData()
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
                            // 依赖属性绑定自动刷新，无需手动赋值
                            console.log("数据绑定已生效，当前车辆:", rightrect.currentVehicleId)
                            // 打印当前车辆的详细数据
                            rightrect.printCurrentVehicleData()
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

















