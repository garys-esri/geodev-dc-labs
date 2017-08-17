# Exercise 2: Add Zoom In and Zoom Out Buttons (Android)

This exercise walks you through the following:
- Add zoom in and zoom out buttons to the UI
- Zoom in and out on the map and the scene
- Add a button for locking the scene's focus point

Prerequisites:
- Complete [Exercise 1](Exercise%201%20Map%20and%20Scene.md), or get the Exercise 1 code solution compiling and running properly, preferably in an IDE.

If you need some help, you can refer to [the solution to this exercise](../../solutions/Android/Ex2_ZoomButtons), available in this repository.

## Add zoom in and zoom out buttons to the UI

1. In `res/layout/activity_main.xml`, add to the `RelativeLayout` two buttons: one for zooming in, and one for zooming out, and place them above the 2D/3D toggle button (note: `zoom_out` and `zoom_in` refer to images that you copied in the previous exercise):

    ```
    <ImageButton
        android:id="@+id/imageButton_zoomOut"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentRight="true"
        android:layout_above="@id/imageButton_toggle2d3d"
        android:src="@drawable/zoom_out"
        android:onClick="imageButton_zoomOut_onClick"/>
    <ImageButton
        android:id="@+id/imageButton_zoomIn"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignRight="@id/imageButton_zoomOut"
        android:layout_above="@id/imageButton_zoomOut"
        android:src="@drawable/zoom_in"
        android:onClick="imageButton_zoomIn_onClick"/>
    ```
    
1. The XML you just added specifies an `onClick` method for each button. Create a `public void` method with a `View` parameter for each of those method names. For now, you can put a `Toast` in each method just to see that they run:

    ```
    public void imageButton_zoomIn_onClick(View view) {
        Toast.makeText(this, "Zoom in!", Toast.LENGTH_SHORT).show();
    }

    public void imageButton_zoomOut_onClick(View view) {
        Toast.makeText(this, "Zoom out!", Toast.LENGTH_SHORT).show();
    }
    ```
    
1. Run your app. Verify that the zoom buttons display on top of the map and that the event handler methods are called when you click them:

    ![Zoom buttons](04-zoom-buttons.png)

## Zoom in and out on the map and the scene

1. In ArcGIS Runtime, zooming on a map and zooming on a scene use simple but quite different mechanisms. We'll talk more about those mechanisms later, but for now, get ready to zoom by creating an empty `private void zoomMap(double)` method and an empty `private void zoomScene(double)` method in your class. For each of these methods, it's a good idea to name the parameter `factor`.

1. Rather than having your event handlers call `zoomMap` and `zoomScene` directly, you can simplify your code by creating a generic `zoom(double)` method that calls `zoomMap` or `zoomScene` depending on whether you're currently in 2D mode or 3D mode:

    ```
    private void zoom(double factor) {
        if (threeD) {
            zoomScene(factor);
        } else {
            zoomMap(factor);
        }
    }
    ```
    
1. In your zoom button event handler methods, replace the `Toast`s with a call to `zoom(double)` with a _factor_. Use a factor between 0 and 1 to zoom out, and use a factor greater than 1 to zoom in:

    ```
    private void imageButton_zoomIn_onAction() {
        zoom(2.0);
    }
    
    private void imageButton_zoomOut_onAction() {
        zoom(0.5);
    }
    ```

1. For the ArcGIS Runtime 2D `MapView`, the zoom mechanism is relatively simple: get the map scale, divide it by a factor, and use the quotient to set the `MapView`'s viewpoint scale. Write the code for this operation inside the `zoomMap(double)` method:

    ```
    mapView.setViewpointScaleAsync(mapView.getMapScale() / factor);
    ```

1. Create a private method called `getSceneTarget()` that returns the point on Earth's surface on which the camera is currently focusing. You can use this method for zooming and also the lock focus button you will add later:

    ```
    private Geometry getSceneTarget() {
        return sceneView.getCurrentViewpoint(Viewpoint.Type.CENTER_AND_SCALE).getTargetGeometry();
    }
    ```

1. 3D is awesome, but it is almost always more complicated than 2D, and zooming is no exception. ArcGIS Runtime's 3D `SceneView` uses a _viewpoint_ with a _camera_ to change the user's view of the scene. Objects of type `Camera` are immutable and have a fluent API, so you can get a copy of the `SceneView`'s current viewpoint camera, use a factor to move it toward or away from the camera's current target, and use it as the `SceneView`'s new viewpoint camera. You can even animate the camera's movement and specify the duration of the animated camera movement (the code that follows uses `0.5f` to animate for half a second). In this case, we will use the `Camera`'s `zoomToward` method to create a new `Camera`. Add the following code to your `zoomScene(double)` method. As you do, make sure you import `com.esri.arcgisruntime.geometry.Point` and `com.esri.arcgisruntime.mapping.view.Camera` instead of some other `Point` and `Camera` classes:

    ```
    Geometry target = getSceneTarget();
    if (target instanceof Point) {
        Camera camera = sceneView.getCurrentViewpointCamera()
                .zoomToward((Point) target, factor);
        sceneView.setViewpointCameraAsync(camera, 0.5f);
    } else {
        // This shouldn't happen, but in case it does...
        Logger.getLogger(MainActivity.class.getName()).log(Level.WARNING,
                "SceneView.getCurrentViewpoint returned {0} instead of {1}",
                new String[] { target.getClass().getName(), Point.class.getName() });
    }
    ```
    
1. Run your app. Verify that the zoom in and out buttons work.

## Add a button for locking the scene's focus point

This portion of the exercise will teach you how to use _camera controllers_ in ArcGIS Runtime.

1. Inside `res/drawable`, create a new drawable resource file called `lock_focus_button.xml`. Android Studio creates this file with a `<selector>` element. Add two `<item>` elements to the selector: one for drawing the button when it is selected, and one for drawing the button when it is not selected. `drawable/lock` and `drawable/lock_selected` refer to images that you added to `res/drawable` in a previous exercise. Your `lock_focus_button.xml` should look something like this:

    ```
    <?xml version="1.0" encoding="utf-8"?>
    <selector xmlns:android="http://schemas.android.com/apk/res/android">
        <item android:state_selected="false" android:drawable="@drawable/lock" />
        <item android:state_selected="true" android:drawable="@drawable/lock_selected" />
    </selector>
    ```

1. Open `activity_main.xml`. Add to the `RelativeLayout` an `ImageButton` for locking the 3D scene's focus point. Set the button's `android:src` to be the `lock_focus_button` drawable resource you created in the previous step. Give the `ImageButton` an `onClick` event handler (here we call it `imageButton_lockFocus_onClick`). Place the button to the left of the zoom in button:

    ```
    <ImageButton
        android:id="@+id/imageButton_lockFocus"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_toLeftOf="@id/imageButton_zoomIn"
        android:layout_alignBottom="@id/imageButton_zoomIn"
        android:src="@drawable/lock_focus_button"
        android:onClick="imageButton_lockFocus_onClick"/>
    ```

1. In your `MainActivity` class, create the `public void` event listener method that you attached to the button in the previous step. This method should take a `View` as a parameter:

    ```
    public void imageButton_lockFocus_onClick(View view) {
    
    }
    ```

1. In your class, declare an `ImageButton` field and set it to `null`:

    ```
    private ImageButton imageButton_lockFocus = null;
    ```

1. In `onCreate(Bundle)`, after `setContentView`, set `imageButton_lockFocus` to the `ImageButton` you created in XML, using `findViewById`:

    ```
    imageButton_lockFocus = findViewById(R.id.imageButton_lockFocus);
    ```

1. In `imageButton_lockFocus_onClick(View)`, invert the button's `selected` property, and then add an `if-else` statement for whether or not the button is selected. _Note: we could have used a ToggleButton instead of an ImageButton._ Here is the code to add to the listener method:

    ```
    imageButton_lockFocus.setSelected(!imageButton_lockFocus.isSelected());
    if (imageButton_lockFocus.isSelected()) {
    
    } else {
    
    }
    ```

1. If the button is NOT selected, it's only one line of code to set the `SceneView`'s camera controller to a default `GlobeCameraController`. Insert this line in your new `else` block:

    ```
    sceneView.setCameraController(new GlobeCameraController());
    ```

1. If the button IS selected, you need to give the `SceneView` a new `OrbitLocationCameraController`, which locks the camera's focus on a given point. `OrbitLocationCameraController`'s constructor takes two arguments:

    1. The target point on Earth's surface. You can use the current camera's target point by calling your `getSceneTarget()` method.
    1. The distance (in meters) from the target at which the camera should be placed. ArcGIS Runtime's `GeometryEngine` lets you calculate the x/y distance in meters between two points, but the constructor needs an x/y/z distance, which you can calculate using the [Pythagorean theorem](https://en.wikipedia.org/wiki/Pythagorean_theorem) (did we mention that this workshop would require junior high school math?).

    The following steps will help you set up this camera controller.

1. In your empty `if` block, get the scene target, verify that it is of type `Point`, and cast it to `Point`:

    ```
    Geometry target = getSceneTarget();
    if (target instanceof Point) {
        final Point targetPoint = (Point) target;
        
    }
    ```

1. After getting `targetPoint`, get the `SceneView`'s current camera and its location, and verify that the location is not null:

    ```
    final Camera currentCamera = sceneView.getCurrentViewpointCamera();
    Point currentCameraPoint = currentCamera.getLocation();
    if (null != currentCameraPoint) {
        
    }
    ```

1. If the current camera point is not null, use [`GeometryEngine.distanceGeodetic(Point, Point, LinearUnit, AngularUnit, GeodeticCurveType)`](https://developers.arcgis.com/android/latest/api-reference/reference/com/esri/arcgisruntime/geometry/GeometryEngine.html#distanceGeodetic(com.esri.arcgisruntime.geometry.Point%2C%20com.esri.arcgisruntime.geometry.Point%2C%20com.esri.arcgisruntime.geometry.LinearUnit%2C%20com.esri.arcgisruntime.geometry.AngularUnit%2C%20com.esri.arcgisruntime.geometry.GeodeticCurveType)) to calculate the ground distance between the target point and the x/y part of the current camera location. Then use the Pythagorean theorem to calculate the distance from the target point and the current camera:

    ```
    final double xyDistance = GeometryEngine.distanceGeodetic(targetPoint, currentCameraPoint,
            new LinearUnit(LinearUnitId.METERS),
            new AngularUnit(AngularUnitId.DEGREES),
            GeodeticCurveType.GEODESIC
    ).getDistance();
    final double zDistance = currentCameraPoint.getZ();
    final double distanceToTarget = Math.sqrt(Math.pow(xyDistance, 2.0) + Math.pow(zDistance, 2.0));
    ```

1. Create a new [`OrbitLocationCameraController`](https://developers.arcgis.com/android/latest/api-reference/reference/com/esri/arcgisruntime/mapping/view/OrbitLocationCameraController.html) with the target point and distance you calculated. Set its heading and pitch from the current camera. Then give the `SceneView` the camera controller you created:

    ```
    final OrbitLocationCameraController cameraController = new OrbitLocationCameraController(
            (Point) target, distanceToTarget
    );
    cameraController.setCameraHeadingOffset(currentCamera.getHeading());
    cameraController.setCameraPitchOffset(currentCamera.getPitch());
    sceneView.setCameraController(cameraController);
    ```
    
1. Run your app. Switch to 3D mode, navigate to a point where you want to lock, and tap the lock button. Verify that navigation now focuses on the target point. Tap the lock button again and verify that normal navigation is restored:

    ![Lock focus button](04a-lock-focus-button.jpg)

## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to add buttons that programmatically zoom in and out on a 2D map and a 3D scene, as well as how to work with camera controllers.

Ready for more? Choose from the following:
- Start on [**Exercise 3: Add a Feature Layer**](Exercise%203%20Local%20Feature%20Layer.md).
- We used `OrbitLocationCameraController`, which causes navigation to orbit around a fixed location. [`OrbitGeoElementCameraController`](https://developers.arcgis.com/android/latest/api-reference/reference/com/esri/arcgisruntime/mapping/view/OrbitGeoElementCameraController.html) causes navigation to orbit around a [`GeoElement`](https://developers.arcgis.com/android/latest/api-reference/reference/com/esri/arcgisruntime/mapping/GeoElement.html), whose location can move. See if you can figure out how to make the camera focus on a moving point.
