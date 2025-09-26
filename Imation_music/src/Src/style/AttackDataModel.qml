import QtQuick 2.15

QtObject {
    id: attackDataModel
    
    // 基本信息属性
    property string id: "ATK-2023-001"
    property string startTime: "2023-10-15T14:30:00Z"
    property string missionId: "MISSION-ALPHA"
    property string priority: "HIGH"
    
    // 攻击目标属性
    property QtObject attackTarget: QtObject {
        property string type: "MULTIPLE"  // SINGLE/MULTIPLE/ALL
        property var selectedNodes: ["Car001", "Car002", "Car003"]
    }
    
    // 节点攻击参数列表 - 使用ListModel来管理动态数据
    property ListModel nodeAttackParameters: ListModel {
        id: nodeAttackParametersModel
        // 移除硬编码的初始化数据，改为动态初始化
    }
    
    // 元数据属性
    property QtObject metadata: QtObject {
        property string status: "SCHEDULED"  // SCHEDULED/RUNNING/STOPPED
        property string createdAt: "2023-10-10T09:15:00Z"
        property string lastModified: "2023-10-12T16:45:00Z"
    }
    
    // 动态初始化车辆攻击参数
    function initializeVehicleParameters(vehicleNames) {
        // 清空现有数据
        nodeAttackParameters.clear()
        
        // 为每个车辆创建默认攻击参数
        for (var i = 0; i < vehicleNames.length; i++) {
            var vehicleName = vehicleNames[i]
            nodeAttackParameters.append(createNodeAttackParameter(
                vehicleName, 
                "DDoS",           // 默认攻击类型
                "SUSTAINED",      // 默认攻击方法
                ["MULTIPLE", [["V001", "V002"]]], // 默认攻击链路
                [0, 1, 0],        // 默认攻击组成：只启用DDoS
                [60, 10, 5, 100, 0.05], // 默认攻击参数：60s持续时间，10次/秒频率，5强度，100ms延迟，5%丢包率
                [1024, false, []] // 默认高级参数：1024字节包大小，不伪造源IP
            ))
        }
        
        // 更新攻击目标
        attackTarget.selectedNodes = vehicleNames.slice() // 复制数组
        updateStatus("INITIALIZED")
    }
    
    // 创建节点攻击参数对象的工厂函数
    function createNodeAttackParameter(nodeSelection, attackType, attackMethod, 
                                     attackLinks, attackComposition, attackParams, advancedParams) {
        return {
            "nodeSelection": nodeSelection,
            "attackType": attackType,
            "attackMethod": attackMethod,
            "attackLinks": {
                "selectionMode": attackLinks[0],
                "selectedLinks": attackLinks[1]
            },
            "attackComposition": {
                "spoofingEnabled": attackComposition[0],
                "ddosEnabled": attackComposition[1],
                "replayEnabled": attackComposition[2]
            },
            "attackParameters": {
                "duration": attackParams[0],
                "frequency": attackParams[1],
                "intensity": attackParams[2],
                "delayInjection": attackParams[3],
                "expectedPacketLossRatio": attackParams[4]
            },
            "advancedParameters": {
                "packetSize": advancedParams[0],
                "sourceSpoofing": advancedParams[1],
                "spoofedSources": advancedParams[2]
            }
        }
    }
    
    // 辅助方法：获取指定节点的攻击参数
    function getNodeAttackParameters(nodeId) {
        for (var i = 0; i < nodeAttackParameters.count; i++) {
            var item = nodeAttackParameters.get(i);
            if (item.nodeSelection === nodeId) {
                return item;
            }
        }
        return null;
    }
    
    // 辅助方法：获取指定索引的节点攻击参数
    function getNodeAttackParametersByIndex(index) {
        if (index >= 0 && index < nodeAttackParameters.count) {
            return nodeAttackParameters.get(index);
        }
        return null;
    }
    
    // 辅助方法：更新攻击目标
    function updateAttackTarget(targetType, nodes) {
        attackTarget.type = targetType;
        attackTarget.selectedNodes = nodes;
    }
    
    // 辅助方法：添加新的节点攻击参数
    function addNodeAttackParameter(nodeSelection, attackType, attackMethod, 
                                  attackLinks, attackComposition, attackParams, advancedParams) {
        var newParam = createNodeAttackParameter(nodeSelection, attackType, attackMethod, 
                                                attackLinks, attackComposition, attackParams, advancedParams);
        nodeAttackParameters.append(newParam);
        updateStatus("MODIFIED");
        return nodeAttackParameters.count - 1; // 返回新添加项的索引
    }
    
    // 辅助方法：移除指定节点的攻击参数
    function removeNodeAttackParameter(nodeId) {
        for (var i = 0; i < nodeAttackParameters.count; i++) {
            var item = nodeAttackParameters.get(i);
            if (item.nodeSelection === nodeId) {
                nodeAttackParameters.remove(i);
                updateStatus("MODIFIED");
                return true;
            }
        }
        return false;
    }
    
    // 辅助方法：根据索引移除节点攻击参数
    function removeNodeAttackParameterByIndex(index) {
        if (index >= 0 && index < nodeAttackParameters.count) {
            nodeAttackParameters.remove(index);
            updateStatus("MODIFIED");
            return true;
        }
        return false;
    }
    
    // 辅助方法：更新指定节点的攻击参数
    function updateNodeAttackParameter(nodeId, property, value) {
        for (var i = 0; i < nodeAttackParameters.count; i++) {
            var item = nodeAttackParameters.get(i);
            if (item.nodeSelection === nodeId) {
                nodeAttackParameters.setProperty(i, property, value);
                updateStatus("MODIFIED");
                return true;
            }
        }
        return false;
    }
    
    // 辅助方法：清空所有节点攻击参数
    function clearAllNodeAttackParameters() {
        nodeAttackParameters.clear();
        updateStatus("MODIFIED");
    }
    
    // 辅助方法：获取节点攻击参数数量
    function getNodeAttackParametersCount() {
        return nodeAttackParameters.count;
    }
    
    // 辅助方法：更新元数据状态
    function updateStatus(newStatus) {
        metadata.status = newStatus;
        metadata.lastModified = new Date().toISOString();
    }
    
    // 辅助方法：从JSON数据批量导入节点攻击参数
    function importFromJSON(jsonData) {
        try {
            clearAllNodeAttackParameters();
            
            // 更新基本信息
            if (jsonData.id) id = jsonData.id;
            if (jsonData.startTime) startTime = jsonData.startTime;
            if (jsonData.missionId) missionId = jsonData.missionId;
            if (jsonData.priority) priority = jsonData.priority;
            
            // 更新攻击目标
            if (jsonData.attackTarget) {
                updateAttackTarget(jsonData.attackTarget.type, jsonData.attackTarget.selectedNodes);
            }
            
            // 导入节点攻击参数
            if (jsonData.nodeAttackParameters && Array.isArray(jsonData.nodeAttackParameters)) {
                for (var i = 0; i < jsonData.nodeAttackParameters.length; i++) {
                    var param = jsonData.nodeAttackParameters[i];
                    var attackConfig = param.attackConfiguration;
                    var attackParams = param.attackParameters;
                    
                    addNodeAttackParameter(
                        param.nodeSelection,
                        attackConfig.attackType,
                        attackConfig.attackMethod,
                        [attackConfig.attackLinks.selectionMode, attackConfig.attackLinks.selectedLinks],
                        [attackConfig.attackComposition.spoofingEnabled, 
                         attackConfig.attackComposition.ddosEnabled, 
                         attackConfig.attackComposition.replayEnabled],
                        [attackParams.duration, attackParams.frequency, attackParams.intensity, 
                         attackParams.delayInjection, attackParams.expectedPacketLossRatio],
                        [attackParams.advancedParameters.packetSize, 
                         attackParams.advancedParameters.sourceSpoofing, 
                         attackParams.advancedParameters.spoofedSources]
                    );
                }
            }
            
            // 更新元数据
            if (jsonData.metadata) {
                metadata.status = jsonData.metadata.status || "IMPORTED";
                metadata.createdAt = jsonData.metadata.createdAt || new Date().toISOString();
                metadata.lastModified = new Date().toISOString();
            }
            
            return true;
        } catch (error) {
            console.error("导入JSON数据失败:", error);
            return false;
        }
    }
    
    // 辅助方法：导出为JSON格式
    function exportToJSON() {
        var result = {
            "id": id,
            "startTime": startTime,
            "missionId": missionId,
            "priority": priority,
            "attackTarget": {
                "type": attackTarget.type,
                "selectedNodes": attackTarget.selectedNodes
            },
            "nodeAttackParameters": [],
            "metadata": {
                "status": metadata.status,
                "createdAt": metadata.createdAt,
                "lastModified": metadata.lastModified
            }
        };
        
        // 导出节点攻击参数
        for (var i = 0; i < nodeAttackParameters.count; i++) {
            var item = nodeAttackParameters.get(i);
            result.nodeAttackParameters.push({
                "nodeSelection": item.nodeSelection,
                "attackConfiguration": {
                    "attackLinks": {
                        "selectionMode": item.attackLinks.selectionMode,
                        "selectedLinks": item.attackLinks.selectedLinks
                    },
                    "attackType": item.attackType,
                    "attackMethod": item.attackMethod,
                    "attackComposition": {
                        "spoofingEnabled": item.attackComposition.spoofingEnabled,
                        "ddosEnabled": item.attackComposition.ddosEnabled,
                        "replayEnabled": item.attackComposition.replayEnabled
                    }
                },
                "attackParameters": {
                    "duration": item.attackParameters.duration,
                    "frequency": item.attackParameters.frequency,
                    "intensity": item.attackParameters.intensity,
                    "delayInjection": item.attackParameters.delayInjection,
                    "expectedPacketLossRatio": item.attackParameters.expectedPacketLossRatio,
                    "advancedParameters": {
                        "packetSize": item.advancedParameters.packetSize,
                        "sourceSpoofing": item.advancedParameters.sourceSpoofing,
                        "spoofedSources": item.advancedParameters.spoofedSources
                    }
                }
            });
        }
        
        return result;
    }
    
    // 根据模式导出特定车辆的JSON数据
    function exportToJSONByMode(mode, selectedVehicles, currentVehicle) {
        var result = {
            "id": id,
            "startTime": startTime,
            "missionId": missionId,
            "priority": priority,
            "attackTarget": {
                "type": mode,
                "selectedNodes": []
            },
            "nodeAttackParameters": [],
            "metadata": {
                "status": metadata.status,
                "createdAt": metadata.createdAt,
                "lastModified": metadata.lastModified
            }
        };
        
        var vehiclesToExport = []
        
        // 根据模式确定要导出的车辆
        if (mode === "SINGLE") {
            if (currentVehicle) {
                vehiclesToExport = [currentVehicle]
                result.attackTarget.selectedNodes = [currentVehicle]
            }
        } else if (mode === "MULTIPLE") {
            vehiclesToExport = selectedVehicles || []
            result.attackTarget.selectedNodes = vehiclesToExport.slice()
        } else if (mode === "ALL") {
            // 导出所有车辆
            for (var i = 0; i < nodeAttackParameters.count; i++) {
                var item = nodeAttackParameters.get(i);
                vehiclesToExport.push(item.nodeSelection)
            }
            result.attackTarget.selectedNodes = vehiclesToExport.slice()
        }
        
        // 导出指定车辆的攻击参数
        for (var j = 0; j < nodeAttackParameters.count; j++) {
            var item = nodeAttackParameters.get(j);
            if (vehiclesToExport.indexOf(item.nodeSelection) !== -1) {
                result.nodeAttackParameters.push({
                    "nodeSelection": item.nodeSelection,
                    "attackConfiguration": {
                        "attackLinks": {
                            "selectionMode": item.attackLinks.selectionMode,
                            "selectedLinks": item.attackLinks.selectedLinks
                        },
                        "attackType": item.attackType,
                        "attackMethod": item.attackMethod,
                        "attackComposition": {
                            "spoofingEnabled": item.attackComposition.spoofingEnabled,
                            "ddosEnabled": item.attackComposition.ddosEnabled,
                            "replayEnabled": item.attackComposition.replayEnabled
                        }
                    },
                    "attackParameters": {
                        "duration": item.attackParameters.duration,
                        "frequency": item.attackParameters.frequency,
                        "intensity": item.attackParameters.intensity,
                        "delayInjection": item.attackParameters.delayInjection,
                        "expectedPacketLossRatio": item.attackParameters.expectedPacketLossRatio,
                        "advancedParameters": {
                            "packetSize": item.advancedParameters.packetSize,
                            "sourceSpoofing": item.advancedParameters.sourceSpoofing,
                            "spoofedSources": item.advancedParameters.spoofedSources
                        }
                    }
                });
            }
        }
        
        return result;
    }
}