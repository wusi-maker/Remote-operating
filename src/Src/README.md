# 项目 QML 概览（src/Src）

本文件简要说明 `src/Src` 目录下的主要 QML 组件及其职责，并对构成页面骨架的核心文件进行详细讲解：
- `src/Src/commonUI/HomePage.qml`
- `src/Src/rightPage/LayoutRight.qml`
- `src/main.qml`
- `src/Src/commonUI/TechDashboard.qml`

说明仅覆盖当前工程主流程中实际使用的 QML；若某文件已废弃但未删除，默认不在此文档中展开。

## 项目概览
- 整体采用 QML + FluentUI 风格的多页面应用，核心通过 `main.qml` 管理页面显示模式与全局状态。
- 应用根组件为 `commonUI/Windows.qml`，在其内根据 `isSimpleMode` 切换显示：
  - 简洁模式：显示 `TechDashboard` 科技感仪表盘界面。
  - 非简洁模式：显示左侧 `Leftpage` 与右侧 `LayoutRight` 组合界面。
- 全局网络与车辆数据通过 `style/SharedNetworkConnection.qml` 和 `style/VehicleDataModel.qml` 进行接入与解析，右侧页面通过 `rootWindow` 与左侧页面共享数据模型。

## 核心页面详解

### `src/main.qml`
- 角色：应用入口与页面编排。
- 关键点：
  - 根组件使用 `commonUI/Windows.qml`，设置窗口尺寸与全局属性。
  - 全局状态：
    - `networkJsonData`：网络数据缓存与时间戳。
    - `isSimpleMode`：页面模式切换（简洁/常规）。
    - `showHomePage`、`showMapPage`、`showCurvesPage`：常规模式下的区域显示控制。
    - `currentVehicleId`：当前选中车辆 ID，供各子组件共享。
  - 页面结构：
    - 左侧：`leftPage/Leftpage.qml`，通过 `alias leftPage` 暴露给其他组件访问其数据接口。
    - 右侧：`rightPage/LayoutRight.qml`，接收 `rootWindow`，读取左侧的数据模型并展示地图、视频与 HomePage 等。
    - 简洁模式：`commonUI/TechDashboard.qml` 覆盖主区域。
    - 底部：`nightPage/Playmusic.qml` 作为底部控制栏。

### `src/Src/commonUI/HomePage.qml`
- 角色：主页数据处理与部分综合展示容器（在 `LayoutRight` 中按需显示）。
- 数据流：
  - 监听 `SharedNetworkConnection` 的两类信号：
    - `dataUpdated(jsonData, rawData)`：原始数据更新，进入预处理。
    - `vehicleDataReceived(hunterID, vehicleData)`：单车辆数据接入，转为 JSON 并预处理。
  - 使用 `style/VehicleDataModel.qml` 的 `updateFromJSON()` 解析并更新内部模型。
- UI 结构（简述）：
  - 左侧大区域包含“车辆网络拓扑”标题与模式选择，主体为 `Canvas` 绘制拓扑/连接关系的可视化。
  - 维护示例表格数据 `vehicleTableData`，可用于列表展示或占位。
  - 封装处理方法：`preprocessRawData(rawJsonData)` 与 `resetProcessor()`。

### `src/Src/rightPage/LayoutRight.qml`
- 角色：常规模式右侧主容器，组织视频、地图与主页区域，负责跨页面的数据访问与展示。
- 与左侧联动：
  - 通过 `rootWindow.leftPage.getAllVehicleDataModels()` 获取车辆数据模型集合，并根据 `rootWindow.currentVehicleId` 定位当前车辆数据。
  - 提供 `printCurrentVehicleData()` 打印当前车辆详细信息（IMU、车辆、里程计、GPS 等），便于联调与可视化。
- UI 结构（简述）：
  - 顶部 `FluAppBar` 标题显示当前车辆信息，含用户信息区 `title/UserConfigsetting.qml`。
  - `GridLayout` 分为视频与地图两大矩形区域：
    - 视频区域：占位展示摄像头状态与简单控制按钮。
    - 地图区域：`QtLocation`/`QtPositioning` 地图插件，支持瓦片源与基本交互。
  - 内嵌 `HomePage`：根据 `rootWindow.showHomePage` 切换显示，用于在右侧集中展示主页内容。

### `src/Src/commonUI/TechDashboard.qml`
- 角色：科技感仪表盘与多车辆攻击控制台（简洁模式）。
- 数据模型：
  - `style/AttackDataModel.qml`：管理攻击类型、方法、参数与组合（`attackComposition`）。
  - 初始化时为选中车辆生成/加载攻击参数，提供 `getNodeAttackParameters()` 与 `updateNodeAttackParameter()`。
- 车辆选择与参数联动：
  - 维护 `vehicleNames` 与 `vehicleSelectionStates`，计算 `globalVehicleNames`。
  - 通过 `updateSelectedVehicles()`、`loadVehicleParameters(vehicleId)`、`saveCurrentVehicleParameters()` 读写 UI 控件与模型参数。
  - 根据攻击类型/组合（SINGLE/MULTIPLE/ALL、SUSTAINED/INTERMITTENT/BURST）更新模型与复选框。
- UI 概览：
  - 顶部 `FluAppBar`，主体包含多分区控制面板与大型 `Canvas` 拓扑展示，支持 8 种模式切换与淡入淡出动画。
  - 通过组合与勾选，动态联动 `AttackDataModel` 的 `attackComposition` 与各参数值。

## 目录结构与组件说明（简述）

### `src/Src/commonUI`
- `Windows.qml`：应用主窗口容器，通用窗口行为与样式；被 `main.qml` 用作根组件。
- `CurveComponent.qml`：通用曲线绘制组件，支持多曲线显示、坐标轴与图例，暴露多曲线数据接口。
- `VehicleDataPopup.qml`：车辆数据弹窗，展示速度/加速度/车间距/位置Y曲线，支持从 CSV 加载并分车显示。
- `DataDetailPopup.qml`：数据详情弹窗组件，支持键值与表格信息的集中查看。
- `Mapandcemera.qml`：地图与摄像头复合组件，便于在单容器中展示两类信息。
- `ProgressBarComponent.qml`：带主题样式的进度条组件，支持范围与示例值显示。
- `TButton.qml`：通用按钮封装，统一交互与主题风格。
- `HomePage.qml`：详见“核心页面详解”。
- `TechDashboard.qml`：详见“核心页面详解”。

### `src/Src/rightPage`
- `LayoutRight.qml`：详见“核心页面详解”。
- `Rightpage.qml`：右侧页面容器的组合/入口版本（按项目场景选择使用）。
- `CarDashboardLayout.qml`：单车仪表盘布局封装组件。
- `VehicleDashboardLayout.qml`：多车仪表盘布局封装组件。
- `CombinedDashboardLayout.qml`：组合仪表盘布局，融合多视图显示。
- `DashboardComponent.qml`：仪表盘基础组件，提供通用仪表与指示器。
- `DataListView.qml`：列表视图，展示键值型数据行，配合右侧信息面板使用。
- `IconBrowser.qml`：图标/资源浏览组件，便于选择与预览。

### `src/Src/leftPage`
- `Leftpage.qml`：左侧导航与数据面板，集中管理车辆数据模型，向外暴露：
  - `getAllVehicleDataModels()`：返回所有车辆的数据模型集合。
  - `getVehicleDataModel(vehicleId)`：按车辆 ID 获取数据模型。

### `src/Src/nightPage`
- `Playmusic.qml`：底部播放控制栏与媒体区，作为页面底部区域显示。

### `src/Src/style`
- `Theme.qml`：全局主题与颜色样式定义。
- `SharedNetworkConnection.qml`：全局网络连接单例，发出 `dataUpdated` 与 `vehicleDataReceived` 信号，供页面监听。
- `AttackDataModel.qml`：攻击数据模型，维护节点参数与攻击组合，提供更新接口。
- `VehicleDataModel.qml`：车辆数据模型，提供 `updateFromJSON()` 与 `reset()` 等数据解析与维护方法。
- `dark-theme.css`：通用样式表。
- `qmldir`：QML 模块注册文件。

### `src/Src/title`
- `MinAndMax.qml`：窗口控制按钮区域（最小化/最大化/置顶）。
- `Search.qml`：顶部搜索输入组件。
- `SearchPopup.qml`：搜索弹窗组件。
- `UserConfigsetting.qml`：用户信息与配置展示组件，嵌入到顶部栏。

### `src/Src/Network`
- `NetworkConnection.qml`：网络连接配置或展示组件，配合 `SharedNetworkConnection` 使用。

## 数据与通信（简述）
- 网络入口：`SharedNetworkConnection`（单例）负责接收与广播数据更新，页面通过 Connections 监听。
- 车辆数据解析：`VehicleDataModel` 作为处理器，接收 JSON 字符串并解析为结构化数据。
- 攻击参数联动：`AttackDataModel` 管理每个车辆的攻击类型/方法/参数，`TechDashboard` 负责 UI 控制与更新。
- 左右页面数据共享：右侧通过 `rootWindow.leftPage` 访问左侧的数据模型集合；`currentVehicleId` 用于选中车辆的联动显示。

## 页面切换与显示逻辑
- 简洁模式（`isSimpleMode: true`）：显示 `TechDashboard`，隐藏左右页面。
- 常规模式（`isSimpleMode: false`）：显示 `Leftpage` 与 `LayoutRight`；右侧根据 `showHomePage`/`showMapPage`/`showCurvesPage` 切换具体区域。

## 维护建议
- 建议在代码中对废弃文件添加标识或移动至 `deprecated/` 文件夹，便于排除在 README 与索引之外。
- 如需扩展曲线或地图模块，优先复用 `CurveComponent` 与现有数据模型接口，保持风格与结构一致。
- 新增页面时，请在 `main.qml` 明确其显示条件与与全局状态交互方式。

