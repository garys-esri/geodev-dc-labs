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

    // Exercise 3: Specify mobile map package path
    readonly property string mmpkPath: "../../../../../data/DC_Crime_Data.mmpk"

    // Exercise 4: Create symbols for click and buffer
    SimpleMarkerSymbol {
        id: clickSymbol
        style: Enums.SimpleMarkerSymbolStyleCircle
        color: "#FFA500"
        size: 10
    }
    SimpleFillSymbol {
        id: bufferSymbol
        style: Enums.SimpleFillSymbolStyleNull
        outline: SimpleLineSymbol {
            style: Enums.SimpleLineSymbolStyleSolid
            color: "#FFA500"
            width: 3
        }
    }

    // Exercise 4: Create graphics overlays
    GraphicsOverlay {
        id: bufferAndQueryMapGraphics
    }
    GraphicsOverlay {
        id: bufferAndQuerySceneGraphics
        sceneProperties: LayerSceneProperties {
            surfacePlacement: Enums.SurfacePlacementDraped
        }
    }

    // Exercise 4: Create a query parameters object
    QueryParameters {
        id: query
    }

    // add a mapView component
    MapView {
        id: mapView
        anchors.fill: parent

        // add a map to the mapview
        Map {
            // Exercise 1: Add a basemap
            BasemapNationalGeographic {}
        }

        // Exercise 4: Add graphics overlay
        Component.onCompleted: {
            graphicsOverlays.append(bufferAndQueryMapGraphics)
        }

        // Exercise 4: Listen for mouse click and do buffer and query
        onMouseClicked: function (event) {
            if (button_bufferAndQuery.checked) {
                bufferAndQuery(event);
            }
        }
    }

    // Exercise 3: Add a mobile map package to the 2D map
    MobileMapPackage {
        id: mmpk
        path: mmpkPath

        property var basemap: BasemapNationalGeographic {}

        Component.onCompleted: {
            mmpk.load();
        }

        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusLoaded) {
                mapView.map = mmpk.maps[0];
                mapView.map.basemap = basemap;
            }
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

        // Exercise 4: Add graphics overlay
        Component.onCompleted: {
            graphicsOverlays.append(bufferAndQuerySceneGraphics)
        }

        // Exercise 4: Listen for mouse click and do buffer and query
        onMouseClicked: function (event) {
            if (button_bufferAndQuery.checked) {
                bufferAndQuery(event);
            }
        }
    }

    // Exercise 3: Add a mobile map package to the 3D scene
    MobileMapPackage {
        id: sceneMmpk
        path: mmpkPath

        Component.onCompleted: {
            sceneMmpk.load();
        }

        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusLoaded) {
                var thisMap = sceneMmpk.maps[0];
                var layers = [];
                thisMap.operationalLayers.forEach(function (layer) {
                    layers.push(layer);
                });
                thisMap.operationalLayers.clear();
                layers.forEach(function (layer) {
                    sceneView.scene.operationalLayers.append(layer);
                });

                // Zoom and rotate
                var camera = ArcGISRuntimeEnvironment.createObject("Camera", {
                    location: thisMap.initialViewpoint.extent.center,
                    heading: 0,
                    pitch: 0,
                    roll: 0
                }).elevate(20000).rotateAround(thisMap.initialViewpoint.extent.center, 45, 65, 0);
                sceneView.setViewpointCamera(camera);
            }
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

    // Exercise 4: Add a buffer and query button
    Button {
        id: button_bufferAndQuery
        iconSource: "qrc:///Resources/location.png"
        anchors.right: mapView.right
        anchors.rightMargin: 20
        anchors.bottom: button_zoomIn.top
        anchors.bottomMargin: 10
        checkable: true
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

    /*
      Exercise 4: Convert a MouseEvent to a geographic point.
    */
    function getGeoPoint(event) {
        var func = threeD ? sceneView.screenToBaseSurface : mapView.screenToLocation;
        return func(event.x, event.y);
    }

    /*
      Exercise 4: Buffer and query
    */
    function bufferAndQuery(event) {
        if (Qt.LeftButton === event.button) {
            var geoPoint = getGeoPoint(event);
            // Buffer by 1000 meters
            var buffer = GeometryEngine.bufferGeodesic(geoPoint, 1000, Enums.LinearUnitIdMeters, 1, Enums.GeodeticCurveTypeGeodesic)

            // Show click and buffer as graphics
            var graphics = (threeD ? bufferAndQuerySceneGraphics : bufferAndQueryMapGraphics).graphics;
            graphics.clear();
            graphics.append(ArcGISRuntimeEnvironment.createObject("Graphic", {
                geometry: buffer,
                symbol: bufferSymbol
            }));
            graphics.append(ArcGISRuntimeEnvironment.createObject("Graphic", {
                geometry: geoPoint,
                symbol: clickSymbol
            }));

            // Run the query
            query.geometry = buffer;
            var operationalLayers = threeD ? sceneView.scene.operationalLayers : mapView.map.operationalLayers;
            operationalLayers.forEach(function (layer) {
                if (layer.selectFeaturesWithQuery) {
                    /*
                      Note: As of ArcGIS Runtime Quartz Beta 1, this select successfully
                      selects features, but those features are only highlighted on the
                      2D MapView, not on the 3D SceneView. This behavior is scheduled
                      to be fixed in ArcGIS Runtime Quartz.
                    */
                    layer.selectFeaturesWithQuery(query, Enums.SelectionModeNew);
                }
            });
        }
    }
}
