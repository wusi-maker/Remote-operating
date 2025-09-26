import QtQuick 2.15
import "../Network"

// 共享网络连接单例
pragma Singleton

QtObject {
    id: sharedNetworkConnection
    
    // 全局NetworkConnection实例
    property NetworkConnection networkConnection: NetworkConnection {
        id: globalNetworkConnection
        
        // 连接状态变化信号处理
        onNetworkConnectionChanged: {
            console.log("SharedNetworkConnection: 网络连接状态变化:", isConnected ? "已连接" : "未连接")
        }
        
        // 数据接收信号处理
        onDataReceived: function(data) {
            console.log("SharedNetworkConnection: 接收到数据:", data)
        }
        
        // 状态变化信号处理
        onStatusChanged: function(status) {
            console.log("SharedNetworkConnection: 状态变化:", status)
        }
    }
    
    // 便捷访问属性
    readonly property bool isConnected: networkConnection.isConnected
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