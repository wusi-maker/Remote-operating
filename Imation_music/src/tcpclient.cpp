#include "tcpclient.h"

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
    
    qDebug() << "Received" << data.size() << "bytes, buffer size:" << m_buffer.size();
    
    // 处理可能的多个数据包
    processReceivedData(m_buffer);
}

void TcpClient::processReceivedData(const QByteArray &data)
{
    QByteArray buffer = data;
    
    while (buffer.size() >= 8) { // 至少需要 "JSON" (4字节) + 长度 (4字节)
        // 检查是否以 "JSON" 开头
        if (!buffer.startsWith("JSON")) {
            qDebug() << "Invalid packet header, expected 'JSON'. Buffer content:" << buffer.left(20).toHex();
            // 尝试找到下一个有效的JSON头
            int jsonIndex = buffer.indexOf("JSON", 1);
            if (jsonIndex > 0) {
                buffer = buffer.mid(jsonIndex);
                continue;
            } else {
                buffer.clear();
                break;
            }
        }
        
        // 读取数据长度 (大端序)
        if (buffer.size() < 8) {
            qDebug() << "Incomplete header, waiting for more data. Current size:" << buffer.size();
            break; // 数据不完整，等待更多数据
        }
        
        quint32 dataLength = 0;
        for (int i = 0; i < 4; ++i) {
            dataLength = (dataLength << 8) | static_cast<quint8>(buffer[4 + i]);
        }
        
        qDebug() << "Expected data length:" << dataLength;
        
        // 检查数据长度是否合理（防止异常大的数据包）
        if (dataLength > 1024 * 1024) { // 1MB限制
            qDebug() << "Data length too large:" << dataLength << ", clearing buffer";
            buffer.clear();
            break;
        }
        
        // 检查是否有完整的数据包
        if (buffer.size() < 8 + static_cast<int>(dataLength)) {
            qDebug() << "Incomplete packet, waiting for more data. Have:" << buffer.size() << "Need:" << (8 + dataLength);
            break; // 数据不完整，等待更多数据
        }
        
        // 提取JSON数据
        QByteArray jsonData = buffer.mid(8, dataLength);
        QString jsonString = QString::fromUtf8(jsonData);
        
        qDebug() << "Successfully received complete JSON packet, length:" << dataLength;
        qDebug() << "JSON data:" << jsonString;
        
        // 更新最后接收的数据
        m_lastData = jsonString;
        emit dataReceived(jsonString);
        
        // 尝试解析JSON
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(jsonData, &parseError);
        if (parseError.error != QJsonParseError::NoError) {
            qDebug() << "JSON parse error:" << parseError.errorString();
        } else {
            QJsonObject jsonObj = doc.object();
            qDebug() << "Successfully parsed JSON object";
        }
        
        // 移除已处理的数据包
        buffer = buffer.mid(8 + dataLength);
        qDebug() << "Remaining buffer size:" << buffer.size();
    }
    
    // 更新缓冲区
    m_buffer = buffer;
    
    // 如果缓冲区过大且没有有效数据，清空它
    if (m_buffer.size() > 10240 && !m_buffer.startsWith("JSON")) { // 10KB限制
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