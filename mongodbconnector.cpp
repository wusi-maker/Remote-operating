#include "mongodbconnector.h"
#include <QJsonArray>
#include <QUrlQuery>
#include <QAuthenticator>
#include <QSslConfiguration>
#include <QRegularExpression>

MongoDBConnector::MongoDBConnector(QObject *parent)
    : QObject(parent)
    , m_networkManager(nullptr)
    , m_currentReply(nullptr)
    , m_queryTimer(new QTimer(this))
    , m_port(27017)
    , m_queryInterval(1000) // 默认1秒查询一次
    , m_isSubscribed(false)
    , m_isConnected(false)
{
    setupNetworkManager();
    
    // 设置定时器
    m_queryTimer->setSingleShot(false);
    connect(m_queryTimer, &QTimer::timeout, this, &MongoDBConnector::onQueryTimer);
    
    qDebug() << "MongoDB连接器初始化完成";
}

MongoDBConnector::~MongoDBConnector()
{
    stopSubscription();
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply->deleteLater();
    }
}

void MongoDBConnector::setupNetworkManager()
{
    m_networkManager = new QNetworkAccessManager(this);
    
    // 设置SSL配置（如果需要HTTPS）
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone); // 开发环境可以关闭SSL验证
}

void MongoDBConnector::setConnectionParams(const QString &host, int port, const QString &database, const QString &collection)
{
    m_host = host;
    m_port = port;
    m_database = database;
    m_collection = collection;
    
    qDebug() << QString("设置MongoDB连接参数: %1:%2/%3.%4")
                .arg(host).arg(port).arg(database).arg(collection);
}

void MongoDBConnector::setQueryInterval(int intervalMs)
{
    m_queryInterval = intervalMs;
    if (m_queryTimer->isActive()) {
        m_queryTimer->setInterval(intervalMs);
    }
    qDebug() << "设置查询间隔:" << intervalMs << "毫秒";
}

void MongoDBConnector::setAuthentication(const QString &username, const QString &password)
{
    m_username = username;
    m_password = password;
    qDebug() << "设置认证信息，用户名:" << username;
}

void MongoDBConnector::setRestApiEndpoint(const QString &endpoint)
{
    m_restApiEndpoint = endpoint;
    qDebug() << "设置REST API端点:" << endpoint;
}

void MongoDBConnector::setMongoConnectionString(const QString &connectionString, const QString &database, const QString &collection)
{
    m_connectionString = connectionString;
    m_database = database;
    m_collection = collection;
    
    // 从连接字符串中解析主机和端口信息
    // mongodb://sensor_user:sensor_password_123@47.111.21.77:27017/
    QRegularExpression regex("mongodb://([^:]+):([^@]+)@([^:]+):(\d+)/?");
    QRegularExpressionMatch match = regex.match(connectionString);
    
    if (match.hasMatch()) {
        m_username = match.captured(1);
        m_password = match.captured(2);
        m_host = match.captured(3);
        m_port = match.captured(4).toInt();
        
        qDebug() << QString("解析MongoDB连接字符串: %1@%2:%3/%4.%5")
                    .arg(m_username).arg(m_host).arg(m_port).arg(database).arg(collection);
    } else {
        qWarning() << "无法解析MongoDB连接字符串:" << connectionString;
    }
}

void MongoDBConnector::startSubscription()
{
    if (m_isSubscribed) {
        qWarning() << "数据订阅已经启动";
        return;
    }
    
    if (m_host.isEmpty() || m_database.isEmpty() || m_collection.isEmpty()) {
        emit errorOccurred("连接参数不完整，请先设置host、database和collection");
        return;
    }
    
    m_isSubscribed = true;
    m_lastTimestamp = QDateTime::currentDateTime().addSecs(-60); // 从1分钟前开始查询
    
    // 启动定时器
    m_queryTimer->start(m_queryInterval);
    
    // 立即执行一次查询
    queryLatestData();
    
    qInfo() << "MongoDB数据订阅已启动，查询间隔:" << m_queryInterval << "毫秒";
}

void MongoDBConnector::stopSubscription()
{
    if (!m_isSubscribed) {
        return;
    }
    
    m_isSubscribed = false;
    m_queryTimer->stop();
    
    if (m_currentReply) {
        m_currentReply->abort();
    }
    
    qInfo() << "MongoDB数据订阅已停止";
}

void MongoDBConnector::queryLatestData()
{
    if (m_currentReply) {
        // 如果有正在进行的请求，先取消
        m_currentReply->abort();
        m_currentReply->deleteLater();
        m_currentReply = nullptr;
    }
    
    QNetworkRequest request = createRequest();
    
    // 发送GET请求
    m_currentReply = m_networkManager->get(request);
    
    // 连接信号
    connect(m_currentReply, &QNetworkReply::finished,
            this, &MongoDBConnector::onNetworkReplyFinished);
    connect(m_currentReply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::errorOccurred),
            this, &MongoDBConnector::onNetworkError);
    
    qDebug() << "发送MongoDB查询请求:" << request.url().toString();
}

void MongoDBConnector::onQueryTimer()
{
    if (m_isSubscribed) {
        queryLatestData();
    }
}

void MongoDBConnector::onNetworkReplyFinished()
{
    if (!m_currentReply) {
        return;
    }
    
    QByteArray responseData = m_currentReply->readAll();
    int statusCode = m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    
    if (statusCode == 200) {
        m_isConnected = true;
        emit connectionStatusChanged(true);
        processResponse(responseData);
    } else {
        m_isConnected = false;
        emit connectionStatusChanged(false);
        QString errorMsg = QString("HTTP错误: %1, 响应: %2")
                          .arg(statusCode)
                          .arg(QString::fromUtf8(responseData));
        emit errorOccurred(errorMsg);
        qWarning() << errorMsg;
    }
    
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
}

void MongoDBConnector::onNetworkError(QNetworkReply::NetworkError error)
{
    if (!m_currentReply) {
        return;
    }
    
    m_isConnected = false;
    emit connectionStatusChanged(false);
    
    QString errorMsg = QString("网络错误: %1, 详情: %2")
                      .arg(error)
                      .arg(m_currentReply->errorString());
    emit errorOccurred(errorMsg);
    qWarning() << errorMsg;
}

QNetworkRequest MongoDBConnector::createRequest()
{
    QNetworkRequest request;
    
    // 构建请求URL
    QString url = buildQueryUrl();
    request.setUrl(QUrl(url));
    
    // 设置请求头
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("User-Agent", "QT-MongoDB-Connector/1.0");
    
    // 如果有认证信息，添加Basic Auth
    if (!m_username.isEmpty() && !m_password.isEmpty()) {
        QString credentials = m_username + ":" + m_password;
        QByteArray encodedCredentials = credentials.toUtf8().toBase64();
        request.setRawHeader("Authorization", "Basic " + encodedCredentials);
    }
    
    return request;
}

QString MongoDBConnector::buildQueryUrl()
{
    QString url;
    
    if (!m_restApiEndpoint.isEmpty()) {
        // 使用自定义REST API端点
        url = m_restApiEndpoint;
        
        // 添加查询参数
        QUrlQuery query;
        query.addQueryItem("database", m_database);
        query.addQueryItem("collection", m_collection);
        query.addQueryItem("limit", "1");
        query.addQueryItem("sort", "{\"timestamp\":-1}"); // 按时间戳降序排列
        
        if (!url.contains('?')) {
            url += "?";
        } else {
            url += "&";
        }
        url += query.toString();
    } else {
        // 构建MongoDB Data API URL（适用于MongoDB Atlas或自建MongoDB REST服务）
        // 这里假设有一个简单的REST API服务来查询MongoDB
        // 实际部署时需要创建一个简单的Node.js或Python服务来提供REST API
        url = QString("http://%1:3000/api/latest-data")
              .arg(m_host);
        
        // 添加查询参数
        QUrlQuery query;
        query.addQueryItem("database", m_database);
        query.addQueryItem("collection", m_collection);
        
        url += "?" + query.toString();
    }
    
    return url;
}

void MongoDBConnector::processResponse(const QByteArray &data)
{
    if (data.isEmpty()) {
        qWarning() << "收到空响应";
        return;
    }
    
    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &parseError);
    
    if (parseError.error != QJsonParseError::NoError) {
        emit errorOccurred("JSON解析错误: " + parseError.errorString());
        return;
    }
    
    QJsonObject jsonObj;
    
    if (jsonDoc.isObject()) {
        jsonObj = jsonDoc.object();
    } else if (jsonDoc.isArray()) {
        QJsonArray jsonArray = jsonDoc.array();
        if (!jsonArray.isEmpty()) {
            jsonObj = jsonArray.first().toObject();
        }
    }
    
    if (jsonObj.isEmpty()) {
        qDebug() << "没有找到有效数据";
        return;
    }
    
    // 检查数据是否比上次更新的新
    if (isDataNewer(jsonObj)) {
        // 更新时间戳
        if (jsonObj.contains("timestamp")) {
            QString timestampStr = jsonObj["timestamp"].toString();
            m_lastTimestamp = QDateTime::fromString(timestampStr, Qt::ISODate);
        } else if (jsonObj.contains("inserted_at")) {
            QJsonObject insertedAt = jsonObj["inserted_at"].toObject();
            if (insertedAt.contains("$date")) {
                QString dateStr = insertedAt["$date"].toString();
                m_lastTimestamp = QDateTime::fromString(dateStr, Qt::ISODate);
            }
        } else {
            // 如果没有时间戳字段，使用当前时间
            m_lastTimestamp = QDateTime::currentDateTime();
        }
        
        // 发出新数据信号
        QJsonDocument newDoc(jsonObj);
        emit newDataReceived(newDoc.toJson(QJsonDocument::Compact));
        
        qDebug() << "收到新数据，时间戳:" << m_lastTimestamp.toString();
    } else {
        qDebug() << "数据未更新";
    }
}

bool MongoDBConnector::isDataNewer(const QJsonObject &data)
{
    QDateTime dataTimestamp;
    
    // 尝试从不同字段获取时间戳
    if (data.contains("timestamp")) {
        QString timestampStr = data["timestamp"].toString();
        dataTimestamp = QDateTime::fromString(timestampStr, Qt::ISODate);
    } else if (data.contains("inserted_at")) {
        QJsonObject insertedAt = data["inserted_at"].toObject();
        if (insertedAt.contains("$date")) {
            QString dateStr = insertedAt["$date"].toString();
            dataTimestamp = QDateTime::fromString(dateStr, Qt::ISODate);
        }
    }
    
    if (!dataTimestamp.isValid()) {
        // 如果无法解析时间戳，假设是新数据
        qWarning() << "无法解析数据时间戳，假设为新数据";
        return true;
    }
    
    // 比较时间戳
    return dataTimestamp > m_lastTimestamp;
}