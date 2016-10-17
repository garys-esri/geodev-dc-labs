# Exercise 1: Map and Scene (Java)

This exercise walks you through the following:
- Create a new JavaFX app
- Add ArcGIS Runtime to the app
- Add a 2D map and a 3D scene to the app
- Add a toggle button to switch between 2D and 3D

Prerequisites:
- Install the Java Development Kit (JDK) version 8 or higher.
- Optional: install a Java integrated development environment (IDE).

If you need some help, you can refer to [the solution to this exercise](../../solutions/Java/Ex1_MapAndScene), available in this repository.

## Create a new JavaFX app
1. Create a new Java application project in the IDE of your choice. Create a class that extends `javafx.application.Application`:

    ```
    package workshopapp;

    import javafx.application.Application;

    public class WorkshopApp extends Application {

    }
    ```

1. Instantiate a field of type `AnchorPane` that will hold the app's UI components:

    ```
    private final AnchorPane anchorPane = new AnchorPane();
    ```

1. Create a Java package called `resources` in your application. Go to [the images directory](../../images) of this repository and copy all of the images to your `resources` package. Then instantiate a `Button` and two `ImageView` fields that reference the images you copied. Use the 3D `ImageView` for the Button. Be sure to import `javafx.scene.image.Image`, rather than some other `Image` class. (Note: you can use text buttons without the images if you prefer.)

    ```
    private final ImageView imageView_2d =
          new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/two-d.png")));
    private final ImageView imageView_3d =
          new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/three-d.png")));
    private final Button button_toggle2d3d = new Button(null, imageView_3d);
    ```

1. Add a default constructor to your class:

    ```
    public WorkshopApp() {
        super();
    }
    ```
    
1. Implement the `start(Stage)` method. In `start(Stage)`, add the `Button` near the lower-right corner of the `AnchorPane`. Create a new JavaFX `Scene` with your `AnchorPane`. Set the `Stage`'s title, width, height, and scene, and then call `show` on the `Stage`:

    ```
    @Override
    public void start(Stage primaryStage) {
        AnchorPane.setRightAnchor(button_toggle2d3d, 15.0);
        AnchorPane.setBottomAnchor(button_toggle2d3d, 15.0);
        anchorPane.getChildren().addAll(button_toggle2d3d);

        Scene javaFxScene = new Scene(anchorPane);
        primaryStage.setTitle("My first map application");
        primaryStage.setWidth(800);
        primaryStage.setHeight(600);
        primaryStage.setScene(javaFxScene);
        primaryStage.show();
    }
    ```
    
1. Add a `main` method to your class that calls `Application.launch`:

    ```
    public static void main(String[] args) {
        launch(args);
    }
    ```
    
1. Compile and run your app. Verify that a button appears in the lower-right corner of the app:

    ![Blank app with button](01-blank-app-with-button.png)
    
## Add ArcGIS Runtime to the app