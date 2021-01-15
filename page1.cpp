
#include "page1.h"
#include <QQmlComponent>
#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>

page1::page1(QObject *parent) :
    QObject(parent)
  ,a(0)
{
    gp_qmlEngine = new QQmlApplicationEngine(this);
    QQmlComponent lv_component(gp_qmlEngine, QUrl(QStringLiteral("qrc:/main.qml")));
    gp_rootObject = lv_component.create();
    gp_rootObject->setParent(this);
//    QObject *warm1_obj = gp_rootObject->findChild<QObject*>("warm1");
    gp_rootObject->setProperty("gv_name",10);


    QObject::connect(gp_rootObject, SIGNAL(signal_button_10_onClicked()),
                         this, SLOT(slot_button_10_onClicked()));
}

page1::~page1()
{
}

int index = 0;
void page1::slot_button_10_onClicked()
{

    gp_rootObject->setProperty("gv_name",index);
    index ++;
}
