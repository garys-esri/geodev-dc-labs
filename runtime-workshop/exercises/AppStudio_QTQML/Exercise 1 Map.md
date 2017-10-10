# Exercise 1: Map (AppStudio)

This exercise walks you through the following:

- Create a new AppStudio blank application
- Add a 2D map to the app
- Add a 3D map to the app 


Prerequisites:

- [Install AppStudio for ArcGIS](http://doc.arcgis.com/en/appstudio/download/)

If you need some help, you can refer to [the solution to this exercise](../../solutions/AppStudio/Ex1_MapScene), available in this repository.

## Create a new AppStudio for ArcGIS application and add a 2D map
1. Start AppStudio and double click the "New App" button.  Select the radio button for "Starter" and Click on "App" at the top.  Give the app a title like "Ex1_MapScene" and click "Ok".
    

2. The application should be highlighted in your list of applications.  In AppStudio click the green "Qt Creator button" has the tooltip "Edit".  Replace the Text {...} code with the following to create a title bar for your app.  if you want to change the title of your application that shows up in the title, that is located in the iteminfo.json file
    
    ```
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
    ```
3. Now lets add a map to the app.  First you will need to import ArcGIS.AppFramework.Runtime 1.0. Then you will need to add a map to your app by adding the below code after your rectangle you added above.

    ```
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
    ```
4. Compile and run your app. The shortcut to this is Alt-Shift-R.

    ![Basic map with title](01-basic-map-app.PNG)
    
5. Add a status indicator.

    ```
  // Busy Indicator
        BusyIndicator {
            anchors.centerIn: mapView
            width: height
            running: true
            visible: (mapView.drawStatus === Enums.DrawStatusInProgress)
        }
    ```
    
6. Compile and run your app. The shortcut to this is Alt-Shift-R.

    ![Basic map zoomed to DC](02-basic-map-app-zoomed.PNG)
    
7.  Now let's add a 3D map to your app.  First let's add a button to switch between 2D and 3D.
    ```
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
    ```
8.  Also create a global variable for when in 3D vs. 2D.
    ```
    App {
        property bool threeD: false
      //the rest of the app below  
     }
    ```
9.  Now let's create the 3D SceneView just like we create a MapView.  There are a few differences to a SceneView, in that a sceneview has an elevation surface that features are draped on. Also, the use of a camera to control the view of the scene vs. just an extent. 
```
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
    ```
10. Compile and run your app. The shortcut to this is Alt-Shift-R.

## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to add a 2D map, using AppStudio.

