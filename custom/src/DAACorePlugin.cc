#include "DAACorePlugin.h"

#include <QtCore/QApplicationStatic>
#include <QtCore/QFile>
#include <QtQml/QQmlApplicationEngine>


Q_APPLICATION_STATIC(
    DAACorePlugin,
    _daaCorePluginInstance
);


DAACorePlugin::DAACorePlugin(QObject* parent)
    : QGCCorePlugin(parent)
{
}


QGCCorePlugin* DAACorePlugin::instance()
{
    return _daaCorePluginInstance();
}


QQmlApplicationEngine*
DAACorePlugin::createQmlApplicationEngine(QObject* parent)
{
    _qmlEngine =
        QGCCorePlugin::createQmlApplicationEngine(parent);

    _urlInterceptor =
        new DAAOverrideInterceptor();

    _qmlEngine->addUrlInterceptor(
        _urlInterceptor
    );

    return _qmlEngine;
}


void DAACorePlugin::destroyQmlApplicationEngine(
    QQmlApplicationEngine* qmlEngine
)
{
    if (
        qmlEngine &&
        qmlEngine == _qmlEngine
    ) {
        qmlEngine->removeUrlInterceptor(
            _urlInterceptor
        );

        delete _urlInterceptor;

        _urlInterceptor = nullptr;
        _qmlEngine = nullptr;
    }

    QGCCorePlugin::destroyQmlApplicationEngine(
        qmlEngine
    );
}


DAAOverrideInterceptor::DAAOverrideInterceptor()
    : QQmlAbstractUrlInterceptor()
{
}


QUrl DAAOverrideInterceptor::intercept(
    const QUrl& url,
    QQmlAbstractUrlInterceptor::DataType type
)
{
    switch (type) {

    case QQmlAbstractUrlInterceptor::QmlFile:
    case QQmlAbstractUrlInterceptor::UrlString:

        if (url.scheme() == QStringLiteral("qrc")) {

            const QString originalPath =
                url.path();

            const QString overrideResource =
                QStringLiteral(":/Custom%1")
                    .arg(originalPath);

            if (QFile::exists(overrideResource)) {

                const QString relativePath =
                    overrideResource.mid(2);

                QUrl result;
                result.setScheme(
                    QStringLiteral("qrc")
                );

                result.setPath(
                    '/' + relativePath
                );

                return result;
            }
        }

        break;

    default:
        break;
    }

    return url;
}
