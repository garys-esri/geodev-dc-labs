/*******************************************************************************
 * Copyright 2016-2017 Esri
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *  http://www.apache.org/licenses/LICENSE-2.0
 *  
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/
package com.esri.wdc.geodev201611;

import com.esri.arcgisruntime.geometry.Geometry;
import com.esri.arcgisruntime.geometry.Point;
import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.ArcGISScene;
import com.esri.arcgisruntime.mapping.ArcGISTiledElevationSource;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.Surface;
import com.esri.arcgisruntime.mapping.Viewpoint;
import com.esri.arcgisruntime.mapping.view.Camera;
import com.esri.arcgisruntime.mapping.view.MapView;
import com.esri.arcgisruntime.mapping.view.SceneView;
import java.util.logging.Level;
import java.util.logging.Logger;
import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

/**
 * This Application class demonstrates key features of ArcGIS Runtime 100.0.
 */
public class WorkshopApp extends Application {
    
    // Exercise 1: Specify elevation service URL
    private static final String ELEVATION_IMAGE_SERVICE = 
            "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";

    // Exercise 1: Declare and instantiate fields, including UI components
    private final MapView mapView = new MapView();
    private ArcGISMap map = new ArcGISMap();
    private final ImageView imageView_2d =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/two_d.png")));
    private final ImageView imageView_3d =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/three_d.png")));
    private final Button button_toggle2d3d = new Button(null, imageView_3d);
    private final AnchorPane anchorPane = new AnchorPane();
    private SceneView sceneView = null;
    private ArcGISScene scene = null;
    private boolean threeD = false;
    
    // Exercise 2: Declare UI components for zoom buttons
    private final ImageView imageView_zoomIn =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/zoom_in.png")));
    private final ImageView imageView_zoomOut =
            new ImageView(new Image(WorkshopApp.class.getResourceAsStream("/resources/zoom_out.png")));
    private final Button button_zoomIn = new Button(null, imageView_zoomIn);
    private final Button button_zoomOut = new Button(null, imageView_zoomOut);
    
    /**
     * Default constructor for class.
     */
    public WorkshopApp() {
        super();

        // Exercise 1: Set up the 2D map, since we will display that first
        map.setBasemap(Basemap.createNationalGeographic());
        mapView.setMap(map);

        // Exercise 1: Set the 2D/3D toggle button's action
        button_toggle2d3d.setOnAction(event -> button_toggle2d3d_onAction());
        
        // Exercise 2: Set the zoom buttons' actions
        button_zoomIn.setOnAction(event -> button_zoomIn_onAction());
        button_zoomOut.setOnAction(event -> button_zoomOut_onAction());
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

        // Exercise 2: Place the zoom buttons in the UI
        AnchorPane.setRightAnchor(button_zoomOut, 15.0);
        AnchorPane.setBottomAnchor(button_zoomOut, 80.0);
        AnchorPane.setRightAnchor(button_zoomIn, 15.0);
        AnchorPane.setBottomAnchor(button_zoomIn, 145.0);
        anchorPane.getChildren().addAll(button_zoomOut, button_zoomIn);
        
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
                sceneView = new SceneView();
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
     * Exercise 2: zoom in
     */
    private void button_zoomIn_onAction() {
        zoom(2.0);
    }
    
    /**
     * Exercise 2: zoom out
     */
    private void button_zoomOut_onAction() {
        zoom(0.5);
    }
    
    /**
     * Exercise 2: determine whether to call zoomMap or zoomScene
     */
    private void zoom(double factor) {
        if (threeD) {
            zoomScene(factor);
        } else {
            zoomMap(factor);
        }
    }
    
    /**
     * Exercise 2: Utility method for zooming the 2D map
     * @param factor the zoom factor (greater than 1 to zoom in, less than 1 to zoom out)
     */
    private void zoomMap(double factor) {
        mapView.setViewpointScaleAsync(mapView.getMapScale() / factor);
    }
    
    /**
     * Exercise 2: Utility method for zooming the 3D scene
     * @param factor the zoom factor (greater than 1 to zoom in, less than 1 to zoom out)
     */
    private void zoomScene(double factor) {
        Geometry target = sceneView.getCurrentViewpoint(Viewpoint.Type.CENTER_AND_SCALE).getTargetGeometry();
        if (target instanceof Point) {
            Camera camera = sceneView.getCurrentViewpointCamera()
                    .zoomToward((Point) target, factor);
            sceneView.setViewpointCameraAsync(camera, 0.5f);
        } else {
            Logger.getLogger(WorkshopApp.class.getName()).log(Level.WARNING,
                    "SceneView.getCurrentViewpoint returned {0} instead of {1}",
                    new String[] { target.getClass().getName(), Point.class.getName() });
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