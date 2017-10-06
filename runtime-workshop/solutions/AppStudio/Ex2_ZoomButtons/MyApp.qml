/* Copyright 2017 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

App {
    id: app
    width: 400
    height: 640

    Rectangle {
        id: titleRect
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: titleText.paintedHeight + titleText.anchors.margins * 2
        color: app.info.propertyValue("titleBackgroundColor", "darkblue")

        Text {
            id: titleText

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 2 * AppFramework.displayScaleFactor
            }

            text: app.info.title
            color: app.info.propertyValue("titleTextColor", "white")
            font {
                pointSize: 22
            }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MapView {
        id:mapView
        anchors {
            left: parent.left
            right: parent.right
            top: titleRect.bottom
            bottom: parent.bottom
        }
        Map {
           id: map
           BasemapStreetsVector {}
           ViewpointExtent {
                Envelope {
                    xMax: -8539362.27
                    yMax: 4723928.16
                    xMin: -8610295.83
                    yMin: 4702907.97
                    spatialReference: SpatialReference {wkid: 102100}
                }
           }
        }
        Column{
            anchors.right: parent.right
            anchors.top: titleRect.bottom
            spacing: 10
            padding: 5
            Button {
                id:zoomIn
                visible: true
                height: 32
                width: 32
                text: "+"
                enabled: true
                style: ButtonStyle {
                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 25
                        border.width: control.activeFocus ? 2 : 1
                        border.color: "#888"
                        radius: 4
                        gradient: Gradient {
                            GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                            GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                        }
                    }
                }
                onClicked: {
                    var theScale = mapView.mapScale
                    theScale = theScale - (theScale/2)
                    mapView.setViewpointScale(theScale)
                }

            }
            Button {
                id:zoomOut
                visible: true
                height: 32
                width: 32
                text: "-"
                enabled: true
                style: ButtonStyle {
                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 25
                        border.width: control.activeFocus ? 2 : 1
                        border.color: "#888"
                        radius: 4
                        gradient: Gradient {
                            GradientStop { position: 0 ; color: control.pressed ? "#ccc" : "#eee" }
                            GradientStop { position: 1 ; color: control.pressed ? "#aaa" : "#ccc" }
                        }
                    }
                }
                onClicked: {
                    var theScale = mapView.mapScale
                    theScale += theScale
                    mapView.setViewpointScale(theScale)
                }
            }
        }
        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: mapView
            width: height
            running: true
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    }
}

