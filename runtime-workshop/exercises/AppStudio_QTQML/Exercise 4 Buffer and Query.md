# Exercise 4: Buffer a Point and Query Features (AppStudio)

This exercise walks you through the following:
- Get the user to click a point
- Display the clicked point and a buffer around it
- Query for features within the buffer

Prerequisites:
- Complete [Exercise 3](Exercise 3 Add Feature Service.md), or get the Exercise 3 code solution compiling and running properly, preferably in AppStudio.

If you need some help, you can refer to [the solution to this exercise](../../solutions/Appstudio/Ex4_BufferAndQuery), available in this repository.

## Get the user to click a point

You can use ArcGIS Runtime to detect when and where the user interacts with the map, either with the mouse or with a touchscreen. In this exercise, you just need the user to click or tap a point. You could detect every user click, but instead, we will let the user activate and deactivate this capability with a button.

1. We will add a new button to the UI using [one of the images in the repo](../../images/location.png).  Add the following code below:

    ```
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
                    
                    }
                }

    }
    ```
    
1. Next we need to add a GraphicsLayer to add the graphics to the map:

    ```
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

    ```
      
1. In the onStatusChanged when the MapStutusReady we want to set the renderingmode and add the graphicslayers so onStatusChanged will look like this:

    ```
    onStatusChanged: {
            if (status === Enums.MapStatusReady) {
                extent = initialExtent;
                startGraphics.renderingMode = Enums.RenderingModeStatic;
                addLayer(startGraphics);

            }
        }

    ```
    
1. Next let's create the graphic for the buffer that is created:

    ```
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
    ```
    
1. Next let's add the metro stops feature service to query when we do the buffer

    ```
            GeodatabaseFeatureServiceTable {
                id: featureServiceTable
                url: "http://services.arcgis.com/lA2FZKuu26Fips7U/arcgis/rest/services/MetroStops/FeatureServer/0"
        }

        FeatureLayer {
                    id: metrostopsLayer
                    featureTable: featureServiceTable
                    visible: false
        }

    ```
    
1. Now let's add the onMouseClick and create the buffer:

       ```
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
                }
            }

        }
    ```
    
1. Compile and run your app. Verify that when you click the button and click on the map you get a point and buffer

    ![Create Buffer](06-buffer.png)

1.  Now let's select the metro stops within the buffer.  First we need to create our query.
    ```
		Query {
                id: queryParams
                spatialRelationship: Enums.SpatialRelationshipIntersects
                outFields: ["OBJECTID_1", "NAME"]
            }
    ```

1. Then set the query's geometry and select the features by query.  This will be done after the buffer is added to the map.
	```
		queryParams.geometry = graphic1.geometry;
                    metrostopsLayer.selectionColor = "aqua";
                    metrostopsLayer.selectFeaturesByQuery(queryParams);
    ```
1. Compile and run your app. Verify that when you click the button and click on the map you get a point and buffer

    ![Buffer and Query](07-buffer-and-query.png)

1.  Let's add one last bit of code to clear graphics when the button is pressed again.  You will add this to the code for the button's onPressedChanged:
	```
	if (!checked){
        startGraphics.removeAllGraphics();
        metrostopsLayer.clearSelection();
    }
    ```	
## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to get a user's input on the map, buffer a point, display graphics on the map, and select features based on a query.

Ready for more? Choose from the following:

- [**Exercise 5: Service Area**](Exercise 5 ServiceArea.md)
