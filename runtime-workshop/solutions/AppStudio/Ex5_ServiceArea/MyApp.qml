
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
    property var facilityParams: null
    property bool busy: false
    property string message: ""
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
           FeatureLayer {
               ServiceFeatureTable {
                   url: "http://services.arcgis.com/lA2FZKuu26Fips7U/arcgis/rest/services/MetroLines/FeatureServer/0"
               }
           }
           FeatureLayer {
               id: metrostopsLayer
               visible: false
               ServiceFeatureTable {
                   url: "http://services.arcgis.com/lA2FZKuu26Fips7U/ArcGIS/rest/services/MetroStops/FeatureServer/0"
               }
           }
           onLoadStatusChanged: {
               serviceAreaTask.load();
           }

        }
        GraphicsOverlay{
            id: startGraphics
            renderer: SimpleRenderer {
                SimpleMarkerSymbol {
                    style: Enums.SimpleMarkerSymbolStyleSquare
                    size: 10
                    color: "green"
                }
            }
        }
        Graphic {
            id: bufferGraphic
            symbol: SimpleFillSymbol {
                color: Qt.rgba(0.0, 0, 0.5, 0)
                outline:  SimpleLineSymbol {
                    color: "aqua"
                    style: Enums.SimpleLineSymbolStyleSolid
                    width: 2
                }
            }
        }


        onMouseClicked: {
            startGraphics.graphics.clear();
            metrostopsLayer.clearSelection();
            var graphic = ArcGISRuntimeEnvironment.createObject("Graphic");
            graphic.geometry = mouse.mapPoint;
            graphic.spatialReference = map.spatialReference;
               if (bufferqueryButton.checked) {
                   //console.log(startGraphics.numberOfGraphics);
                   if (startGraphics.graphics.count === 0) {
                       startGraphics.graphics.append(graphic);
                       metrostopsLayer.visible = true;
                       //console.log(graphic.spatialReference);

                       var bufferPolygon = GeometryEngine.buffer(graphic.geometry, 10000)
                       console.log(bufferPolygon);
                       bufferGraphic.geometry = bufferPolygon;
                       startGraphics.graphics.append(bufferGraphic);

                       queryParams.geometry = bufferGraphic.geometry;
                       metrostopsLayer.selectionColor = "aqua";
                       metrostopsLayer.selectFeaturesWithQuery(queryParams,Enums.SelectionModeNew);

                   }
               }
               else if (drivetimeButton.checked) {
                   if (startGraphics.graphics.count === 0) {
                     startGraphics.graphics.append(graphic);
                     var facilitiesFeatures = [];
                     var facilities = ArcGISRuntimeEnvironment.createObject(
                                   "ServiceAreaFacility", {geometry: graphic.geometry});
                     //console.log(facilities);

                     facilitiesFeatures.push(facilities);
                     console.log(facilitiesFeatures.length);



                     console.log(facilityParams);
                     facilityParams.setFacilities(facilitiesFeatures);

                     console.log("call solver");
                     serviceAreaTask.solveServiceArea(facilityParams);
                   }
               }
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
                ArcGISSceneLayer{
                    url: "https://tiles.arcgis.com/tiles/gdD5QuS3M8xgrMER/arcgis/rest/services/BuildingsDC/SceneServer"
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
                id:zoomIn
                visible: true
                height: 32
                width: 32
                text: "+"
                enabled: true
                onClicked: {
                    var theScale = mapView.mapScale
                    theScale = theScale - (theScale/2)
                    console.log(theScale)
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
                onClicked: {
                    var theScale = mapView.mapScale
                    theScale += theScale
                    mapView.setViewpointScale(theScale)
                }
            }
        }
        Column{
            id: controls
            spacing: 10
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 10
            }

            Button {
                id: bufferqueryButton
                enabled: true
                Image {
                        anchors.fill: parent
                        source: "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/location.png"
                        //source: "http://static.arcgis.com/images/Symbols/SafetyHealth/Hospital.png"
                        fillMode: Image.PreserveAspectFit
                }

                checkable: true
                width: 30
                height: 30
                checked: false
                onPressedChanged: {
                    if (!checked){
                        startGraphics.graphics.clear();
                        metrostopsLayer.clearSelection();
                    }

                }

            }
            Button {
                id: drivetimeButton
                enabled: true
                Image {
                    anchors.fill: parent
                    source: "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/car.png"
                    //source: "http://static.arcgis.com/images/Symbols/SafetyHealth/Hospital.png"
                    fillMode: Image.PreserveAspectFit
                }
                checkable: true
                width: 30
                height: 30
                checked: false

                onPressedChanged: {
                    if (!checked){
                        if (bufferqueryButton.checked)
                            bufferqueryButton.checked = false;
                        startGraphics.graphics.clear();
                        metrostopsLayer.clearSelection();
                    }
                }
            }
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

        QueryParameters {
                id: queryParams
                spatialRelationship: Enums.SpatialRelationshipIntersects
        }

        SimpleFillSymbol {
            id: polygonFill
            // default property: ouline
                    SimpleLineSymbol {
                        style: Enums.SimpleLineSymbolStyleDash
                        color: Qt.rgba(0.0, 0.0, 0.5, 1)
                        width: 1
                        antiAlias: true
                    }
        }

        Graphic {
            id: serviceAreaPolygonGraphic
        }

        SimpleLineSymbol {
            id: symbolOutline
            color: "black"
            width: 0.5
        }

        SimpleMarkerSymbol {
            id: facilitySymbol
            color: "blue"
            style: Enums.SimpleMarkerSymbolStyleSquare
            size: 10
            outline: symbolOutline
        }

        Graphic {
            id: facilityGraphic
            symbol: facilitySymbol
        }
        Credential {
            id: oAuthCredentials
            oAuthClientInfo: OAuthClientInfo {
                clientId: "2MGu4pheoHoITxjH"
                clientSecret: "361f3be9e7884af8aefcf893e0de0e9d"
                oAuthMode: Enums.OAuthModeApp

            }
        }

        ServiceAreaTask {
            id: serviceAreaTask
            url: "http://route.arcgis.com/arcgis/rest/services/World/ServiceAreas/NAServer/ServiceArea_World"
            //url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/NetworkAnalysis/SanDiego/NAServer/ServiceArea"
            credential: oAuthCredentials

            onLoadStatusChanged: {
                if (loadStatus !== Enums.LoadStatusLoaded)
                    return;

                setupRouting();
            }
            onSolveServiceAreaStatusChanged: {

                if (solveServiceAreaStatus === Enums.TaskStatusCompleted) {

                    var results = solveServiceAreaResult.resultPolygons(0);
                    var theVal = results.length - 1;
                    for (var index = theVal; index >= 0; index--) {
                        var polySymbol = ArcGISRuntimeEnvironment.createObject("SimpleFillSymbol");
                        polySymbol.color = Qt.rgba(Math.random()%255, Math.random()%255, Math.random()%255, .5);
                        var resultGeometry = results[index].geometry;

                        var graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: resultGeometry, symbol: polySymbol});
                        startGraphics.graphics.append(graphic);
                    }
                } else if (solveServiceAreaResult === null || solveServiceAreaResult.error) {
                    errorMsg = "Solve error:" + solveServiceAreaResult.error.message + "\nPlease reset and start over.";
                    messageDialog.visible = true;
                }
            }
            onCreateDefaultParametersStatusChanged: {
                console.log("inside oncreatedefaultparams changed");
                       if (createDefaultParametersStatus !== Enums.TaskStatusCompleted)
                           return;

                       busy = false;
                       facilityParams = createDefaultParametersResult;
                       facilityParams.defaultImpedanceCutoffs = [1.0, 3.0, 5.0];
                       facilityParams.outputSpatialReference = SpatialReference.createWebMercator();
                       facilityParams.returnPolygonBarriers = true;
                       facilityParams.polygonDetail = Enums.ServiceAreaPolygonDetailHigh;
                       console.log("facilityparams:  ", facilityParams.defaultImpedanceCutoffs);
                   }

        }
        // Busy Indicator
        BusyIndicator {
            anchors.centerIn: mapView
            width: height
            running: true
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
        function setupRouting() {
            //busy = true;
            //message = "";
            serviceAreaTask.createDefaultParameters();
        }
    }


