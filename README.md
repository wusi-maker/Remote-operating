# 智能车辆监控系统 (Smart Vehicle Monitoring System)

[![Qt Version](https://img.shields.io/badge/Qt-6.9.2-blue.svg)](https://www.qt.io)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Build](https://img.shields.io/badge/build-CMake-orange.svg)](CMakeLists.txt)

一个基于Qt和FluentUI框架开发的现代化智能车辆监控系统，具备实时数据监控、网络拓扑可视化、攻击检测等先进功能。

## ✨ 核心特性

### 🚗 多模式显示
- **简洁模式**: 科技感仪表盘，专注攻击监控和数据可视化
- **常规模式**: 完整功能界面，集成数据管理、地图、视频监控

### 📊 三大核心页面

#### 1. TechDashboard - 科技感仪表盘
- 🎨 现代化FluentUI设计风格
- 📈 多车辆实时监控面板
- ⚡ 8种攻击模式参数配置
- 🌐 Canvas绘制的网络拓扑图

#### 2. HomePage - 车辆数据管理中心
- 📋 车辆网络拓扑可视化
- 📊 实时数据更新和预处理
- 🎯 车辆状态监控面板
- 📑 结构化数据表格展示

#### 3. LayoutRight - 综合信息显示
- 🗺️ Qt Location地图集成
- 📹 视频监控区域
- 📊 车辆仪表盘显示
- 👤 用户信息配置界面

### 🔧 技术架构

#### 前端技术
- **Qt 6.9.2+**: 跨平台应用框架
- **FluentUI**: 现代化UI组件库
- **QML**: 声明式UI设计语言
- **Qt Location**: 地图服务集成

#### 后端技术
- **C++17**: 核心业务逻辑
- **CMake**: 现代化构建系统
- **TCP/IP**: 网络通信协议

#### 数据模型
- **VehicleDataModel**: 车辆数据结构管理
- **AttackDataModel**: 攻击参数配置
- **SharedNetworkConnection**: 网络数据共享

## 🚀 快速开始

### 环境要求
- Qt 6.9.2 或更高版本
- CMake 3.16+
- C++17 兼容编译器
- Windows/macOS/Linux 操作系统

### 构建步骤
```bash
# 克隆项目
git clone https://github.com/your-username/smart-vehicle-monitoring.git
cd smart-vehicle-monitoring

# 创建构建目录
mkdir build && cd build

# 配置项目
cmake ..

# 构建项目
cmake --build .

# 运行应用
./src/test
```

### 开发环境配置
```bash
# Windows (MinGW)
cmake -G "MinGW Makefiles" ..

# macOS/Linux
cmake -G "Unix Makefiles" ..
```

## 📁 项目结构

```
smart-vehicle-monitoring/
├── src/                    # 源代码目录
│   ├── main.cpp           # 应用入口
│   ├── main.qml           # 主QML文件
│   ├── App.qml            # 应用根组件
│   ├── Src/               # QML组件目录
│   │   ├── commonUI/      # 通用UI组件
│   │   ├── leftPage/      # 左侧页面组件
│   │   ├── rightPage/     # 右侧页面组件
│   │   ├── nightPage/     # 底部页面组件
│   │   ├── style/         # 样式和主题
│   │   └── Network/       # 网络相关组件
│   └── Resource/          # 资源文件
├── FluentUI/              # FluentUI框架
├── docs/                  # 项目文档
├── examples/              # 示例和演示
├── CMakeLists.txt         # CMake构建配置
└── .gitignore            # Git忽略规则
```

## 🌍 国际化支持

项目支持中英文双语切换：
- 使用 `tr()` 函数进行C++代码国际化
- 使用 `qsTr()` 函数进行QML代码国际化
- 自动翻译更新脚本支持

### 更新翻译
```bash
# 更新翻译文件
# 执行 Qt Creator 中的 "Script-UpdateTranslations"
```

## 📸 截图展示

*运行应用后，在 `docs/screenshots/` 目录下查看实际截图*

## 📝 开发文档

详细开发文档请查看 [docs/README.md](docs/README.md)

博客写作指南请查看 [docs/blog-guide.md](docs/blog-guide.md)

## 🤝 贡献指南

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 🐛 问题反馈

如果您在使用过程中遇到问题，请：
1. 查看 [文档](docs/) 中的常见问题
2. 在 [Issues](https://github.com/your-username/smart-vehicle-monitoring/issues) 中搜索类似问题
3. 创建新的 Issue 描述您的问题

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- [Qt Framework](https://www.qt.io/) - 跨平台应用开发框架
- [FluentUI](https://github.com/zhuzichu520/FluentUI) - 现代化UI组件库
- [QCustomPlot](https://www.qcustomplot.com/) - 图表绘制库

## 📞 联系方式

- 项目维护者: [Your Name]
- 邮箱: [your.email@example.com]
- 博客: [your-blog-url]

---

⭐ 如果这个项目对您有帮助，请给个Star支持一下！