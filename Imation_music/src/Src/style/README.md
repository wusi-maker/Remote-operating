# 深色主题样式指南

本目录包含了基于Tesla项目优秀设计的深色主题样式文件，适用于桌面端应用开发。

## 文件说明

### Theme.qml
- **用途**: QML应用程序的主题配置文件
- **特点**: 单例模式，提供全局颜色和样式属性
- **适用**: Qt Quick/QML桌面应用开发

### dark-theme.css
- **用途**: Web应用程序的深色主题CSS文件
- **特点**: 使用CSS变量，便于主题切换和维护
- **适用**: Web前端开发、Electron应用等

## 颜色设计理念

本主题采用深色背景设计，具有以下特点：

1. **主背景色**: `#17161c` - 深紫灰色，减少眼部疲劳
2. **强调色**: `#439df3` - 明亮蓝色，提供良好的视觉焦点
3. **文本层级**: 从白色到灰色的渐变，确保良好的可读性
4. **状态色**: 包含成功、警告、错误等语义化颜色

## QML使用方法

### 1. 注册主题模块

在你的QML项目中，确保Theme.qml被正确注册为单例：

```qml
// 在qmldir文件中添加
singleton Theme 1.0 Theme.qml
```

### 2. 在QML文件中使用

```qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import "./style" // 导入样式目录

ApplicationWindow {
    color: Theme.backgroundColor
    
    Button {
        text: "示例按钮"
        background: Rectangle {
            color: Theme.buttonColor
            border.color: Theme.borderColor
            radius: 8
        }
        
        contentItem: Text {
            text: parent.text
            color: Theme.primaryTextColor
        }
    }
    
    Rectangle {
        color: Theme.cardBackground
        border.color: Theme.borderColor
        radius: 12
        
        Text {
            text: "卡片内容"
            color: Theme.primaryTextColor
        }
    }
}
```

## CSS使用方法

### 1. 引入CSS文件

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>深色主题应用</title>
    <link rel="stylesheet" href="./Src/style/dark-theme.css">
</head>
<body class="dark-theme">
    <!-- 你的内容 -->
</body>
</html>
```

### 2. 使用预定义样式类

```html
<!-- 按钮 -->
<button class="btn-primary">主要按钮</button>
<button class="btn-secondary">次要按钮</button>

<!-- 卡片 -->
<div class="card">
    <h3 class="text-primary">卡片标题</h3>
    <p class="text-secondary">卡片描述内容</p>
</div>

<!-- 输入框 -->
<input type="text" class="input-field" placeholder="请输入内容">

<!-- 文本样式 -->
<p class="text-primary">主要文本</p>
<p class="text-secondary">次要文本</p>
<p class="text-success">成功状态文本</p>
<p class="text-warning">警告状态文本</p>
<p class="text-error">错误状态文本</p>
```

### 3. 使用CSS变量

```css
/* 自定义组件样式 */
.custom-component {
    background-color: var(--card-background);
    border: 1px solid var(--border-color);
    color: var(--primary-text-color);
    padding: 16px;
    border-radius: 8px;
}

.custom-button {
    background: var(--primary-gradient);
    color: var(--primary-text-color);
    border: none;
    padding: 12px 24px;
    border-radius: 6px;
    cursor: pointer;
}

.custom-button:hover {
    background-color: var(--secondary-color);
}
```

## 颜色参考表

| 用途 | QML属性 | CSS变量 | 颜色值 |
|------|---------|---------|--------|
| 主背景 | `backgroundColor` | `--background-color` | `#17161c` |
| 卡片背景 | `cardBackground` | `--card-background` | `#201f25` |
| 按钮颜色 | `buttonColor` | `--button-color` | `#2f2f39` |
| 主要强调色 | `primaryColor` | `--primary-color` | `#439df3` |
| 主要文本 | `primaryTextColor` | `--primary-text-color` | `#FFFFFF` |
| 次要文本 | `secondaryTextColor` | `--secondary-text-color` | `#CCCCCC` |
| 边框颜色 | `borderColor` | `--border-color` | `#3A3A3A` |
| 成功色 | `successColor` | `--success-color` | `#34C759` |
| 警告色 | `warningColor` | `--warning-color` | `#FF9500` |
| 错误色 | `errorColor` | `--error-color` | `#FF3B30` |

## 最佳实践

1. **一致性**: 在整个应用中保持颜色使用的一致性
2. **对比度**: 确保文本和背景之间有足够的对比度
3. **语义化**: 使用语义化的颜色名称，如success、warning、error
4. **可访问性**: 考虑色盲用户，不仅仅依赖颜色来传达信息
5. **测试**: 在不同的显示器和环境光线下测试主题效果

## 扩展建议

- 可以基于这套颜色系统创建浅色主题版本
- 添加更多的组件样式类
- 考虑添加动画和过渡效果
- 支持主题动态切换功能

## 致谢

本主题设计灵感来源于Tesla项目的优秀UI设计，感谢原作者的精美设计。