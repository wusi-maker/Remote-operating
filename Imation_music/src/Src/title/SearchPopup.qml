import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 搜索弹窗组件
Item {
    id: searchPopup
    visible: false
    width: parent.width  // 与搜索框同宽
    height: 300         // 固定高度，可滚动
    z: 100              // 确保在其他组件上方


    // 点击外部区域关闭
    MouseArea {
        anchors.fill: parent
        onClicked: searchPopup.visible = false
    }
    // 历史记录数据模型
    ListModel {
        id: historyModel
        // 示例数据
        ListElement { text: "晴天" }
        ListElement { text: "周杰伦" }
        ListElement { text: "青花瓷" }
        ListElement { text: "音乐播放器" }
        ListElement { text: "搜索历史" }
        ListElement { text: "流行歌曲" }
        ListElement { text: "经典老歌" }
        ListElement { text: "摇滚音乐" }
    }

    // 半透明背景遮罩
    Rectangle {
        id: overlay
        anchors.fill: parent
        color: "#0a0a0f"
        opacity: 0.95
        radius: 4
        border.color: "#36262f"
        border.width: 1

        // 标题栏
        Rectangle {
            id: header
            width: parent.width
            height: 35
            color: "transparent"
            border.width: 1
            border.color: "#36262f"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 15
                text: qsTr("搜索历史")
                color: "#a0a0a0"
                font.pixelSize: 14
            }

            Button {
                id: clearButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 15
                text: qsTr("清除全部")
                font.pixelSize: 12
                background: Rectangle {
                    color: "transparent"
                    radius: 3
                }
                onClicked: historyModel.clear()
            }
        }

        // 滚动区域
        Flickable {
            id: flick
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            contentWidth: parent.width
            contentHeight: historyContainer.implicitHeight
            flickableDirection: Flickable.VerticalFlick
            clip: true

            // 历史记录容器
            Column {
                id: historyContainer
                width: parent.width
                spacing: 1

                // 历史记录项
                Repeater {
                    model: historyModel

                    Rectangle {
                        id: historyItem
                        width: parent.width
                        height: 40
                        color: "#241c26"

                        // 鼠标悬停效果
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: historyItem.color = "#2d2430"
                            onExited: historyItem.color = "#241c26"
                            onClicked: {
                                // 点击历史项填充搜索框
                                searchField.text = model.text
                                searchPopup.visible = false
                            }
                        }

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            source: "qrc:/Resource/title/search.svg"
                            sourceSize: Qt.size(18, 18)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 45
                            text: model.text
                            color: "#ffffff"
                            font.pixelSize: 14
                        }

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 15
                            source: "qrc:/Resource/title/close.svg"
                            sourceSize: Qt.size(16, 16)
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    historyModel.remove(index)
                                    mouse.accepted = true  // 防止事件冒泡
                                }
                            }
                        }
                    }
                }

                // 空状态提示
                Text {
                    visible: historyModel.count === 0
                    text: qsTr("暂无搜索历史")
                    color: "#666666"
                    font.pixelSize: 14
                    padding: 20
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    // 显示/隐藏动画
    Behavior on visible {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 200
        }
        NumberAnimation {
            property: "scale"
            from: 0.95
            to: 1
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    // 初始状态
    opacity: 0
    scale: 0.95
}
