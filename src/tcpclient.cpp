#include "tcpclient.h"
#include "VideoStreamDevice.h"
#include <QJsonDocument>
#include <QJsonObject>

TcpClient::TcpClient(QObject *parent)
    : QObject(parent)
    , m_socket(new QTcpSocket(this))
    , m_connectionStatus("未连接")
{
    // 连接信号和槽
    connect(m_socket, &QTcpSocket::connected, this, &TcpClient::onConnected);
    connect(m_socket, &QTcpSocket::disconnected, this, &TcpClient::onDisconnected);
    connect(m_socket, QOverload<QAbstractSocket::SocketError>::of(&QAbstractSocket::errorOccurred),
            this, &TcpClient::onErrorOccurred);
    connect(m_socket, &QTcpSocket::readyRead, this, &TcpClient::onReadyRead);
}

TcpClient::~TcpClient()
{
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        m_socket->disconnectFromHost();
    }
}

bool TcpClient::isConnected() const
{
    return m_socket->state() == QAbstractSocket::ConnectedState;
}

QString TcpClient::getLastData() const
{
    return m_lastData;
}

QString TcpClient::getConnectionStatus() const
{
    return m_connectionStatus;
}

void TcpClient::connectToServer(const QString &host, int port)
{
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        qDebug() << "Already connected to server";
        return;
    }

    if (m_socket->state() == QAbstractSocket::ConnectingState) {
        qDebug() << "Already connecting to server";
        return;
    }

    setConnectionStatus("连接中...");
    qDebug() << "Connecting to" << host << ":" << port;
    m_socket->connectToHost(host, port);
}

void TcpClient::disconnectFromServer()
{
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        setConnectionStatus("断开连接中...");
        m_socket->disconnectFromHost();
    }
}

void TcpClient::sendData(const QString &data)
{
    if (m_socket->state() == QAbstractSocket::ConnectedState) {
        QByteArray byteData = data.toUtf8();
        m_socket->write(byteData);
        qDebug() << "Sent data:" << data;
    } else {
        qDebug() << "Cannot send data: not connected";
    }
}

void TcpClient::onConnected()
{
    setConnectionStatus("已连接");
    qDebug() << "Connected to server";
    emit connectedChanged();
    emit connectionSucceeded();
}

void TcpClient::onDisconnected()
{
    setConnectionStatus("未连接");
    qDebug() << "Disconnected from server";
    m_buffer.clear(); // 清空缓冲区
    emit connectedChanged();
    emit disconnected();
}

void TcpClient::onErrorOccurred(QAbstractSocket::SocketError error)
{
    QString errorString = m_socket->errorString();
    setConnectionStatus("连接错误: " + errorString);
    qDebug() << "Socket error:" << error << errorString;
    emit connectionFailed(errorString);
}

void TcpClient::onReadyRead()
{
    QByteArray data = m_socket->readAll();
    m_buffer.append(data);
    
    // qDebug() << "Received" << data.size() << "bytes, buffer size:" << m_buffer.size();
    // 打印接收到的数据的开头部分（Hex），用于调试协议头
    if (data.size() > 0) {
       // qDebug() << "RX Head:" << data.left(8).toHex() << "ASCII:" << data.left(8);
    }
    
    // 处理可能的多个数据包
    processReceivedData(m_buffer);
}

void TcpClient::processReceivedData(const QByteArray &data)
{
    QByteArray buffer = data;
    
    while (buffer.size() >= 8) { // 至少需要 "JSON" 或 "VIDE" (4字节) + 长度 (4字节)
        bool isJson = buffer.startsWith("JSON");
        bool isVideo = buffer.startsWith("VIDE");

        // 检查是否以 "JSON" 或 "VIDE" 开头
        if (!isJson && !isVideo) {
            // 暂时注释掉错误日志，避免刷屏，如果确实是协议问题需要打开
            qDebug() << "Invalid packet header. Head:" << buffer.left(8).toHex(); 
            
            // 尝试找到下一个有效的头
            int jsonIndex = buffer.indexOf("JSON", 1);
            int videoIndex = buffer.indexOf("VIDE", 1);
            
            int nextIndex = -1;
            if (jsonIndex > 0 && videoIndex > 0) nextIndex = qMin(jsonIndex, videoIndex);
            else if (jsonIndex > 0) nextIndex = jsonIndex;
            else if (videoIndex > 0) nextIndex = videoIndex;

            if (nextIndex > 0) {
                buffer = buffer.mid(nextIndex);
                continue;
            } else {
                // 如果缓冲区没有满，且没找到头，可能只是数据错位，但为了安全还是清空
                // 或者我们可以只移除第一个字节继续找（效率低）
                // 这里选择清空，强制对齐
                buffer.clear();
                break;
            }
        }
        
        // 读取数据长度 (大端序)
        if (buffer.size() < 8) {
            // qDebug() << "Incomplete header, waiting for more data. Current size:" << buffer.size();
            break; // 数据不完整，等待更多数据
        }
        
        quint32 dataLength = 0;
        for (int i = 0; i < 4; ++i) {
            dataLength = (dataLength << 8) | static_cast<quint8>(buffer[4 + i]);
        }
        
        // qDebug() << "Expected data length:" << dataLength;
        
        // 检查数据长度是否合理（防止异常大的数据包）
        // 视频数据可能较大，增加限制到 10MB
        if (dataLength > 10 * 1024 * 1024) { 
            qDebug() << "Data length too large:" << dataLength << ", clearing buffer";
            buffer.clear();
            break;
        }
        
        // 检查是否有完整的数据包
        if (buffer.size() < 8 + static_cast<int>(dataLength)) {
            // qDebug() << "Incomplete packet, waiting for more data. Have:" << buffer.size() << "Need:" << (8 + dataLength);
            break; // 数据不完整，等待更多数据
        }
        
        // 提取数据内容
        QByteArray payload = buffer.mid(8, dataLength);
        
        if (isJson) {
            QString jsonString = QString::fromUtf8(payload);
            
            qDebug() << "Successfully received complete JSON packet, length:" << dataLength;
            // qDebug() << "JSON data:" << jsonString;
            
            // 更新最后接收的数据
            m_lastData = jsonString;
            emit dataReceived(jsonString);
            
            // 尝试解析JSON
            QJsonParseError parseError;
            QJsonDocument doc = QJsonDocument::fromJson(payload, &parseError);
            if (parseError.error != QJsonParseError::NoError) {
                qDebug() << "JSON parse error:" << parseError.errorString();
            } else {
                // QJsonObject jsonObj = doc.object();
                // qDebug() << "Successfully parsed JSON object";
            }
        } else if (isVideo) {
            // qDebug() << "Successfully received VIDEO packet, length:" << dataLength;
            
            // 直接写入 VideoStreamDevice，绕过 QML 信号传输大数据的开销
            if (VideoStreamDevice::instance()) {
                VideoStreamDevice::instance()->appendData(payload);
            }
            
            // 发送信号通知 UI (仅作为触发器，不再传递实际数据以减少开销)
            // 传递空字节数组，避免 QML 引擎进行昂贵的数据拷贝
            emit videoDataReceived(QByteArray()); 
        }
        
        // 移除已处理的数据包
        buffer = buffer.mid(8 + dataLength);
    }
    
    // 更新缓冲区为剩余数据
    m_buffer = buffer;
    
    // 如果缓冲区过大且没有有效数据，清空它
    // 增加缓冲区限制以适应可能的视频数据碎片
    if (m_buffer.size() > 1024000 && !m_buffer.startsWith("JSON") && !m_buffer.startsWith("VIDE")) { // 1MB限制
        qDebug() << "Clearing oversized invalid buffer, size:" << m_buffer.size();
        m_buffer.clear();
    }
}

void TcpClient::setConnectionStatus(const QString &status)
{
    if (m_connectionStatus != status) {
        m_connectionStatus = status;
        emit statusChanged();
    }
}