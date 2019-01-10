
// Copyright 2016-2019 ESRI
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

import QtQuick 2.6
import QtQuick.Controls 1.4
import Esri.ArcGISRuntime 100.4

ApplicationWindow {
    id: appWindow
    width: 800
    height: 600
    title: "Workshop App"

    // Exercise 1: Create a variable to track 2D vs. 3D
    property bool threeD: false

    // Exercise 3: Specify operational layer paths
    readonly property url mmpkPath: workingDirectory + "/../../../../../../data/DC_Crime_Data.mmpk"
    readonly property url sceneServiceUrl: "https://www.arcgis.com/home/item.html?id=2c9286dfc69349408764e09022b1f52e"
    readonly property url kmlUrl: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_week_age_link.kml"

    // Exercise 3: Create a KML layer for the 2D map
    property KmlLayer kmlLayer2d: KmlLayer {
        dataset: KmlDataset {
            url: kmlUrl
        }
    }

    // add a mapView component
    MapView {
        id: mapView
        anchors.fill: parent
        // set focus to enable keyboard navigation
        focus: true

        // add a map to the mapview
        Map {
            // Exercise 1: Add a basemap
            BasemapTopographicVector {}
        }
    }

    // Exercise 3: Add a mobile map package to the 2D map
    MobileMapPackage {
        id: mmpk
        path: mmpkPath

        property var basemap: BasemapTopographicVector {}

        Component.onCompleted: {
            mmpk.load();
        }

        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusLoaded) {
                mapView.map = mmpk.maps[0];
                mapView.map.basemap = basemap;

                // Exercise 3: Add a KML layer to the map
                mapView.map.operationalLayers.append(kmlLayer2d);
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
            Surface {
                ArcGISTiledElevationSource {
                    url: "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
                }
            }

            // Exercise 3: Add a scene layer to the scene
            ArcGISSceneLayer {
                id: sceneLayer
                url: sceneServiceUrl

                function rotate() {
                    sceneView.setViewpointCompleted.disconnect(rotate);
                    var camera = sceneView.currentViewpointCamera.rotateAround(
                                sceneView.currentViewpointCenter.center, 45.0, 65.0, 0.0);
                    sceneView.setViewpointCamera(camera);
                }

                onLoadStatusChanged: {
                    if (Enums.LoadStatusLoaded === loadStatus) {
                        var viewpointExtent = ArcGISRuntimeEnvironment.createObject("ViewpointExtent", {
                            extent: sceneLayer.fullExtent
                        });
                        sceneView.setViewpointCompleted.connect(rotate);
                        sceneView.setViewpoint(viewpointExtent);
                    }
                }
            }

            // Exercise 3: Add a KML layer to the scene
            KmlLayer {
                dataset: KmlDataset {
                    url: kmlUrl
                }
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

    // Exercise 2: Create a default GlobeCameraController
    GlobeCameraController {
        id: globeCameraController_default
    }

    // Exercise 2: Add a lock focus button
    Button {
        id: button_lockFocus
        iconSource: "qrc:///Resources/lock.png"
        anchors.right: mapView.right
        anchors.rightMargin: 20
        anchors.bottom: button_zoomIn.top
        anchors.bottomMargin: 10
        checkable: true

        onClicked: {
            if (button_lockFocus.checked) {
                var currentCamera = sceneView.currentViewpointCamera;
                var currentCameraPoint = currentCamera.location;
                if (currentCameraPoint) {
                    var xyDistance = GeometryEngine.distanceGeodetic(
                                sceneView.currentViewpointCenter.center,
                                currentCameraPoint,
                                Enums.LinearUnitIdMeters,
                                Enums.AngularUnitIdDegrees,
                                Enums.GeodeticCurveTypeGeodesic
                    ).distance;
                    var zDistance = currentCameraPoint.z;
                    var distanceToTarget = Math.sqrt(Math.pow(xyDistance, 2.0) + Math.pow(zDistance, 2.0));
                    var cameraController = ArcGISRuntimeEnvironment.createObject("OrbitLocationCameraController", {
                        targetLocation: sceneView.currentViewpointCenter.center,
                        cameraDistance: distanceToTarget
                    });
                    cameraController.cameraHeadingOffset = currentCamera.heading;
                    cameraController.cameraPitchOffset = currentCamera.pitch;
                    sceneView.cameraController = cameraController;
                }
            } else {
                sceneView.cameraController = globeCameraController_default;
            }
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
