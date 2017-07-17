# Exercise 2: Add Zoom In and Zoom Out Buttons (.NET C#)

This exercise walks you through the following:
- Add zoom in and zoom out buttons to the UI
- Zoom in and out on the map and the scene

Prerequisites:
- Complete [Exercise 1](Exercise 1 Map and Scene.md), or get the Exercise 1 code solution compiling and running properly, preferably in an IDE.

If you need some help, you can refer to [the solution to this exercise](../../solutions/dotNETWPF/Ex2_ZoomButtons), available in this repository.

## Add zoom in and zoom out buttons to the UI
1. If desired, make a copy of your Exercise 1 or continue to use the Exercise 1 solution. Just make sure you're running your Exercise 2 code as you complete this exercise.
1. First let's create our two new buttons for zoom in and zoom out within the UI so go to MainWindow.xaml and add the following above the creation of the viewbutton from exercise 1:

    ```
    <Button x:Name="ZoomInButton" Width="50" Height="50" Padding="1" HorizontalAlignment="Right" Margin="0,5,12.4,5" Content="{DynamicResource ZoomIn}"/>
    <Button x:Name="ZoomOutButton" Width="50" Height="50" Padding="1" HorizontalAlignment="Right" RenderTransformOrigin="-0.919,0.469" Margin="0,5,12.4,5" Content="{DynamicResource ZoomOut}"/>

    ```
 
1. Create the click event for each button by typing click= and use tab to create the code in MainWindow.xaml.cs.  Your xaml will look like:

    ```
    <Button x:Name="ZoomInButton" Click="ZoomInButton_Click"  Width="50" Height="50" Padding="1" HorizontalAlignment="Right" Margin="0,5,5,5" Content="{DynamicResource ZoomIn}"/>
    <Button x:Name="ZoomOutButton" Click="ZoomOutButton_Click" Width="50" Height="50" Padding="1" HorizontalAlignment="Right" RenderTransformOrigin="-0.919,0.469" Margin="0,5,5,5" Content="{DynamicResource ZoomOut}"/>

    ```
    And the MainWindow.xaml.cs will have two new methods that look like:
     ```
     private void ZoomOutButton_Click(object sender, RoutedEventArgs e)
        {

        }

        private void ZoomInButton_Click(object sender, RoutedEventArgs e)
        {

        }
      ```
    
1. Compile and run your app. Verify that the zoom buttons display on top of the map, that they do not block the 2D/3D toggle button, and that the event handler methods are called when you click them:

    ![Zoom buttons](04-zoom-buttons.png)

## Zoom in and out on the map and the scene

1. In ArcGIS Runtime, zooming on a map and zooming on a scene use simple but quite different mechanisms. We'll talk more about those mechanisms later, but for now, get ready to zoom by creating an empty `private void zoomMap(double factor)` method and a `private void zoomScene(double factor)` method in your class. For each of these methods, it's a good idea to name the parameter `factor`.

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
    
1. In your zoom button event handler methods, call to `zoom(double)` with a _factor_. Use a factor between 0 and 1 to zoom out, and use a factor greater than 1 to zoom in:

    ```
    
        private void ZoomInButton_Click(object sender, RoutedEventArgs e)
        {
            zoom(2);
        }
        private void ZoomOutButton_Click(object sender, RoutedEventArgs e)
        {
            zoom(.5);
        }
    ```
    
1. For the ArcGIS Runtime 2D `MapView`, the zoom mechanism is relatively simple: get the map scale, divide it by a factor, and use the quotient to set the `MapView`'s viewpoint scale. Write the code for this operation inside the `zoomMap(double)` method:

    ```
    mapView.SetViewpointScaleAsync(mapView.GetCurrentViewpoint(ViewpointType.CenterAndScale).Scale / factor);
    ```
    
1. 3D is awesome, but it is almost always more complicated than 2D, and zooming is no exception. ArcGIS Runtime's 3D `SceneView` uses a _viewpoint_ with a _camera_ to change the user's view of the scene. Objects of type `Camera` are immutable and have a fluent API, so you can get a copy of the `SceneView`'s current viewpoint camera, use a factor to move it toward or away from the camera's current target, and use it as the `SceneView`'s new viewpoint camera. You can even animate the camera's movement and specify the duration of the animated camera movement (the code that follows uses a TimeSpan). In this case, we will use the `Camera`'s `zoomToward` method to create a new `Camera`. Add the following code to your `zoomScene(double)` method. 

    ```
    private void zoomScene(double factor)
        {
            Esri.ArcGISRuntime.Geometry.Geometry target = sceneView.GetCurrentViewpoint(ViewpointType.CenterAndScale).TargetGeometry;
            if (target.GeometryType == GeometryType.Point)
            {
                Camera camera = sceneView.Camera.ZoomToward((Esri.ArcGISRuntime.Geometry.MapPoint)target, factor);
                sceneView.SetViewpointCameraAsync(camera, new TimeSpan(1000));
            }
        }
    ```
    
1. Compile and run your app. Verify that the zoom in and out buttons work in both 2D mode and 3D mode.
    
## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to add buttons that programmatically zoom in and out on a 2D map and a 3D scene.

Ready for more? Start on [**Exercise 3: Add a Feature Layer**](Exercise 3 Local Feature Layer.md).
