# Exercise 1: Map and Scene (Qt Quick)

This exercise walks you through the following:
- Create a new Qt Quick app with ArcGIS Runtime
- Add a 3D scene to the app, and use a toggle button to switch between 2D and 3D

Prerequisites:
- Meet [the system requirements for ArcGIS Runtime Quartz Beta 1 for Qt](https://developers.arcgis.com/qt/quartz/qml/guide/arcgis-runtime-sdk-for-qt-system-requirements.htm).
- Install Qt Creator.
- Install the ArcGIS Runtime SDK Quartz Beta 1 for Qt. Go to [the Runtime for Qt guide](https://developers.arcgis.com/qt/quartz/qml/guide/arcgis-runtime-sdk-for-qt.htm) and expand **Get started** to see links to the install instructions. On that page, there is a button in the upper right corner to go to [the downloads page](https://developers.arcgis.com/downloads/). Follow all of the applicable install instructions in order to configure Runtime with Qt Creator. (Note: there is no need to follow the Android portion of the instructions if you're not deploying to Android for this workshop.)
- This exercise was developed for Windows. If you would like to deploy to a different platform, such as Linux, Mac, Android, or iOS, additional setup may be required.

If you need some help, you can refer to [the solution to this exercise](../../../solutions/Qt/Qt Quick/Ex1_MapAndScene), available in this repository.

## Create a new Qt Quick app with ArcGIS Runtime

1. In Qt Creator, create a new **ArcGIS Runtime Qt Quick Application** project. Go through the wizard to create the project. Run the project to verify that you see an app with a map:

    ![Map app](01-map.png)
    
1. Qt Creator should open `main.qml` by default. If not, open it in your project under `Resources/qml/qml.qrc/qml/main.qml`. Replace `BasemapStreets` with a basemap of your choice, such as `BasemapNationalGeographic`. If you type `Basemap` and then `Ctrl+Space`, Qt Creator offers code completion to show you the different basemaps available.

## Add a 3D scene to the app, and use a toggle button to switch between 2D and 3D

1. Add a property to your `ApplicationWindow` to track the 2D/3D state:

    ```
    property bool threeD: false
    ```
    
1. Give your `MapView` an ID:

    ```
    MapView {
        id: mapView
        ...
    }
    ```
    
1. After your `MapView`, add an invisible `SceneView` that fills the window just like the `MapView`. Give its scene a basemap, such as `BasemapImagery`:

    ```
    SceneView {
        id: sceneView
        anchors.fill: parent
        visible: false

        Scene {
            BasemapImagery {}
        }
    }
    ```
    
1. Download [the exercise images](../../../images) and add them to your project's `Resources.qrc` file, alongside the existing `AppIcon.png` file. In Qt Creator, right-click `Resources/Resources/Resources.qrc/Resources`, choose **Add Existing Files**, and select the files you downloaded. (Note: if you clone the repo, you can just copy the images from there instead of downloading again.)
    
1. After your `SceneView`, add a button to toggle between 2D and 3D:

    ```
    Button {
        id: button_toggle2d3d
        iconSource: "qrc:///Resources/three_d.png"
        anchors.right: mapView.right
        anchors.rightMargin: 20
        anchors.bottom: mapView.bottom
        anchors.bottomMargin: 20
    }
    ```
    
1. Add an `onClicked` handler to your button that 1) toggles the value of `threeD`, 2) toggles the visibility of the map view and scene view, and 3) changes the button's image:

    ```
    onClicked: {
        threeD = !threeD
        mapView.visible = !threeD
        sceneView.visible = threeD
        iconSource = "qrc:///Resources/" +
                (threeD ? "two" : "three") +
                "_d.png"
    }
    ```
    
1. Run your app. Verify that you can toggle between 2D and 3D:

    ![Scene](02-scene.jpg)

## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to add a 2D map and a 3D scene to an app, using ArcGIS Runtime.

Ready for more? Choose from the following:

- [**Exercise 2: Add Zoom In and Zoom Out Buttons**](Exercise 2 Zoom Buttons.md)
- **Bonus**: the map and scene we added operate independently. When you pan the map, the scene does not move, and when you pan the scene, the map does not move. Can you figure out how to link the viewpoints of the map and the scene so that when you pan one, the other automatically pans? 2D and 3D use different mechanisms for panning and zooming, so watch out! Send us a pull request if you figure it out.