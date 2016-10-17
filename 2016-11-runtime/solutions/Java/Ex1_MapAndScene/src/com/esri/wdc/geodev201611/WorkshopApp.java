package com.esri.wdc.geodev201611;

import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.ArcGISScene;
import com.esri.arcgisruntime.mapping.ArcGISTiledElevationSource;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.Surface;
import com.esri.arcgisruntime.mapping.view.MapView;
import com.esri.arcgisruntime.mapping.view.SceneView;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

/**
 * This Application class demonstrates key features of ArcGIS Runtime Quartz.
 */
public class WorkshopApp extends Application {
    
    // Exercise 1: Specify elevation service URL
    private static final String ELEVATION_IMAGE_SERVICE = 
            "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";

    // Exercise 1: Declare and instantiate fields, including UI components
    private final MapView mapView = new MapView();
    private final SceneView sceneView = new SceneView();
    private final ImageView imageView_2d =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/two-d.png")));
    private final ImageView imageView_3d =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/three-d.png")));
    private final Button button_toggle2d3d = new Button(null, imageView_3d);
    private final AnchorPane anchorPane = new AnchorPane();
    private ArcGISMap map;
    private ArcGISScene scene;
    private boolean threeD = false;
    
    /**
     * Default constructor for class.
     */
    public WorkshopApp() {
        super();

        // Exercise 1: Set up the 2D map, since we will display that first
        map = new ArcGISMap();
        map.setBasemap(Basemap.createNationalGeographic());
        mapView.setMap(map);

        // Exercise 1: Set the 2D/3D toggle button's action
        button_toggle2d3d.setOnAction(event -> button_toggle2d3d_onAction());
    }
    
    @Override
    public void start(Stage primaryStage) {
        // Exercise 1: Place the MapView and 2D/3D toggle button in the UI
        AnchorPane.setLeftAnchor(mapView, 0.0);
        AnchorPane.setRightAnchor(mapView, 0.0);
        AnchorPane.setTopAnchor(mapView, 0.0);
        AnchorPane.setBottomAnchor(mapView, 0.0);
        AnchorPane.setRightAnchor(button_toggle2d3d, 15.0);
        AnchorPane.setBottomAnchor(button_toggle2d3d, 15.0);
        anchorPane.getChildren().addAll(mapView, button_toggle2d3d);

        // Exercise 1: Finish displaying the UI
        // JavaFX Scene (unrelated to ArcGIS 3D scene)
        Scene javaFxScene = new Scene(anchorPane);
        primaryStage.setTitle("My first map application");
        primaryStage.setWidth(800);
        primaryStage.setHeight(600);
        primaryStage.setScene(javaFxScene);
        primaryStage.show();
    }
    
    @Override
    public void stop() throws Exception {
        // Exercise 1: Dispose of the MapView and SceneView before exiting
        mapView.dispose();
        if (null != sceneView) {
            sceneView.dispose();
        }
        
        super.stop();
    }

    /**
     * Exercise 1: Toggle between 2D map and 3D scene
     */
    private void button_toggle2d3d_onAction() {
        threeD = !threeD;
        button_toggle2d3d.setGraphic(threeD ? imageView_2d : imageView_3d);
        
        // Exercise 1: Switch between 2D map and 3D scene
        if (threeD) {
            if (null == scene) {
                // Set up the 3D scene. This only happens the first time the user switches to 3D.
                scene = new ArcGISScene();
                scene.setBasemap(Basemap.createImagery());
                Surface surface = new Surface();
                surface.getElevationSources().add(new ArcGISTiledElevationSource(ELEVATION_IMAGE_SERVICE));
                scene.setBaseSurface(surface);
                sceneView.setArcGISScene(scene);
                AnchorPane.setLeftAnchor(sceneView, 0.0);
                AnchorPane.setRightAnchor(sceneView, 0.0);
                AnchorPane.setTopAnchor(sceneView, 0.0);
                AnchorPane.setBottomAnchor(sceneView, 0.0);
            }
            anchorPane.getChildren().remove(mapView);
            anchorPane.getChildren().add(0, sceneView);
        } else {
            anchorPane.getChildren().remove(sceneView);
            anchorPane.getChildren().add(0, mapView);
        }
    }
    
    /**
     * Exercise 1: Main method that runs the app.
     * @param args Command line arguments (none are expected for this app).
     */
    public static void main(String[] args) {
        launch(args);
    }
    
}