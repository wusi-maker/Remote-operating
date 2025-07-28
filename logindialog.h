
#include <QDialog>
#include <QTcpServer>
#include <QDialog>
#include <QLineEdit>
#include <QPushButton>
#include <QLabel>
#include <QMovie>
#include <QThread>
#include <QTcpServer>
#include<QTcpSocket>
#include<QMessageBox>
#include<QGridLayout>

namespace Ui {
class LoginDialog;
}

class LoginDialog : public QDialog {
    Q_OBJECT

public:
    explicit LoginDialog(QWidget *parent = nullptr);
    ~LoginDialog();

    int getPort() const { return m_port; }
    bool isTestMode() const { return m_testMode; }

private slots:
    void onStartClicked();
    void onNewConnection();

private:
    Ui::LoginDialog *ui;
    QTcpServer *m_tcpServer;
    int m_port = 0;
    bool m_testMode = false;
    void showLoading(bool show);
};
