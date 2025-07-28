# MongoDB数据订阅使用示例

本文档展示如何在项目中使用MongoDB数据订阅功能。

## 功能概述

项目现已支持从MongoDB数据库订阅最新数据，并自动解析JSON格式的传感器数据。当数据库中有新数据时，系统会自动获取并更新UI显示。

## 使用方法

### 1. 基本设置

```cpp
// 在main.cpp或其他初始化代码中
MainWindow window(8080, false, 9999);

// 设置MongoDB连接参数
window.setupMongoDBConnection(
    "localhost",        // MongoDB服务器地址
    27017,              // MongoDB端口
    "sensor_database",  // 数据库名称
    "sensor_data"       // 集合名称
);

// 设置查询间隔（可选，默认1000毫秒）
window.setMongoDBQueryInterval(2000); // 2秒查询一次

// 如果需要认证（可选）
window.setMongoDBAuthentication("username", "password");

// 启动数据订阅
window.startMongoDBSubscription();
```

### 2. 运行时控制

```cpp
// 检查连接状态
if (window.isMongoDBConnected()) {
    qDebug() << "MongoDB已连接";
}

// 停止订阅
window.stopMongoDBSubscription();

// 重新启动订阅
window.startMongoDBSubscription();
```

## MongoDB数据格式要求

数据库中的JSON文档应包含以下字段结构：

```json
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
```

## REST API配置

### 方式1：使用自定义REST API端点

```cpp
// 设置自定义REST API端点
window.m_mongoConnector->setRestApiEndpoint("http://your-api-server.com/api/latest-sensor-data");
```

### 方式2：使用标准MongoDB HTTP接口

如果您的MongoDB服务器启用了HTTP接口，系统会自动构建查询URL：
```
http://localhost:28017/api/v1/sensor_database/sensor_data/latest
```

## 时间戳处理

系统支持以下时间戳格式：

1. **ISO 8601格式**：
   ```json
   {"timestamp": "2024-01-15T10:30:45.123Z"}
   ```

2. **MongoDB日期格式**：
   ```json
   {"inserted_at": {"$date": "2024-01-15T10:30:45.123Z"}}
   ```

系统会自动检测数据是否比上次查询更新，只有新数据才会触发解析和UI更新。

## 错误处理

系统会自动处理以下错误情况：

- 网络连接失败
- JSON解析错误
- MongoDB服务器错误
- 认证失败

所有错误信息都会通过Qt的日志系统输出，您可以通过以下方式监听错误：

```cpp
// 错误信息会自动输出到控制台
// 也可以在onMongoError槽函数中添加自定义错误处理逻辑
```

## 性能优化建议

1. **合理设置查询间隔**：根据数据更新频率调整查询间隔，避免过于频繁的查询
2. **使用索引**：在MongoDB中为timestamp字段创建索引以提高查询性能
3. **限制数据大小**：确保返回的JSON文档大小合理，避免传输大量无用数据

## 注意事项

1. 启动MongoDB订阅时，系统会自动切换到JSON解析模式
2. 确保MongoDB服务器可访问且配置正确
3. 如果使用认证，请确保用户名和密码正确
4. 系统会从当前时间前1分钟开始查询，避免重复处理历史数据

## 故障排除

### 常见问题

1. **连接失败**：检查MongoDB服务器地址和端口是否正确
2. **认证失败**：验证用户名和密码是否正确
3. **数据格式错误**：确保JSON数据格式符合要求
4. **时间戳问题**：检查时间戳字段是否存在且格式正确

### 调试信息

系统会输出详细的调试信息，包括：
- 连接状态变化
- 查询请求和响应
- 数据解析结果
- 错误详情

通过查看控制台输出可以快速定位问题。