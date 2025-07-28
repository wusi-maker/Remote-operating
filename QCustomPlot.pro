QT += core gui network \
      multimedia multimediawidgets  # 视频显示
QT += widgets printsupport
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17


# 设置生成的可执行文件名称
TARGET = MyApp

# 设置输出目录（例如源码目录下的 bin 文件夹）
DESTDIR = $$PWD/bin
MKDIR = $$DESTDIR
# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    cardashboard.cpp \
    ffmpegdecoder.cpp \
    logindialog.cpp \
    main.cpp \
    mainwindow.cpp \
    mapcanvas.cpp \


HEADERS += \
    cardashboard.h \
    ffmpegdecoder.h \
    logindialog.h \
    mainwindow.h \
    mapcanvas.h \

FORMS += \
    logindialog.ui \
    mainwindow.ui

# 添加QCustomPlot
HEADERS += qcustomplot.h
SOURCES += qcustomplot.cpp

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    resources.qrc
