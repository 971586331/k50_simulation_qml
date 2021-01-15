#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlComponent>
#include "mainwindow.h"
#include "page1.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    mainwindow cpp_interface;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("cpp_interface", &cpp_interface);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

//    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
//    QApplication app(argc, argv);

//    new page1();

    return app.exec();
}
