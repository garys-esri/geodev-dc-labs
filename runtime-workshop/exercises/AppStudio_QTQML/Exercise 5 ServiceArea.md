# Exercise 5: Service Area (AppStudio)

This exercise walks you through the following:
- Get the user to click on the map and calculate drive times from that location
- Display them on the map

Prerequisites:
- Complete [Exercise 4](Exercise 4 Buffer and Query.md), or get the Exercise 4 code solution compiling and running properly, preferably in AppStudio.

If you need some help, you can refer to [the solution to this exercise](../../solutions/AppStudio/Ex5_ServiceArea), available in this repository.

## Create drive times from users click on the map

After doing Exercise 4, this should seem familiar to you.

1. First we should create a new button for the drive time.  We want this button to appear under the buffer and query button so put it within the context of the Column under the other button:

    ```
    Button {
                id: drivetimeButton
                enabled: true
                Image {
                    anchors.fill: parent
                    source: "https://raw.githubusercontent.com/garys-esri/geodev-dc-labs/master/2016-11-runtime/images/car.png"
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

    ```
1. We need to add a bit of code into the onPressedChanged for each button (DriveTime and BufferAndQuery).  If one button is already pressed and the other is pressed we want to set the checked to false for the one that was already pressed and clear any graphics from the previous mouse clicks on the map.  The drivetimeButton onPressedChanged will look like:
    ```
    onPressedChanged: {
                    if (!checked){
                        if (bufferqueryButton.checked)
                            bufferqueryButton.checked = false;
                        startGraphics.removeAllGraphics();
                        metrostopsLayer.clearSelection();
                    }
                }
    ```
    And the bufferandquery button onPressedChanged will look like this:
	```
    onPressedChanged: {
                    if (!checked){
                        if (drivetimeButton.checked)
                            drivetimeButton.checked = false;
                        startGraphics.removeAllGraphics();
                        metrostopsLayer.clearSelection();
                    }
                }
    ```
1. Add a global variable for facilities:
	```
    property int facilities: 0
	```
1. Next we need to create the NetworkAnalystFeatures:

    ```
               NAFeaturesAsFeature {
                id: facilitiesFeatures
            }

    ```
1. Also create some graphics and symbols for these features:

    ```
                SimpleFillSymbol {
                id: polygonFill
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

    ```

1. Next we will need to create the ServiceAreaTaskParameters that will be passed to the serviceAreaTask that we will create later:  

    ```
    ServiceAreaTaskParameters {
                id: taskParameters
            }
    ```    
    
1. Now let's add the code for when the button for drivetime is clicked and the user clicks on the map.  This will be added as an else if to the onMouseClicked.  Basically we are getting the graphic where the user clicked and adding this location to the facilitiesFeatures that we created earlier and then creating the taskParameters properties for the facility locations, defaultBreaks, and the outSpatialReference.

    ```
    else if (drivetimeButton.checked) {
                if (startGraphics.numberOfGraphics === 0) {
                  startGraphics.addGraphic(graphic);
                  facilitiesFeatures.setFeatures(0);
                  facilities = 0;

                  facilities++;
                  facilitiesFeatures.addFeature(graphic);

                  taskParameters.facilities = facilitiesFeatures;
                  taskParameters.defaultBreaks = [1.0, 3.0, 5.0];
                  taskParameters.outSpatialReference = map.spatialReference;
		}
	}
    ```

1. Since the ServiceArea requires a credentials to use the service, we can do this a couple different ways but this exercise we will use the clientId and clientSecret.  You get these by going to developers.arcgis.com and registering your app with the org account that you are using for the class.  Once you have these add the strings below with this code:

    ```
     UserCredentials {
            id: oAuthCredentials
            oAuthClientInfo: OAuthClientInfo {
                clientId: ""
                clientSecret: ""
                oAuthMode: Enums.OAuthModeApp

            }
        }
    ```
    
1. Now let's build the solver for the service area.  In the serviceAreaTask we will pass the url for the rest service and in the onSolveStatusChanged if it is complete we will add the polygons to the map by randomly assigning different colored polygons for the service areas.  If there is an error we will report it.

    ```
    ServiceAreaTask {
                id: serviceAreaTask
                url: "http://route.arcgis.com/arcgis/rest/services/World/ServiceAreas/NAServer/ServiceArea_World"

                onSolveStatusChanged: {
                    if (solveStatus === Enums.SolveStatusCompleted) {

                        var polygons = solveResult.serviceAreaPolygons.graphics;
                        for (var index = 0; index < polygons.length; index++) {
                            var polygon = polygons[index];
                            polygonFill.color = Qt.rgba(Math.random()%255, Math.random()%255, Math.random()%255, .5);
                            serviceAreaPolygonGraphic.symbol = polygonFill; // re-randomize the color
                            var graphic = serviceAreaPolygonGraphic.clone();
                            graphic.geometry = polygon.geometry;
                            startGraphics.addGraphic(graphic);
                        }
                    } else if (solveStatus === Enums.SolveStatusErrored) {
                        errorMsg = "Solve error:" + solveError.message+ "\nPlease reset and start over.";
                        messageDialog.visible = true;
                    }
                }
            }
   ```
    
1. The last step is actually calling the service area to be solved.  This will be done back on the onMouseClicked and these two lines will be added after you set the taskParameters.

    ```
   		serviceAreaTask.credentials = oAuthCredentials;
        serviceAreaTask.solve(taskParameters);
    ```
        
1. Compile and run your app. Verify that you can click the drive time button and click on the map and drive times are created.:

    ![Service Area](08-service-area.png)

    
## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to calculate a service area using a web service and display the service areas on the map.


That concludes the exercises for this workshop. Well done!
