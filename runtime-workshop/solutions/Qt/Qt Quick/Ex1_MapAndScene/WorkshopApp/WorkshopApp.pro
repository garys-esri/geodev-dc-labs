#-------------------------------------------------
#  Copyright 2016-2019 ESRI
#
#  All rights reserved under the copyright laws of the United States
#  and applicable international laws, treaties, and conventions.
#
#  You may freely redistribute and use this sample code, with or
#  without modification, provided you include the original copyright
#  notice and use restrictions.
#
#  See the Sample code usage restrictions document for further information.
#-------------------------------------------------

VERSION = "2019.01"

mac {
    cache()
}

#-------------------------------------------------------------------------------

CONFIG += c++11

QT += core gui opengl network positioning sensors qml quick

ARCGIS_RUNTIME_VERSION = 100.4
include($$PWD/arcgisruntime.pri)

TEMPLATE = app
TARGET = WorkshopApp

equals(QT_MAJOR_VERSION, 5) {
    lessThan(QT_MINOR_VERSION, 9) { 
        error("$$TARGET requires Qt 5.9.2")
    }
    equals(QT_MINOR_VERSION, 9) : lessThan(QT_PATCH_VERSION, 2) {
        error("$$TARGET requires Qt 5.9.2")
    }
}

#-------------------------------------------------------------------------------

HEADERS += \
    AppInfo.h

SOURCES += \
    main.cpp

RESOURCES += \
    qml/qml.qrc \
    Resources/Resources.qrc

OTHER_FILES += \
    wizard.xml \
    wizard.png

#-------------------------------------------------------------------------------

win32 {
    include (Win/Win.pri)
}

macx {
    include (Mac/Mac.pri)
}

ios {
    include (iOS/iOS.pri)
}

android {
    include (Android/Android.pri)
}

