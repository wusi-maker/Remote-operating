/********************************************************************************
** Form generated from reading UI file 'logindialog.ui'
**
** Created by: Qt User Interface Compiler version 6.9.1
**
** WARNING! All changes made in this file will be lost when recompiling UI file!
********************************************************************************/

#ifndef UI_LOGINDIALOG_H
#define UI_LOGINDIALOG_H

#include <QtCore/QVariant>
#include <QtWidgets/QApplication>
#include <QtWidgets/QDialog>
#include <QtWidgets/QGridLayout>
#include <QtWidgets/QHBoxLayout>
#include <QtWidgets/QLabel>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QSpacerItem>
#include <QtWidgets/QVBoxLayout>
#include <QtWidgets/QWidget>

QT_BEGIN_NAMESPACE

class Ui_LoginDialog
{
public:
    QGridLayout *gridLayout;
    QWidget *widget_2;
    QHBoxLayout *horizontalLayout;
    QLabel *loadingLabel;
    QSpacerItem *horizontalSpacer;
    QWidget *widget;
    QVBoxLayout *verticalLayout;
    QLabel *titleLabel;
    QLineEdit *portEdit;
    QPushButton *startButton;
    QSpacerItem *horizontalSpacer_2;

    void setupUi(QDialog *LoginDialog)
    {
        if (LoginDialog->objectName().isEmpty())
            LoginDialog->setObjectName("LoginDialog");
        LoginDialog->resize(362, 235);
        gridLayout = new QGridLayout(LoginDialog);
        gridLayout->setObjectName("gridLayout");
        widget_2 = new QWidget(LoginDialog);
        widget_2->setObjectName("widget_2");
        horizontalLayout = new QHBoxLayout(widget_2);
        horizontalLayout->setObjectName("horizontalLayout");
        loadingLabel = new QLabel(widget_2);
        loadingLabel->setObjectName("loadingLabel");

        horizontalLayout->addWidget(loadingLabel);

        horizontalSpacer = new QSpacerItem(40, 20, QSizePolicy::Policy::Expanding, QSizePolicy::Policy::Minimum);

        horizontalLayout->addItem(horizontalSpacer);

        widget = new QWidget(widget_2);
        widget->setObjectName("widget");
        verticalLayout = new QVBoxLayout(widget);
        verticalLayout->setObjectName("verticalLayout");
        titleLabel = new QLabel(widget);
        titleLabel->setObjectName("titleLabel");

        verticalLayout->addWidget(titleLabel);

        portEdit = new QLineEdit(widget);
        portEdit->setObjectName("portEdit");

        verticalLayout->addWidget(portEdit);

        startButton = new QPushButton(widget);
        startButton->setObjectName("startButton");

        verticalLayout->addWidget(startButton);


        horizontalLayout->addWidget(widget);

        horizontalSpacer_2 = new QSpacerItem(40, 20, QSizePolicy::Policy::Expanding, QSizePolicy::Policy::Minimum);

        horizontalLayout->addItem(horizontalSpacer_2);


        gridLayout->addWidget(widget_2, 0, 1, 1, 1);


        retranslateUi(LoginDialog);

        QMetaObject::connectSlotsByName(LoginDialog);
    } // setupUi

    void retranslateUi(QDialog *LoginDialog)
    {
        loadingLabel->setText(QString());
        titleLabel->setText(QCoreApplication::translate("LoginDialog", "Server Connecting", nullptr));
        portEdit->setPlaceholderText(QCoreApplication::translate("LoginDialog", "\350\276\223\345\205\245\347\233\221\345\220\254\347\253\257\345\217\243", nullptr));
        startButton->setText(QCoreApplication::translate("LoginDialog", "\345\220\257\345\212\250\346\234\215\345\212\241\345\231\250", nullptr));
        (void)LoginDialog;
    } // retranslateUi

};

namespace Ui {
    class LoginDialog: public Ui_LoginDialog {};
} // namespace Ui

QT_END_NAMESPACE

#endif // UI_LOGINDIALOG_H
