#include "mapcanvas.h"
#include <QPainter>
#include <QMouseEvent>
#include <QMenu>
#include <QFileDialog>
#include <QDebug>
#include <climits> // 包含整数范围头文件
MapCanvas::MapCanvas(QWidget *parent) : QWidget(parent)
{
    setMinimumSize(300, 240);
    setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
    setMouseTracking(true);
    setHighPrecisionMode(true, 6); // 默认启用6位精度（对应1e6缩放）
}


void MapCanvas::setHighPrecisionMode(bool enable, int decimalPlaces)
{
    m_highPrecisionMode = enable;
    m_decimalPlaces = qBound(6, decimalPlaces, 10); // 限制精度范围6-10位
    m_baseScaleFactor = qPow(10.0, m_decimalPlaces); // 计算基础缩放因子（如6位→1e6）
    update();
}

// 坐标有效性检查（防止数值溢出）
bool MapCanvas::isCoordinateValid(double lat, double lon)
{
    // 检查经纬度是否在64位整数范围内（放大后）
    qint64 latInt = static_cast<qint64>(lat * m_baseScaleFactor);
    qint64 lonInt = static_cast<qint64>(lon * m_baseScaleFactor);
    return (latInt >= INT64_MIN && latInt <= INT64_MAX &&
            lonInt >= INT64_MIN && lonInt <= INT64_MAX);
}

// ================= 配置方法 =================
void MapCanvas::setChinaRange(bool enable) {
    m_chinaRange = enable;
}

void MapCanvas::setGridVisible(bool visible) {
    m_showGrid = visible;
    update();
}

void MapCanvas::setTrackColor(const QColor &color) {
    m_trackColor = color;
    update();
}

void MapCanvas::setPointSize(int size) {
    m_pointSize = qMax(1, size);
    update();
}

// ================= 核心功能 =================
// MapCanvas::addPoint() 修改
void MapCanvas::addPoint(double latitude, double longitude)
{
    // 中国区域限制（可注释掉测试）
    if (m_chinaRange && !isCoordinateValid(latitude, longitude)) {
        qWarning() << "Invalid coordinate (China range):" << latitude << longitude;
        return;
    }

    QPointF canvasPoint = latLonToCanvas(latitude, longitude);
    if (canvasPoint.isNull()) return; // 跳过无效坐标

    m_points.append(canvasPoint);

    // 限制历史点数（防止内存溢出）
    const int maxPoints = 2000;
    if (m_points.size() > maxPoints) {
        m_points.removeFirst();
    }

    update(); // 触发重绘
}
// MapCanvas::latLonToCanvas() 修改
// 核心坐标转换函数
QPointF MapCanvas::latLonToCanvas(double latitude, double longitude)
{
    if (!isCoordinateValid(latitude, longitude)) {
        qWarning() << "Coordinate overflow:" << latitude << longitude;
        return QPointF(); // 返回无效点
    }

    // 转换为整数坐标（避免浮点误差）
    qint64 latInt = static_cast<qint64>(latitude * m_baseScaleFactor);
    qint64 lonInt = static_cast<qint64>(longitude * m_baseScaleFactor);

    // 首次添加点时初始化原点
    if (m_points.isEmpty()) {
        m_originLatInt = latInt;
        m_originLonInt = lonInt;
        m_dynamicScale = 1.0; // 初始动态缩放系数
    }

    // 计算相对于原点的偏移（整数运算，无精度损失）
    qint64 dLat = latInt - m_originLatInt;
    qint64 dLon = lonInt - m_originLonInt;

    // 动态缩放计算（根据数据分布自动调整，防止画布超出范围）
    if (m_points.size() > 10) { // 积累一定点数后开始动态调整
        double maxOffset = 0;
        for (const QPointF& p : m_points) {
            maxOffset = qMax(maxOffset, qMax(qAbs(p.x()), qAbs(p.y())));
        }
        if (maxOffset > 0) {
            m_dynamicScale = qMin(width(), height()) / (2.0 * maxOffset); // 保持数据在画布中心±1/2范围内
            m_dynamicScale = qMax(0.1, m_dynamicScale); // 最小缩放系数0.1
        }
    }

    // 转换为画布坐标（浮点型，用于绘制）
    double centerX = width() / 2.0;
    double centerY = height() / 2.0;
    double x = centerX + (static_cast<double>(dLon) * m_dynamicScale);
    double y = centerY - (static_cast<double>(dLat) * m_dynamicScale);

    return QPointF(x, y);
}

void MapCanvas::drawGrid(QPainter *painter)
{
    if (!m_highPrecisionMode) return;

    painter->setPen(QPen(Qt::lightGray, 0.5));
    int centerX = width() / 2;
    int centerY = height() / 2;

    // 网格步长：根据精度和动态缩放计算（单位：度）
    double gridStepDeg = qPow(10.0, -(m_decimalPlaces - 4)) * m_dynamicScale; // 显示0.0001度级别网格
    double gridStepPx = gridStepDeg * m_baseScaleFactor; // 转换为画布像素步长

    // 绘制水平/垂直网格线
    for (double y = centerY; y < height(); y += gridStepPx) {
        painter->drawLine(0, y, width(), y);
    }
    for (double y = centerY; y > 0; y -= gridStepPx) {
        painter->drawLine(0, y, width(), y);
    }
    for (double x = centerX; x < width(); x += gridStepPx) {
        painter->drawLine(x, 0, x, height());
    }
    for (double x = centerX; x > 0; x -= gridStepPx) {
        painter->drawLine(x, 0, x, height());
    }
}





void MapCanvas::clearPoints()
{
    m_points.clear();
    m_originLatInt = 0;  // 正确类型赋值
    m_originLonInt = 0;  // 正确类型赋值
    m_dynamicScale = 1.0;  // 重置动态缩放
    update();
}

void MapCanvas::exportToImage(const QString &filename)
{
    QPixmap pixmap(size());
    render(&pixmap);
    pixmap.save(filename);
}

// ================= 绘图逻辑 =================
void MapCanvas::paintEvent(QPaintEvent *event)
{
    Q_UNUSED(event);
    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing, true);

    // 1. 绘制背景
    painter.fillRect(rect(), QColor(240, 240, 240));

    // 2. 绘制网格
    if (m_showGrid) {
        drawGrid(&painter);
    }

    // 3. 绘制轨迹
    if (!m_points.isEmpty()) {
        // 轨迹线
        painter.setPen(QPen(m_trackColor, 2.5));
        painter.drawPolyline(m_points);

        // 历史点
        painter.setBrush(m_historyPointColor);
        painter.setPen(Qt::NoPen);
        for (const QPointF &p : m_points) {
            painter.drawEllipse(p, m_pointSize, m_pointSize);
        }

        // 当前点（带白边）
        painter.setPen(QPen(Qt::white, 1.5));
        painter.setBrush(m_currentPointColor);
        painter.drawEllipse(m_points.last(), m_pointSize * 1.5, m_pointSize * 1.5);

        // 坐标原点标记
        double originLat = static_cast<double>(m_originLatInt) / m_baseScaleFactor;
        double originLon = static_cast<double>(m_originLonInt) / m_baseScaleFactor;
        QPointF origin = latLonToCanvas(originLat, originLon);

        painter.setPen(QPen(Qt::blue, 1));
        painter.drawLine(origin.x()-8, origin.y(), origin.x()+8, origin.y());
        painter.drawLine(origin.x(), origin.y()-8, origin.x(), origin.y()+8);
    }

    // 4. 鼠标悬停提示
    if (m_showTooltip) {
        drawCoordinateTooltip(&painter, m_lastMousePos);
    }
}

// ================= 交互功能 =================
void MapCanvas::mouseMoveEvent(QMouseEvent *event)
{
    m_lastMousePos = event->pos();
    m_showTooltip = !m_points.isEmpty();
    update();
}

void MapCanvas::drawCoordinateTooltip(QPainter *painter, const QPointF &pos)
{
    // 先将整数原点转换回浮点数
    double originLat = static_cast<double>(m_originLatInt) / m_baseScaleFactor;
    double originLon = static_cast<double>(m_originLonInt) / m_baseScaleFactor;

    // 计算反向坐标（考虑动态缩放）
    int centerX = width() / 2;
    int centerY = height() / 2;
    double lon = originLon + (pos.x() - centerX) / (m_baseScaleFactor * m_dynamicScale);
    double lat = originLat - (pos.y() - centerY) / (m_baseScaleFactor * m_dynamicScale);

    // 绘制工具提示
    QString text = QString("经度: %1\n纬度: %2").arg(lon, 0, 'f', m_decimalPlaces)
                       .arg(lat, 0, 'f', m_decimalPlaces);
    QRect tooltipRect(pos.x() + 15, pos.y() - 40, 150, 40);

    painter->setPen(QPen(Qt::black, 1));
    painter->setBrush(QColor(255, 255, 225));
    painter->drawRect(tooltipRect);
    painter->drawText(tooltipRect, Qt::AlignCenter, text);
}

void MapCanvas::contextMenuEvent(QContextMenuEvent *event)
{
    QMenu menu(this);

    // 导出图片
    QAction *exportAction = menu.addAction("导出图片");
    connect(exportAction, &QAction::triggered, [this]() {
        QString file = QFileDialog::getSaveFileName(this, "保存图片", "", "PNG图像(*.png)");
        if (!file.isEmpty()) exportToImage(file);
    });

    // 清空轨迹
    QAction *clearAction = menu.addAction("清空轨迹");
    connect(clearAction, &QAction::triggered, this, &MapCanvas::clearPoints);

    menu.exec(event->globalPos());
}
