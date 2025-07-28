#include "logindialog.h"
#include "ui_logindialog.h"


LoginDialog::LoginDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::LoginDialog),
    m_tcpServer(new QTcpServer(this))
{
    ui->setupUi(this);


    // 初始化动画（但不启动）
    QMovie *movie = new QMovie(":/images/batter_waitor.gif", QByteArray(), this);
    movie->setCacheMode(QMovie::CacheAll);
    ui->loadingLabel->setMovie(movie);
    // 连接信号槽
    connect(ui->startButton, &QPushButton::clicked,
            this, &LoginDialog::onStartClicked);
    connect(m_tcpServer, &QTcpServer::newConnection,
            this, &LoginDialog::onNewConnection);
}

void LoginDialog::onStartClicked()
{
    bool ok;
    m_port = ui->portEdit->text().toInt(&ok);

    if (!ok || m_port <= 0) {
        QMessageBox::warning(this, "错误", "请输入有效的端口号");
        return;
    }

    // 测试模式特殊处理
    if (m_port == 114514) {
        m_testMode = true;
        accept();
        return;
    }
    // 隐藏所有输入控件
    ui->titleLabel->hide();
    ui->portEdit->hide();
    ui->startButton->hide();

    // 显示并启动动画
    ui->loadingLabel->show();
    ui->loadingLabel->movie()->start();

    // 强制界面刷新
    update();

    // 正常启动服务器
    showLoading(true);
    if (!m_tcpServer->listen(QHostAddress::Any, m_port)) {
        showLoading(false);
        QMessageBox::critical(this, "错误",
                              QString("无法启动服务器:\n%1").arg(m_tcpServer->errorString()));
    }
}

void LoginDialog::onNewConnection()
{
    QTcpSocket *clientSocket = m_tcpServer->nextPendingConnection();

    if (clientSocket) {
        qDebug() << "客户端已连接:" << clientSocket->peerAddress().toString();
        m_tcpServer->close();
        accept(); // 关闭对话框
    }
}

void LoginDialog::showLoading(bool show)
{
    ui->portEdit->setEnabled(!show);
    ui->startButton->setEnabled(!show);
    ui->loadingLabel->setVisible(show);
    ui->loadingLabel->movie()->setPaused(!show);
}

LoginDialog::~LoginDialog()
{
    delete ui;
}
