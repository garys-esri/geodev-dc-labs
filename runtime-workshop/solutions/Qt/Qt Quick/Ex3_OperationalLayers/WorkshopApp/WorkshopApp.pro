#-------------------------------------------------
#  Copyright 2016 ESRI
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

mac {
    cache()
}

#-------------------------------------------------------------------------------

# Adjust these values as needed
OPENSSL_LIBS = D:/GitHub/openssl/out32dll
OPENSSL_INCLUDE = D:/GitHub/openssl/inc32

CONFIG += c++11

QT += core gui opengl network positioning sensors qml quick

ARCGIS_RUNTIME_VERSION = 100.1
include($$PWD/arcgisruntime.pri)

TEMPLATE = app
TARGET = WorkshopApp

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

LIBS += -L$$OPENSSL_LIBS
INCLUDEPATH += $$OPENSSL_INCLUDE

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

