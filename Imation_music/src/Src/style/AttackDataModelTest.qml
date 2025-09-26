import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: testWindow
    width: 800
    height: 600
    visible: true
    title: "AttackDataModel 测试"
    
    AttackDataModel {
        id: attackModel
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        
        Column {
            spacing: 10
            width: parent.width
            
            Text {
                text: "AttackDataModel 功能测试"
                font.pixelSize: 24
                font.bold: true
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#cccccc"
            }
            
            // 基本信息显示
            Text {
                text: "基本信息:"
                font.pixelSize: 18
                font.bold: true
            }
            
            Text {
                text: "ID: " + attackModel.id
            }
            
            Text {
                text: "任务ID: " + attackModel.missionId
            }
            
            Text {
                text: "优先级: " + attackModel.priority
            }
            
            Text {
                text: "攻击目标类型: " + attackModel.attackTarget.type
            }
            
            Text {
                text: "选中节点: " + JSON.stringify(attackModel.attackTarget.selectedNodes)
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#cccccc"
            }
            
            // 节点攻击参数显示
            Text {
                text: "节点攻击参数 (共 " + attackModel.getNodeAttackParametersCount() + " 个):"
                font.pixelSize: 18
                font.bold: true
            }
            
            Repeater {
                model: attackModel.nodeAttackParameters
                
                Rectangle {
                    width: parent.width
                    height: nodeInfo.height + 20
                    border.color: "#dddddd"
                    border.width: 1
                    radius: 5
                    
                    Column {
                        id: nodeInfo
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 5
                        
                        Text {
                            text: "节点: " + model.nodeSelection
                            font.bold: true
                        }
                        
                        Text {
                            text: "攻击类型: " + model.attackType
                        }
                        
                        Text {
                            text: "攻击方法: " + model.attackMethod
                        }
                        
                        Text {
                            text: "链路选择模式: " + model.attackLinks.selectionMode
                        }
                        
                        Text {
                            text: "持续时间: " + model.attackParameters.duration + "ms"
                        }
                        
                        Text {
                            text: "频率: " + model.attackParameters.frequency + " 次/秒"
                        }
                        
                        Text {
                            text: "强度: " + model.attackParameters.intensity + "%"
                        }
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#cccccc"
            }
            
            // 测试按钮
            Text {
                text: "功能测试:"
                font.pixelSize: 18
                font.bold: true
            }
            
            Row {
                spacing: 10
                
                Button {
                    text: "添加新节点"
                    onClicked: {
                        var index = attackModel.addNodeAttackParameter(
                            "Car00" + (attackModel.getNodeAttackParametersCount() + 1),
                            "DDoS",
                            "SUSTAINED",
                            ["SINGLE", [["V001", "V002"]]],
                            [0, 1, 0],
                            [2000, 100, 80, 120, 0.5],
                            [1024, false, []]
                        );
                        console.log("添加新节点，索引:", index);
                    }
                }
                
                Button {
                    text: "删除最后一个节点"
                    enabled: attackModel.getNodeAttackParametersCount() > 0
                    onClicked: {
                        var count = attackModel.getNodeAttackParametersCount();
                        if (count > 0) {
                            var success = attackModel.removeNodeAttackParameterByIndex(count - 1);
                            console.log("删除节点结果:", success);
                        }
                    }
                }
                
                Button {
                    text: "清空所有节点"
                    onClicked: {
                        attackModel.clearAllNodeAttackParameters();
                        console.log("已清空所有节点攻击参数");
                    }
                }
            }
            
            Row {
                spacing: 10
                
                Button {
                    text: "导出JSON"
                    onClicked: {
                        var jsonData = attackModel.exportToJSON();
                        console.log("导出的JSON数据:", JSON.stringify(jsonData, null, 2));
                    }
                }
                
                Button {
                    text: "重新加载默认数据"
                    onClicked: {
                        // 模拟从JSON导入数据
                        var defaultData = {
                            "id": "ATK-2023-002",
                            "startTime": "2023-10-16T10:00:00Z",
                            "missionId": "MISSION-BETA",
                            "priority": "MEDIUM",
                            "attackTarget": {
                                "type": "SINGLE",
                                "selectedNodes": ["Car001"]
                            },
                            "nodeAttackParameters": [
                                {
                                    "nodeSelection": "Car001",
                                    "attackConfiguration": {
                                        "attackLinks": {
                                            "selectionMode": "ALL",
                                            "selectedLinks": []
                                        },
                                        "attackType": "REPLAY",
                                        "attackMethod": "BURST",
                                        "attackComposition": {
                                            "spoofingEnabled": 0,
                                            "ddosEnabled": 0,
                                            "replayEnabled": 1
                                        }
                                    },
                                    "attackParameters": {
                                        "duration": 5000,
                                        "frequency": 50,
                                        "intensity": 95,
                                        "delayInjection": 80,
                                        "expectedPacketLossRatio": 0.9,
                                        "advancedParameters": {
                                            "packetSize": 2048,
                                            "sourceSpoofing": true,
                                            "spoofedSources": ["10.0.0.10", "10.0.0.11"]
                                        }
                                    }
                                }
                            ],
                            "metadata": {
                                "status": "SCHEDULED",
                                "createdAt": "2023-10-16T09:00:00Z",
                                "lastModified": "2023-10-16T09:30:00Z"
                            }
                        };
                        
                        var success = attackModel.importFromJSON(defaultData);
                        console.log("导入数据结果:", success);
                    }
                }
            }
            
            Rectangle {
                width: parent.width
                height: 1
                color: "#cccccc"
            }
            
            // 元数据显示
            Text {
                text: "元数据:"
                font.pixelSize: 18
                font.bold: true
            }
            
            Text {
                text: "状态: " + attackModel.metadata.status
            }
            
            Text {
                text: "创建时间: " + attackModel.metadata.createdAt
            }
            
            Text {
                text: "最后修改: " + attackModel.metadata.lastModified
            }
        }
    }
}