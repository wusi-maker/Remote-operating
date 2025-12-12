import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import QtLocation
import QtPositioning

Rectangle {
    id: mapCameraModule
    color: "#1a1a1a"
    border.color: "#333"
    border.width: 2
    radius: 8
    
    // 根窗口引用
    property var rootWindow: null
    
    // 录制状态
    property bool isRecording: false
    // 使用地图控件
    // 主布局：地图和摄像头并列显示
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // 车辆摄像头视频背景控件或曲线图显示区域
        Rectangle {
            id: vehicleCameraBackground
            width: parent.width * 0.5
            height: parent.height
            color: "#1a1a1a"
            border.color: "#333"
            border.width: 2
            radius: 8
            visible: !rootWindow || !rootWindow.showCurvesPage

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
                    color: isRecording ? "#ff4444" : "#4CAF50"
                    border.color: "white"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: isRecording ? "⏹" : "⏺"
                        color: "white"
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            isRecording = !isRecording;
                            console.log("录制状态切换:", isRecording);
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

        // 曲线图显示区域
        Rectangle {
            id: curvesDisplayArea
            width: parent.width * 0.5
            height: parent.height
            color: "#1a1a1a"
            border.color: "#333"
            border.width: 0
            radius: 8
            visible: rootWindow && rootWindow.showCurvesPage

            // 四个曲线图的网格布局
            Grid {
                anchors.fill: parent
                anchors.margins: 10
                rows: 2
                columns: 2
                spacing: 10

                // 曲线图1 - 速度
                CurveComponent {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    chartTitle: "车辆速度"
                    xAxisLabel: "时间 (s)"
                    yAxisLabel: "速度 (km/h)"
                    curveColor: "#3498db"
                    showSineWave: false
                    yMin: 0
                    yMax: 120
                }

                // 曲线图2 - 电池电量
                CurveComponent {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    chartTitle: "电池电量"
                    xAxisLabel: "时间 (s)"
                    yAxisLabel: "电量 (%)"
                    curveColor: "#2ecc71"
                    showSineWave: false
                    yMin: 0
                    yMax: 100
                }

                // 曲线图3 - 温度
                CurveComponent {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    chartTitle: "系统温度"
                    xAxisLabel: "时间 (s)"
                    yAxisLabel: "温度 (°C)"
                    curveColor: "#e74c3c"
                    showSineWave: false
                    yMin: 20
                    yMax: 80
                }

                // 曲线图4 - 信号强度
                CurveComponent {
                    width: (parent.width - parent.spacing) / 2
                    height: (parent.height - parent.spacing) / 2
                    chartTitle: "信号强度"
                    xAxisLabel: "时间 (s)"
                    yAxisLabel: "强度 (dBm)"
                    curveColor: "#f39c12"
                    showSineWave: false
                    yMin: -100
                    yMax: -20
                }
            }
        }

        // 地图控件
        Rectangle {
            width: parent.width * 0.5
            height: parent.height
            color: "#2b2b2b"  // 暗色背景
            radius: 8
            anchors.leftMargin: 20
            // 地图内部布局：左侧地图，右侧控制面板
            Row {
             anchors.fill: parent
             anchors.margins: 10
             spacing: 10

            // 左侧地图容器
            Rectangle {
                id: mapContainer
                width: parent.width * 0.7
                height: parent.height
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
                    //参见文档https://doc.qt.io/qt-5.12/qml-qtlocation-plugin.html

                    //首选插件语言环境的有序列表,但是貌似没啥用
                    locales: "zh-CN"

                    //插件的名称
                    //osm需要把openssl的dll放到运行目录
                    //esri默认就能用,mapbox的我这里加载不了,here的不知道咋用
                    //esri默认这个图成都那里不对（放大后）
                    name: "osm" // "mapboxgl", "esri", "osm"...

                    //首选插件名称的有序列表,设置了name值时无效
                    //preferred: ["here","osm"]

                    //选择附加到哪个服务插件时Plugin对象所需的功能集,设置了name值时无效
                    //required: Plugin.AnyMappingFeatures | Plugin.AnyGeocodingFeatures
                }

                //初始中心点-成都
                center: QtPositioning.coordinate(centerLat, centerLon)
                //初始缩放等级
                zoomLevel: mapZoomReset
                //最大缩放等级 - 提高到18级以获得更高精度
                maximumZoomLevel: 20
                //最小缩放等级
                minimumZoomLevel: 3
                //背景色，没有正常加载时显色的图块颜色
                color: "green"

                //自定义属性
                property real mapZoomReset : 15  // 调整初始缩放为较小级别
                property var mouseCoord : center
                //可供在外部初始化
                property real centerLat : 30.23388667
                property real centerLon : 120.04296818

                // 测试用的10个经纬度数据
                property var testCoordinates: [
                    {lat: 30.23388667, lon: 120.04296818}, // 杭州西湖
                    {lat: 30.24500000, lon: 120.05000000}, // 西湖北
                    {lat: 30.22000000, lon: 120.03000000}, // 西湖南
                    {lat: 30.25000000, lon: 120.06000000}, // 西湖东北
                    {lat: 30.21000000, lon: 120.02000000}, // 西湖西南
                    {lat: 30.26000000, lon: 120.07000000}, // 更远的点1
                    {lat: 30.20000000, lon: 120.01000000}, // 更远的点2
                    {lat: 30.27000000, lon: 120.08000000}, // 更远的点3
                    {lat: 30.19000000, lon: 120.00000000}, // 更远的点4
                    {lat: 30.28000000, lon: 120.09000000}  // 更远的点5
                ]


                //标点数组
                property var mapMarkers: []
                //路径数组，用于连接标点
                property var pathCoordinates: []
                //连线数组，用于管理MapPolyline对象
                property var connectionLines: []
                //最大标点数量
                property int maxlineNum: 10

                    // 标点组件
                Component {
                    id: markerComponent
                    MapQuickItem {
                        property real lat: 0
                        property real lng: 0
                        coordinate: QtPositioning.coordinate(lat, lng)
                        anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                        sourceItem: Rectangle {
                            width: 50
                            height: width
                            radius: width/2
                            color: "yellow"
                            border.color: "orange"
                            border.width: 2
                             opacity: 0.8
                         }
                     }
                 }

                // 连线组件
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

                // 组件完成后直接调用addMarker函数进行测试
                Component.onCompleted: {
                    console.log("Map组件加载完成，开始测试addMarker函数");
                    console.log("当前maxlineNum值:", maxlineNum);

                    // 延迟执行以确保地图完全加载
                    Qt.callLater(function() {
                        console.log("开始添加测试标点");
                        // 测试addMarker函数 - 添加两个测试点
                        var testCoord1 = QtPositioning.coordinate(30.23388667, 120.04296818);
                        var testCoord2 = QtPositioning.coordinate(30.24500000, 120.05000000);

                        console.log("准备添加测试点1:", testCoord1.latitude, testCoord1.longitude);
                        addMarker(testCoord1);

                        console.log("准备添加测试点2:", testCoord2.latitude, testCoord2.longitude);
                        addMarker(testCoord2);

                        console.log("测试完成，当前标点数组长度:", mapMarkers.length);
                    });
                }

                // // 使用Rectangle方式创建的对比标点
                MapQuickItem {
                    coordinate: QtPositioning.coordinate(30.23388667, 120.04296818)
                    zoomLevel: 20
                    anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                    sourceItem: Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: "blue"
                        border.color: "darkblue"
                        border.width: 2
                        opacity: 0.9

                        Text {
                            anchors.centerIn: parent
                            text: "R1"
                            color: "white"
                            font.bold: true
                        }
                    }
                }

                MapQuickItem {
                    coordinate: QtPositioning.coordinate(30.25000000, 120.06000000)
                    zoomLevel: 20
                    anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)
                    sourceItem: Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: "green"
                        border.color: "darkgreen"
                        border.width: 2
                        opacity: 0.9

                        Text {
                            anchors.centerIn: parent
                            text: "R2"
                            color: "white"
                            font.bold: true
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




                //信息提示框 - 增强版
                Rectangle{
                    anchors.left: parent.left
                    anchors.top: parent.top
                    height: item_center.height+30
                    width: item_center.width+30
                    radius: 5
                    color: "black"
                    opacity: 0.85
                    border.color: "#4CAF50"
                    border.width: 1

                    Column {
                        x: 15
                        y: 15
                        spacing: 20

                        Text{
                            id: item_center
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            text: "缩放等级: " + Math.floor(item_map.zoomLevel)
                        }

                        Text{
                            color: "white"
                            font.pixelSize: 12
                            text: "纬度: " + item_map.mouseCoord.latitude.toFixed(8) + "°"
                        }

                        Text{
                            color: "white"
                            font.pixelSize: 12
                            text: "经度: " + item_map.mouseCoord.longitude.toFixed(8) + "°"
                        }



                        Text{
                            color: "#90A4AE"
                            font.pixelSize: 10
                            text: "坐标系: WGS84 | 小数位: 8位"
                        }
                    }
                }

                //响应鼠标事件 - 支持拖动和点击
                MouseArea {
                    anchors.fill: parent
                    property bool isDragging: false
                    property point lastPanPoint

                    // 启用拖动手势
                    drag.target: null

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

                            // 如果移动距离超过阈值，认为是拖动操作
                            if (Math.abs(deltaX) > 5 || Math.abs(deltaY) > 5) {
                                isDragging = true;

                                // 计算地图中心点的偏移
                                var startCoord = item_map.toCoordinate(lastPanPoint);
                                var endCoord = item_map.toCoordinate(currentPoint);

                                // 计算新的中心点
                                var newLat = item_map.center.latitude + (startCoord.latitude - endCoord.latitude);
                                var newLon = item_map.center.longitude + (startCoord.longitude - endCoord.longitude);

                                // 更新地图中心
                                item_map.center = QtPositioning.coordinate(newLat, newLon);

                                lastPanPoint = currentPoint;
                            }
                        }
                    }

                    onClicked: {
                        // 更新鼠标坐标显示，但不添加标点
                        if (!isDragging) {
                            var coord = item_map.toCoordinate(Qt.point(mouse.x, mouse.y));
                            item_map.mouseCoord = coord;
                        }

                        //发射信号
                        mouse.accepted = true;
                        //此处设置选定，用于改变其它item的focus状态
                        focus = true;
                    }
                }

                //添加标点函数 - 使用指定样式的标点
                function addMarker(coordinate) {
                    try {
                        console.log("开始添加标点，坐标: " + coordinate.latitude + ", " + coordinate.longitude);
                        console.log("当前标点数量: " + mapMarkers.length + ", 最大数量: " + maxlineNum);

                        // 检查坐标有效性
                        if (!coordinate || isNaN(coordinate.latitude) || isNaN(coordinate.longitude)) {
                            console.error("无效的坐标参数");
                            return false;
                        }

                        // 检查是否超过最大数量，如果超过则移除最早的标点和连线
                        if (mapMarkers.length >= maxlineNum) {
                            console.log("达到最大标点数量，移除最早的标点");
                            // 移除最早的标点
                            var oldestMarker = mapMarkers.shift();
                            if (oldestMarker) {
                                oldestMarker.destroy();
                            }

                            // 移除最早的连线
                            if (connectionLines.length > 0) {
                                var oldestLine = connectionLines.shift();
                                if (oldestLine) {
                                    oldestLine.destroy();
                                }
                            }

                            // 更新路径坐标数组
                            if (pathCoordinates.length > 0) {
                                pathCoordinates.shift();
                            }
                        }

                        // 创建新的标点 - 使用Component
                        console.log("正在创建标点对象...");
                        var markerItem = markerComponent.createObject(item_map, {
                            "lat": coordinate.latitude,
                            "lng": coordinate.longitude
                        });

                        if (markerItem) {
                            console.log("标点对象创建成功");
                            mapMarkers.push(markerItem);
                            pathCoordinates.push(coordinate);
                        } else {
                            console.error("标点对象创建失败");
                            return false;
                        }
                    } catch (error) {
                        console.error("创建标点时发生错误: " + error.toString());
                        return false;
                    }

                    // 如果有前一个标点，创建连线
                    try {
                        if (mapMarkers.length > 1) {
                            console.log("创建连线，当前标点数量: " + mapMarkers.length);
                            var prevCoordinate = pathCoordinates[pathCoordinates.length - 2];
                            console.log("前一个坐标: " + prevCoordinate.latitude + ", " + prevCoordinate.longitude);
                            console.log("当前坐标: " + coordinate.latitude + ", " + coordinate.longitude);

                            var lineItem = lineComponent.createObject(item_map, {
                                "lat1": prevCoordinate.latitude,
                                "lng1": prevCoordinate.longitude,
                                "lat2": coordinate.latitude,
                                "lng2": coordinate.longitude
                            });

                            if (lineItem) {
                                connectionLines.push(lineItem);
                                console.log("连线创建成功");
                            } else {
                                console.error("连线创建失败");
                            }
                        }
                    } catch (lineError) {
                        console.error("创建连线时发生错误: " + lineError.toString());
                    }

                    console.log("标点添加成功，当前标点数量: " + mapMarkers.length + ", 连线数量: " + connectionLines.length);
                    return true;
                }

                //清除所有标点函数
                function clearAllMarkers() {
                    // 清除所有标点
                    for (var i = 0; i < mapMarkers.length; i++) {
                        mapMarkers[i].destroy();
                    }
                    mapMarkers = [];

                    // 清除所有连线
                    for (var j = 0; j < connectionLines.length; j++) {
                        connectionLines[j].destroy();
                    }
                    connectionLines = [];

                    pathCoordinates = [];
                    console.log("已清除所有标点、连线和路径");
                }

                    //清除路径（保留现有功能）
                function clearPath() {
                    pathCoordinates = [];
                    if (pathLine) {
                        pathLine.path = [];
                    }
                    console.log("已清除路径");
                }
                    //路径连线
                    MapPolyline {
                        id: pathLine
                        line.width: 3
                        line.color: "#2196F3"
                        path: item_map.pathCoordinates
                    }
                }
            }
            // 右侧控制面板
            Column {
                width: parent.width * 0.28
                height: parent.height
                spacing: 20

                //经纬度输入控件
                Rectangle {
                    id: coordInputPanel
                    width: parent.width
                    height: 120
                    color: "#3c3c3c"
                    opacity: 0.9
                    radius: 8
                    border.color: "#4CAF50"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "坐标跳转"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#4CAF50"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Row {
                            spacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter

                            TextField {
                                id: latInput
                                width: 80
                                height: 30
                                placeholderText: "纬度"

                                color: "black"
                                validator: DoubleValidator {
                                    bottom: -90.0
                                    top: 90.0
                                    decimals: 8
                                }
                            }

                            TextField {
                                id: lonInput
                                width: 80
                                height: 30
                                placeholderText: "经度"
                                color: "black"
                                validator: DoubleValidator {
                                    bottom: -180.0
                                    top: 180.0
                                    decimals: 8
                                }
                            }
                        }

                        Button {
                            text: "跳转"
                            width: 80
                            height: 30
                            anchors.horizontalCenter: parent.horizontalCenter

                            onClicked: {
                                var lat = parseFloat(latInput.text);
                                var lon = parseFloat(lonInput.text);

                                if (!isNaN(lat) && !isNaN(lon) &&
                                    lat >= -90 && lat <= 90 &&
                                    lon >= -180 && lon <= 180) {
                                    var newCoord = QtPositioning.coordinate(lat, lon);
                                    item_map.center = newCoord;
                                    item_map.mouseCoord = newCoord;
                                    console.log("跳转到坐标: " + lat + ", " + lon);
                                } else {
                                    console.log("无效的坐标输入");
                                }
                            }
                        }
                    }
                }

                //缩放控制按钮
                Rectangle {
                    id: zoomControls
                    width: parent.width
                    height: 120
                    color: "#3c3c3c"
                    opacity: 0.9
                    radius: 8
                    border.color: "#4CAF50"
                    border.width: 2

                    Column {
                        anchors.centerIn: parent
                        spacing: 10

                        // Text {
                        //     text: "缩放控制"
                        //     font.bold: true
                        //     font.pixelSize: 14
                        //     color: "#4CAF50"
                        //     anchors.horizontalCenter: parent.horizontalCenter
                        // }

                        GridLayout {
                            columns: 2
                            rowSpacing: 10
                            columnSpacing: 10
                            anchors.horizontalCenter: parent.horizontalCenter

                            Button {
                                text: "+"
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 35
                                font.pixelSize: 18
                                font.bold: true

                                onClicked: {
                                    if (item_map.zoomLevel < item_map.maximumZoomLevel) {
                                        item_map.zoomLevel += 1;
                                    }
                                }
                            }

                            Button {
                                text: "-"
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 35
                                font.pixelSize: 18
                                font.bold: true

                                onClicked: {
                                    if (item_map.zoomLevel > item_map.minimumZoomLevel) {
                                        item_map.zoomLevel -= 1;
                                    }
                                }
                            }

                            Button {
                                text: "重置"
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 35
                                font.pixelSize: 10

                                onClicked: {
                                    item_map.zoomLevel = item_map.mapZoomReset;
                                    item_map.center = QtPositioning.coordinate(item_map.centerLat, item_map.centerLon);
                                    item_map.mouseCoord = item_map.center;
                                }
                            }

                            Button {
                                text: "清除"
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 35
                                font.pixelSize: 10

                                onClicked: {
                                    item_map.clearAllMarkers();
                                }
                            }
                        }
                    }
                }

                //信息显示面板
                Rectangle {
                    id: infoPanel
                    width: parent.width
                    height: 150
                    color: "#3c3c3c"
                    opacity: 0.95
                    radius: 8
                    border.color: "#4CAF50"
                    border.width: 2

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 6

                        Text {
                            text: "地图信息"
                            font.bold: true
                            font.pixelSize: 14
                            color: "#4CAF50"
                        }

                        Text {
                            text: "缩放等级: " + Math.floor(item_map.zoomLevel)
                            font.pixelSize: 12
                            color: "white"
                        }

                        Text {
                            text: "纬度: " + item_map.mouseCoord.latitude.toFixed(6) + "°"
                            font.pixelSize: 11
                            color: "white"
                        }

                        Text {
                            text: "经度: " + item_map.mouseCoord.longitude.toFixed(6) + "°"
                            font.pixelSize: 11
                            color: "white"
                        }

                        Text {
                            text: "坐标系: WGS84"
                            font.pixelSize: 10
                            color: "#90A4AE"
                        }

                        Text {
                            text: "标点: " + item_map.mapMarkers.length + " | 连线: " + item_map.connectionLines.length
                            font.pixelSize: 10
                            color: "#4CAF50"
                        }
                    }
                }
            }

        }
        }


    }
}
