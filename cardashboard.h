
#ifndef CARDASHBOARD_H
#define CARDASHBOARD_H

#include <QPainter>
#include <QTimer>
#include <QWidget>
#include <QtMath>

class CarDashboard : public QWidget

{


    Q_OBJECT

public:
    CarDashboard(QWidget *parent,
                double minNum, double maxNum,
                double warningMin, double warningMax,
                 int num_step,int init_num,
                 const QString& speed_unit,int width,int height);


    ~CarDashboard();

    void setExpectNum(double value);

protected:
    void paintEvent(QPaintEvent *event) override;

private:
    void initDashboard(QPainter &painter);
    void drawMidCircle(QPainter &painter,int radius);
    void drawScaleLine(QPainter &painter, int radius);
    void drawScaleValue(QPainter &painter, int radius);
    void drawPoint(QPainter &painter, int radius);
    void drawSector(QPainter &painter, int radius);
    void drawInnerEllipse(QPainter& painter, int radius);
    void drawInnerEllipseBlack(QPainter& painter, int radius);
    void drawCurrentSpeed(QPainter& painter);
    void drawEllipseOutSkirts(QPainter& painter, int radius);

    int m_startAngle;//起始角度
    double m_angle2;//车速盘每个刻度角度
    double m_currentValue;//车速当前值
    QTimer m_timer;
    bool m_flag;//指针转动标志位

    // the m_angle2 is Decide the angle of each rotation
    // the total angle is 240 degrees
    int total_degrees;
    double warning_deggres;
    double minwarning_deggres;

    double start_painter;
    double end_painter;
    double show_num;
    double m_warnminNum;
    double m_warnmaxNum;
    QString m_unit;
};

#endif // CARDASHBOARD_H
