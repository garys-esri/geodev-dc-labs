
// Copyright 2016-2017 ESRI
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
import Esri.ArcGISRuntime 100.1

ApplicationWindow {
    id: appWindow
    width: 800
    height: 600
    title: "Workshop App"

    // Exercise 1: Create a variable to track 2D vs. 3D
    property bool threeD: false

    // Exercise 3: Specify mobile map package path
    readonly property url mmpkPath: workingDirectory + "/../../../../../../data/DC_Crime_Data.mmpk"

    // Exercise 5: Declare origin point and route parameters variables
    property var originPoint: undefined
    property var routeParameters: undefined

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

    // Exercise 5: Create symbols for routing
    SimpleMarkerSymbol {
        id: routeOriginSymbol
        style: Enums.SimpleMarkerSymbolStyleTriangle
        color: "#C000FF00"
        size: 10
    }
    SimpleMarkerSymbol {
        id: routeDestinationSymbol
        style: Enums.SimpleMarkerSymbolStyleSquare
        color: "#C0FF0000"
        size: 10
    }
    SimpleLineSymbol {
        id: routeLineSymbol
        style: Enums.SimpleLineSymbolStyleSolid
        color: "#C0550055"
        width: 5
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

    // Exercise 5: Create graphics overlays for routing
    GraphicsOverlay {
        id: mapRouteGraphics
    }
    GraphicsOverlay {
        id: sceneRouteGraphics
        sceneProperties: LayerSceneProperties {
            surfacePlacement: Enums.SurfacePlacementDraped
        }
    }

    // Exercise 4: Create a query parameters object
    QueryParameters {
        id: query
    }

    // Exercise 5: Create route task
    RouteTask {
        id: routeTask
        url: "http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World"
        /*
          Note: for ArcGIS Online routing, this tutorial uses a username and password
          in the source code for simplicity. For security reasons, you would not
          do it this way in a real app. Instead, you would do one of the following:
          - Use an OAuth 2.0 user login
          - Use an OAuth 2.0 app login (not directly supported in ArcGIS Runtime Quartz as of Beta 1)
          - Challenge the user for credentials
        */
        credential: Credential {
            username: "myUsername"
            password: "myPassword"
        }

        Component.onCompleted: {
            load();
        }

        onLoadStatusChanged: {
            if (Enums.LoadStatusLoaded === loadStatus) {
                createDefaultParameters();
            }
        }

        onCreateDefaultParametersStatusChanged: {
            if (Enums.TaskStatusCompleted === createDefaultParametersStatus) {
                routeParameters = createDefaultParametersResult;
                button_routing.visible = true;
            }
        }

        onSolveRouteStatusChanged: {
            if (Enums.TaskStatusCompleted === solveRouteStatus && solveRouteResult && 0 < solveRouteResult.routes.length) {
                var routeGraphic = ArcGISRuntimeEnvironment.createObject("Graphic", {
                    geometry: solveRouteResult.routes[0].routeGeometry,
                    symbol: routeLineSymbol
                });
                (threeD ? sceneRouteGraphics : mapRouteGraphics).graphics.append(routeGraphic);
            } else if (error) {
                console.log("Error: " + error.message);
            }
        }
    }

    // add a mapView component
    MapView {
        id: mapView
        anchors.fill: parent
        wrapAroundMode: Enums.WrapAroundModeDisabled
        // set focus to enable keyboard navigation
        focus: true

        // add a map to the mapview
        Map {
            // Exercise 1: Add a basemap
            BasemapNationalGeographic {}
        }

        // Exercise 4: Add graphics overlay
        Component.onCompleted: {
            graphicsOverlays.append(bufferAndQueryMapGraphics)

            // Exercise 5: Add routing graphics overlay
            graphicsOverlays.append(mapRouteGraphics)
        }

        // Exercise 4: Listen for mouse click and do buffer and query
        onMouseClicked: function (event) {
            if (button_bufferAndQuery.checked) {
                bufferAndQuery(event);

            // Exercise 5: If routing button is selected, add stop
            } else if (button_routing.checked) {
                addStopToRoute(event);

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

            // Exercise 5: Add routing graphics overlay
            graphicsOverlays.append(sceneRouteGraphics)
        }

        // Exercise 4: Listen for mouse click and do buffer and query
        onMouseClicked: function (event) {
            if (button_bufferAndQuery.checked) {
                bufferAndQuery(event);

            // Exercise 5: If routing button is selected, add stop
            } else if (button_routing.checked) {
                addStopToRoute(event);

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

            // Exercise 5: Set originPoint to undefined to reset routing when switching between 2D and 3D
            originPoint = undefined;
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

        // Exercise 5: If this button is checked, uncheck the routing button
        onCheckedChanged: {
            if (checked) {
                button_routing.checked = false;
            }
        }
    }

    // Exercise 5: Add a routing button
    Button {
        id: button_routing
        iconSource: "qrc:///Resources/routing.png"
        anchors.right: mapView.right
        anchors.rightMargin: 20
        anchors.bottom: button_bufferAndQuery.top
        anchors.bottomMargin: 10
        checkable: true
        visible: false

        // If this button is checked, uncheck the buffer and query button
        onCheckedChanged: {
            if (checked) {
                button_bufferAndQuery.checked = false
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
            var buffer = GeometryEngine.bufferGeodetic(geoPoint, 1000, Enums.LinearUnitIdMeters, 1, Enums.GeodeticCurveTypeGeodesic)

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

    /*
      Exercise 5: Add a stop to the route, and calculate the route if we have two stops.
    */
    function addStopToRoute(event) {
        if (Qt.LeftButton === event.button) {
            var point = getGeoPoint(event);
            if (point.hasZ) {
                point = ArcGISRuntimeEnvironment.createObject("Point", {
                    x: point.x,
                    y: point.y,
                    spatialReference: point.spatialReference
                });
            }
            var graphics = (threeD ? sceneRouteGraphics : mapRouteGraphics).graphics;
            if (!originPoint) {
                originPoint = point;
                graphics.clear();
                graphics.append(ArcGISRuntimeEnvironment.createObject("Graphic", {
                    geometry: point,
                    symbol: routeOriginSymbol
                }));
            } else {
                graphics.append(ArcGISRuntimeEnvironment.createObject("Graphic", {
                    geometry: point,
                    symbol: routeDestinationSymbol
                }));
                routeParameters.clearStops();
                var stops = [];
                [originPoint, point].forEach(function (p) {
                    stops.push(ArcGISRuntimeEnvironment.createObject("Stop", {
                        geometry: p
                    }));
                });
                routeParameters.setStops(stops);
                routeTask.solveRoute(routeParameters);

                originPoint = null;
            }
        }
    }
}
