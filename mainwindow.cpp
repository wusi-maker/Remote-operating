#include "mainwindow.h"
#include <QRandomGenerator>
#include <QMessageBox>
#include <QVBoxLayout>
#include <QDebug>
// JSON数据解析相关库函数
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include "ui_mainwindow.h"

// 辅助函数：将字节转换为缩放浮点数
float bytesToScaledFloat(const uint8_t* data, float scale) {
    int32_t rawValue = (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
    return static_cast<float>(rawValue) / scale;
}

// 辅助函数：将字节转换为缩放双精度数
double bytesToScaledDouble(const uint8_t* data, double scale) {
    int32_t rawValue = (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
    return static_cast<double>(rawValue) / scale;
}

MainWindow::MainWindow(int port, bool testMode, int udpPort, QWidget *parent)
    : QMainWindow(parent)
    , ui(std::make_unique<Ui::MainWindow>())
    , m_tcpServer(std::make_unique<QTcpServer>(this))
    , m_tcpServer2(std::make_unique<QTcpServer>(this))
    , m_clientSocket(nullptr)
    , m_clientSocket2(nullptr)
    , m_testFlag(testMode)
    , m_updateTimer(std::make_unique<QTimer>(this))
    , m_currentTime(0.0)
    , m_intervalWithOthers(0.0)
{
    ui->setupUi(this);
    
    // 按模块化方式初始化
    initializeWindow();
    initializePlots();
    initializeGauges();
    initializeLayouts();
    initializeNetworking(port);
    initializeVideoDecoder(udpPort);
    initializeTimers();
    

}


MainWindow::~MainWindow() {
    // 停止定时器
    if (m_updateTimer) {
        m_updateTimer->stop();
    }
    
    // 断开网络连接
    if (m_clientSocket) {
        m_clientSocket->disconnectFromHost();
    }
    if (m_clientSocket2) {
        m_clientSocket2->disconnectFromHost();
    }
    
    // 关闭服务器
    if (m_tcpServer) {
        m_tcpServer->close();
    }
    if (m_tcpServer2) {
        m_tcpServer2->close();
    }
    
    // 智能指针会自动释放其他资源
}

void MainWindow::initializeWindow() {
    resize(1200, 800);
    setMinimumSize(800, 600);
    m_timer.start();
    
    // 设置初始UI值
    ui->Transerve_val->setText("0.000");
    ui->Longitudinal_val->setText("0.000");
    ui->wheel_rpm->setText("0.000");
    ui->wheel_angle->setText("0.000");
    ui->wheel_angle_2->setText("0.000");
    ui->wheel_angle_3->setText("0.000");
    ui->wheel_angle_4->setText("0.000");
    ui->wheel_angle_5->setText("0.000");
    ui->wheel_angle_6->setText("0.000");
    ui->Transerve_val_2->setText("0.000");
    ui->Longitudinal_val_2->setText("0.000");
}

void MainWindow::initializePlots() {
    // 创建所有图表
    m_imuQuatPlot = std::make_unique<QCustomPlot>(ui->ori_angular);
    m_imuAngularVelPlot = std::make_unique<QCustomPlot>(ui->angularVal);
    m_imuLinearAccPlot = std::make_unique<QCustomPlot>(ui->linerVal);
    m_carRpmPlot = std::make_unique<QCustomPlot>(ui->carRpm);
    m_carAnglePlot = std::make_unique<QCustomPlot>(ui->carAngle);
    m_carVelPlot = std::make_unique<QCustomPlot>(ui->carVal);
    
    // 设置所有图表的黑色背景样式
    setupPlotWithBlackBackground(m_imuQuatPlot.get());
    setupPlotWithBlackBackground(m_imuAngularVelPlot.get());
    setupPlotWithBlackBackground(m_imuLinearAccPlot.get());
    setupPlotWithBlackBackground(m_carRpmPlot.get());
    setupPlotWithBlackBackground(m_carAnglePlot.get());
    setupPlotWithBlackBackground(m_carVelPlot.get());
    
    // 配置IMU四元数图表
    m_imuQuatPlot->addGraph()->setPen(QPen(Qt::blue));
    m_imuQuatPlot->addGraph()->setPen(QPen(Qt::red));
    m_imuQuatPlot->addGraph()->setPen(QPen(Qt::green));
    m_imuQuatPlot->addGraph()->setPen(QPen(Qt::magenta));
    m_imuQuatPlot->xAxis->setLabel("时间 (s)");
    m_imuQuatPlot->yAxis->setLabel("值");
    m_imuQuatPlot->legend->setVisible(true);
    m_imuQuatPlot->graph(0)->setName("orientation_x");
    m_imuQuatPlot->graph(1)->setName("orientation_y");
    m_imuQuatPlot->graph(2)->setName("orientation_z");
    m_imuQuatPlot->graph(3)->setName("orientation_w");
    
    // 配置IMU角速度图表
    m_imuAngularVelPlot->addGraph()->setPen(QPen(Qt::cyan));
    m_imuAngularVelPlot->addGraph()->setPen(QPen(Qt::yellow));
    m_imuAngularVelPlot->xAxis->setLabel("时间 (s)");
    m_imuAngularVelPlot->yAxis->setLabel("值");
    m_imuAngularVelPlot->legend->setVisible(true);
    m_imuAngularVelPlot->graph(0)->setName("ang_x");
    m_imuAngularVelPlot->graph(1)->setName("ang_y");
    
    // 配置IMU线性加速度图表
    m_imuLinearAccPlot->addGraph()->setPen(QPen(Qt::darkGreen));
    m_imuLinearAccPlot->addGraph()->setPen(QPen(Qt::darkRed));
    m_imuLinearAccPlot->xAxis->setLabel("时间 (s)");
    m_imuLinearAccPlot->yAxis->setLabel("值");
    m_imuLinearAccPlot->legend->setVisible(true);
    m_imuLinearAccPlot->graph(0)->setName("lin_x");
    m_imuLinearAccPlot->graph(1)->setName("lin_y");
    
    // 配置车辆RPM图表
    m_carRpmPlot->addGraph()->setPen(QPen(Qt::darkBlue));
    m_carRpmPlot->xAxis->setLabel("时间 (s)");
    m_carRpmPlot->yAxis->setLabel("轮毂转速");
    
    // 配置车辆角度图表
    m_carAnglePlot->addGraph()->setPen(QPen(Qt::darkCyan));
    m_carAnglePlot->xAxis->setLabel("时间 (s)");
    m_carAnglePlot->yAxis->setLabel("前轮转动角");
    
    // 配置车辆速度图表
    m_carVelPlot->addGraph()->setPen(QPen(Qt::darkMagenta));
    m_carVelPlot->addGraph()->setPen(QPen(Qt::darkYellow));
    m_carVelPlot->xAxis->setLabel("时间 (s)");
    m_carVelPlot->yAxis->setLabel("值");
    m_carVelPlot->legend->setVisible(true);
    m_carVelPlot->graph(0)->setName("纵向速度");
    m_carVelPlot->graph(1)->setName("横向速度");
}

void MainWindow::initializeGauges() {
    // 创建仪表盘控件
    m_rpmGauge = std::make_unique<CarDashboard>(
        ui->gaugeRpm, -5, 5, -3, 3, 1, 0, "m/s", 480, 420);
    m_angleGauge = std::make_unique<CarDashboard>(
        ui->gaugeAngle, -6, 6, -4, 4, 1, 0, "degrees", 300, 240);
}

void MainWindow::initializeLayouts() {
    // 设置图表布局
    auto setupLayout = [](QWidget* container, QCustomPlot* plot) {
        auto layout = new QVBoxLayout(container);
        layout->addWidget(plot);
        layout->setContentsMargins(0, 0, 0, 0);
    };
    
    setupLayout(ui->ori_angular, m_imuQuatPlot.get());
    setupLayout(ui->angularVal, m_imuAngularVelPlot.get());
    setupLayout(ui->linerVal, m_imuLinearAccPlot.get());
    setupLayout(ui->carRpm, m_carRpmPlot.get());
    setupLayout(ui->carAngle, m_carAnglePlot.get());
    setupLayout(ui->carVal, m_carVelPlot.get());
    
    // 初始化地图画布
    setupMapCanvas();
}

void MainWindow::initializeNetworking(int port) {
    if (m_testFlag) {
        return; // 测试模式下不启动网络服务
    }
    
    // 启动主TCP服务器
    if (!m_tcpServer->listen(QHostAddress::Any, port)) {
        QString errorMsg = QString("主服务器启动失败 (端口 %1): %2")
                          .arg(port)
                          .arg(m_tcpServer->errorString());
        qCritical() << errorMsg;
        QMessageBox::critical(this, "网络错误", errorMsg);
        return;
    }
    connect(m_tcpServer.get(), &QTcpServer::newConnection, 
            this, &MainWindow::handleNewConnection);
    qInfo() << "主TCP服务器启动成功，端口:" << port;
    
    // 启动第二个TCP服务器 (端口7777)
    if (!m_tcpServer2->listen(QHostAddress::Any, 7777)) {
        QString errorMsg = QString("辅助服务器启动失败 (端口 7777): %1")
                          .arg(m_tcpServer2->errorString());
        qCritical() << errorMsg;
        QMessageBox::critical(this, "网络错误", errorMsg);
        return;
    }
    connect(m_tcpServer2.get(), &QTcpServer::newConnection, 
            this, &MainWindow::handleNewConnection2);
    qInfo() << "辅助TCP服务器启动成功，端口: 7777";
}

void MainWindow::initializeVideoDecoder(int udpPort) {
    // 初始化视频显示标签
    ui->udp_ffmpeg->setAlignment(Qt::AlignCenter);
    ui->udp_ffmpeg->setSizePolicy(QSizePolicy::Ignored, QSizePolicy::Ignored);
    ui->udp_ffmpeg->setScaledContents(true);
    
    // 创建并配置解码器
    m_decoder = std::make_unique<FFmpegDecoder>(udpPort, this);
    connect(m_decoder.get(), &FFmpegDecoder::frameReceived,
            this, &MainWindow::onFrameReceived);
    connect(ui->cencel, &QPushButton::clicked,
            this, &MainWindow::on_cencel_clicked);
    
    // 自动启动解码器
    m_decoder->start();
    qInfo() << "视频解码器启动，UDP端口:" << udpPort;
}

void MainWindow::initializeTimers() {
    connect(m_updateTimer.get(), &QTimer::timeout, 
            this, &MainWindow::updatePlots);
    m_updateTimer->start(UPDATE_INTERVAL_MS);
    qInfo() << "定时器启动，更新间隔:" << UPDATE_INTERVAL_MS << "ms";
}

// 数据管理辅助方法的模板特化实现
template<typename T>
void MainWindow::appendDataWithLimit(QVector<T>& container, const T& value, int maxSize) {
    container.append(value);
    if (container.size() > maxSize) {
        container.removeFirst();
    }
}

void MainWindow::setupMapCanvas()
{
    // 清除原有布局
    if (ui->widget_2->layout()) {
        delete ui->widget_2->layout();
    }

    m_mapCanvas.reset(new MapCanvas(ui->widget_2));
    m_mapCanvas->setHighPrecisionMode(true, 8); // 启用高精度模式，小数点后8位
    m_mapCanvas->setGridVisible(true);

    // 设置布局
    QHBoxLayout *layout = new QHBoxLayout(ui->widget_2);
    layout->setContentsMargins(0, 0, 0, 0);
    // 使用get()获取unique_ptr的裸指针
    layout->addWidget(m_mapCanvas.get());
    ui->widget_2->setLayout(layout);
}

// 定义一个设置图表为黑色背景的函数
void MainWindow::setupPlotWithBlackBackground(QCustomPlot *plot) {
    // 设置图表整体背景为黑色
    plot->setBackground(QBrush(Qt::black));

    // 设置坐标轴矩形区域背景为黑色
    plot->axisRect()->setBackground(QBrush(Qt::black));

    // 设置坐标轴标签为白色
    plot->xAxis->setLabelColor(Qt::white);
    plot->yAxis->setLabelColor(Qt::white);

    // 设置坐标轴刻度为白色
    plot->xAxis->setTickLabelColor(Qt::white);
    plot->yAxis->setTickLabelColor(Qt::white);

    // 设置坐标轴为白色
    plot->xAxis->setBasePen(QPen(Qt::white));
    plot->yAxis->setBasePen(QPen(Qt::white));
    plot->xAxis->setTickPen(QPen(Qt::white));
    plot->yAxis->setTickPen(QPen(Qt::white));
    plot->xAxis->setSubTickPen(QPen(Qt::white));
    plot->yAxis->setSubTickPen(QPen(Qt::white));

    // 设置图例文字为白色
    if (plot->legend->visible()) {
        plot->legend->setTextColor(Qt::white);
    }
}

void MainWindow::onFrameReceived(QImage frame)
{
    // 调试打印（每秒一次）
    static int frameCount = 0;

    if(frameCount >= 250) {
        // ui->udp_ffmpeg->setText(QString("FPS: %1").arg(fps, 0, 'f', 1));
        frameCount = 0;
    }
    frameCount++;

    // 显示图像（使用硬件加速）
    QPixmap pix = QPixmap::fromImage(frame);
    if(!pix.isNull()){
        ui->udp_ffmpeg->setPixmap(pix);
        ui->udp_ffmpeg->setScaledContents(true);
    } else {
        qWarning() << "[MainWindow] Received invalid frame!";
    }
}

void MainWindow::on_cencel_clicked()
{
    // 确认对话框
    auto reply = QMessageBox::question(
        this,
        "关闭连接",
        "确定要关闭视频连接吗？",
        QMessageBox::Yes | QMessageBox::No
        );

    if(reply == QMessageBox::Yes && m_decoder) {
        m_decoder->stop();
        ui->udp_ffmpeg->clear();
        qDebug() << "Video connection closed";
    }
}

void MainWindow::on_start_clicked()
{
    m_decoder->start();
    QMessageBox::information(this, "连接状态", "成功建立连接");
}

// 改进的协议解析核心逻辑
void MainWindow::parseCustomProtocol(const QByteArray &data, const QString &parse_mode) {
    if (data.isEmpty()) {
        qWarning() << "接收到空数据";
        return;
    }
    
    if (parse_mode == "JSON") {
        parseJsonProtocol(data);
        return;
    }
    
    // 默认使用二进制协议解析
    m_receiveBuffer.append(data);
    
    while (m_receiveBuffer.size() >= MIN_FRAME_SIZE) {
        if (!processNextFrame()) {
            break;  // 数据不完整，等待更多数据
        }
    }
}

bool MainWindow::processNextFrame() {
    // 查找帧头
    int headerPos = findFrameHeader();
    if (headerPos < 0) {
        qWarning() << "未找到帧头，清空缓冲区";
        m_receiveBuffer.clear();
        return false;
    }
    
    // 移除帧头前的无效数据
    if (headerPos > 0) {
        m_receiveBuffer.remove(0, headerPos);
    }
    
    // 验证帧完整性
    if (m_receiveBuffer.size() < MIN_FRAME_SIZE) {
        return false; // 等待更多数据
    }
    
    uint8_t dataLength = static_cast<uint8_t>(m_receiveBuffer[2]);
    int totalFrameSize = 2 + 1 + dataLength + 1 + 1; // 头(2) + 长度(1) + 数据(N) + 校验(1) + 尾(1)
    
    if (m_receiveBuffer.size() < totalFrameSize) {
        return false; // 数据不完整
    }
    
    // 提取完整帧
    QByteArray frame = m_receiveBuffer.left(totalFrameSize);
    m_receiveBuffer.remove(0, totalFrameSize);
    
    // 验证校验和和帧尾
    if (!validateFrameIntegrity(frame)) {
        qWarning() << "帧校验失败";
        return true; // 继续处理下一帧
    }
    
    // 解析帧数据
    return parseFrameData(frame);
}

int MainWindow::findFrameHeader() {
    // 查找标准帧头 0xEE 0xFF
    int headerPos = m_receiveBuffer.indexOf(QByteArray(2, '\0').replace(0, FRAME_HEADER_1).replace(1, FRAME_HEADER_2));
    return headerPos;
}

bool MainWindow::validateFrameIntegrity(const QByteArray &frame) {
    // 检查帧尾
    if (static_cast<uint8_t>(frame[frame.size()-1]) != FRAME_FOOTER) {
        return false;
    }
    
    // 检查校验和
    return validateChecksum(frame);
}

bool MainWindow::parseFrameData(const QByteArray &frame) {
    const uint8_t* dataPtr = reinterpret_cast<const uint8_t*>(frame.constData() + 3);
    
    // 解析传感器数据
    SensorData sensorData = extractSensorData(dataPtr);
    
    // 更新UI显示
    updateVehicleDataDisplays(
        sensorData.lateralVel, sensorData.longitudinalVel, sensorData.rpm,
        sensorData.angle, sensorData.odomX, sensorData.odomY);
    
    // 检查GPS数据是否需要更新
    bool needGpsUpdate = shouldUpdateGpsData(sensorData.latitude, sensorData.longitude);
    
    // 使用智能指针和现代变量名存储数据
    storeDataWithLimit(sensorData);
    
    // 应用数据限制
    applySensorDataLimits(sensorData);
    
    // 更新仪表盘
    updateGauges(sensorData);
    
    // 条件性更新GPS相关显示
    if (needGpsUpdate) {
        m_mapCanvas->addPoint(sensorData.latitude, sensorData.longitude);
        updateGpsTable(m_timeData.last(), sensorData.latitude, sensorData.longitude);
    }
    
    return true;
}

// JSON协议解析函数
/***********************************
JSON数据示例
{
  "_id": {
    "$oid": "6850f699993d67cde0fb9505"
  },
  "imu": {
    "orientation": {
      "x": -0.0014248318797614053,
      "y": 0.0006354897787555261,
      "z": -0.7253289002418698,
      "w": -0.6884007568143763
    },
    "angular_velocity": {
      "x": -0.001195745076984167,
      "y": 0.00018730969168245792,
      "z": -0.0005574872484430671
    },
    "linear_acceleration": {
      "x": -0.03387652337551117,
      "y": -0.016141166910529137,
      "z": -9.754646301269531
    }
  },
  "vehicle": {
    "motor_rpm_avg": 0,
    "steering_angle": 0,
    "linear_velocity": 0
  },
  "odometry": {
    "angular_z": 0,
    "position": {
      "x": 0,
      "y": 0
    }
  },
  "gps": {
    "latitude": 0,
    "longitude": 0
  },
  "timestamp": "2025-06-17T13:01:13.935770",
  "inserted_at": {
    "$date": "2025-06-17T13:01:13.915Z"
  }
}
**************************/
void MainWindow::parseJsonProtocol(const QByteArray &data) {
    QJsonParseError parseError;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(data, &parseError);
    
    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON解析错误:" << parseError.errorString();
        return;
    }
    
    if (!jsonDoc.isObject()) {
        qWarning() << "JSON数据格式错误：不是有效的对象";
        return;
    }
    
    QJsonObject jsonObj = jsonDoc.object();
    
    // 创建传感器数据结构
    SensorData sensorData;
    
    // 解析IMU数据
    if (jsonObj.contains("imu") && jsonObj["imu"].isObject()) {
        QJsonObject imuObj = jsonObj["imu"].toObject();
        
        // 解析四元数
        if (imuObj.contains("orientation") && imuObj["orientation"].isObject()) {
            QJsonObject orientationObj = imuObj["orientation"].toObject();
            sensorData.orientationX = orientationObj["x"].toDouble();
            sensorData.orientationY = orientationObj["y"].toDouble();
            sensorData.orientationZ = orientationObj["z"].toDouble();
            sensorData.orientationW = orientationObj["w"].toDouble();
        }
        
        // 解析角速度
        if (imuObj.contains("angular_velocity") && imuObj["angular_velocity"].isObject()) {
            QJsonObject angularVelObj = imuObj["angular_velocity"].toObject();
            sensorData.angularVelX = angularVelObj["x"].toDouble();
            sensorData.angularVelY = angularVelObj["y"].toDouble();
        }
        
        // 解析线性加速度
        if (imuObj.contains("linear_acceleration") && imuObj["linear_acceleration"].isObject()) {
            QJsonObject linearAccObj = imuObj["linear_acceleration"].toObject();
            sensorData.linearAccX = linearAccObj["x"].toDouble();
            sensorData.linearAccY = linearAccObj["y"].toDouble();
        }
    }
    
    // 解析车辆数据
    if (jsonObj.contains("vehicle") && jsonObj["vehicle"].isObject()) {
        QJsonObject vehicleObj = jsonObj["vehicle"].toObject();
        sensorData.rpm = vehicleObj["motor_rpm_avg"].toDouble();
        sensorData.angle = vehicleObj["steering_angle"].toDouble();
        sensorData.longitudinalVel = vehicleObj["linear_velocity"].toDouble();
        sensorData.lateralVel = 0.0; // JSON中没有横向速度，设为0
    }
    
    // 解析里程计数据
    if (jsonObj.contains("odometry") && jsonObj["odometry"].isObject()) {
        QJsonObject odomObj = jsonObj["odometry"].toObject();
        if (odomObj.contains("position") && odomObj["position"].isObject()) {
            QJsonObject positionObj = odomObj["position"].toObject();
            sensorData.odomX = positionObj["x"].toDouble();
            sensorData.odomY = positionObj["y"].toDouble();
        }
    }
    
    // 解析GPS数据
    if (jsonObj.contains("gps") && jsonObj["gps"].isObject()) {
        QJsonObject gpsObj = jsonObj["gps"].toObject();
        sensorData.latitude = gpsObj["latitude"].toDouble();
        sensorData.longitude = gpsObj["longitude"].toDouble();
    }
    
    // 设置时间戳
    sensorData.timestamp = m_timer.elapsed() / 1000.0;
    
    // 更新UI显示
    updateVehicleDataDisplays(
        sensorData.lateralVel, sensorData.longitudinalVel, sensorData.rpm,
        sensorData.angle, sensorData.odomX, sensorData.odomY);
    
    // 检查GPS数据是否需要更新
    bool needGpsUpdate = shouldUpdateGpsData(sensorData.latitude, sensorData.longitude);
    
    // 存储数据
    storeDataWithLimit(sensorData);
    
    // 应用数据限制
    applySensorDataLimits(sensorData);
    
    // 更新仪表盘
    updateGauges(sensorData);
    
    // 条件性更新GPS相关显示
    if (needGpsUpdate) {
        m_mapCanvas->addPoint(sensorData.latitude, sensorData.longitude);
        updateGpsTable(m_timeData.last(), sensorData.latitude, sensorData.longitude);
    }
}

MainWindow::SensorData MainWindow::extractSensorData(const uint8_t* dataPtr) {
    SensorData data;
    
    // IMU四元数数据
    data.orientationX = bytesToScaledFloat(dataPtr, IMU_ORIENTATION_SCALE);
    data.orientationY = bytesToScaledFloat(dataPtr + 2, IMU_ORIENTATION_SCALE);
    data.orientationZ = bytesToScaledFloat(dataPtr + 4, IMU_ORIENTATION_SCALE);
    data.orientationW = bytesToScaledFloat(dataPtr + 6, IMU_ORIENTATION_SCALE);
    
    // IMU角速度数据
    data.angularVelX = bytesToScaledFloat(dataPtr + 8, IMU_ANGULAR_VEL_SCALE);
    data.angularVelY = bytesToScaledFloat(dataPtr + 10, IMU_ANGULAR_VEL_SCALE);
    
    // IMU线性加速度数据
    data.linearAccX = bytesToScaledFloat(dataPtr + 12, IMU_LINEAR_ACC_SCALE);
    data.linearAccY = bytesToScaledFloat(dataPtr + 14, IMU_LINEAR_ACC_SCALE);
    
    // 车辆状态数据
    data.rpm = bytesToScaledFloat(dataPtr + 16, CAR_RPM_SCALE);
    data.angle = bytesToScaledFloat(dataPtr + 18, CAR_ANGLE_SCALE);
    data.longitudinalVel = bytesToScaledFloat(dataPtr + 20, CAR_ANGLE_SCALE);
    data.lateralVel = bytesToScaledFloat(dataPtr + 22, CAR_ANGLE_SCALE);
    
    // 里程计数据
    data.odomX = bytesToScaledFloat(dataPtr + 24, 100.0f);
    data.odomY = bytesToScaledFloat(dataPtr + 26, 100.0f);
    
    // GPS数据
    data.latitude = bytesToScaledDouble(dataPtr + 28, GPS_COORDINATE_SCALE);
    data.longitude = bytesToScaledDouble(dataPtr + 36, GPS_COORDINATE_SCALE);
    
    // 时间戳
    data.timestamp = m_timer.elapsed() / 1000.0;
    
    return data;
}

bool MainWindow::shouldUpdateGpsData(double latitude, double longitude) {
    if (m_gpsLatitude.isEmpty()) {
        return true; // 第一次接收数据
    }
    
    // 检查GPS坐标是否有显著变化
    double latDiff = std::abs(latitude - m_gpsLatitude.last());
    double lonDiff = std::abs(longitude - m_gpsLongitude.last());
    
    return (latDiff > FLOAT_COMPARISON_EPSILON || lonDiff > FLOAT_COMPARISON_EPSILON);
}

void MainWindow::storeDataWithLimit(const SensorData& data) {
    // 使用模板方法管理数据存储
    appendDataWithLimit(m_imuOrientationX, data.orientationX);
    appendDataWithLimit(m_imuOrientationY, data.orientationY);
    appendDataWithLimit(m_imuOrientationZ, data.orientationZ);
    appendDataWithLimit(m_imuOrientationW, data.orientationW);
    
    appendDataWithLimit(m_imuAngularVelX, data.angularVelX);
    appendDataWithLimit(m_imuAngularVelY, data.angularVelY);
    
    appendDataWithLimit(m_imuLinearAccX, data.linearAccX);
    appendDataWithLimit(m_imuLinearAccY, data.linearAccY);
    
    appendDataWithLimit(m_carRpm, data.rpm);
    appendDataWithLimit(m_carAngle, data.angle);
    appendDataWithLimit(m_carLongitudinalVel, data.longitudinalVel);
    appendDataWithLimit(m_carLateralVel, data.lateralVel);
    
    appendDataWithLimit(m_odomPoseX, data.odomX);
    appendDataWithLimit(m_odomPoseY, data.odomY);
    
    appendDataWithLimit(m_gpsLatitude, data.latitude);
    appendDataWithLimit(m_gpsLongitude, data.longitude);
    
    appendDataWithLimit(m_timeData, data.timestamp);
}

void MainWindow::applySensorDataLimits(SensorData& data) {
    data.longitudinalVel = qBound(SPEED_LIMIT_MIN, data.longitudinalVel, SPEED_LIMIT_MAX);
    data.angle = qBound(ANGLE_LIMIT_MIN, data.angle, ANGLE_LIMIT_MAX);
}

void MainWindow::updateGauges(const SensorData& data) {
    if (m_rpmGauge) {
        m_rpmGauge->setExpectNum(data.longitudinalVel);
    }
    if (m_angleGauge) {
        m_angleGauge->setExpectNum(data.angle * 10 * -1.0);
    }
}

void MainWindow::updateVehicleDataDisplays(
    double av, double lv, double rpm,
    double angle, double odomX, double odomY)
{
    // 定义格式化函数
    auto formatValue = [](double value) {
        return QString::number(value, 'f', DECIMAL_PLACES);
    };
    
    bool needUpdate = false;

    // 检查横向速度是否需要更新
    if (std::abs(av - m_lastValues.lateralVel) > FLOAT_COMPARISON_EPSILON) {
        ui->Transerve_val->setText(formatValue(av));
        m_lastValues.lateralVel = av;
        needUpdate = true;
    }

    // 检查纵向速度是否需要更新
    if (std::abs(lv - m_lastValues.longitudinalVel) > FLOAT_COMPARISON_EPSILON) {
        ui->Longitudinal_val->setText(formatValue(lv));
        m_lastValues.longitudinalVel = lv;
        needUpdate = true;
    }

    // 检查RPM是否需要更新
    if (std::abs(rpm - m_lastValues.rpm) > FLOAT_COMPARISON_EPSILON) {
        ui->wheel_rpm->setText(formatValue(rpm));
        m_lastValues.rpm = rpm;
        needUpdate = true;
    }

    // 检查角度是否需要更新
    if (std::abs(angle - m_lastValues.angle) > FLOAT_COMPARISON_EPSILON) {
        ui->wheel_angle->setText(formatValue(angle));
        m_lastValues.angle = angle;
        needUpdate = true;
    }

    // 检查里程计X是否需要更新
    if (std::abs(odomX - m_lastValues.odomX) > FLOAT_COMPARISON_EPSILON) {
        ui->wheel_angle_2->setText(formatValue(odomX));
        m_lastValues.odomX = odomX;
        needUpdate = true;
    }

    // 检查里程计Y是否需要更新
    if (std::abs(odomY - m_lastValues.odomY) > FLOAT_COMPARISON_EPSILON) {
        ui->wheel_angle_3->setText(formatValue(odomY));
        m_lastValues.odomY = odomY;
        needUpdate = true;
    }

    // 计算行驶距离
    double distance = std::sqrt(odomX * odomX + odomY * odomY);
    if (std::abs(distance - m_lastValues.distance) > FLOAT_COMPARISON_EPSILON) {
        ui->wheel_angle_4->setText(formatValue(distance));
        m_lastValues.distance = distance;
        needUpdate = true;
    }
    
    // 延迟批量更新UI
    if (needUpdate && !m_uiUpdatePending) {
        m_uiUpdatePending = true;
        QTimer::singleShot(10, this, [this]() {
            update();
            m_uiUpdatePending = false;
        });
    }
}

void MainWindow::updateGpsTable(double time, double latitude, double longitude) {
    QTableWidget *table = ui->tableWidget;
    const int maxRows = table->rowCount(); // 获取最大行数（14行）

    // 1. 查找第一个空行（初始插入时使用）
    int firstEmptyRow = -1;
    for (int row = 0; row < maxRows; ++row) {
        if (!table->item(row, 0) || table->item(row, 0)->text().isEmpty()) {
            firstEmptyRow = row;
            break;
        }
    }

    // 2. 两种情况处理
    if (firstEmptyRow != -1) {
        // 情况A：表格未满，在第一个空行插入
        if (!table->item(firstEmptyRow, 0)) {
            table->setItem(firstEmptyRow, 0, new QTableWidgetItem);
            table->setItem(firstEmptyRow, 1, new QTableWidgetItem);
            table->setItem(firstEmptyRow, 2, new QTableWidgetItem);
        }
        table->item(firstEmptyRow, 0)->setText(QString::number(time, 'f', 3));
        table->item(firstEmptyRow, 1)->setText(QString::number(latitude, 'f', 8));
        table->item(firstEmptyRow, 2)->setText(QString::number(longitude, 'f', 8));
    } else {
        // 情况B：表格已满，上移所有行
        // 先移除首行
        table->removeRow(0);
        // 在末尾添加新行
        table->insertRow(maxRows - 1);
        table->setItem(maxRows - 1, 0, new QTableWidgetItem(QString::number(time, 'f', 3)));
        table->setItem(maxRows - 1, 1, new QTableWidgetItem(QString::number(latitude, 'f', 8)));
        table->setItem(maxRows - 1, 2, new QTableWidgetItem(QString::number(longitude, 'f', 8)));
    }

    // 3. 自动滚动并高亮最新数据
    table->scrollToBottom();
    if (firstEmptyRow != -1) {
        table->item(firstEmptyRow, 0)->setBackground(QColor(100, 200, 150)); // 高亮新数据
    } else {
        table->item(maxRows - 1, 0)->setBackground(QColor(100, 200, 150));
    }
}

bool MainWindow::validateChecksum(const QByteArray &frame) {
    uint8_t checksum = static_cast<uint8_t>(frame[2]); // 长度字段
    const uint8_t* dataStart = reinterpret_cast<const uint8_t*>(frame.constData() + 3);
    int dataLength = static_cast<uint8_t>(frame[2]);
    // 从长度字段到最后一个字段结束，即不包括帧头帧尾
    for (int i = 0; i < dataLength; ++i) {
        // 异或累积
        checksum ^= dataStart[i];
    }

    return checksum == static_cast<uint8_t>(frame[frame.size()-2]);
}

uint16_t MainWindow::bytesToUInt16(const uint8_t* bytes) {
    return (static_cast<uint16_t>(bytes[0]) << 8) | bytes[1];
}


void MainWindow::updatePlots() {
    if (m_timeData.isEmpty()) return;

    static int updateCounter = 0;
    updateCounter++;
    
    // 降低更新频率，每3次调用才真正更新
    if (updateCounter % 3 != 0) {
        return;
    }

    double currentTime = m_timeData.last();
    double timeWindow = TIME_WINDOW_SECONDS;

    // ================== 更新IMU数据曲线 ==================
    // 四元数曲线 - 使用新的变量名
    m_imuQuatPlot->graph(0)->setData(m_timeData, m_imuOrientationX);
    m_imuQuatPlot->graph(1)->setData(m_timeData, m_imuOrientationY);
    m_imuQuatPlot->graph(2)->setData(m_timeData, m_imuOrientationZ);
    m_imuQuatPlot->graph(3)->setData(m_timeData, m_imuOrientationW);
    m_imuQuatPlot->xAxis->setRange(currentTime - timeWindow, currentTime);
    m_imuQuatPlot->yAxis->rescale();
    m_imuQuatPlot->replot(QCustomPlot::rpQueuedReplot);

    // 角速度曲线
    m_imuAngularVelPlot->graph(0)->setData(m_timeData, m_imuAngularVelX);
    m_imuAngularVelPlot->graph(1)->setData(m_timeData, m_imuAngularVelY);
    m_imuAngularVelPlot->xAxis->setRange(currentTime - timeWindow, currentTime);
    m_imuAngularVelPlot->yAxis->rescale();
    m_imuAngularVelPlot->replot(QCustomPlot::rpQueuedReplot);

    // 线性加速度曲线
    m_imuLinearAccPlot->graph(0)->setData(m_timeData, m_imuLinearAccX);
    m_imuLinearAccPlot->graph(1)->setData(m_timeData, m_imuLinearAccY);
    m_imuLinearAccPlot->xAxis->setRange(currentTime - timeWindow, currentTime);
    m_imuLinearAccPlot->yAxis->rescale();
    m_imuLinearAccPlot->replot(QCustomPlot::rpQueuedReplot);

    // ================== 更新车辆数据曲线 ==================
    // 转速曲线
    m_carRpmPlot->graph(0)->setData(m_timeData, m_carRpm);
    m_carRpmPlot->xAxis->setRange(currentTime - timeWindow, currentTime);
    m_carRpmPlot->yAxis->rescale();
    m_carRpmPlot->replot(QCustomPlot::rpQueuedReplot);

    // 转向角曲线
    m_carAnglePlot->graph(0)->setData(m_timeData, m_carAngle);
    m_carAnglePlot->xAxis->setRange(currentTime - timeWindow, currentTime);
    m_carAnglePlot->yAxis->rescale();
    m_carAnglePlot->replot(QCustomPlot::rpQueuedReplot);
    
    // 速度曲线
    m_carVelPlot->graph(0)->setData(m_timeData, m_carLongitudinalVel);
    m_carVelPlot->graph(1)->setData(m_timeData, m_carLateralVel);
    m_carVelPlot->xAxis->setRange(currentTime - timeWindow, currentTime);
    m_carVelPlot->yAxis->rescale();
    m_carVelPlot->replot(QCustomPlot::rpQueuedReplot);
}

void MainWindow::handleNewConnection() {
    m_clientSocket = m_tcpServer->nextPendingConnection();
    connect(m_clientSocket, &QTcpSocket::readyRead, this, &MainWindow::readClientData);
    connect(m_clientSocket, &QTcpSocket::disconnected, [this]() {
        m_clientSocket->deleteLater();
        m_clientSocket = nullptr;
    });
}

void MainWindow::readClientData() {
    QByteArray data = m_clientSocket->readAll();
    parseCustomProtocol(data, m_parseMode);
}

void MainWindow::handleNewConnection2() {
    QMutexLocker locker(&m_bufferMutex);

    if (!m_tcpServer2) return;  // 双重检查

    m_clientSocket2 = m_tcpServer2->nextPendingConnection();
    if (!m_clientSocket2) return;

    // 使用lambda捕获this指针需要确保生命周期
    connect(m_clientSocket2, &QTcpSocket::readyRead, this, [this]() {
        if (m_clientSocket2 && m_clientSocket2->bytesAvailable() > 0) {
            QByteArray data = m_clientSocket2->readAll();
            parseNewProtocol(data);
        }
    }, Qt::QueuedConnection);  // 确保线程安全

    connect(m_clientSocket2, &QTcpSocket::disconnected, this, [this]() {
        QMutexLocker locker(&m_bufferMutex);
        if (m_clientSocket2) {
            m_clientSocket2->deleteLater();
            m_clientSocket2 = nullptr;
        }
    }, Qt::QueuedConnection);
}

void MainWindow::readClientData2() {
    QByteArray data = m_clientSocket2->readAll();
    parseNewProtocol(data);
}

void MainWindow::parseNewProtocol(const QByteArray &data) {
    QMutexLocker locker(&m_bufferMutex);

    // 安全边界检查
    if (data.isEmpty() || m_receiveBuffer2.size() > 10 * 1024 * 1024) { // 限制缓冲区10MB
        m_receiveBuffer2.clear();
        return;
    }

    m_receiveBuffer2.append(data);

    while (m_receiveBuffer2.size() >= 5) {
        // 帧头检查
        if (!m_receiveBuffer2.startsWith("\x48\x4C")) {
            m_receiveBuffer2.remove(0, 1);
            continue;
        }

        // 长度检查
        uint8_t dataLength = static_cast<uint8_t>(m_receiveBuffer2[2]);
        if (dataLength == 0 || dataLength > 255) {  // 假设最大255字节
            m_receiveBuffer2.remove(0, 3);
            continue;
        }

        int totalFrameSize = 2 + 1 + dataLength + 1 + 1;
        if (m_receiveBuffer2.size() < totalFrameSize) return;

        // 提取帧数据
        QByteArray frame = m_receiveBuffer2.left(totalFrameSize);
        m_receiveBuffer2.remove(0, totalFrameSize);

        // 校验
        if (frame.size() < 5 || frame.back() != '\xDD' || !validateChecksum(frame)) {
            qDebug() << "无效帧被丢弃";
            continue;
        }

        // 解析数据
        const uint8_t* dataPtr = reinterpret_cast<const uint8_t*>(frame.constData() + 3);

        // 按照客户端发送顺序解析数据
        double front_distance = bytesToScaledFloat(dataPtr, 100.0f);
        double linear_velocity = bytesToScaledFloat(dataPtr + 2, 1000.0f);
        double angular_z = bytesToScaledFloat(dataPtr + 4, 1000.0f);
        double driver_state = bytesToScaledFloat(dataPtr + 6, 100.0f);
        double pos_x = bytesToScaledFloat(dataPtr + 8, 100.0f);
        double pos_y = bytesToScaledFloat(dataPtr + 10, 100.0f);

        // 线程安全更新UI
        QMetaObject::invokeMethod(this, [this, front_distance, linear_velocity, angular_z, driver_state, pos_x, pos_y]() {
            ui->Transerve_val_2->setText(QString::number(angular_z, 'f', 3));
            ui->Longitudinal_val_2->setText(QString::number(linear_velocity, 'f', 3));
            
            // 更新其他UI元素...
        });
    }
    
}


