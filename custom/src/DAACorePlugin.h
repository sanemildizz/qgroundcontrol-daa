#pragma once

#include <QtQml/QQmlAbstractUrlInterceptor>

#include "QGCCorePlugin.h"

class QQmlApplicationEngine;

class DAAOverrideInterceptor : public QQmlAbstractUrlInterceptor
{
public:
    DAAOverrideInterceptor();

    QUrl intercept(
        const QUrl& url,
        QQmlAbstractUrlInterceptor::DataType type
    ) override;
};


class DAACorePlugin : public QGCCorePlugin
{
    Q_OBJECT

public:
    explicit DAACorePlugin(QObject* parent = nullptr);

    static QGCCorePlugin* instance();

    QQmlApplicationEngine* createQmlApplicationEngine(
        QObject* parent
    ) final;

    void destroyQmlApplicationEngine(
        QQmlApplicationEngine* qmlEngine
    ) final;

private:
    QQmlApplicationEngine* _qmlEngine = nullptr;
    DAAOverrideInterceptor* _urlInterceptor = nullptr;
};
