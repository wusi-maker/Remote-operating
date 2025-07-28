#ifndef MAPCANVAS_H
#define MAPCANVAS_H

#include <QWidget>
#include <QVector>
#include <QPointF>
#include <QColor>
#include <QtMath> // 包含数学函数头文件

class MapCanvas : public QWidget
{
    Q_OBJECT
public:
    explicit MapCanvas(QWidget *parent = nullptr);

    // 配置接口
    void setChinaRange(bool enable);
    void setScaleFactor(double factor);
    void setGridVisible(bool visible);
    void setTrackColor(const QColor &color);
    void setPointSize(int size);
    void setHighPrecisionMode(bool enable, int decimalPlaces = 7);

public slots:
    void addPoint(double latitude, double longitude);
    void clearPoints();
    void exportToImage(const QString &filename);

protected:
    void paintEvent(QPaintEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void contextMenuEvent(QContextMenuEvent *event) override;

private:
    QPointF latLonToCanvas(double latitude, double longitude);
    void drawGrid(QPainter *painter);
    void drawCoordinateTooltip(QPainter *painter, const QPointF &pos);
    bool isCoordinateValid(double lat, double lon); // 坐标有效性检查

    // 配置参数
    bool m_chinaRange = true;
    bool m_showGrid = true;
    bool m_highPrecisionMode = true;
    int m_decimalPlaces = 7;
    double m_baseScaleFactor = 1e6; // 基础缩放因子（对应小数点后6位）
    double m_dynamicScale = 1.0;     // 动态缩放系数（根据数据自动调整）
    int m_pointSize = 4;
    QColor m_trackColor = QColor(0, 0, 255, 150);
    QColor m_currentPointColor = Qt::red;
    QColor m_historyPointColor = QColor(144, 238, 144, 200);

    // 数据存储（使用整数存储原点坐标，避免浮点误差）
    qint64 m_originLatInt = 0; // 原点纬度（放大m_baseScaleFactor倍后的整数）
    qint64 m_originLonInt = 0; // 原点经度（放大m_baseScaleFactor倍后的整数）
    QVector<QPointF> m_points; // 存储画布坐标（浮点型，用于绘制）

    // 交互状态
    QPointF m_lastMousePos;
    bool m_showTooltip = false;
};

#endif // MAPCANVAS_H
