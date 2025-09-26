#ifndef TCPCLIENT_H
#define TCPCLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QByteArray>
#include <QString>
#include <QDebug>

class TcpClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(QString lastData READ getLastData NOTIFY dataReceived)
    Q_PROPERTY(QString connectionStatus READ getConnectionStatus NOTIFY statusChanged)

public:
    explicit TcpClient(QObject *parent = nullptr);
    ~TcpClient();

    // 属性访问器
    bool isConnected() const;
    QString getLastData() const;
    QString getConnectionStatus() const;

    // 可从QML调用的方法
    Q_INVOKABLE void connectToServer(const QString &host = "120.26.31.3", int port = 7777);
    Q_INVOKABLE void disconnectFromServer();
    Q_INVOKABLE void sendData(const QString &data);

signals:
    void connectedChanged();
    void dataReceived(const QString &data);
    void statusChanged();
    void connectionSucceeded();
    void connectionFailed(const QString &error);
    void disconnected();

private slots:
    void onConnected();
    void onDisconnected();
    void onErrorOccurred(QAbstractSocket::SocketError error);
    void onReadyRead();

private:
    void processReceivedData(const QByteArray &data);
    void setConnectionStatus(const QString &status);

    QTcpSocket *m_socket;
    QString m_lastData;
    QString m_connectionStatus;
    QByteArray m_buffer; // 用于处理不完整的数据包
};

#endif // TCPCLIENT_H