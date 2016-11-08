
// Copyright 2016 ESRI
//
// All rights reserved under the copyright laws of the United States
// and applicable international laws, treaties, and conventions.
//
// You may freely redistribute and use this sample code, with or
// without modification, provided you include the original copyright
// notice and use restrictions.
//
// See the Sample code usage restrictions document for further information.
//

#include <QDebug>
#include <QSettings>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QCommandLineParser>
#include <QDir>
#include <QSurfaceFormat>

#ifdef Q_OS_WIN
#include <Windows.h>
#endif

#include "AppInfo.h"

//------------------------------------------------------------------------------

#define kSettingsFormat                 QSettings::IniFormat

//------------------------------------------------------------------------------

#define kArgShowName                    "show"
#define kArgShowValueName               "showOption"
#define kArgShowDescription             "Show option maximized | minimized | fullscreen | normal | default"
#define kArgShowDefault                 "show"

#define kShowMaximized                  "maximized"
#define kShowMinimized                  "minimized"
#define kShowFullScreen                 "fullscreen"
#define kShowNormal                     "normal"

//------------------------------------------------------------------------------

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    if (QT_VERSION_MAJOR == 5 && QT_VERSION_MINOR > 6)
    {
        // Workaround for Qt versions greater than 5.6
        // Force to OpenGL ES 3
        QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
        fmt.setVersion(3, 0);
        QSurfaceFormat::setDefaultFormat(fmt);
    }
#endif

    qDebug() << "Initializing application";

    QGuiApplication app(argc, argv);

    QCoreApplication::setApplicationName(kApplicationName);
    QCoreApplication::setApplicationVersion(kApplicationVersion);
    QCoreApplication::setOrganizationName(kOrganizationName);
#ifdef Q_OS_MAC
    QCoreApplication::setOrganizationDomain(kOrganizationName);
#else
    QCoreApplication::setOrganizationDomain(kOrganizationDomain);
#endif
    QSettings::setDefaultFormat(kSettingsFormat);

#ifdef Q_OS_WIN
    // Force usage of OpenGL ES through ANGLE on Windows
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
#endif

    // Initialize license

#ifdef kClientId
    QCoreApplication::instance()->setProperty("Esri.ArcGISRuntime.clientId", kClientId);
#ifdef kLicense
    QCoreApplication::instance()->setProperty("Esri.ArcGISRuntime.license", kLicense);
#endif
#endif

    // Intialize application window

    QQmlApplicationEngine appEngine;
    appEngine.addImportPath(QDir(QCoreApplication::applicationDirPath()).filePath("qml"));
    appEngine.load(QUrl(kApplicationSourceUrl));

    auto topLevelObject = appEngine.rootObjects().value(0);
    qDebug() << Q_FUNC_INFO << topLevelObject;

    auto window = qobject_cast<QQuickWindow *>(topLevelObject);
    if (!window)
    {
        qCritical("Error: Your root item has to be a Window.");

        return -1;
    }

#if !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID)
    // Process command line

    QCommandLineOption showOption(kArgShowName, kArgShowDescription, kArgShowValueName, kArgShowDefault);

    QCommandLineParser commandLineParser;

    commandLineParser.setApplicationDescription(kApplicationDescription);
    commandLineParser.addOption(showOption);
    commandLineParser.addHelpOption();
    commandLineParser.addVersionOption();
    commandLineParser.process(app);

    // Show app window

    auto showValue = commandLineParser.value(kArgShowName).toLower();

    if (showValue.compare(kShowMaximized) == 0)
    {
        window->showMaximized();
    }
    else if (showValue.compare(kShowMinimized) == 0)
    {
        window->showMinimized();
    }
    else if (showValue.compare(kShowFullScreen) == 0)
    {
        window->showFullScreen();
    }
    else if (showValue.compare(kShowNormal) == 0)
    {
        window->showNormal();
    }
    else
    {
        window->show();
    }

#else
    window->show();
#endif

    return app.exec();
}

//------------------------------------------------------------------------------
