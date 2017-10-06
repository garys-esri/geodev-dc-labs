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
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.1

App {
    property bool threeD: false

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
        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: mapView
            width: height
            running: true
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    }
    SceneView {
        id: sceneView
        anchors.fill: parent
        visible: false

        Scene {
            BasemapImagery {}
            Surface {
                ArcGISTiledElevationSource {
                    url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                }
            }
        }
    }
    Component.onCompleted: {
    // set viewpoint to the specified camera
        sceneView.setViewpointCameraAndWait(camera)
    }

    Camera {
            id: camera
            heading: 10.0
            pitch: 80.0
            roll: 100.0

            Point {
                x: -77.04
                y: 38.88
                z: 500.0
                spatialReference: SpatialReference.createWgs84()
            }
    }
    Column{
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        padding: 5

        Button {
            id: changeView
            enabled: true
            Image {
                id: theView
                anchors.fill: parent
                source: "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/three_d.png"
                fillMode: Image.PreserveAspectFit
            }
            checkable: false
            width: 30
            height: 30

            onClicked: {
                threeD = !threeD
                            mapView.visible = !threeD
                            sceneView.visible = threeD
                theView.source = threeD ? "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/two_d.png" : "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/three_d.png"

            }
        }
    }
}


