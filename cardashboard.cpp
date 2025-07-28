#include "cardashboard.h"
#include <QHBoxLayout>
#include <QPushButton>
#include<QDebug>

CarDashboard::CarDashboard(QWidget *parent,
                           double minNum=0, double maxNum=240,
                           double warningMin=0, double warningMax=160,
                           int num_step=20,int init_num=0,
                           const QString& speed_unit="km/h",int width=500,int height=420)
    : QWidget(parent)
{


    // 设置窗口标题和大小
    setWindowTitle("汽车仪表盘");
    resize(width, height);
    // the first Angle of pointer
    m_startAngle = 150;
    // control pointer
    m_currentValue = init_num;
    m_flag = true;

    // the m_angle2 is Decide the angle of each rotation
    // the total angle is 240 degrees
    end_painter=maxNum;
    start_painter=minNum;
    m_warnmaxNum=warningMax;
    m_warnminNum=warningMin;
    m_unit=speed_unit;
    show_num=num_step/5.0;
    total_degrees=((maxNum-minNum)/num_step)*5;
    warning_deggres=((warningMax-minNum)/num_step)*5;
    minwarning_deggres=((warningMin-minNum)/num_step)*5;
    m_angle2 = 240 * 1.0 / total_degrees;
    qDebug()<<"minwarning_deggres"<<minwarning_deggres<<"warning_deggres"<<warning_deggres;


}

CarDashboard::~CarDashboard()
{


}

// cardashboard.cpp
void CarDashboard::setExpectNum(double num) {
    m_currentValue = num; // 存储数值
    //刷新控件,
    update();}

void CarDashboard::paintEvent(QPaintEvent *event)
{


    QPainter painter(this);
    int dashBoad_r = height()/2;//仪表盘半径(half of widget)
    // qDebug()<<height()<<"and "<<width();
    initDashboard(painter);
    drawMidCircle(painter,50);
    drawScaleLine(painter, dashBoad_r);
    drawScaleValue(painter, dashBoad_r);
    drawPoint(painter, dashBoad_r);
    drawSector(painter, dashBoad_r+25);
    drawInnerEllipse(painter, 80);
    drawInnerEllipseBlack(painter, 60);

    drawCurrentSpeed(painter);
    drawEllipseOutSkirts(painter, dashBoad_r+25);
}

//初始化仪表盘背景及画笔样式
void CarDashboard::initDashboard(QPainter &painter)
{


    //消除锯齿
    painter.setRenderHint(QPainter::Antialiasing,true);
    //设置底色
    painter.setBrush(QColor(0,0,0));
    //绘制矩形
    painter.drawRect(rect());

}

//绘制中心小圆
void CarDashboard::drawMidCircle(QPainter &painter, int radius)
{


    //设置画笔颜色和宽度
    painter.setPen(QPen(QColor(255,255,255),3));
    //设置中心坐标点
    float center_X=rect().width()/2.0;
    float center_Y=rect().height()*0.7;
    QPoint center(center_X, center_Y);
    //平移坐标点
    painter.translate(center);
    //原点坐标（0，0）绘制半径为radius的圆
    painter.drawEllipse(QPoint(0,0), radius, radius);


    // painter the second rotundity
    // center.setX(cw);
    // center.setY(0);
    // painter.translate(center);
    // painter.drawEllipse(QPoint(0,0), radius, radius);
}

//绘制仪表盘
void CarDashboard::drawScaleLine(QPainter &painter, int radius)
{

    //保存当前坐标
    painter.save();
    painter.setPen(QPen(Qt::white, 5));
    //设置起始刻度位置
    painter.rotate(m_startAngle);
    for(int i=0; i <= total_degrees; i++){

        // 每次循环开始时重置为默认白色画笔
        painter.setPen(QPen(Qt::white, 5));
        if(i >=warning_deggres )
            painter.setPen(QPen(Qt::yellow, 5));
        if(i<=minwarning_deggres)
        {
            painter.setPen(QPen(Qt::yellow, 5));
        }
        if(i % 5 == 0)
            painter.drawLine(radius-20, 0, radius-3, 0);//绘制长刻度
        else
            painter.drawLine(radius-8, 0, radius-3, 0);//绘制短刻度
        //绘制完一个刻度旋转一次坐标
        painter.rotate(m_angle2);
    }
    //恢复坐标
    painter.restore();
    painter.setPen(QPen(Qt::white, 5));

}


//绘制刻度值
void CarDashboard::drawScaleValue(QPainter &painter, int radius)
{
    //设置字体类型和大小
    QFont textFont("Arial",15);
    //设置粗体
    textFont.setBold(true);
    painter.setFont(textFont);
    int text_r = radius - 49;


    int num=start_painter-show_num*5;

    for(int i = 0; i <=total_degrees; i++)
    {
        if(i % 5 == 0)
        {
            painter.setPen(QPen(Qt::white, 5));

            num+=show_num*5;
            if(i>=warning_deggres)
                painter.setPen(QPen(Qt::yellow, 5));
            if(i<=minwarning_deggres)
            {
                painter.setPen(QPen(Qt::yellow, 5));
            }
            //保存当前坐标系
            painter.save();
            int delX = qCos((210-m_angle2*i)*M_PI/180) * text_r;
            int delY = qSin(qDegreesToRadians(210-m_angle2*i)) * text_r;
            //平移坐标系
            painter.translate(QPoint(delX,-delY));
            //旋转坐标系
            painter.rotate(-120+m_angle2*i);
            //写上刻度值，文字居中
            painter.drawText(-25,-25,50,30,Qt::AlignCenter,QString::number(num));
            //恢复坐标系
            painter.restore();
        }
    }
    painter.setPen(QPen(Qt::white, 5));
}

//绘制指针
void CarDashboard::drawPoint(QPainter &painter, int radius)
{


    //保存当前坐标
    painter.save();
    //设置画刷颜色
    painter.setBrush(Qt::white);
    //设置画笔为无线条
    painter.setPen(Qt::NoPen);
    static const QPointF points[4] = {
        QPointF(0, 0.0),
        QPointF(radius*0.6, -1.1),
        QPointF(radius*0.6, 1.1),
        QPointF(0, 15.0)
    };
    double ecpect_rotaion=((m_currentValue-start_painter)/(end_painter-start_painter))*total_degrees*m_angle2;
    // qDebug()<<m_currentValue<<"and"<< (m_currentValue-start_painter)/end_painter;
    //坐标选旋转
    painter.rotate(m_startAngle+ecpect_rotaion );
    //绘制多边形
    painter.drawPolygon(points, 4);
    //恢复坐标
    painter.restore();




}

//画扇形
void CarDashboard::drawSector(QPainter &painter, int radius)
{


    //定义矩形区域
    QRect rentangle(-radius, -radius, radius*2, radius*2);
    //设置画笔无线条
    painter.setPen(Qt::NoPen);
    //设置画刷颜色


    painter.setBrush(QColor(170,170,0,80));

    painter.drawPie(rentangle, (360-150)*16, -0 * 0*16);
}


// 画渐变内圆
void CarDashboard::drawInnerEllipse(QPainter &painter, int radius)
{


    QRadialGradient radial(0,0,radius);
    //中心颜色
    radial.setColorAt(0.0,QColor(255,170,0,200));
    //外围颜色
    radial.setColorAt(1.0,QColor(0,0,0,100));
    //设置画刷渐变色
    painter.setBrush(radial);
    //画圆形
    painter.drawEllipse(QPoint(0,0), radius, radius);


    // painter.drawEllipse(QPoint(0,0), radius, radius);

}

// 画黑色内圈
void CarDashboard::drawInnerEllipseBlack(QPainter &painter, int radius)
{


    //设置画刷
    painter.setBrush(Qt::black);
    //绘制圆形
    // painter.drawEllipse(QPoint(0,0), radius, radius);


    painter.drawEllipse(QPoint(0,0), radius, radius);
}

//绘制当前数值
void CarDashboard::drawCurrentSpeed(QPainter &painter)
{


    painter.setPen(Qt::white);
    //绘制数值
    QFont font("Arial", 18);
    font.setBold(true);
    painter.setFont(font);
    if(m_currentValue>m_warnmaxNum||m_currentValue< m_warnminNum||m_currentValue== m_warnminNum||m_currentValue== m_warnmaxNum)
        painter.setPen(Qt::yellow);
    painter.drawText(QRect(-60,-60,120,70),Qt::AlignCenter,QString::number(m_currentValue, 'f', 1));
    //绘制单位
    QFont font_u("Arial", 13);
    painter.setFont(font_u);
    painter.drawText(QRect(-60,-60,120,160),Qt::AlignCenter,m_unit);



}

// 画外壳，发光外圈

void CarDashboard::drawEllipseOutSkirts(QPainter &painter, int radius)
{


    //设置扇形绘制区域
    QRect outAngle(-radius, -radius, 2*radius, 2*radius);
    painter.setPen(Qt::NoPen);
    //设置渐变色
    QRadialGradient radia(0,0,radius);



    radia.setColorAt(1,QColor(255,170,0,200));
    radia.setColorAt(0.97,QColor(255,170,0,120));
    radia.setColorAt(0.9,QColor(0,0,0,0));
    radia.setColorAt(0,QColor(0,0,0,0));
    painter.setBrush(radia);
    painter.drawPie(outAngle,(360-150)*16,-m_angle2*61*16);
}

