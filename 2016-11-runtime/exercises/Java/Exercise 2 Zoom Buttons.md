# Exercise 2: Add Zoom In and Zoom Out Buttons (Java)

This exercise walks you through the following:
- Add zoom in and zoom out buttons to the UI
- Zoom in and out on the map and the scene

Prerequisites:
- Complete [Exercise 1](Exercise 1 Map and Scene.md), or get the Exercise 1 code solution compiling and running properly, preferably in an IDE.

If you need some help, you can refer to [the solution to this exercise](../../solutions/Java/Ex2_ZoomButtons), available in this repository.

## Add zoom in and zoom out buttons to the UI
1. If desired, make a copy of your Exercise 1 class. Just make sure you're running your Exercise 2 code as you complete this exercise.
1. In your class, before your constructor, instantiate two buttons: one for zooming in, and one for zooming out:

    ```
    private final ImageView imageView_zoomIn =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/zoom-in.png")));
    private final ImageView imageView_zoomOut =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/zoom-out.png")));
    private final Button button_zoomIn = new Button(null, imageView_zoomIn);
    private final Button button_zoomOut = new Button(null, imageView_zoomOut);
    ```
    
1. In your `start(Stage)` method, after adding the MapView and 2D/3D toggle button to the UI, add the zoom in and zoom out buttons to the UI, near the 2D/3D toggle button in the lower right corner:

    ```
    AnchorPane.setRightAnchor(button_zoomOut, 15.0);
    AnchorPane.setBottomAnchor(button_zoomOut, 80.0);
    AnchorPane.setRightAnchor(button_zoomIn, 15.0);
    AnchorPane.setBottomAnchor(button_zoomIn, 145.0);
    anchorPane.getChildren().addAll(button_zoomOut, button_zoomIn);
    ```
    
1. Create `private void` event handler methods for the zoom in and zoom out buttons. Add a `System.out.println` to each event handler for now, just to verify that the buttons work:

    ```
    private void button_zoomIn_onAction() {
        System.out.println("TODO zoom in!");
    }
    
    private void button_zoomOut_onAction() {
        System.out.println("TODO zoom out!");
    }
    ```
    
1. In your constructor, set the zoom buttons' `onAction` handlers to call the event handler methods you just created:

    ```
    button_zoomIn.setOnAction(event -> button_zoomIn_onAction());
    button_zoomOut.setOnAction(event -> button_zoomOut_onAction());
    ```
    
1. Compile and run your app. Verify that the zoom buttons display on top of the map, that they do not block the 2D/3D toggle button, and that the event handler methods are called when you click them:

    ![Zoom buttons](04-zoom-buttons.png)

## Zoom in and out on the map and the scene

1. In ArcGIS Runtime, zooming on a map and zooming on a scene use simple but quite different mechanisms. We'll talk more about those mechanisms later, but for now, get ready to zoom by creating an empty `private void zoomMap(double)` method and a `private void zoomScene(double)` method in your class. For each of these methods, it's a good idea to name the parameter `factor`.

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
    
1. In your zoom button event handler methods, replace the `System.out.println` call with a call to `zoom(double)` with a _factor_. Use a factor between 0 and 1 to zoom out, and use a factor greater than 1 to zoom in:

    ```
    private void button_zoomIn_onAction() {
        zoom(2.0);
    }
    
    private void button_zoomOut_onAction() {
        zoom(0.5);
    }
    ```
    
1. For the ArcGIS Runtime 2D `MapView`, the zoom mechanism is relatively simple: get the map scale, divide it by a factor, and use the quotient to set the `MapView`'s viewpoint scale. Write the code for this operation inside the `zoomMap(double)` method:

    ```
    mapView.setViewpointScaleAsync(mapView.getMapScale() / factor);
    ```
    
1. 3D is awesome, but it is almost always more complicated than 2D, and zooming is no exception. ArcGIS Runtime's 3D `SceneView` uses a _viewpoint_ with a _camera_ to change the user's view of the scene. Objects of type `Camera` are immutable and have a fluent API, so you can get a copy of the `SceneView`'s current viewpoint camera, use a factor to move it toward or away from the camera's current target, and use it as the `SceneView`'s new viewpoint camera. You can even animate the camera's movement and specify the duration of the animated camera movement. In this case, we will use the `Camera`'s `zoomToward` method to create a new `Camera`. Add the following code to your `zoomScene(double)` method:

    ```
    Geometry target = sceneView.getCurrentViewpoint(Viewpoint.Type.CENTER_AND_SCALE).getTargetGeometry();
    if (target instanceof Point) {
        Camera camera = sceneView.getCurrentViewpointCamera()
                // Zoom factor for 3D scene is inverse of 2D map (>1 zooms in)
                .zoomToward((Point) target, 1.0 / factor);
        sceneView.setViewpointCameraWithDurationAsync(camera, 0.5f);
    } else {
        Logger.getLogger(WorkshopApp.class.getName()).log(Level.WARNING,
                "SceneView.getCurrentViewpoint returned {0} instead of {1}",
                new String[] { target.getClass().getName(), Point.class.getName() });
    }
    ```
    
1. Compile and run your app. Verify that the zoom in and out buttons work in both 2D mode and 3D mode.
    
## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to add buttons that programmatically zoom in and out on a 2D map and a 3D scene.

Ready for more? Start on [**Exercise 3: Add a Feature Layer**](Exercise 3 Local Feature Layer.md).