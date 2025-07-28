// MongoDB测试示例文件
// 此文件展示如何在应用程序中集成MongoDB数据订阅功能

#include <QApplication>
#include <QTimer>
#include <QDebug>
#include "mainwindow.h"

// 测试MongoDB连接和数据订阅的示例函数
void setupMongoDBTest(MainWindow* window) {
    qDebug() << "开始设置MongoDB测试...";
    
    // 1. 设置MongoDB连接参数
    // 请根据您的实际MongoDB配置修改以下参数
    QString mongoHost = "localhost";        // MongoDB服务器地址
    int mongoPort = 27017;                  // MongoDB端口
    QString database = "sensor_database";   // 数据库名称
    QString collection = "sensor_data";     // 集合名称
    
    window->setupMongoDBConnection(mongoHost, mongoPort, database, collection);
    
    // 2. 设置查询间隔（可选）
    // 设置为3秒查询一次，避免过于频繁的查询
    window->setMongoDBQueryInterval(3000);
    
    // 3. 如果MongoDB需要认证，取消注释以下行并设置正确的用户名和密码
    // window->setMongoDBAuthentication("your_username", "your_password");
    
    // 4. 延迟启动订阅，确保UI完全初始化
    QTimer::singleShot(2000, [window]() {
        qDebug() << "启动MongoDB数据订阅...";
        window->startMongoDBSubscription();
        
        // 检查连接状态
        QTimer::singleShot(5000, [window]() {
            if (window->isMongoDBConnected()) {
                qInfo() << "MongoDB连接成功！";
            } else {
                qWarning() << "MongoDB连接失败，请检查配置";
            }
        });
    });
}

// 如果您想要在main函数中使用MongoDB功能，可以参考以下代码：
/*
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    
    // 创建主窗口
    MainWindow window(8080, false, 9999);
    
    // 设置MongoDB测试
    setupMongoDBTest(&window);
    
    // 显示窗口
    window.show();
    
    return app.exec();
}
*/

// 模拟MongoDB数据的JSON示例
// 您可以将此数据插入到MongoDB中进行测试
const char* SAMPLE_JSON_DATA = R"(
{
  "timestamp": "2024-01-15T10:30:45.123Z",
  "imu": {
    "orientation": {
      "x": 0.123,
      "y": 0.456,
      "z": 0.789,
      "w": 0.987
    },
    "angular_velocity": {
      "x": 1.23,
      "y": 4.56
    },
    "linear_acceleration": {
      "x": 2.34,
      "y": 5.67
    }
  },
  "vehicle": {
    "rpm": 1500.5,
    "steering_angle": 15.2,
    "longitudinal_velocity": 12.5,
    "lateral_velocity": 0.8
  },
  "odometry": {
    "pose": {
      "x": 100.25,
      "y": 200.75
    }
  },
  "gps": {
    "latitude": 39.9042,
    "longitude": 116.4074
  }
}
)";

// MongoDB插入测试数据的示例命令（在MongoDB shell中执行）:
/*
use sensor_database
db.sensor_data.insertOne({
  "timestamp": new Date(),
  "imu": {
    "orientation": {"x": 0.123, "y": 0.456, "z": 0.789, "w": 0.987},
    "angular_velocity": {"x": 1.23, "y": 4.56},
    "linear_acceleration": {"x": 2.34, "y": 5.67}
  },
  "vehicle": {
    "rpm": 1500.5,
    "steering_angle": 15.2,
    "longitudinal_velocity": 12.5,
    "lateral_velocity": 0.8
  },
  "odometry": {
    "pose": {"x": 100.25, "y": 200.75}
  },
  "gps": {
    "latitude": 39.9042,
    "longitude": 116.4074
  }
})
*/

// 测试REST API的curl命令示例：
/*
# 如果您有自定义的REST API端点，可以使用以下命令测试：
curl -X GET "http://localhost:28017/api/v1/sensor_database/sensor_data/latest" \
     -H "Content-Type: application/json"

# 或者测试带认证的请求：
curl -X GET "http://localhost:28017/api/v1/sensor_database/sensor_data/latest" \
     -H "Content-Type: application/json" \
     -u "username:password"
*/