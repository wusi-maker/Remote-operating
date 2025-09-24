// NetworkConnection.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import TcpClient 1.0

Item {
    id: networkConnection
    
    // 对外暴露的属性
    property alias connected: tcpClient.connected
    property string latestData: ""
    property string debugInfo: "等待连接..."
    
    // 连接状态属性（可写）
    property string connectionStatus: "等待连接..."
    
    // 弹窗相关属性
    property string dialogTitle: ""
    property string dialogMessage: ""
    property string dialogType: ""  // "success" 或 "error"
    property bool showDialog: false
    
    // 信号定义
    signal dataReceived(string data)
    signal networkConnectionChanged(bool connected)
    signal statusChanged(string status)
    
    // TCP客户端
    TcpClient {
        id: tcpClient
        
        onConnectionSucceeded: {
            console.log("TCP连接成功")
            showConnectionDialog("success", "连接成功", "已成功连接到服务器 47.111.21.77:7777")
            debugInfo = "连接成功，等待数据..."
            networkConnectionChanged(true)
            // 通过信号传递状态变化
            statusChanged("已连接")
        }
        
        onDisconnected: {
            console.log("TCP连接断开")
            debugInfo = "连接已断开"
            networkConnectionChanged(false)
            // 通过信号传递状态变化
            statusChanged("已断开")
        }
        
        onConnectionFailed: {
            console.log("TCP连接错误:", error)
            showConnectionDialog("error", "连接失败", "连接服务器失败: " + error)
            debugInfo = "连接失败: " + error
            networkConnectionChanged(false)
            // 通过信号传递状态变化
            statusChanged("连接失败")
        }
        
        onDataReceived: {
            console.log("接收到数据:", data)
            
            // 更新最新数据
            latestData = data
            
            // 发出数据接收信号
            networkConnection.dataReceived(data)
        }
    }
    
    // 显示连接对话框的函数
    function showConnectionDialog(type, title, message) {
        dialogType = type
        dialogTitle = title
        dialogMessage = message
        showDialog = true
    }
    
    // 对外暴露的方法
    function connectToServer() {
        tcpClient.connectToServer()
    }
    
    function disconnectFromServer() {
        tcpClient.disconnectFromServer()
    }
}