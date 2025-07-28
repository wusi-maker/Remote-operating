#pragma once

#include <QObject>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <QDebug>

class MongoDBConnector : public QObject
{
    Q_OBJECT

public:
    explicit MongoDBConnector(QObject *parent = nullptr);
    ~MongoDBConnector();
    
    // 设置MongoDB连接参数
    void setConnectionParams(const QString &host, int port, const QString &database, const QString &collection);
    
    // 设置完整的MongoDB连接字符串
    void setMongoConnectionString(const QString &connectionString, const QString &database, const QString &collection);
    
    // 设置查询间隔（毫秒）
    void setQueryInterval(int intervalMs);
    
    // 开始/停止数据订阅
    void startSubscription();
    void stopSubscription();
    
    // 手动查询最新数据
    void queryLatestData();
    
    // 设置认证信息（如果需要）
    void setAuthentication(const QString &username, const QString &password);
    
    // 设置REST API端点（如果使用MongoDB Atlas或自定义REST API）
    void setRestApiEndpoint(const QString &endpoint);
    
signals:
    // 当有新数据时发出信号
    void newDataReceived(const QByteArray &jsonData);
    
    // 连接状态信号
    void connectionStatusChanged(bool connected);
    
    // 错误信号
    void errorOccurred(const QString &error);

private slots:
    void onQueryTimer();
    void onNetworkReplyFinished();
    void onNetworkError(QNetworkReply::NetworkError error);

private:
    // 网络相关
    QNetworkAccessManager *m_networkManager;
    QNetworkReply *m_currentReply;
    
    // 定时器
    QTimer *m_queryTimer;
    
    // 连接参数
    QString m_host;
    int m_port;
    QString m_database;
    QString m_collection;
    QString m_username;
    QString m_password;
    QString m_restApiEndpoint;
    QString m_connectionString; // 完整的MongoDB连接字符串
    
    // 查询参数
    int m_queryInterval; // 毫秒
    QDateTime m_lastTimestamp; // 上次查询的时间戳
    
    // 状态
    bool m_isSubscribed;
    bool m_isConnected;
    
    // 私有方法
    void setupNetworkManager();
    QNetworkRequest createRequest();
    QString buildQueryUrl();
    void processResponse(const QByteArray &data);
    bool isDataNewer(const QJsonObject &data);
};