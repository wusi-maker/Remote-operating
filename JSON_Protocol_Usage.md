# JSON协议解析使用说明

## 概述

本项目现在支持两种数据解析模式：
1. **BINARY模式**（默认）：解析二进制协议数据
2. **JSON模式**：解析JSON格式的传感器数据

## JSON数据格式

系统支持以下JSON数据结构：

```json
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
```

## 使用方法

### 1. 设置解析模式

```cpp
// 创建MainWindow实例
MainWindow window(8888, false, 9999);

// 设置为JSON解析模式
window.setParseMode("JSON");

// 或者设置为二进制解析模式（默认）
window.setParseMode("BINARY");
```

### 2. 检查当前解析模式

```cpp
QString currentMode = window.getParseMode();
qDebug() << "当前解析模式:" << currentMode;
```

### 3. 数据映射

JSON数据字段与系统内部数据的映射关系：

| JSON字段 | 系统变量 | 说明 |
|---------|---------|------|
| `imu.orientation.x/y/z/w` | `orientationX/Y/Z/W` | IMU四元数 |
| `imu.angular_velocity.x/y` | `angularVelX/Y` | IMU角速度 |
| `imu.linear_acceleration.x/y` | `linearAccX/Y` | IMU线性加速度 |
| `vehicle.motor_rpm_avg` | `rpm` | 电机转速 |
| `vehicle.steering_angle` | `angle` | 转向角度 |
| `vehicle.linear_velocity` | `longitudinalVel` | 纵向速度 |
| `odometry.position.x/y` | `odomX/Y` | 里程计位置 |
| `gps.latitude/longitude` | `latitude/longitude` | GPS坐标 |

## 注意事项

1. JSON模式下，横向速度（`lateralVel`）被设置为0，因为JSON数据中没有对应字段
2. 系统会自动验证JSON格式的有效性，无效的JSON数据会被忽略
3. 缺失的字段会使用默认值（通常为0）
4. 时间戳使用系统内部计时器，而不是JSON中的timestamp字段

## 错误处理

- JSON解析错误会在控制台输出警告信息
- 无效的JSON格式会被自动跳过
- 系统会继续等待下一个有效的数据包