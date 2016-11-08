/*******************************************************************************
 * Copyright 2016 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/
import QtQuick 2.3
import QtQuick.Controls 1.2
import Esri.ArcGISRuntime 100.0

ApplicationWindow {
    id: appWindow
    width: 800
    height: 600
    title: "Workshop App"

    // Exercise 1: Declare a variable to track 2D vs. 3D
    property bool threeD: false

    // add a mapView component
    MapView {
        id: mapView
        anchors.fill: parent

        // add a map to the mapview
        Map {
            // Exercise 1: Add a basemap
            BasemapNationalGeographic {}
        }
    }

    // Exercise 1: Add a 3D scene view
    SceneView {
        id: sceneView
        anchors.fill: parent
        visible: false

        Scene {
            BasemapImagery {}
        }
    }

    // Exercise 1: Add 2D/3D toggle button
    Button {
        iconSource: "qrc:///Resources/three_d.png"
        anchors.right: mapView.right
        anchors.rightMargin: 20
        anchors.bottom: mapView.bottom
        anchors.bottomMargin: 20

        // Exercise 1: Handle 2D/3D toggle button click
        onClicked: {
            threeD = !threeD
            mapView.visible = !threeD
            sceneView.visible = threeD
            iconSource = "qrc:///Resources/" +
                    (threeD ? "two" : "three") +
                    "_d.png"
        }
    }
}
