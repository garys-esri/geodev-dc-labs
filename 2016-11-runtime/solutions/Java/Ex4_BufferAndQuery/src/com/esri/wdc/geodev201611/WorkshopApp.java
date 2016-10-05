package com.esri.wdc.geodev201611;

import com.esri.arcgisruntime.datasource.QueryParameters;
import com.esri.arcgisruntime.geometry.GeometryEngine;
import com.esri.arcgisruntime.geometry.LinearUnit;
import com.esri.arcgisruntime.geometry.LinearUnitId;
import com.esri.arcgisruntime.geometry.Point;
import com.esri.arcgisruntime.geometry.Polygon;
import com.esri.arcgisruntime.geometry.SpatialReference;
import com.esri.arcgisruntime.layers.FeatureLayer;
import com.esri.arcgisruntime.layers.Layer;
import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.ArcGISScene;
import com.esri.arcgisruntime.mapping.ArcGISTiledElevationSource;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.LayerList;
import com.esri.arcgisruntime.mapping.Surface;
import com.esri.arcgisruntime.mapping.Viewpoint;
import com.esri.arcgisruntime.mapping.mobilemappackage.MobileMapPackage;
import com.esri.arcgisruntime.mapping.view.Camera;
import com.esri.arcgisruntime.mapping.view.GeoView;
import com.esri.arcgisruntime.mapping.view.Graphic;
import com.esri.arcgisruntime.mapping.view.GraphicsOverlay;
import com.esri.arcgisruntime.mapping.view.MapView;
import com.esri.arcgisruntime.mapping.view.SceneView;
import com.esri.arcgisruntime.symbology.SimpleFillSymbol;
import com.esri.arcgisruntime.symbology.SimpleLineSymbol;
import com.esri.arcgisruntime.symbology.SimpleMarkerSymbol;
import com.esri.arcgisruntime.util.ListenableList;
import java.util.ArrayList;
import java.util.List;
import javafx.application.Application;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.Point2D;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ToggleButton;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

public class WorkshopApp extends Application {
    
    private static final String MMPK_PATH = "../../../data/DC_Crime_Data.mmpk";
    private static final String ELEVATION_IMAGE_SERVICE = 
            "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";
    
    // Exercise 4: Set up LinearUnit object for unit conversion
    private static final LinearUnit UNIT_METERS = new LinearUnit(LinearUnitId.METERS);
    
    // Exercise 4: Create symbols for click and buffer
    private static final SimpleMarkerSymbol CLICK_SYMBOL =
            new SimpleMarkerSymbol(SimpleMarkerSymbol.Style.CIRCLE, 0xFFffa500, 10);
    private static final SimpleFillSymbol BUFFER_SYMBOL =
            new SimpleFillSymbol(SimpleFillSymbol.Style.NULL, 0xFFFFFFFF, new SimpleLineSymbol(
                    SimpleLineSymbol.Style.SOLID, 0xFFFFA500, 3));
    
    // Exercise 1: Declare fields, including UI components
    private ArcGISMap map;
    private ArcGISScene scene;
    private boolean threeD = false;
    private MapView mapView;
    private SceneView sceneView;
    private final ImageView imageView_2d = new ImageView(new Image(getClass().getResourceAsStream("/resources/two-d.png")));
    private final ImageView imageView_3d = new ImageView(new Image(getClass().getResourceAsStream("/resources/three-d.png")));
    private final Button button_toggle2d3d = new Button(null, imageView_3d);
    private final AnchorPane anchorPane = new AnchorPane();
    
    // Exercise 2: Declare UI components for zoom buttons
    private final ImageView imageView_zoomIn = new ImageView(new Image(getClass().getResourceAsStream("/resources/zoom-in.png")));
    private final ImageView imageView_zoomOut = new ImageView(new Image(getClass().getResourceAsStream("/resources/zoom-out.png")));
    private final Button button_zoomIn = new Button(null, imageView_zoomIn);
    private final Button button_zoomOut = new Button(null, imageView_zoomOut);
    
    // Exercise 4: Declare UI component for location button
    private final ImageView imageView_location = new ImageView(new Image(getClass().getResourceAsStream("/resources/location.png")));
    private final ToggleButton toggleButton_bufferAndQuery = new ToggleButton(null, imageView_location);
    
    // Exercise 4: Instantiate an EventHandler for buffering and querying
    private final EventHandler<MouseEvent> eventHandler_bufferAndQuery = event -> {
        if (MouseButton.PRIMARY.equals(event.getButton()) && event.isStillSincePress()) {
            Point2D screenPoint = new Point2D(event.getX(), event.getY());
            Point geoPoint = threeD ?
                    sceneView.screenToBaseSurface(screenPoint) :
                    mapView.screenToLocation(screenPoint);
            // Project to meters to do the buffer
            geoPoint = (Point) GeometryEngine.project(geoPoint, SpatialReference.create(3857));
            // Buffer by 1000 meters
            Polygon buffer = GeometryEngine.buffer(geoPoint, 1000.0);
            
            // Show click and buffer as graphics
            GeoView geoView = threeD ? sceneView : mapView;
            ListenableList<Graphic> graphics = geoView.getGraphicsOverlays().get(0).getGraphics();
            graphics.clear();
            graphics.add(new Graphic(buffer, BUFFER_SYMBOL));
            graphics.add(new Graphic(geoPoint, CLICK_SYMBOL));
            
            // Run the query
            QueryParameters query = new QueryParameters();
            query.setGeometry(buffer);
            LayerList operationalLayers = threeD ?
                    sceneView.getArcGISScene().getOperationalLayers() :
                    mapView.getMap().getOperationalLayers();
            operationalLayers.parallelStream().filter(
                    layer -> layer instanceof FeatureLayer
            ).forEach(layer -> {
                /**
                 * Note: As of ArcGIS Runtime Quartz Beta 2, this select successfully
                 * selects features, but those features are only highlighted on the
                 * 2D MapView, not on the 3D SceneView. This behavior has been reported
                 * to the ArcGIS Runtime development team.
                 */
                ((FeatureLayer) layer).selectFeaturesAsync(query, FeatureLayer.SelectionMode.NEW);
            });
        }
    };
    
    @Override
    public void start(Stage primaryStage) {
        // Exercise 1: Set the 2D/3D toggle button's action
        button_toggle2d3d.setOnAction((ActionEvent event) -> {
            button_toggle2d3d_onAction();
        });
        
        // Exercise 1: Set up the 2D map, since we will display that first
        map = new ArcGISMap();
        map.setBasemap(Basemap.createNationalGeographic());
        mapView = new MapView();
        mapView.setMap(map);
        
        // Exercise 4: Add a GraphicsOverlay for the click and buffer
        mapView.getGraphicsOverlays().add(new GraphicsOverlay());
        
        /**
         * Exercise 3: Open a mobile map package (.mmpk) and
         * add its operational layers to the map
         */
        final MobileMapPackage mmpk = new MobileMapPackage(MMPK_PATH);
        mmpk.addDoneLoadingListener(() -> {
            List<ArcGISMap> maps = mmpk.getMaps();
            if (0 < maps.size()) {
                map = maps.get(0);
                mapView.setMap(map);
            }
            map.setBasemap(Basemap.createNationalGeographic());
        });
        mmpk.loadAsync();
        
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
        
        // Exercise 4: Place the location button in the UI
        AnchorPane.setRightAnchor(toggleButton_bufferAndQuery, 90.0);
        AnchorPane.setBottomAnchor(toggleButton_bufferAndQuery, 15.0);
        anchorPane.getChildren().add(toggleButton_bufferAndQuery);
        
        // Exercise 2: Set the zoom buttons' actions
        button_zoomIn.setOnAction(event -> button_zoomIn_onAction());
        button_zoomOut.setOnAction(event -> button_zoomOut_onAction());
        
        // Exercise 4: Set the buffer and query toggle button's action
        toggleButton_bufferAndQuery.setOnAction(event -> {
            if (toggleButton_bufferAndQuery.isSelected()) {
                mapView.setOnMouseClicked(eventHandler_bufferAndQuery);
                if (null != sceneView) {
                    sceneView.setOnMouseClicked(eventHandler_bufferAndQuery);
                }
            } else {
                mapView.setOnMouseClicked(null);
                if (null != sceneView) {
                    sceneView.setOnMouseClicked(null);
                }
            }
        });
        
        // Exercise 1: Finish displaying the UI
        // JavaFX Scene (unrelated to ArcGIS 3D scene)
        Scene javaFxScene = new Scene(anchorPane);
        primaryStage.setTitle("My first map application");
        primaryStage.setWidth(800);
        primaryStage.setHeight(600);
        primaryStage.setScene(javaFxScene);
        primaryStage.show();        
    }
    
    /**
     * Exercise 1: Toggle between 2D map and 3D scene
     */
    private void button_toggle2d3d_onAction() {
        threeD = !threeD;
        button_toggle2d3d.setGraphic(threeD ? imageView_2d : imageView_3d);

        if (threeD) {
            if (null == sceneView) {
                // Set up the 3D scene. This only happens the first time the user switches to 3D.
                scene = new ArcGISScene();
                scene.setBasemap(Basemap.createImagery());
                
                // Add elevation surface
                Surface surface = new Surface();
                surface.getElevationSources().add(new ArcGISTiledElevationSource(ELEVATION_IMAGE_SERVICE));
                scene.setBaseSurface(surface);
                
                /**
                 * Exercise 3: Open a mobile map package (.mmpk) and
                 * add its operational layers to the scene
                 */
                scene.addDoneLoadingListener(() -> {
                    final MobileMapPackage mmpk = new MobileMapPackage(MMPK_PATH);
                    mmpk.addDoneLoadingListener(() -> {
                        List<ArcGISMap> maps = mmpk.getMaps();
                        if (0 < maps.size()) {
                            final ArcGISMap thisMap = maps.get(0);
                            ArrayList<Layer> layers = new ArrayList<>();
                            layers.addAll(thisMap.getOperationalLayers());
                            thisMap.getOperationalLayers().clear();
                            layers.stream().forEach((layer) -> {
                                scene.getOperationalLayers().add(layer);
                            });
                            sceneView.setViewpoint(thisMap.getInitialViewpoint());
                            // Rotate the camera
                            Viewpoint viewpoint = sceneView.getCurrentViewpoint(Viewpoint.Type.CENTER_AND_SCALE);
                            Point targetPoint = (Point) viewpoint.getTargetGeometry();
                            Camera camera = sceneView.getCurrentViewpointCamera()
                                    .rotateAround(targetPoint, 45.0, 65.0, 0.0);
                            sceneView.setViewpointCameraAsync(camera);
                        }
                    });
                    mmpk.loadAsync();
                });
                
                sceneView = new SceneView();
                sceneView.setArcGISScene(scene);
                AnchorPane.setLeftAnchor(sceneView, 0.0);
                AnchorPane.setRightAnchor(sceneView, 0.0);
                AnchorPane.setTopAnchor(sceneView, 0.0);
                AnchorPane.setBottomAnchor(sceneView, 0.0);
                
                // Exercise 4: Add a GraphicsOverlay for the click and buffer
                sceneView.getGraphicsOverlays().add(new GraphicsOverlay());
                
                /**
                 * Exercise 4: The buffer and query toggle button might already
                 * be selected. If so, we need to set the SceneView's event handler.
                 */
                if (toggleButton_bufferAndQuery.isSelected()) {
                    sceneView.setOnMouseClicked(eventHandler_bufferAndQuery);
                }
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
        zoom(0.5);
    }
    
    /**
     * Exercise 2: zoom out
     */
    private void button_zoomOut_onAction() {
        zoom(2.0);
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
     * Exercise 2: utility method for zooming the 2D map
     * @param factor the zoom factor (greater than 1 to zoom out, less than 1 to zoom in)
     */
    private void zoomMap(double factor) {
        mapView.setViewpointScaleAsync(mapView.getMapScale() * factor);
    }
    
    /**
     * Exercise 2: utility method for zooming the 3D scene
     * @param factor the zoom factor (greater than 1 to zoom out, less than 1 to zoom in)
     */
    private void zoomScene(double factor) {
        Point target = (Point) sceneView.getCurrentViewpoint(Viewpoint.Type.CENTER_AND_SCALE).getTargetGeometry();
        Camera camera = sceneView.getCurrentViewpointCamera()
                // Zoom factor for 3D scene is inverse of 2D map (>1 zooms in)
                .zoomToward(target, 1.0 / factor);
        sceneView.setViewpointCameraWithDurationAsync(camera, 0.5f);
    }

    @Override
    public void stop() throws Exception {
        // Exercise 1: dispose the MapView and SceneView before exiting
        mapView.dispose();
        if (null != sceneView) {
            sceneView.dispose();
        }
        
        super.stop();
    }

    public static void main(String[] args) {
        launch(args);
    }
    
}