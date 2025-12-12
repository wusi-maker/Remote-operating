import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import FluentUI 1.0

FluLauncher {
    id: app
    Component.onCompleted: {
        FluApp.init(app)
        FluApp.windowIcon = "qrc:/Resource/bottomelement/wusi_icon.ico"
        FluRouter.routes = {
            "/":"qrc:/main.qml",
        }
        FluRouter.navigate("/")
    }
}
