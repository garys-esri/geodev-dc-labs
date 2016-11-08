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

    // Exercise 1: Create a variable to track 2D vs. 3D
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
        id: button_toggle2d3d
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

    // Exercise 2: Add a zoom out button
    Button {
        id: button_zoomOut
        iconSource: "qrc:///Resources/zoom_out.png"
        anchors.right: mapView.right
        anchors.rightMargin: 20
        anchors.bottom: button_toggle2d3d.top
        anchors.bottomMargin: 10

        onClicked: {
            zoom(0.5)
        }
    }

    // Exercise 2: Add a zoom in button
    Button {
        id: button_zoomIn
        iconSource: "qrc:///Resources/zoom_in.png"
        anchors.right: mapView.right
        anchors.rightMargin: 20
        anchors.bottom: button_zoomOut.top
        anchors.bottomMargin: 10

        onClicked: {
            zoom(2)
        }
    }

    /*
      Exercise 2: Determine whether to call zoomMap or zoomScene
    */
    function zoom(factor) {
        var zoomFunction = threeD ? zoomScene : zoomMap
        zoomFunction(factor)
    }

    /*
      Exercise 2: Utility method for zooming the 2D map
    */
    function zoomMap(factor) {
        mapView.setViewpointScale(mapView.mapScale / factor)
    }

    /*
      Exercise 2: Utility method for zooming the 3D scene
    */
    function zoomScene(factor) {
        var target = sceneView.currentViewpointCenter.center
        var camera = sceneView.currentViewpointCamera.zoomToward(target, factor)
        sceneView.setViewpointCameraAndSeconds(camera, 0.5)
    }
}
