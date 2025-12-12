#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QtQml>
#include "tcpclient.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);
    // 设置全局应用图标，确保任务栏/Alt-Tab显示正确
    app.setWindowIcon(QIcon(":/Resource/bottomelement/wusi_icon.ico"));

    // 注册C++类到QML
    qmlRegisterType<TcpClient>("TcpClient", 1, 0, "TcpClient");
    
    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "test_" + QLocale(locale).name();
        if (translator.load("./i18n/"+ baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/App.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}


