#include "config.h"
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>

bool ConfigManager::loadFromFile(const QString& filename) {
    QFile file(filename);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "无法打开配置文件:" << filename;
        qInfo() << "使用默认配置";
        return false;
    }

    QByteArray data = file.readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    
    if (error.error != QJsonParseError::NoError) {
        qWarning() << "配置文件JSON解析错误:" << error.errorString();
        return false;
    }

    QJsonObject root = doc.object();
    
    // 加载各个配置部分
    if (root.contains("plot")) {
        plotConfigFromJson(root["plot"].toObject());
    }
    if (root.contains("network")) {
        networkConfigFromJson(root["network"].toObject());
    }
    if (root.contains("protocol")) {
        protocolConfigFromJson(root["protocol"].toObject());
    }
    if (root.contains("ui")) {
        uiConfigFromJson(root["ui"].toObject());
    }

    if (!validateConfig()) {
        qWarning() << "配置验证失败，恢复默认设置";
        resetToDefaults();
        return false;
    }

    qInfo() << "配置文件加载成功:" << filename;
    return true;
}

bool ConfigManager::saveToFile(const QString& filename) const {
    QJsonObject root;
    root["plot"] = plotConfigToJson();
    root["network"] = networkConfigToJson();
    root["protocol"] = protocolConfigToJson();
    root["ui"] = uiConfigToJson();
    
    // 添加元数据
    root["version"] = "1.0";
    root["generated"] = QDateTime::currentDateTime().toString(Qt::ISODate);

    QJsonDocument doc(root);
    
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "无法写入配置文件:" << filename;
        return false;
    }

    file.write(doc.toJson());
    qInfo() << "配置文件保存成功:" << filename;
    return true;
}

void ConfigManager::resetToDefaults() {
    m_plotConfig = PlotConfig{};
    m_networkConfig = NetworkConfig{};
    m_protocolConfig = ProtocolConfig{};
    m_uiConfig = UIConfig{};
    qInfo() << "配置已重置为默认值";
}

bool ConfigManager::validateConfig() const {
    // 验证图表配置
    if (m_plotConfig.maxDataPoints <= 0 || m_plotConfig.maxDataPoints > 100000) {
        qWarning() << "图表配置无效: maxDataPoints =" << m_plotConfig.maxDataPoints;
        return false;
    }
    
    if (m_plotConfig.updateIntervalMs <= 0 || m_plotConfig.updateIntervalMs > 10000) {
        qWarning() << "图表配置无效: updateIntervalMs =" << m_plotConfig.updateIntervalMs;
        return false;
    }

    // 验证网络配置
    if (m_networkConfig.defaultTcpPort <= 0 || m_networkConfig.defaultTcpPort > 65535) {
        qWarning() << "网络配置无效: defaultTcpPort =" << m_networkConfig.defaultTcpPort;
        return false;
    }

    // 验证协议配置
    if (m_protocolConfig.imuOrientationScale <= 0) {
        qWarning() << "协议配置无效: imuOrientationScale =" << m_protocolConfig.imuOrientationScale;
        return false;
    }

    // 验证UI配置
    if (m_uiConfig.decimalPlaces < 0 || m_uiConfig.decimalPlaces > 10) {
        qWarning() << "UI配置无效: decimalPlaces =" << m_uiConfig.decimalPlaces;
        return false;
    }

    return true;
}

QString ConfigManager::getConfigDescription() const {
    return QString(
        "配置概要:\n"
        "- 图表: 最大数据点=%1, 更新间隔=%2ms\n"
        "- 网络: TCP端口=%3, UDP端口=%4\n"
        "- 协议: IMU缩放=%5, GPS缩放=%6\n"
        "- UI: 小数位=%7, 窗口大小=%8x%9"
    ).arg(m_plotConfig.maxDataPoints)
     .arg(m_plotConfig.updateIntervalMs)
     .arg(m_networkConfig.defaultTcpPort)
     .arg(m_networkConfig.defaultUdpPort)
     .arg(m_protocolConfig.imuOrientationScale)
     .arg(m_protocolConfig.gpsCoordinateScale)
     .arg(m_uiConfig.decimalPlaces)
     .arg(m_uiConfig.defaultWindowWidth)
     .arg(m_uiConfig.defaultWindowHeight);
}

// JSON转换方法实现
QJsonObject ConfigManager::plotConfigToJson() const {
    QJsonObject obj;
    obj["maxDataPoints"] = m_plotConfig.maxDataPoints;
    obj["updateIntervalMs"] = m_plotConfig.updateIntervalMs;
    obj["timeWindowSeconds"] = m_plotConfig.timeWindowSeconds;
    obj["useQueuedReplot"] = m_plotConfig.useQueuedReplot;
    obj["performanceUpdateRatio"] = m_plotConfig.performanceUpdateRatio;
    return obj;
}

QJsonObject ConfigManager::networkConfigToJson() const {
    QJsonObject obj;
    obj["defaultTcpPort"] = m_networkConfig.defaultTcpPort;
    obj["defaultTcpPort2"] = m_networkConfig.defaultTcpPort2;
    obj["defaultUdpPort"] = m_networkConfig.defaultUdpPort;
    obj["connectionTimeoutMs"] = m_networkConfig.connectionTimeoutMs;
    obj["maxRetryAttempts"] = m_networkConfig.maxRetryAttempts;
    obj["maxBufferSizeMB"] = m_networkConfig.maxBufferSizeMB;
    return obj;
}

QJsonObject ConfigManager::protocolConfigToJson() const {
    QJsonObject obj;
    obj["imuOrientationScale"] = static_cast<double>(m_protocolConfig.imuOrientationScale);
    obj["imuAngularVelScale"] = static_cast<double>(m_protocolConfig.imuAngularVelScale);
    obj["imuLinearAccScale"] = static_cast<double>(m_protocolConfig.imuLinearAccScale);
    obj["carRpmScale"] = static_cast<double>(m_protocolConfig.carRpmScale);
    obj["carAngleScale"] = static_cast<double>(m_protocolConfig.carAngleScale);
    obj["gpsCoordinateScale"] = m_protocolConfig.gpsCoordinateScale;
    obj["speedLimitMin"] = m_protocolConfig.speedLimitMin;
    obj["speedLimitMax"] = m_protocolConfig.speedLimitMax;
    obj["angleLimitMin"] = m_protocolConfig.angleLimitMin;
    obj["angleLimitMax"] = m_protocolConfig.angleLimitMax;
    return obj;
}

QJsonObject ConfigManager::uiConfigToJson() const {
    QJsonObject obj;
    obj["decimalPlaces"] = m_uiConfig.decimalPlaces;
    obj["floatComparisonEpsilon"] = m_uiConfig.floatComparisonEpsilon;
    obj["uiUpdateDelayMs"] = m_uiConfig.uiUpdateDelayMs;
    obj["defaultWindowWidth"] = m_uiConfig.defaultWindowWidth;
    obj["defaultWindowHeight"] = m_uiConfig.defaultWindowHeight;
    obj["minWindowWidth"] = m_uiConfig.minWindowWidth;
    obj["minWindowHeight"] = m_uiConfig.minWindowHeight;
    
    // 仪表盘配置
    QJsonObject gaugeObj;
    gaugeObj["rpmMin"] = m_uiConfig.gauge.rpmMin;
    gaugeObj["rpmMax"] = m_uiConfig.gauge.rpmMax;
    gaugeObj["rpmWidth"] = m_uiConfig.gauge.rpmWidth;
    gaugeObj["rpmHeight"] = m_uiConfig.gauge.rpmHeight;
    gaugeObj["rpmUnit"] = m_uiConfig.gauge.rpmUnit;
    gaugeObj["angleMin"] = m_uiConfig.gauge.angleMin;
    gaugeObj["angleMax"] = m_uiConfig.gauge.angleMax;
    gaugeObj["angleWidth"] = m_uiConfig.gauge.angleWidth;
    gaugeObj["angleHeight"] = m_uiConfig.gauge.angleHeight;
    gaugeObj["angleUnit"] = m_uiConfig.gauge.angleUnit;
    obj["gauge"] = gaugeObj;
    
    return obj;
}

void ConfigManager::plotConfigFromJson(const QJsonObject& json) {
    if (json.contains("maxDataPoints")) {
        m_plotConfig.maxDataPoints = json["maxDataPoints"].toInt();
    }
    if (json.contains("updateIntervalMs")) {
        m_plotConfig.updateIntervalMs = json["updateIntervalMs"].toInt();
    }
    if (json.contains("timeWindowSeconds")) {
        m_plotConfig.timeWindowSeconds = json["timeWindowSeconds"].toDouble();
    }
    if (json.contains("useQueuedReplot")) {
        m_plotConfig.useQueuedReplot = json["useQueuedReplot"].toBool();
    }
    if (json.contains("performanceUpdateRatio")) {
        m_plotConfig.performanceUpdateRatio = json["performanceUpdateRatio"].toInt();
    }
}

void ConfigManager::networkConfigFromJson(const QJsonObject& json) {
    if (json.contains("defaultTcpPort")) {
        m_networkConfig.defaultTcpPort = json["defaultTcpPort"].toInt();
    }
    if (json.contains("defaultTcpPort2")) {
        m_networkConfig.defaultTcpPort2 = json["defaultTcpPort2"].toInt();
    }
    if (json.contains("defaultUdpPort")) {
        m_networkConfig.defaultUdpPort = json["defaultUdpPort"].toInt();
    }
    if (json.contains("connectionTimeoutMs")) {
        m_networkConfig.connectionTimeoutMs = json["connectionTimeoutMs"].toInt();
    }
    if (json.contains("maxRetryAttempts")) {
        m_networkConfig.maxRetryAttempts = json["maxRetryAttempts"].toInt();
    }
    if (json.contains("maxBufferSizeMB")) {
        m_networkConfig.maxBufferSizeMB = json["maxBufferSizeMB"].toInt();
    }
}

void ConfigManager::protocolConfigFromJson(const QJsonObject& json) {
    if (json.contains("imuOrientationScale")) {
        m_protocolConfig.imuOrientationScale = static_cast<float>(json["imuOrientationScale"].toDouble());
    }
    if (json.contains("imuAngularVelScale")) {
        m_protocolConfig.imuAngularVelScale = static_cast<float>(json["imuAngularVelScale"].toDouble());
    }
    if (json.contains("imuLinearAccScale")) {
        m_protocolConfig.imuLinearAccScale = static_cast<float>(json["imuLinearAccScale"].toDouble());
    }
    if (json.contains("carRpmScale")) {
        m_protocolConfig.carRpmScale = static_cast<float>(json["carRpmScale"].toDouble());
    }
    if (json.contains("carAngleScale")) {
        m_protocolConfig.carAngleScale = static_cast<float>(json["carAngleScale"].toDouble());
    }
    if (json.contains("gpsCoordinateScale")) {
        m_protocolConfig.gpsCoordinateScale = json["gpsCoordinateScale"].toDouble();
    }
    if (json.contains("speedLimitMin")) {
        m_protocolConfig.speedLimitMin = json["speedLimitMin"].toDouble();
    }
    if (json.contains("speedLimitMax")) {
        m_protocolConfig.speedLimitMax = json["speedLimitMax"].toDouble();
    }
    if (json.contains("angleLimitMin")) {
        m_protocolConfig.angleLimitMin = json["angleLimitMin"].toDouble();
    }
    if (json.contains("angleLimitMax")) {
        m_protocolConfig.angleLimitMax = json["angleLimitMax"].toDouble();
    }
}

void ConfigManager::uiConfigFromJson(const QJsonObject& json) {
    if (json.contains("decimalPlaces")) {
        m_uiConfig.decimalPlaces = json["decimalPlaces"].toInt();
    }
    if (json.contains("floatComparisonEpsilon")) {
        m_uiConfig.floatComparisonEpsilon = json["floatComparisonEpsilon"].toDouble();
    }
    if (json.contains("uiUpdateDelayMs")) {
        m_uiConfig.uiUpdateDelayMs = json["uiUpdateDelayMs"].toInt();
    }
    if (json.contains("defaultWindowWidth")) {
        m_uiConfig.defaultWindowWidth = json["defaultWindowWidth"].toInt();
    }
    if (json.contains("defaultWindowHeight")) {
        m_uiConfig.defaultWindowHeight = json["defaultWindowHeight"].toInt();
    }
    if (json.contains("minWindowWidth")) {
        m_uiConfig.minWindowWidth = json["minWindowWidth"].toInt();
    }
    if (json.contains("minWindowHeight")) {
        m_uiConfig.minWindowHeight = json["minWindowHeight"].toInt();
    }
    
    // 仪表盘配置
    if (json.contains("gauge")) {
        QJsonObject gaugeObj = json["gauge"].toObject();
        if (gaugeObj.contains("rpmMin")) {
            m_uiConfig.gauge.rpmMin = gaugeObj["rpmMin"].toDouble();
        }
        if (gaugeObj.contains("rpmMax")) {
            m_uiConfig.gauge.rpmMax = gaugeObj["rpmMax"].toDouble();
        }
        if (gaugeObj.contains("rpmWidth")) {
            m_uiConfig.gauge.rpmWidth = gaugeObj["rpmWidth"].toInt();
        }
        if (gaugeObj.contains("rpmHeight")) {
            m_uiConfig.gauge.rpmHeight = gaugeObj["rpmHeight"].toInt();
        }
        if (gaugeObj.contains("rpmUnit")) {
            m_uiConfig.gauge.rpmUnit = gaugeObj["rpmUnit"].toString();
        }
        if (gaugeObj.contains("angleMin")) {
            m_uiConfig.gauge.angleMin = gaugeObj["angleMin"].toDouble();
        }
        if (gaugeObj.contains("angleMax")) {
            m_uiConfig.gauge.angleMax = gaugeObj["angleMax"].toDouble();
        }
        if (gaugeObj.contains("angleWidth")) {
            m_uiConfig.gauge.angleWidth = gaugeObj["angleWidth"].toInt();
        }
        if (gaugeObj.contains("angleHeight")) {
            m_uiConfig.gauge.angleHeight = gaugeObj["angleHeight"].toInt();
        }
        if (gaugeObj.contains("angleUnit")) {
            m_uiConfig.gauge.angleUnit = gaugeObj["angleUnit"].toString();
        }
    }
} 