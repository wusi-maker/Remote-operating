// mainwindow.h
#pragma once

#include <QMainWindow>
#include <QTcpServer>
#include <QTcpSocket>
#include <QTimer>
#include <QVector>
#include <QMutex>
#include <QElapsedTimer>
#include <memory>

#include "qcustomplot.h"
#include "cardashboard.h"
#include "ffmpegdecoder.h"
#include "mapcanvas.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(int port, bool testMode, int udpPort, QWidget *parent = nullptr);
    ~MainWindow();
    
    // 设置数据解析模式
    void setParseMode(const QString &mode) { m_parseMode = mode; }
    QString getParseMode() const { return m_parseMode; }
    
    // MongoDB控制方法
    void setupMongoDBConnection(const QString &host, int port, const QString &database, const QString &collection);
    void startMongoDBSubscription();
    void stopMongoDBSubscription();
    void setMongoDBQueryInterval(int intervalMs);
    void setMongoDBAuthentication(const QString &username, const QString &password);
    bool isMongoDBConnected() const;

private slots:
    void handleNewConnection();          // 处理新客户端连接
    void readClientData();              // 读取客户端原始二进制数据
    void readClientData2();             // 读取第二个端口的数据

    void updatePlots();                 // 更新所有曲线
    void onFrameReceived(QImage frame); // 视频帧接收处理
    void on_cencel_clicked();           // 取消按钮点击
    void on_start_clicked();            // 开始按钮点击
    


private:
    // ================== 常量定义 ==================
    // 协议解析常量
    static constexpr float IMU_ORIENTATION_SCALE = 1000.0f;
    static constexpr float IMU_ANGULAR_VEL_SCALE = 1000.0f;
    static constexpr float IMU_LINEAR_ACC_SCALE = 1000.0f;
    static constexpr float CAR_RPM_SCALE = 10.0f;
    static constexpr float CAR_ANGLE_SCALE = 1000.0f;
    static constexpr double GPS_COORDINATE_SCALE = 1e8;
    
    // 数据管理常量
    static constexpr int MAX_DATA_POINTS = 1000;
    static constexpr int UPDATE_INTERVAL_MS = 50;  // 20Hz
    static constexpr double TIME_WINDOW_SECONDS = 10.0;
    
    // 协议帧格式常量
    static constexpr uint8_t FRAME_HEADER_1 = 0xEE;
    static constexpr uint8_t FRAME_HEADER_2 = 0xFF;
    static constexpr uint8_t FRAME_FOOTER = 0xDD;
    static constexpr int MIN_FRAME_SIZE = 5;
    static constexpr double FLOAT_COMPARISON_EPSILON = 0.001;
    
    // UI更新常量
    static constexpr int DECIMAL_PLACES = 3;
    static constexpr double SPEED_LIMIT_MIN = -6.0;
    static constexpr double SPEED_LIMIT_MAX = 6.0;
    static constexpr double ANGLE_LIMIT_MIN = -5.0;
    static constexpr double ANGLE_LIMIT_MAX = 5.0;

    // ================== 私有方法 ==================
    // 初始化方法
    void initializeWindow();
    void initializePlots();
    void initializeGauges();
    void initializeLayouts();
    void initializeNetworking(int port);
    void initializeVideoDecoder(int udpPort);
    void initializeTimers();
    
    // 协议解析相关
    void parseCustomProtocol(const QByteArray &data, const QString &parse_mode = "BINARY");
    void parseJsonProtocol(const QByteArray &data);
    bool validateChecksum(const QByteArray &frame);
    uint16_t bytesToUInt16(const uint8_t* bytes);
    void parseNewProtocol(const QByteArray &data);
    
    // 网络处理
    void handleNewConnection2();
    
    // UI更新方法
    void setupPlotWithBlackBackground(QCustomPlot *plot);
    void updateGpsTable(double time, double latitude, double longitude);
    void updateVehicleDataDisplays(double av, double lv, double rpm,
                                  double angle, double odomX, double odomY);
    void updateMap(double latitude, double longitude);
    void setupMapCanvas();
    
    // 数据管理辅助方法,其中规定了存储数量的最大值，超出则会被丢弃
    template<typename T>
    void appendDataWithLimit(QVector<T>& container, const T& value, int maxSize = MAX_DATA_POINTS);

    // ================== 数据结构定义 ==================
    struct SensorData {
        double orientationX, orientationY, orientationZ, orientationW;
        double angularVelX, angularVelY;
        double linearAccX, linearAccY;
        double rpm, angle, longitudinalVel, lateralVel;
        double odomX, odomY;
        double latitude, longitude;
        double timestamp;
    };

    // ================== 协议解析优化方法 ==================
    bool processNextFrame();
    int findFrameHeader();
    bool validateFrameIntegrity(const QByteArray &frame);
    bool parseFrameData(const QByteArray &frame);
    SensorData extractSensorData(const uint8_t* dataPtr);
    bool shouldUpdateGpsData(double latitude, double longitude);
    void storeDataWithLimit(const SensorData& data);
    void applySensorDataLimits(SensorData& data);
    void updateGauges(const SensorData& data);

    // ================== 成员变量 ==================
    std::unique_ptr<Ui::MainWindow> ui;

    // 网络通信相关
    std::unique_ptr<QTcpServer> m_tcpServer;
    std::unique_ptr<QTcpServer> m_tcpServer2;
    QTcpSocket* m_clientSocket;
    QTcpSocket* m_clientSocket2;
    QByteArray m_receiveBuffer;
    QByteArray m_receiveBuffer2;
    mutable QMutex m_bufferMutex;

    // 控制标志和定时器
    bool m_testFlag;
    std::unique_ptr<QTimer> m_updateTimer;
    double m_currentTime = 0.0;
    QElapsedTimer m_timer;
    QString m_parseMode = "JSON"; // 解析模式："BINARY" 或 "JSON",通过该模式选择是使用JSON数据解析还是使用二进制数据解析

    // 数据容器 - 时间序列
    QVector<double> m_timeData;
    QVector<double> m_xPosition, m_yPosition;
    QVector<double> m_xVelocity, m_yVelocity;
    QVector<double> m_xAcceleration, m_yAcceleration;

    // IMU传感器数据容器
    QVector<double> m_imuOrientationX, m_imuOrientationY, m_imuOrientationZ, m_imuOrientationW;
    QVector<double> m_imuAngularVelX, m_imuAngularVelY;
    QVector<double> m_imuLinearAccX, m_imuLinearAccY;
    
    // 车辆状态数据容器
    QVector<double> m_carRpm, m_carAngle, m_carLongitudinalVel, m_carLateralVel;
    QVector<double> m_odomPoseX, m_odomPoseY;
    QVector<double> m_gpsLatitude, m_gpsLongitude;
    double m_intervalWithOthers;

    // 缓存上次更新的值，避免重复更新UI
    struct LastValues {
        double lateralVel = 0.0;
        double longitudinalVel = 0.0;
        double rpm = 0.0;
        double angle = 0.0;
        double odomX = 0.0;
        double odomY = 0.0;
        double distance = 0.0;
    } m_lastValues;

    // 图形控件 - 使用智能指针管理
    QWidget *m_imuContainer;
    QWidget *m_carContainer;
    std::unique_ptr<QCustomPlot> m_imuQuatPlot;
    std::unique_ptr<QCustomPlot> m_imuAngularVelPlot;
    std::unique_ptr<QCustomPlot> m_imuLinearAccPlot;
    std::unique_ptr<QCustomPlot> m_carRpmPlot;
    std::unique_ptr<QCustomPlot> m_carAnglePlot;
    std::unique_ptr<QCustomPlot> m_carVelPlot;

    // 仪表盘控件
    std::unique_ptr<CarDashboard> m_rpmGauge;
    std::unique_ptr<CarDashboard> m_angleGauge;

    // 地图和视频相关
    std::unique_ptr<MapCanvas> m_mapCanvas;
    std::unique_ptr<FFmpegDecoder> m_decoder;
    

    // UI更新优化
    bool m_uiUpdatePending = false;
};
