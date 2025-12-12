import QtQuick 2.15
import "../Network"

// 共享网络连接单例
pragma Singleton

QtObject {
    id: sharedNetworkConnection
    
    // 全局原始数据存储
    property var rawJsonData: ({})
    property string lastReceivedData: ""
    property var lastUpdateTime: new Date()
    
    // 数据更新信号 - 供其他组件监听
    signal dataUpdated(var jsonData, string rawData)
    signal vehicleDataReceived(string hunterID, var vehicleData)
    
    // 全局NetworkConnection实例
    property NetworkConnection networkConnection: NetworkConnection {
        id: globalNetworkConnection
        
        // 连接状态变化信号处理
        onNetworkConnectionChanged: {
            console.log("SharedNetworkConnection: 网络连接状态变化:", isConnected ? "已连接" : "未连接")
        }
        
        // 数据接收信号处理
        onDataReceived: function(data) {
            console.log("SharedNetworkConnection: 接收到数据:")
            
            // 更新全局数据
            updateGlobalData(data)
        }
        
        // 状态变化信号处理
        onStatusChanged: function(status) {
            console.log("SharedNetworkConnection: 状态变化:", status)
        }
    }
    
    // 更新全局数据的函数
    function updateGlobalData(rawData) {
        try {
            // 保存原始数据
            lastReceivedData = rawData
            lastUpdateTime = new Date()
            
            // 尝试解析JSON数据
            var parsedData = JSON.parse(rawData)
            rawJsonData = parsedData
            
            console.log("SharedNetworkConnection: 全局数据已更新")
            
            // 发出数据更新信号
            dataUpdated(parsedData, rawData)
            
            // 如果数据包含hunterID，发出车辆特定数据信号
            if (parsedData.hunterID) {
                vehicleDataReceived(parsedData.hunterID, parsedData)
                console.log("SharedNetworkConnection: 车辆数据分发 -", parsedData.hunterID)
            }
            
        } catch (error) {
            console.error("SharedNetworkConnection: 数据解析错误:", error)
        }
    }
    
    // 手动更新数据的函数（用于测试或其他数据源）
    function manualUpdateData(jsonData) {
        var rawData = typeof jsonData === 'string' ? jsonData : JSON.stringify(jsonData)
        updateGlobalData(rawData)
    }
    
    // 获取最新数据
    function getLatestData() {
        return {
            rawJsonData: rawJsonData,
            lastReceivedData: lastReceivedData,
            lastUpdateTime: lastUpdateTime
        }
    }
    
    // 清除数据
    function clearData() {
        rawJsonData = {}
        lastReceivedData = ""
        lastUpdateTime = new Date()
        console.log("SharedNetworkConnection: 全局数据已清除")
    }
    
    // 便捷访问属性
    readonly property bool isConnected: networkConnection.connected
    readonly property string status: networkConnection.status
    
    // 便捷方法
    function connectToServer(host, port) {
        return networkConnection.connectToServer(host, port)
    }
    
    function disconnectFromServer() {
        networkConnection.disconnectFromServer()
    }
    
    function sendJsonData(jsonData) {
        return networkConnection.sendJsonData(jsonData)
    }
    
    function showConnectionDialog() {
        networkConnection.showConnectionDialog()
    }
    
    // 组件完成时的初始化
    Component.onCompleted: {
        console.log("SharedNetworkConnection: 全局网络连接实例已创建")
    }
}