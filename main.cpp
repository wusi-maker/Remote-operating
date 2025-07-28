#include "mainwindow.h"
#include"logindialog.h"
#include <QApplication>
#include<QDebug>
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    qDebug() << "Before dialog exec";
    // // 显示登录对话框
    // LoginDialog login;
    // if (login.exec() != QDialog::Accepted)
    //     return 0;
    // qDebug() << "After dialog exec";
    // 创建主窗口
    // MainWindow w(login.getPort(), login.isTestMode(),9999);



    MainWindow w(8888, false,9999);
    w.show();
    return a.exec();
}
