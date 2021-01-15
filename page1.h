#ifndef MAIN_H
#define MAIN_H

#include <QObject>
#include <QQmlApplicationEngine>
#include <QClipboard>


class page1 : public QObject{

  Q_OBJECT

public:
    explicit page1(QObject *parent = nullptr);
    ~page1();

public slots:
    void slot_button_10_onClicked();

private:
    QQmlApplicationEngine *gp_qmlEngine;
    QObject               *gp_rootObject;
    QClipboard            *gp_clipboard;
    int  a;
};

#endif // MAIN_H
