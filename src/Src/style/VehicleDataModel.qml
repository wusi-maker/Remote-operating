import QtQuick 2.15

QtObject {
    id: vehicleDataModel
    
    // 基本信息属性
    property string dataType: ""
    property string hunterID: ""
    property string timestamp: ""
    // 标识是否为测试数据模型
    property bool testFlag: false
    
    // IMU数据属性
    property QtObject imu: QtObject {
        // 方向四元数
        property QtObject orientation: QtObject {
            property real x: 0.0
            property real y: 0.0
            property real z: 0.0
            property real w: 0.0
        }
        
        // 角速度
        property QtObject angular_velocity: QtObject {
            property real x: 0.0
            property real y: 0.0
            property real z: 0.0
        }
        
        // 线性加速度
        property QtObject linear_acceleration: QtObject {
            property real x: 0.0
            property real y: 0.0
            property real z: 0.0
        }
    }
    
    // 车辆数据属性
    property QtObject vehicle: QtObject {
        property real motor_rpm_avg: 0.0
        property real steering_angle: 0.0
        property real linear_velocity: 0.0
        property real battery_level: 0.0
    }
    
    // 里程计数据属性
    property QtObject odometry: QtObject {
        property real angular_z: 0.0
        property QtObject position: QtObject {
            property real x: 0.0
            property real y: 0.0
        }
    }
    
    // GPS数据属性
    property QtObject gps: QtObject {
        property real latitude: 0.0
        property real longitude: 0.0
    }
    
    // 辅助方法：从JSON数据更新车辆状态
    function updateFromJSON(jsonData) {
        try {
            // 如果传入的是字符串，先解析为对象
            var parsedData = jsonData
            if (typeof jsonData === "string") {
                // console.log("VehicleDataModel: 检测到字符串类型，开始解析JSON")
                parsedData = JSON.parse(jsonData)
                // console.log("VehicleDataModel: JSON解析完成，解析后的数据:", JSON.stringify(parsedData))
            }
            
            // 计算数据变化差值总和
            var totalDiff = 0.0
            
            // IMU数据差异
            if (parsedData.imu) {
                if (parsedData.imu.orientation) {
                    totalDiff += Math.abs(imu.orientation.x - (parsedData.imu.orientation.x || 0))
                    totalDiff += Math.abs(imu.orientation.y - (parsedData.imu.orientation.y || 0))
                    totalDiff += Math.abs(imu.orientation.z - (parsedData.imu.orientation.z || 0))
                    totalDiff += Math.abs(imu.orientation.w - (parsedData.imu.orientation.w || 0))
                }
                if (parsedData.imu.angular_velocity) {
                    totalDiff += Math.abs(imu.angular_velocity.x - (parsedData.imu.angular_velocity.x || 0))
                    totalDiff += Math.abs(imu.angular_velocity.y - (parsedData.imu.angular_velocity.y || 0))
                    totalDiff += Math.abs(imu.angular_velocity.z - (parsedData.imu.angular_velocity.z || 0))
                }
                if (parsedData.imu.linear_acceleration) {
                    totalDiff += Math.abs(imu.linear_acceleration.x - (parsedData.imu.linear_acceleration.x || 0))
                    totalDiff += Math.abs(imu.linear_acceleration.y - (parsedData.imu.linear_acceleration.y || 0))
                    totalDiff += Math.abs(imu.linear_acceleration.z - (parsedData.imu.linear_acceleration.z || 0))
                }
            }
            
            // 车辆数据差异
            if (parsedData.vehicle) {
                totalDiff += Math.abs(vehicle.motor_rpm_avg - (parsedData.vehicle.motor_rpm_avg || 0))
                totalDiff += Math.abs(vehicle.steering_angle - (parsedData.vehicle.steering_angle || 0))
                totalDiff += Math.abs(vehicle.linear_velocity - (parsedData.vehicle.linear_velocity || 0))
                if (parsedData.vehicle.battery_level !== undefined) {
                    totalDiff += Math.abs(vehicle.battery_level - (parsedData.vehicle.battery_level || 0))
                }
            }
            
            // 里程计数据差异
            if (parsedData.odometry) {
                totalDiff += Math.abs(odometry.angular_z - (parsedData.odometry.angular_z || 0))
                if (parsedData.odometry.position) {
                    totalDiff += Math.abs(odometry.position.x - (parsedData.odometry.position.x || 0))
                    totalDiff += Math.abs(odometry.position.y - (parsedData.odometry.position.y || 0))
                }
            }
            
            // GPS数据差异
            if (parsedData.gps) {
                totalDiff += Math.abs(gps.latitude - (parsedData.gps.latitude || 0))
                totalDiff += Math.abs(gps.longitude - (parsedData.gps.longitude || 0))
            }
            
            // 检查是否存在有效的GPS数据（非零）
            var hasValidGPS = false
            if (parsedData.gps) {
                var lat = parsedData.gps.latitude || 0
                var lon = parsedData.gps.longitude || 0
                if (Math.abs(lat) > 0.00000001 || Math.abs(lon) > 0.0000001) {
                    hasValidGPS = true
                }
            }

            // 只有当数据有变化，或者存在有效GPS数据时，才更新本地接收时间
            // 使用一个很小的阈值来处理浮点数精度问题
            if (totalDiff > 0.0001 || hasValidGPS) {
                lastUpdateLocalTime = new Date().getTime()
            } else {
                // console.log("VehicleDataModel: 数据未发生变化，视为无效更新")
            }

            // console.log("VehicleDataModel: parsedData所有属性:", Object.keys(parsedData))
            
            // 更新基本信息
            if (parsedData.DataType !== undefined) {
                dataType = parsedData.DataType
                // console.log("VehicleDataModel: 设置 dataType =", dataType)
            }
            if (parsedData.hunterID !== undefined) {
                hunterID = parsedData.hunterID
                // console.log("VehicleDataModel: 设置 hunterID =", hunterID)
            }
            if (parsedData.timestamp !== undefined) {
                timestamp = parsedData.timestamp
                // console.log("VehicleDataModel: 设置 timestamp =", timestamp)
            }
            
            // 更新IMU数据
            // console.log("VehicleDataModel: 检查IMU数据存在性:", parsedData.imu, typeof parsedData.imu)
            if (parsedData.imu) {
                // console.log("VehicleDataModel: 处理IMU数据")
                if (parsedData.imu.orientation) {
                    imu.orientation.x = parsedData.imu.orientation.x
                    imu.orientation.y = parsedData.imu.orientation.y
                    imu.orientation.z = parsedData.imu.orientation.z
                    imu.orientation.w = parsedData.imu.orientation.w
                    // console.log("VehicleDataModel: 设置orientation =", imu.orientation.x, imu.orientation.y, imu.orientation.z, imu.orientation.w)
                }
                
                if (parsedData.imu.angular_velocity) {
                    imu.angular_velocity.x = parsedData.imu.angular_velocity.x
                    imu.angular_velocity.y = parsedData.imu.angular_velocity.y
                    imu.angular_velocity.z = parsedData.imu.angular_velocity.z
                    // console.log("VehicleDataModel: 设置angular_velocity =", imu.angular_velocity.x, imu.angular_velocity.y, imu.angular_velocity.z)
                }
                
                if (parsedData.imu.linear_acceleration) {
                    imu.linear_acceleration.x = parsedData.imu.linear_acceleration.x
                    imu.linear_acceleration.y = parsedData.imu.linear_acceleration.y
                    imu.linear_acceleration.z = parsedData.imu.linear_acceleration.z
                    // console.log("VehicleDataModel: 设置linear_acceleration =", imu.linear_acceleration.x, imu.linear_acceleration.y, imu.linear_acceleration.z)
                }
            }
            
            // 更新车辆数据
            // console.log("VehicleDataModel: 检查vehicle数据存在性:", parsedData.vehicle, typeof parsedData.vehicle)
            if (parsedData.vehicle) {
                // console.log("VehicleDataModel: 处理vehicle数据")
                vehicle.motor_rpm_avg = parsedData.vehicle.motor_rpm_avg
                vehicle.steering_angle = parsedData.vehicle.steering_angle
                vehicle.linear_velocity = parsedData.vehicle.linear_velocity
                if (parsedData.vehicle.battery_level !== undefined) {
                    vehicle.battery_level = parsedData.vehicle.battery_level
                }
                // console.log("VehicleDataModel: 设置vehicle =", vehicle.motor_rpm_avg, vehicle.steering_angle, vehicle.linear_velocity)
            }
            
            // 更新里程计数据
            // console.log("VehicleDataModel: 检查odometry数据存在性:", parsedData.odometry, typeof parsedData.odometry)
            if (parsedData.odometry) {
                // console.log("VehicleDataModel: 处理odometry数据")
                odometry.angular_z = parsedData.odometry.angular_z
                if (parsedData.odometry.position) {
                    odometry.position.x = parsedData.odometry.position.x
                    odometry.position.y = parsedData.odometry.position.y
                    // console.log("VehicleDataModel: 设置odometry =", odometry.angular_z, odometry.position.x, odometry.position.y)
                }
            }
            
            // 更新GPS数据
            // console.log("VehicleDataModel: 检查GPS数据存在性:", parsedData.gps, typeof parsedData.gps)
            if (parsedData.gps) {
                // console.log("VehicleDataModel: 处理GPS数据")
                gps.latitude = parsedData.gps.latitude
                gps.longitude = parsedData.gps.longitude
                // console.log("VehicleDataModel: 设置GPS =", gps.latitude, gps.longitude)
            }
            
            // console.log("VehicleDataModel: 数据更新完成")
            return true
        } catch (error) {
            console.error("VehicleDataModel: 更新车辆数据失败:", error)
            return false
        }
    }
    
    // 辅助方法：重置所有数据为默认值
    function reset() {
        dataType = ""
        hunterID = ""
        timestamp = ""
        
        // 重置IMU数据
        imu.orientation.x = 0.0
        imu.orientation.y = 0.0
        imu.orientation.z = 0.0
        imu.orientation.w = 0.0
        
        imu.angular_velocity.x = 0.0
        imu.angular_velocity.y = 0.0
        imu.angular_velocity.z = 0.0
        
        imu.linear_acceleration.x = 0.0
        imu.linear_acceleration.y = 0.0
        imu.linear_acceleration.z = 0.0
        
        // 重置车辆数据
        vehicle.motor_rpm_avg = 0.0
        vehicle.steering_angle = 0.0
        vehicle.linear_velocity = 0.0
        vehicle.battery_level = 0.0
        
        // 重置里程计数据
        odometry.angular_z = 0.0
        odometry.position.x = 0.0
        odometry.position.y = 0.0
        
        // 重置GPS数据
        gps.latitude = 0.0
        gps.longitude = 0.0
    }
    
    // 辅助方法：导出为JSON格式
    function exportToJSON() {
        return {
            "DataType": dataType,
            "hunterID": hunterID,
            "imu": {
                "orientation": {
                    "x": imu.orientation.x,
                    "y": imu.orientation.y,
                    "z": imu.orientation.z,
                    "w": imu.orientation.w
                },
                "angular_velocity": {
                    "x": imu.angular_velocity.x,
                    "y": imu.angular_velocity.y,
                    "z": imu.angular_velocity.z
                },
                "linear_acceleration": {
                    "x": imu.linear_acceleration.x,
                    "y": imu.linear_acceleration.y,
                    "z": imu.linear_acceleration.z
                }
            },
            "vehicle": {
                "motor_rpm_avg": vehicle.motor_rpm_avg,
                "steering_angle": vehicle.steering_angle,
                "linear_velocity": vehicle.linear_velocity,
                "battery_level": vehicle.battery_level
            },
            "odometry": {
                "angular_z": odometry.angular_z,
                "position": {
                    "x": odometry.position.x,
                    "y": odometry.position.y
                }
            },
            "gps": {
                "latitude": gps.latitude,
                "longitude": gps.longitude
            },
            "timestamp": timestamp
        }
    }
    
    // 辅助方法：获取车辆状态摘要信息
    function getStatusSummary() {
        return {
            "vehicleId": hunterID,
            "isOnline": dataType === "hunterStatus",
            "coordinate": gps.latitude + ", " + gps.longitude,
            "speed": vehicle.linear_velocity,
            "position": "(" + odometry.position.x.toFixed(3) + ", " + odometry.position.y.toFixed(3) + ")",
            "lastUpdate": timestamp
        }
    }
    
    // 辅助方法：计算车辆朝向角度（从四元数转换为欧拉角）
    function getHeadingAngle() {
        // 从四元数计算偏航角（Z轴旋转）
        var siny_cosp = 2 * (imu.orientation.w * imu.orientation.z + imu.orientation.x * imu.orientation.y)
        var cosy_cosp = 1 - 2 * (imu.orientation.y * imu.orientation.y + imu.orientation.z * imu.orientation.z)
        var yaw = Math.atan2(siny_cosp, cosy_cosp)
        
        // 转换为度数
        return yaw * 180 / Math.PI
    }
    
    // 辅助方法：获取加速度大小
    function getAccelerationMagnitude() {
        var ax = imu.linear_acceleration.x
        var ay = imu.linear_acceleration.y
        var az = imu.linear_acceleration.z
        return Math.sqrt(ax * ax + ay * ay + az * az)
    }
    
    // 辅助方法：获取角速度大小
    function getAngularVelocityMagnitude() {
        var wx = imu.angular_velocity.x
        var wy = imu.angular_velocity.y
        var wz = imu.angular_velocity.z
        return Math.sqrt(wx * wx + wy * wy + wz * wz)
    }
    
    // 辅助方法：检查数据是否有效
    function isDataValid() {
        
        // 检查数据时效性（5秒内的数据认为有效）
        var currentTime = new Date().getTime()
        var dataTime = 0
        
        if (lastUpdateLocalTime > 0) {
             dataTime = lastUpdateLocalTime
        } else {
             dataTime = new Date(timestamp).getTime()
        }
        
        var timeDiff = currentTime - dataTime
        
        if (timeDiff > 1000) { // 5秒超时
            return false
        }
        
        return true
    }
    
    // 本地最后更新时间戳（毫秒）
    property double lastUpdateLocalTime: 0
    
    // 辅助方法：检查车辆是否在运动
    function isMoving() {
        return Math.abs(vehicle.linear_velocity) > 0.01 || getAngularVelocityMagnitude() > 0.01
    }

    // 点击点列表（FIFO）
    property var clickedPoints: []
    // 最大点数限制
    property int maxClickedPoints: 80

    // 添加点击点（FIFO逻辑）
    function addClickedPoint(lat, lon) {
        var newPoint = {
            "latitude": lat,
            "longitude": lon,
            "timestamp": new Date().getTime()
        }
        
        // 创建新数组以触发属性绑定更新
        var newList = clickedPoints.slice()
        
        // 添加到末尾
        newList.push(newPoint)
        
        // 如果超过最大数量，移除第一个（先进先出）
        if (newList.length > maxClickedPoints) {
            newList.shift()
        }
        
        // 更新属性
        clickedPoints = newList
        // console.log("VehicleDataModel: 添加点击点", lat, lon, "当前数量:", clickedPoints.length)
    }
    
    // 清除所有点击点
    function clearClickedPoints() {
        clickedPoints = []
    }
}