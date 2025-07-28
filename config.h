#pragma once

#include <QString>
#include <QColor>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFile>
#include <QDebug>

/**
 * @brief 配置管理类 - 集中管理所有配置参数
 * 
 * 这个类实现了单例模式，用于管理应用程序的所有配置参数。
 * 支持从JSON文件加载和保存配置。
 */
class ConfigManager {
public:
    // 图表配置结构
    struct PlotConfig {
        int maxDataPoints = 1000;
        int updateIntervalMs = 50;
        double timeWindowSeconds = 10.0;
        QColor backgroundColor = Qt::black;
        QColor textColor = Qt::white;
        bool useQueuedReplot = true;
        int performanceUpdateRatio = 3; // 每3次调用才更新一次
    };
    
    // 网络配置结构
    struct NetworkConfig {
        int defaultTcpPort = 8888;
        int defaultTcpPort2 = 7777;
        int defaultUdpPort = 9999;
        int connectionTimeoutMs = 5000;
        int maxRetryAttempts = 3;
        int maxBufferSizeMB = 10;
    };
    
    // 协议配置结构
    struct ProtocolConfig {
        // 缩放因子
        float imuOrientationScale = 1000.0f;
        float imuAngularVelScale = 1000.0f;
        float imuLinearAccScale = 1000.0f;
        float carRpmScale = 10.0f;
        float carAngleScale = 1000.0f;
        double gpsCoordinateScale = 1e8;
        
        // 帧格式
        uint8_t frameHeader1 = 0xEE;
        uint8_t frameHeader2 = 0xFF;
        uint8_t frameFooter = 0xDD;
        int minFrameSize = 5;
        
        // 数据范围限制
        double speedLimitMin = -6.0;
        double speedLimitMax = 6.0;
        double angleLimitMin = -5.0;
        double angleLimitMax = 5.0;
    };
    
    // UI配置结构
    struct UIConfig {
        int decimalPlaces = 3;
        double floatComparisonEpsilon = 0.001;
        int uiUpdateDelayMs = 10;
        
        // 窗口设置
        int defaultWindowWidth = 1200;
        int defaultWindowHeight = 800;
        int minWindowWidth = 800;
        int minWindowHeight = 600;
        
        // 仪表盘设置
        struct GaugeConfig {
            double rpmMin = -5.0;
            double rpmMax = 5.0;
            double rpmWarningMin = -3.0;
            double rpmWarningMax = 3.0;
            int rpmWidth = 480;
            int rpmHeight = 420;
            QString rpmUnit = "m/s";
            
            double angleMin = -6.0;
            double angleMax = 6.0;
            double angleWarningMin = -4.0;
            double angleWarningMax = 4.0;
            int angleWidth = 300;
            int angleHeight = 240;
            QString angleUnit = "degrees";
        } gauge;
    };

    // 单例模式访问方法
    static ConfigManager& instance() {
        static ConfigManager instance;
        return instance;
    }

    // 配置文件操作
    bool loadFromFile(const QString& filename = "config.json");
    bool saveToFile(const QString& filename = "config.json") const;
    void resetToDefaults();

    // 配置访问器
    const PlotConfig& plotConfig() const { return m_plotConfig; }
    const NetworkConfig& networkConfig() const { return m_networkConfig; }
    const ProtocolConfig& protocolConfig() const { return m_protocolConfig; }
    const UIConfig& uiConfig() const { return m_uiConfig; }

    // 配置修改器（用于运行时调整）
    PlotConfig& plotConfig() { return m_plotConfig; }
    NetworkConfig& networkConfig() { return m_networkConfig; }
    ProtocolConfig& protocolConfig() { return m_protocolConfig; }
    UIConfig& uiConfig() { return m_uiConfig; }

    // 验证配置的有效性
    bool validateConfig() const;
    
    // 获取配置描述（用于调试）
    QString getConfigDescription() const;

private:
    ConfigManager() = default;
    ~ConfigManager() = default;
    
    // 禁用拷贝构造和赋值
    ConfigManager(const ConfigManager&) = delete;
    ConfigManager& operator=(const ConfigManager&) = delete;

    // 配置转换方法
    QJsonObject plotConfigToJson() const;
    QJsonObject networkConfigToJson() const;
    QJsonObject protocolConfigToJson() const;
    QJsonObject uiConfigToJson() const;
    
    void plotConfigFromJson(const QJsonObject& json);
    void networkConfigFromJson(const QJsonObject& json);
    void protocolConfigFromJson(const QJsonObject& json);
    void uiConfigFromJson(const QJsonObject& json);

    // 成员变量
    PlotConfig m_plotConfig;
    NetworkConfig m_networkConfig;
    ProtocolConfig m_protocolConfig;
    UIConfig m_uiConfig;
};

// 便于使用的宏定义
#define APP_CONFIG ConfigManager::instance()
#define PLOT_CONFIG APP_CONFIG.plotConfig()
#define NETWORK_CONFIG APP_CONFIG.networkConfig()
#define PROTOCOL_CONFIG APP_CONFIG.protocolConfig()
#define UI_CONFIG APP_CONFIG.uiConfig() 