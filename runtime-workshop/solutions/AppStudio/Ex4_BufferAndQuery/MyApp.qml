/* Copyright 2015 Esri
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


import QtQuick 2.3
import QtQuick.Controls 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

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
    Map {
        id: map

        anchors {
            left: parent.left
            right: parent.right
            top: titleRect.bottom
            bottom: parent.bottom
        }

        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true

        ArcGISTiledMapServiceLayer {
            url: app.info.propertyValue("basemapServiceUrl", "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        }

        onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                extent = initialExtent;
                startGraphics.renderingMode = Enums.RenderingModeStatic;
                addLayer(startGraphics);

            }
        }
        Envelope {
            id: initialExtent
            xMax: -8539362.27
            yMax: 4723928.16
            xMin: -8610295.83
            yMin: 4702907.97
            spatialReference: map.spatialReference
        }

        ZoomButtons {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }
        }

        positionDisplay {
            positionSource: PositionSource {
            }
        }

        GeodatabaseFeatureServiceTable {
                id: metroLineTable
                url: "http://services.arcgis.com/lA2FZKuu26Fips7U/arcgis/rest/services/MetroLines/FeatureServer/0"
        }

        FeatureLayer{
            id: metrolineLayer
            featureTable: metroLineTable
            visible: true
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
                        fillMode: Image.PreserveAspectFit
                }

                checkable: true
                width: 30
                height: 30
                checked: false
                onPressedChanged: {
                    if (!checked){
                        startGraphics.removeAllGraphics();
                        metrostopsLayer.clearSelection();
                    }

                }

            }
        }
        GraphicsLayer {
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
                    color: Qt.rgba(0.0, 0, 0.5, 0.5)
                    outline:  SimpleLineSymbol {
                        color: "aqua"
                        style: Enums.SimpleLineSymbolStyleSolid
                        width: 2
                    }
                }
            }

        GeodatabaseFeatureServiceTable {
                id: featureServiceTable
                url: "http://services.arcgis.com/lA2FZKuu26Fips7U/arcgis/rest/services/MetroStops/FeatureServer/0"
        }

        FeatureLayer {
                    id: metrostopsLayer
                    featureTable: featureServiceTable
                    visible: false
        }
        onMouseClicked: {
            startGraphics.removeAllGraphics();
            metrostopsLayer.clearSelection();
            var graphic = ArcGISRuntime.createObject("Graphic");
            graphic.geometry = mouse.mapPoint;

            if (bufferqueryButton.checked) {
                if (startGraphics.numberOfGraphics === 0) {
                    startGraphics.addGraphic(graphic);
                    metrostopsLayer.visible = true;

                    var bufferPolygon = graphic.geometry.buffer(10000, map.spatialReference.unit);
                    var graphic1 = bufferGraphic.clone();
                    graphic1.geometry = bufferPolygon;
                    startGraphics.addGraphic(graphic1);

                    queryParams.geometry = graphic1.geometry;
                    metrostopsLayer.selectionColor = "aqua";
                    metrostopsLayer.selectFeaturesByQuery(queryParams);

                }
            }


        }
        Query {
                id: queryParams
                spatialRelationship: Enums.SpatialRelationshipIntersects
                outFields: ["OBJECTID_1", "NAME"]
            }

    }






}
