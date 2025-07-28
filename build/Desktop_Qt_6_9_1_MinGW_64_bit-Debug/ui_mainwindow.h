/********************************************************************************
** Form generated from reading UI file 'mainwindow.ui'
**
** Created by: Qt User Interface Compiler version 6.9.1
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_MAINWINDOW_H
#define UI_MAINWINDOW_H

#include <QtCore/QVariant>
#include <QtWidgets/QApplication>
#include <QtWidgets/QFormLayout>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QHeaderView>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QMainWindow>
#include <QtWidgets/QMenuBar>
#include <QtWidgets/QProgressBar>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QStatusBar>
#include <QtWidgets/QTabWidget>
#include <QtWidgets/QTableWidget>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_MainWindow
{
public:
    QWidget *centralwidget;
    QLabel *TitleLabel;
    QGroupBox *groupBox_2;
    QVBoxLayout *verticalLayout;
    QHBoxLayout *horizontalLayout_2;
    QWidget *angularVal;
    QWidget *linerVal;
    QWidget *ori_angular;
    QGroupBox *groupBox;
    QVBoxLayout *verticalLayout_3;
    QWidget *widget;
    QVBoxLayout *verticalLayout_2;
    QLabel *udp_ffmpeg;
    QHBoxLayout *horizontalLayout;
    QSpacerItem *horizontalSpacer;
    QPushButton *start;
    QPushButton *cencel;
    QSpacerItem *horizontalSpacer_2;
    QGroupBox *groupBox_6;
    QVBoxLayout *verticalLayout_7;
    QWidget *widget_2;
    QTableWidget *tableWidget;
    QGroupBox *groupBox_3;
    QTabWidget *tabWidget;
    QWidget *tab_1;
    QGridLayout *gridLayout;
    QWidget *carRpm;
    QWidget *carAngle;
    QWidget *carVal;
    QWidget *tab_2;
    QHBoxLayout *horizontalLayout_10;
    QWidget *gaugeRpm;
    QVBoxLayout *verticalLayout_4;
    QWidget *gaugeAngle;
    QGroupBox *groupBox_7;
    QHBoxLayout *horizontalLayout_9;
    QFormLayout *formLayout;
    QLabel *label_19;
    QProgressBar *progressBar;
    QLabel *label_20;
    QProgressBar *progressBar_2;
    QGroupBox *groupBox_4;
    QVBoxLayout *verticalLayout_6;
    QHBoxLayout *horizontalLayout_4;
    QLabel *label_15;
    QLineEdit *lineEdit_6;
    QHBoxLayout *horizontalLayout_7;
    QLabel *label_16;
    QLineEdit *lineEdit_5;
    QHBoxLayout *horizontalLayout_12;
    QLabel *label_2;
    QLabel *Transerve_val;
    QHBoxLayout *horizontalLayout_13;
    QLabel *label;
    QLabel *Longitudinal_val;
    QHBoxLayout *horizontalLayout_14;
    QLabel *label_3;
    QLabel *wheel_rpm;
    QHBoxLayout *horizontalLayout_15;
    QLabel *label_4;
    QLabel *wheel_angle;
    QHBoxLayout *horizontalLayout_17;
    QLabel *label_6;
    QLabel *wheel_angle_2;
    QHBoxLayout *horizontalLayout_18;
    QLabel *label_8;
    QLabel *wheel_angle_3;
    QGroupBox *groupBox_5;
    QHBoxLayout *horizontalLayout_6;
    QTabWidget *tabWidget_2;
    QWidget *tab_3;
    QVBoxLayout *verticalLayout_8;
    QHBoxLayout *horizontalLayout_5;
    QLabel *label_17;
    QLineEdit *lineEdit_7;
    QHBoxLayout *horizontalLayout_8;
    QLabel *label_18;
    QLineEdit *lineEdit_8;
    QHBoxLayout *horizontalLayout_16;
    QLabel *label_5;
    QLabel *Transerve_val_2;
    QHBoxLayout *horizontalLayout_21;
    QLabel *label_11;
    QLabel *Longitudinal_val_2;
    QHBoxLayout *horizontalLayout_19;
    QLabel *label_7;
    QLabel *wheel_angle_5;
    QHBoxLayout *horizontalLayout_20;
    QLabel *label_10;
    QLabel *wheel_angle_6;
    QHBoxLayout *horizontalLayout_3;
    QLabel *label_9;
    QLabel *wheel_angle_4;
    QWidget *tab_4;
    QMenuBar *menubar;
    QStatusBar *statusbar;

    void setupUi(QMainWindow *MainWindow)
    {
        if (MainWindow->objectName().isEmpty())
            MainWindow->setObjectName("MainWindow");
        MainWindow->resize(1930, 1099);
        MainWindow->setMinimumSize(QSize(1830, 0));
        MainWindow->setStyleSheet(QString::fromUtf8("\n"
" /* ====== \345\205\250\345\261\200\346\267\261\350\211\262\344\270\273\351\242\230 ====== */\n"
" QWidget {\n"
"     background-color: #2b2b2b;  /* \344\270\273\350\203\214\346\231\257\350\211\262 */\n"
"     color: #f0f0f0;            /* \351\273\230\350\256\244\346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"     font-family: \"Segoe UI\", \"Microsoft YaHei\", sans-serif;\n"
"     font-size: 14pt;\n"
"     border: none;\n"
" }\n"
"\n"
" /* ====== \346\240\207\351\242\230\346\240\207\347\255\276 ====== */\n"
" QLabel#TitleLabel {\n"
"     color: #ffa726;            /* \346\251\231\350\211\262\346\240\207\351\242\230 */\n"
"     font-size: 20pt;\n"
"     font-weight: bold;\n"
"     padding: 6px 4px;\n"
"     border-bottom: 2px solid #ffa726;\n"
" }\n"
"\n"
" /* ====== \351\200\232\347\224\250\346\240\207\347\255\276 ====== */\n"
" QLabel {\n"
"     color: #f0f0f0;\n"
"     padding: 2px;\n"
" }\n"
"\n"
" /* ====== \345\270\246\350\276\271\346\241\206\347\232\204\346\240\207\347\255\276\357\274\210\345"
                        "\246\202\346\225\260\346\215\256\345\261\225\347\244\272\357\274\211===== */\n"
" QLabel#label_distanceAhead,\n"
" QLabel#label_RadarData,\n"
" QLabel#label_mileage,\n"
" QLabel#label_frameNumber,\n"
" QLabel#label_fuelTankCapacity {\n"
"     border: 2px solid #ffa726;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"     border-radius: 4px;\n"
"     padding: 4px;\n"
"     background-color: #3c3f41;  /* \346\232\227\347\201\260\350\211\262\345\241\253\345\205\205 */\n"
" }\n"
"\n"
" /* ====== \350\276\223\345\205\245\346\241\206 ====== */\n"
" QLineEdit {\n"
"     background-color: #3c3f41;\n"
"     border: 1px solid #5c5c5c;\n"
"     border-radius: 4px;\n"
"     padding: 4px;\n"
"     color: #ffffff;\n"
" }\n"
"\n"
" /* ====== \346\214\211\351\222\256 ====== */\n"
" QPushButton {\n"
"     background-color: #8e3e1f;  /* \346\267\261\346\251\231\350\211\262 */\n"
"     color: #ffffff;\n"
"     border: 1px solid #aa5c33;\n"
"     border-radius: 6px;\n"
"     padding: 6px 12px;\n"
"     font-weight: bo"
                        "ld;\n"
" }\n"
"\n"
" /* \346\202\254\345\201\234\346\225\210\346\236\234 */\n"
" QPushButton:hover {\n"
"     background-color: #a34b27;  /* \344\272\256\346\251\231\350\211\262 */\n"
" }\n"
"\n"
" /* \351\200\211\344\270\255\347\212\266\346\200\201\357\274\210\345\246\202\345\274\200\345\205\263\346\214\211\351\222\256\357\274\211 */\n"
" QPushButton:checked {\n"
"     background-color: #2e7d5b;  /* \346\267\261\347\273\277\350\211\262 */\n"
"     border-color: #3fa376;\n"
" }\n"
"\n"
" /* \347\246\201\347\224\250\347\212\266\346\200\201 */\n"
" QPushButton:disabled {\n"
"     background-color: #444444;\n"
"     color: #888888;\n"
" }\n"
"\n"
" /* ====== \345\210\206\347\273\204\346\241\206 ====== */\n"
" QGroupBox {\n"
"     border: 1px solid #5c5c5c;\n"
"     border-radius: 6px;\n"
"     margin-top: 10px;\n"
"     padding-top: 15px;\n"
" }\n"
"\n"
" QGroupBox::title {\n"
"     color: #dcdcdc;\n"
"     subcontrol-origin: margin;\n"
"     padding-left: 6px;\n"
" }\n"
"    "));
        centralwidget = new QWidget(MainWindow);
        centralwidget->setObjectName("centralwidget");
        TitleLabel = new QLabel(centralwidget);
        TitleLabel->setObjectName("TitleLabel");
        TitleLabel->setGeometry(QRect(9, 9, 1930, 54));
        TitleLabel->setAlignment(Qt::AlignmentFlag::AlignCenter);
        groupBox_2 = new QGroupBox(centralwidget);
        groupBox_2->setObjectName("groupBox_2");
        groupBox_2->setGeometry(QRect(11, 71, 581, 441));
        groupBox_2->setMinimumSize(QSize(501, 441));
        groupBox_2->setStyleSheet(QString::fromUtf8("background-color:#2B2B2B"));
        verticalLayout = new QVBoxLayout(groupBox_2);
        verticalLayout->setObjectName("verticalLayout");
        horizontalLayout_2 = new QHBoxLayout();
        horizontalLayout_2->setObjectName("horizontalLayout_2");
        angularVal = new QWidget(groupBox_2);
        angularVal->setObjectName("angularVal");

        horizontalLayout_2->addWidget(angularVal);

        linerVal = new QWidget(groupBox_2);
        linerVal->setObjectName("linerVal");

        horizontalLayout_2->addWidget(linerVal);


        verticalLayout->addLayout(horizontalLayout_2);

        ori_angular = new QWidget(groupBox_2);
        ori_angular->setObjectName("ori_angular");

        verticalLayout->addWidget(ori_angular);

        groupBox = new QGroupBox(centralwidget);
        groupBox->setObjectName("groupBox");
        groupBox->setGeometry(QRect(10, 520, 581, 501));
        groupBox->setMinimumSize(QSize(0, 0));
        groupBox->setStyleSheet(QString::fromUtf8(""));
        verticalLayout_3 = new QVBoxLayout(groupBox);
        verticalLayout_3->setObjectName("verticalLayout_3");
        widget = new QWidget(groupBox);
        widget->setObjectName("widget");
        verticalLayout_2 = new QVBoxLayout(widget);
        verticalLayout_2->setObjectName("verticalLayout_2");
        udp_ffmpeg = new QLabel(widget);
        udp_ffmpeg->setObjectName("udp_ffmpeg");
        udp_ffmpeg->setMinimumSize(QSize(0, 0));

        verticalLayout_2->addWidget(udp_ffmpeg);

        horizontalLayout = new QHBoxLayout();
        horizontalLayout->setObjectName("horizontalLayout");
        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Policy::Expanding, QSizePolicy::Policy::Minimum);

        horizontalLayout->addItem(horizontalSpacer);

        start = new QPushButton(widget);
        start->setObjectName("start");

        horizontalLayout->addWidget(start);

        cencel = new QPushButton(widget);
        cencel->setObjectName("cencel");

        horizontalLayout->addWidget(cencel);

        horizontalSpacer_2 = new QSpacerItem(40, 20, QSizePolicy::Policy::Expanding, QSizePolicy::Policy::Minimum);

        horizontalLayout->addItem(horizontalSpacer_2);


        verticalLayout_2->addLayout(horizontalLayout);


        verticalLayout_3->addWidget(widget);

        groupBox_6 = new QGroupBox(centralwidget);
        groupBox_6->setObjectName("groupBox_6");
        groupBox_6->setGeometry(QRect(1440, 70, 471, 951));
        groupBox_6->setMinimumSize(QSize(0, 0));
        verticalLayout_7 = new QVBoxLayout(groupBox_6);
        verticalLayout_7->setObjectName("verticalLayout_7");
        widget_2 = new QWidget(groupBox_6);
        widget_2->setObjectName("widget_2");
        widget_2->setMinimumSize(QSize(430, 350));

        verticalLayout_7->addWidget(widget_2);

        tableWidget = new QTableWidget(groupBox_6);
        if (tableWidget->columnCount() < 3)
            tableWidget->setColumnCount(3);
        QFont font;
        font.setPointSize(14);
        QTableWidgetItem *__qtablewidgetitem = new QTableWidgetItem();
        __qtablewidgetitem->setFont(font);
        tableWidget->setHorizontalHeaderItem(0, __qtablewidgetitem);
        QTableWidgetItem *__qtablewidgetitem1 = new QTableWidgetItem();
        __qtablewidgetitem1->setFont(font);
        tableWidget->setHorizontalHeaderItem(1, __qtablewidgetitem1);
        QTableWidgetItem *__qtablewidgetitem2 = new QTableWidgetItem();
        __qtablewidgetitem2->setFont(font);
        tableWidget->setHorizontalHeaderItem(2, __qtablewidgetitem2);
        if (tableWidget->rowCount() < 14)
            tableWidget->setRowCount(14);
        tableWidget->setObjectName("tableWidget");
        tableWidget->setMinimumSize(QSize(41, 0));
        tableWidget->setRowCount(14);
        tableWidget->horizontalHeader()->setMinimumSectionSize(140);
        tableWidget->horizontalHeader()->setDefaultSectionSize(140);
        tableWidget->verticalHeader()->setMinimumSectionSize(40);
        tableWidget->verticalHeader()->setDefaultSectionSize(40);

        verticalLayout_7->addWidget(tableWidget);

        groupBox_3 = new QGroupBox(centralwidget);
        groupBox_3->setObjectName("groupBox_3");
        groupBox_3->setGeometry(QRect(610, 70, 821, 521));
        groupBox_3->setMinimumSize(QSize(0, 0));
        groupBox_3->setStyleSheet(QString::fromUtf8(""));
        tabWidget = new QTabWidget(groupBox_3);
        tabWidget->setObjectName("tabWidget");
        tabWidget->setGeometry(QRect(10, 35, 810, 481));
        QFont font1;
        font1.setFamilies({QString::fromUtf8("Segoe UI")});
        font1.setPointSize(14);
        font1.setItalic(false);
        tabWidget->setFont(font1);
        tab_1 = new QWidget();
        tab_1->setObjectName("tab_1");
        gridLayout = new QGridLayout(tab_1);
        gridLayout->setObjectName("gridLayout");
        carRpm = new QWidget(tab_1);
        carRpm->setObjectName("carRpm");
        carRpm->setMinimumSize(QSize(0, 0));

        gridLayout->addWidget(carRpm, 0, 0, 1, 1);

        carAngle = new QWidget(tab_1);
        carAngle->setObjectName("carAngle");
        carAngle->setMinimumSize(QSize(0, 0));

        gridLayout->addWidget(carAngle, 0, 1, 1, 1);

        carVal = new QWidget(tab_1);
        carVal->setObjectName("carVal");
        carVal->setMinimumSize(QSize(0, 0));

        gridLayout->addWidget(carVal, 1, 0, 1, 2);

        tabWidget->addTab(tab_1, QString());
        tab_2 = new QWidget();
        tab_2->setObjectName("tab_2");
        horizontalLayout_10 = new QHBoxLayout(tab_2);
        horizontalLayout_10->setObjectName("horizontalLayout_10");
        gaugeRpm = new QWidget(tab_2);
        gaugeRpm->setObjectName("gaugeRpm");
        gaugeRpm->setMinimumSize(QSize(480, 420));

        horizontalLayout_10->addWidget(gaugeRpm);

        verticalLayout_4 = new QVBoxLayout();
        verticalLayout_4->setObjectName("verticalLayout_4");
        gaugeAngle = new QWidget(tab_2);
        gaugeAngle->setObjectName("gaugeAngle");
        gaugeAngle->setMinimumSize(QSize(300, 240));

        verticalLayout_4->addWidget(gaugeAngle);

        groupBox_7 = new QGroupBox(tab_2);
        groupBox_7->setObjectName("groupBox_7");
        horizontalLayout_9 = new QHBoxLayout(groupBox_7);
        horizontalLayout_9->setObjectName("horizontalLayout_9");
        formLayout = new QFormLayout();
        formLayout->setObjectName("formLayout");
        label_19 = new QLabel(groupBox_7);
        label_19->setObjectName("label_19");
        label_19->setMinimumSize(QSize(95, 0));
        label_19->setStyleSheet(QString::fromUtf8("color: rgb(206, 92, 0);\n"
"font: 500 20pt \"aakar\";"));

        formLayout->setWidget(0, QFormLayout::ItemRole::LabelRole, label_19);

        progressBar = new QProgressBar(groupBox_7);
        progressBar->setObjectName("progressBar");
        progressBar->setLayoutDirection(Qt::LayoutDirection::LeftToRight);
        progressBar->setStyleSheet(QString::fromUtf8("font: 500 20pt \"aakar\";"));
        progressBar->setValue(24);

        formLayout->setWidget(0, QFormLayout::ItemRole::FieldRole, progressBar);

        label_20 = new QLabel(groupBox_7);
        label_20->setObjectName("label_20");
        label_20->setMinimumSize(QSize(95, 0));
        label_20->setStyleSheet(QString::fromUtf8("color: rgb(206, 92, 0);\n"
"font: 500 20pt \"aakar\";"));

        formLayout->setWidget(1, QFormLayout::ItemRole::LabelRole, label_20);

        progressBar_2 = new QProgressBar(groupBox_7);
        progressBar_2->setObjectName("progressBar_2");
        progressBar_2->setLayoutDirection(Qt::LayoutDirection::LeftToRight);
        progressBar_2->setStyleSheet(QString::fromUtf8("font: 500 20pt \"aakar\";"));
        progressBar_2->setValue(24);

        formLayout->setWidget(1, QFormLayout::ItemRole::FieldRole, progressBar_2);


        horizontalLayout_9->addLayout(formLayout);


        verticalLayout_4->addWidget(groupBox_7);


        horizontalLayout_10->addLayout(verticalLayout_4);

        tabWidget->addTab(tab_2, QString());
        groupBox_4 = new QGroupBox(centralwidget);
        groupBox_4->setObjectName("groupBox_4");
        groupBox_4->setGeometry(QRect(610, 596, 471, 427));
        groupBox_4->setMinimumSize(QSize(295, 310));
        verticalLayout_6 = new QVBoxLayout(groupBox_4);
        verticalLayout_6->setObjectName("verticalLayout_6");
        horizontalLayout_4 = new QHBoxLayout();
        horizontalLayout_4->setObjectName("horizontalLayout_4");
        label_15 = new QLabel(groupBox_4);
        label_15->setObjectName("label_15");
        label_15->setMinimumSize(QSize(95, 0));

        horizontalLayout_4->addWidget(label_15);

        lineEdit_6 = new QLineEdit(groupBox_4);
        lineEdit_6->setObjectName("lineEdit_6");
        lineEdit_6->setMinimumSize(QSize(167, 39));
        lineEdit_6->setMaximumSize(QSize(180, 16777215));

        horizontalLayout_4->addWidget(lineEdit_6);


        verticalLayout_6->addLayout(horizontalLayout_4);

        horizontalLayout_7 = new QHBoxLayout();
        horizontalLayout_7->setObjectName("horizontalLayout_7");
        label_16 = new QLabel(groupBox_4);
        label_16->setObjectName("label_16");
        label_16->setMinimumSize(QSize(95, 0));

        horizontalLayout_7->addWidget(label_16);

        lineEdit_5 = new QLineEdit(groupBox_4);
        lineEdit_5->setObjectName("lineEdit_5");
        lineEdit_5->setMinimumSize(QSize(167, 39));
        lineEdit_5->setMaximumSize(QSize(180, 16777215));

        horizontalLayout_7->addWidget(lineEdit_5);


        verticalLayout_6->addLayout(horizontalLayout_7);

        horizontalLayout_12 = new QHBoxLayout();
        horizontalLayout_12->setObjectName("horizontalLayout_12");
        label_2 = new QLabel(groupBox_4);
        label_2->setObjectName("label_2");
        label_2->setMinimumSize(QSize(95, 0));

        horizontalLayout_12->addWidget(label_2);

        Transerve_val = new QLabel(groupBox_4);
        Transerve_val->setObjectName("Transerve_val");
        Transerve_val->setMinimumSize(QSize(180, 0));
        Transerve_val->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        Transerve_val->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_12->addWidget(Transerve_val);


        verticalLayout_6->addLayout(horizontalLayout_12);

        horizontalLayout_13 = new QHBoxLayout();
        horizontalLayout_13->setObjectName("horizontalLayout_13");
        label = new QLabel(groupBox_4);
        label->setObjectName("label");
        label->setMinimumSize(QSize(95, 0));

        horizontalLayout_13->addWidget(label);

        Longitudinal_val = new QLabel(groupBox_4);
        Longitudinal_val->setObjectName("Longitudinal_val");
        Longitudinal_val->setMinimumSize(QSize(180, 0));
        Longitudinal_val->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        Longitudinal_val->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_13->addWidget(Longitudinal_val);


        verticalLayout_6->addLayout(horizontalLayout_13);

        horizontalLayout_14 = new QHBoxLayout();
        horizontalLayout_14->setObjectName("horizontalLayout_14");
        label_3 = new QLabel(groupBox_4);
        label_3->setObjectName("label_3");
        label_3->setMinimumSize(QSize(95, 0));

        horizontalLayout_14->addWidget(label_3);

        wheel_rpm = new QLabel(groupBox_4);
        wheel_rpm->setObjectName("wheel_rpm");
        wheel_rpm->setMinimumSize(QSize(180, 0));
        wheel_rpm->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        wheel_rpm->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_14->addWidget(wheel_rpm);


        verticalLayout_6->addLayout(horizontalLayout_14);

        horizontalLayout_15 = new QHBoxLayout();
        horizontalLayout_15->setObjectName("horizontalLayout_15");
        label_4 = new QLabel(groupBox_4);
        label_4->setObjectName("label_4");
        label_4->setMinimumSize(QSize(95, 0));

        horizontalLayout_15->addWidget(label_4);

        wheel_angle = new QLabel(groupBox_4);
        wheel_angle->setObjectName("wheel_angle");
        wheel_angle->setMinimumSize(QSize(180, 0));
        wheel_angle->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        wheel_angle->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_15->addWidget(wheel_angle);


        verticalLayout_6->addLayout(horizontalLayout_15);

        horizontalLayout_17 = new QHBoxLayout();
        horizontalLayout_17->setObjectName("horizontalLayout_17");
        label_6 = new QLabel(groupBox_4);
        label_6->setObjectName("label_6");
        label_6->setMinimumSize(QSize(95, 0));

        horizontalLayout_17->addWidget(label_6);

        wheel_angle_2 = new QLabel(groupBox_4);
        wheel_angle_2->setObjectName("wheel_angle_2");
        wheel_angle_2->setMinimumSize(QSize(180, 0));
        wheel_angle_2->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        wheel_angle_2->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_17->addWidget(wheel_angle_2);


        verticalLayout_6->addLayout(horizontalLayout_17);

        horizontalLayout_18 = new QHBoxLayout();
        horizontalLayout_18->setObjectName("horizontalLayout_18");
        label_8 = new QLabel(groupBox_4);
        label_8->setObjectName("label_8");
        label_8->setMinimumSize(QSize(95, 0));

        horizontalLayout_18->addWidget(label_8);

        wheel_angle_3 = new QLabel(groupBox_4);
        wheel_angle_3->setObjectName("wheel_angle_3");
        wheel_angle_3->setMinimumSize(QSize(180, 0));
        wheel_angle_3->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        wheel_angle_3->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_18->addWidget(wheel_angle_3);


        verticalLayout_6->addLayout(horizontalLayout_18);

        groupBox_5 = new QGroupBox(centralwidget);
        groupBox_5->setObjectName("groupBox_5");
        groupBox_5->setGeometry(QRect(1090, 590, 344, 431));
        horizontalLayout_6 = new QHBoxLayout(groupBox_5);
        horizontalLayout_6->setObjectName("horizontalLayout_6");
        tabWidget_2 = new QTabWidget(groupBox_5);
        tabWidget_2->setObjectName("tabWidget_2");
        tab_3 = new QWidget();
        tab_3->setObjectName("tab_3");
        verticalLayout_8 = new QVBoxLayout(tab_3);
        verticalLayout_8->setObjectName("verticalLayout_8");
        horizontalLayout_5 = new QHBoxLayout();
        horizontalLayout_5->setObjectName("horizontalLayout_5");
        label_17 = new QLabel(tab_3);
        label_17->setObjectName("label_17");
        label_17->setMinimumSize(QSize(95, 0));

        horizontalLayout_5->addWidget(label_17);

        lineEdit_7 = new QLineEdit(tab_3);
        lineEdit_7->setObjectName("lineEdit_7");
        lineEdit_7->setMinimumSize(QSize(167, 39));
        lineEdit_7->setMaximumSize(QSize(180, 16777215));

        horizontalLayout_5->addWidget(lineEdit_7);


        verticalLayout_8->addLayout(horizontalLayout_5);

        horizontalLayout_8 = new QHBoxLayout();
        horizontalLayout_8->setObjectName("horizontalLayout_8");
        label_18 = new QLabel(tab_3);
        label_18->setObjectName("label_18");
        label_18->setMinimumSize(QSize(95, 0));

        horizontalLayout_8->addWidget(label_18);

        lineEdit_8 = new QLineEdit(tab_3);
        lineEdit_8->setObjectName("lineEdit_8");
        lineEdit_8->setMinimumSize(QSize(167, 39));
        lineEdit_8->setMaximumSize(QSize(180, 16777215));

        horizontalLayout_8->addWidget(lineEdit_8);


        verticalLayout_8->addLayout(horizontalLayout_8);

        horizontalLayout_16 = new QHBoxLayout();
        horizontalLayout_16->setObjectName("horizontalLayout_16");
        label_5 = new QLabel(tab_3);
        label_5->setObjectName("label_5");
        label_5->setMinimumSize(QSize(95, 0));

        horizontalLayout_16->addWidget(label_5);

        Transerve_val_2 = new QLabel(tab_3);
        Transerve_val_2->setObjectName("Transerve_val_2");
        Transerve_val_2->setMinimumSize(QSize(180, 0));
        Transerve_val_2->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        Transerve_val_2->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_16->addWidget(Transerve_val_2);


        verticalLayout_8->addLayout(horizontalLayout_16);

        horizontalLayout_21 = new QHBoxLayout();
        horizontalLayout_21->setObjectName("horizontalLayout_21");
        label_11 = new QLabel(tab_3);
        label_11->setObjectName("label_11");
        label_11->setMinimumSize(QSize(95, 0));

        horizontalLayout_21->addWidget(label_11);

        Longitudinal_val_2 = new QLabel(tab_3);
        Longitudinal_val_2->setObjectName("Longitudinal_val_2");
        Longitudinal_val_2->setMinimumSize(QSize(180, 0));
        Longitudinal_val_2->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        Longitudinal_val_2->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_21->addWidget(Longitudinal_val_2);


        verticalLayout_8->addLayout(horizontalLayout_21);

        horizontalLayout_19 = new QHBoxLayout();
        horizontalLayout_19->setObjectName("horizontalLayout_19");
        label_7 = new QLabel(tab_3);
        label_7->setObjectName("label_7");
        label_7->setMinimumSize(QSize(95, 0));

        horizontalLayout_19->addWidget(label_7);

        wheel_angle_5 = new QLabel(tab_3);
        wheel_angle_5->setObjectName("wheel_angle_5");
        wheel_angle_5->setMinimumSize(QSize(180, 0));
        wheel_angle_5->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        wheel_angle_5->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_19->addWidget(wheel_angle_5);


        verticalLayout_8->addLayout(horizontalLayout_19);

        horizontalLayout_20 = new QHBoxLayout();
        horizontalLayout_20->setObjectName("horizontalLayout_20");
        label_10 = new QLabel(tab_3);
        label_10->setObjectName("label_10");
        label_10->setMinimumSize(QSize(95, 0));

        horizontalLayout_20->addWidget(label_10);

        wheel_angle_6 = new QLabel(tab_3);
        wheel_angle_6->setObjectName("wheel_angle_6");
        wheel_angle_6->setMinimumSize(QSize(180, 0));
        wheel_angle_6->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        wheel_angle_6->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_20->addWidget(wheel_angle_6);


        verticalLayout_8->addLayout(horizontalLayout_20);

        horizontalLayout_3 = new QHBoxLayout();
        horizontalLayout_3->setObjectName("horizontalLayout_3");
        label_9 = new QLabel(tab_3);
        label_9->setObjectName("label_9");
        label_9->setMinimumSize(QSize(110, 0));

        horizontalLayout_3->addWidget(label_9);

        wheel_angle_4 = new QLabel(tab_3);
        wheel_angle_4->setObjectName("wheel_angle_4");
        wheel_angle_4->setMinimumSize(QSize(180, 0));
        wheel_angle_4->setStyleSheet(QString::fromUtf8("QLabel {\n"
"    border: 2px solid #FFA500;  /* \346\251\231\350\211\262\350\276\271\346\241\206 */\n"
"    border-radius: 5px;         /* \345\234\206\350\247\222 */\n"
"    padding: 5px;              /* \345\206\205\350\276\271\350\267\235 */\n"
"    background-color: #2B2B2B; /* \350\203\214\346\231\257\350\211\262 */\n"
"    color: white;              /* \346\226\207\345\255\227\351\242\234\350\211\262 */\n"
"}"));
        wheel_angle_4->setAlignment(Qt::AlignmentFlag::AlignCenter);

        horizontalLayout_3->addWidget(wheel_angle_4);


        verticalLayout_8->addLayout(horizontalLayout_3);

        tabWidget_2->addTab(tab_3, QString());
        tab_4 = new QWidget();
        tab_4->setObjectName("tab_4");
        tabWidget_2->addTab(tab_4, QString());

        horizontalLayout_6->addWidget(tabWidget_2);

        MainWindow->setCentralWidget(centralwidget);
        menubar = new QMenuBar(MainWindow);
        menubar->setObjectName("menubar");
        menubar->setGeometry(QRect(0, 0, 1930, 33));
        MainWindow->setMenuBar(menubar);
        statusbar = new QStatusBar(MainWindow);
        statusbar->setObjectName("statusbar");
        MainWindow->setStatusBar(statusbar);

        retranslateUi(MainWindow);

        tabWidget->setCurrentIndex(1);
        tabWidget_2->setCurrentIndex(0);


        QMetaObject::connectSlotsByName(MainWindow);
    } // setupUi

    void retranslateUi(QMainWindow *MainWindow)
    {
        MainWindow->setWindowTitle(QCoreApplication::translate("MainWindow", "MainWindow", nullptr));
        TitleLabel->setText(QCoreApplication::translate("MainWindow", "\351\201\245\346\223\215\344\275\234\345\271\263\345\217\260", nullptr));
        groupBox_2->setTitle(QCoreApplication::translate("MainWindow", "IMU\346\225\260\346\215\256", nullptr));
        groupBox->setTitle(QCoreApplication::translate("MainWindow", "\345\256\236\346\227\266\350\247\206\351\242\221", nullptr));
        udp_ffmpeg->setText(QString());
        start->setText(QCoreApplication::translate("MainWindow", "start", nullptr));
        cencel->setText(QCoreApplication::translate("MainWindow", "cencel", nullptr));
        groupBox_6->setTitle(QCoreApplication::translate("MainWindow", "\345\234\260\345\233\276\346\230\276\347\244\272", nullptr));
        QTableWidgetItem *___qtablewidgetitem = tableWidget->horizontalHeaderItem(0);
        ___qtablewidgetitem->setText(QCoreApplication::translate("MainWindow", "\346\227\266\345\210\273(s)", nullptr));
        QTableWidgetItem *___qtablewidgetitem1 = tableWidget->horizontalHeaderItem(1);
        ___qtablewidgetitem1->setText(QCoreApplication::translate("MainWindow", "\347\273\217\345\272\246", nullptr));
        QTableWidgetItem *___qtablewidgetitem2 = tableWidget->horizontalHeaderItem(2);
        ___qtablewidgetitem2->setText(QCoreApplication::translate("MainWindow", "\347\272\254\345\272\246", nullptr));
        groupBox_3->setTitle(QCoreApplication::translate("MainWindow", "\350\275\246\350\276\206\346\225\260\346\215\256", nullptr));
        tabWidget->setTabText(tabWidget->indexOf(tab_1), QCoreApplication::translate("MainWindow", "\346\233\262\347\272\277\346\230\276\347\244\272", nullptr));
        groupBox_7->setTitle(QCoreApplication::translate("MainWindow", "\350\275\246\350\276\206\347\224\265\351\207\217", nullptr));
        label_19->setText(QCoreApplication::translate("MainWindow", "\345\244\264\350\275\246\347\224\265\351\207\217:", nullptr));
        label_20->setText(QCoreApplication::translate("MainWindow", "\350\275\246\350\276\2061\347\224\265\351\207\217:", nullptr));
        tabWidget->setTabText(tabWidget->indexOf(tab_2), QCoreApplication::translate("MainWindow", "\344\273\252\350\241\250\347\233\230", nullptr));
        groupBox_4->setTitle(QCoreApplication::translate("MainWindow", "\345\244\264\350\275\246\350\241\214\351\251\266\346\225\260\346\215\256", nullptr));
        label_15->setText(QCoreApplication::translate("MainWindow", "\350\275\246\350\276\206IP:", nullptr));
        lineEdit_6->setText(QCoreApplication::translate("MainWindow", "192.168.1.108", nullptr));
        label_16->setText(QCoreApplication::translate("MainWindow", "\350\275\246\346\236\266\345\217\267:", nullptr));
        lineEdit_5->setText(QCoreApplication::translate("MainWindow", "car_master", nullptr));
        label_2->setText(QCoreApplication::translate("MainWindow", "\350\247\222\351\200\237\345\272\246", nullptr));
        Transerve_val->setText(QString());
        label->setText(QCoreApplication::translate("MainWindow", "\347\272\277\351\200\237\345\272\246:", nullptr));
        Longitudinal_val->setText(QString());
        label_3->setText(QCoreApplication::translate("MainWindow", "\350\275\256\346\257\202\350\275\254\351\200\237:", nullptr));
        wheel_rpm->setText(QString());
        label_4->setText(QCoreApplication::translate("MainWindow", "\345\211\215\350\275\256\350\275\254\345\212\250\350\247\222:", nullptr));
        wheel_angle->setText(QString());
        label_6->setText(QCoreApplication::translate("MainWindow", "X\345\235\220\346\240\207:", nullptr));
        wheel_angle_2->setText(QString());
        label_8->setText(QCoreApplication::translate("MainWindow", "Y\345\235\220\346\240\207:", nullptr));
        wheel_angle_3->setText(QString());
        groupBox_5->setTitle(QCoreApplication::translate("MainWindow", "\350\267\237\351\232\217\350\275\246\350\276\206\346\225\260\346\215\256", nullptr));
        label_17->setText(QCoreApplication::translate("MainWindow", "\350\275\246\350\276\206IP:", nullptr));
        lineEdit_7->setText(QCoreApplication::translate("MainWindow", "192.168.1.104", nullptr));
        label_18->setText(QCoreApplication::translate("MainWindow", "\350\275\246\346\236\266\345\217\267:", nullptr));
        lineEdit_8->setText(QCoreApplication::translate("MainWindow", "car_retinue1", nullptr));
        label_5->setText(QCoreApplication::translate("MainWindow", "\350\247\222\351\200\237\345\272\246:", nullptr));
        Transerve_val_2->setText(QString());
        label_11->setText(QCoreApplication::translate("MainWindow", "\347\272\277\351\200\237\345\272\246:", nullptr));
        Longitudinal_val_2->setText(QString());
        label_7->setText(QCoreApplication::translate("MainWindow", "X\345\235\220\346\240\207:", nullptr));
        wheel_angle_5->setText(QString());
        label_10->setText(QCoreApplication::translate("MainWindow", "Y\345\235\220\346\240\207:", nullptr));
        wheel_angle_6->setText(QString());
        label_9->setText(QCoreApplication::translate("MainWindow", "\344\270\216\345\211\215\350\275\246\351\227\264\350\267\235:", nullptr));
        wheel_angle_4->setText(QString());
        tabWidget_2->setTabText(tabWidget_2->indexOf(tab_3), QCoreApplication::translate("MainWindow", "\350\267\237\351\232\217\350\275\246\350\276\2061", nullptr));
        tabWidget_2->setTabText(tabWidget_2->indexOf(tab_4), QCoreApplication::translate("MainWindow", "\350\267\237\351\232\217\350\275\246\350\276\2062", nullptr));
    } // retranslateUi

};

namespace Ui {
    class MainWindow: public Ui_MainWindow {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_MAINWINDOW_H
