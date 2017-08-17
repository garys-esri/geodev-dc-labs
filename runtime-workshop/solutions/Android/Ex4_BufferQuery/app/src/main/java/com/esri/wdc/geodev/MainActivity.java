package com.esri.wdc.geodev;

import android.app.Activity;
import android.os.Bundle;
import android.os.Environment;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.esri.arcgisruntime.data.QueryParameters;
import com.esri.arcgisruntime.geometry.AngularUnit;
import com.esri.arcgisruntime.geometry.AngularUnitId;
import com.esri.arcgisruntime.geometry.GeodeticCurveType;
import com.esri.arcgisruntime.geometry.Geometry;
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
import com.esri.arcgisruntime.mapping.MobileMapPackage;
import com.esri.arcgisruntime.mapping.Viewpoint;
import com.esri.arcgisruntime.mapping.view.Camera;
import com.esri.arcgisruntime.mapping.view.DefaultMapViewOnTouchListener;
import com.esri.arcgisruntime.mapping.view.DefaultSceneViewOnTouchListener;
import com.esri.arcgisruntime.mapping.view.GlobeCameraController;
import com.esri.arcgisruntime.mapping.view.Graphic;
import com.esri.arcgisruntime.mapping.view.GraphicsOverlay;
import com.esri.arcgisruntime.mapping.view.MapView;
import com.esri.arcgisruntime.mapping.view.OrbitLocationCameraController;
import com.esri.arcgisruntime.mapping.view.SceneView;
import com.esri.arcgisruntime.symbology.SimpleFillSymbol;
import com.esri.arcgisruntime.symbology.SimpleLineSymbol;
import com.esri.arcgisruntime.symbology.SimpleMarkerSymbol;
import com.esri.arcgisruntime.util.ListenableList;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MainActivity extends Activity {

    // Exercise 1: Specify elevation service URL
    private static final String ELEVATION_IMAGE_SERVICE =
            "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";

    // Exercise 3: Instantiate mobile map package (MMPK) path
    private static final String MMPK_PATH = Environment.getExternalStorageDirectory().getPath() + "/data/DC_Crime_Data.mmpk";

    // Exercise 4: Instantiate symbols
    private static final SimpleMarkerSymbol CLICK_SYMBOL =
            new SimpleMarkerSymbol(SimpleMarkerSymbol.Style.CIRCLE, 0xFFffa500, 10);
    private static final SimpleFillSymbol BUFFER_SYMBOL =
            new SimpleFillSymbol(SimpleFillSymbol.Style.NULL, 0xFFFFFFFF,
                    new SimpleLineSymbol(SimpleLineSymbol.Style.SOLID, 0xFFFFA500, 3));

    // Exercise 1: Declare and instantiate fields
    private MapView mapView = null;
    private ArcGISMap map = new ArcGISMap();
    private SceneView sceneView = null;
    private ArcGISScene scene = new ArcGISScene();
    private ImageButton imageButton_toggle2d3d = null;
    private boolean threeD = false;

    // Exercise 2: Declare field for lock focus button.
    private ImageButton imageButton_lockFocus = null;

    // Exercise 4: Declare fields
    private ImageButton imageButton_bufferAndQuery = null;
    private final GraphicsOverlay bufferAndQueryMapGraphics = new GraphicsOverlay();
    private final GraphicsOverlay bufferAndQuerySceneGraphics = new GraphicsOverlay();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Exercise 1: Set up the 2D map.
        mapView = findViewById(R.id.mapView);
        map.setBasemap(Basemap.createNationalGeographic());
        mapView.setMap(map);

        // Exercise 3: Instantiate and load mobile map package
        final MobileMapPackage mmpk = new MobileMapPackage(MMPK_PATH);
        mmpk.addDoneLoadingListener(new Runnable() {
            @Override
            public void run() {
                List<ArcGISMap> maps = mmpk.getMaps();
                if (0 < maps.size()) {
                    map = maps.get(0);
                    mapView.setMap(map);
                    map.addDoneLoadingListener(new Runnable() {
                        @Override
                        public void run() {
                            Viewpoint viewpoint = map.getInitialViewpoint();
                            if (null != viewpoint) {
                                mapView.setViewpointAsync(viewpoint);
                            }
                        }
                    });
                }
                map.setBasemap(Basemap.createNationalGeographic());
            }
        });
        mmpk.loadAsync();

        // Exercise 1: Set up the 3D scene.
        sceneView = findViewById(R.id.sceneView);
        map.addDoneLoadingListener(new Runnable() {
            @Override
            public void run() {
                scene.setBasemap(Basemap.createImagery());
                sceneView.setScene(scene);
                scene.getBaseSurface().getElevationSources().add(new ArcGISTiledElevationSource(ELEVATION_IMAGE_SERVICE));

                // Exercise 4: Add graphics overlays to scene
                sceneView.getGraphicsOverlays().add(bufferAndQuerySceneGraphics);
            }
        });

        // Exercise 2: Get the lock focus button.
        imageButton_lockFocus = findViewById(R.id.imageButton_lockFocus);

        // Exercise 3: Open mobile map package and add its layers to the 3D scene.
        scene.addDoneLoadingListener(new Runnable() {
            @Override
            public void run() {
                final MobileMapPackage mmpk = new MobileMapPackage(MMPK_PATH);
                mmpk.addDoneLoadingListener(new Runnable() {
                    @Override
                    public void run() {
                        List<ArcGISMap> maps = mmpk.getMaps();
                        if (0 < maps.size()) {
                            final ArcGISMap thisMap = maps.get(0);
                            thisMap.addDoneLoadingListener(new Runnable() {
                                @Override
                                public void run() {
                                    ArrayList<Layer> layers = new ArrayList<>();
                                    layers.addAll(thisMap.getOperationalLayers());
                                    thisMap.getOperationalLayers().clear();
                                    scene.getOperationalLayers().addAll(layers);
                                    sceneView.setViewpoint(thisMap.getInitialViewpoint());
                                    Viewpoint viewpoint = sceneView.getCurrentViewpoint(Viewpoint.Type.CENTER_AND_SCALE);
                                    Point targetPoint = (Point) viewpoint.getTargetGeometry();
                                    Camera camera = sceneView.getCurrentViewpointCamera()
                                            .rotateAround(targetPoint, 45.0, 65.0, 0.0);
                                    sceneView.setViewpointCameraAsync(camera);
                                }
                            });
                            thisMap.loadAsync();
                        }
                    }
                });
                mmpk.loadAsync();
            }
        });

        // Exercise 4: Set field values
        imageButton_bufferAndQuery = findViewById(R.id.imageButton_bufferAndQuery);

        // Exercise 4: Add graphics overlays to map
        mapView.getGraphicsOverlays().add(bufferAndQueryMapGraphics);
    }

    /**
     * Exercise 1: Resume the MapView when the Activity resumes.
     */
    @Override
    protected void onResume() {
        if (null != mapView) {
            mapView.resume();
        }
        if (null != sceneView) {
            sceneView.resume();
        }
        super.onResume();
    }

    /**
     * Exercise 1: Pause the MapView when the Activity pauses.
     */
    @Override
    protected void onPause() {
        if (null != mapView) {
            mapView.pause();
        }
        if (null != sceneView) {
            sceneView.pause();
        }
        super.onPause();
    }

    /**
     * Exercise 1: Dispose the MapView when the Activity is destroyed.
     */
    @Override
    protected void onDestroy() {
        if (null != mapView) {
            mapView.dispose();
        }
        if (null != sceneView) {
            sceneView.dispose();
        }
        super.onDestroy();
    }

    /**
     * Exercise 1: Toggle between 2D map and 3D scene.
     */
    public void imageButton_toggle2d3d_onClick(View view) {
        threeD = !threeD;
        setWeight(mapView, threeD ? 1f : 0f);
        setWeight(sceneView, threeD ? 0f : 1f);
        if (null == imageButton_toggle2d3d) {
            imageButton_toggle2d3d = findViewById(R.id.imageButton_toggle2d3d);
        }
        imageButton_toggle2d3d.setImageResource(threeD ? R.drawable.two_d : R.drawable.three_d);
    }

    /**
     * Exercise 1: Set the weight of a View, e.g. to show or hide it.
     */
    private void setWeight(View view, float weight) {
        final ViewGroup.LayoutParams params = view.getLayoutParams();
        if (params instanceof LinearLayout.LayoutParams) {
            ((LinearLayout.LayoutParams) params).weight = weight;
        }
        view.setLayoutParams(params);
    }

    /**
     * Exercise 2: Listener for zoom in button.
     *
     * @param view The button.
     */
    public void imageButton_zoomIn_onClick(View view) {
        zoom(2.0);
    }

    /**
     * Exercise 2: Listener for zoom out button.
     *
     * @param view The button.
     */
    public void imageButton_zoomOut_onClick(View view) {
        zoom(0.5);
    }

    /**
     * Exercise 2: Zoom the 2D map.
     */
    private void zoomMap(double factor) {
        mapView.setViewpointScaleAsync(mapView.getMapScale() / factor);
    }

    /**
     * Exercise 2: Get the SceneView viewpoint target.
     *
     * @return the SceneView viewpoint target.
     */
    private Geometry getSceneTarget() {
        return sceneView.getCurrentViewpoint(Viewpoint.Type.CENTER_AND_SCALE).getTargetGeometry();
    }

    /**
     * Exercise 2: Zoom the 3D scene.
     */
    private void zoomScene(double factor) {
        Geometry target = getSceneTarget();
        if (target instanceof Point) {
            Camera camera = sceneView.getCurrentViewpointCamera()
                    .zoomToward((Point) target, factor);
            sceneView.setViewpointCameraAsync(camera, 0.5f);
        } else {
            // This shouldn't happen, but in case it does...
            Logger.getLogger(MainActivity.class.getName()).log(Level.WARNING,
                    "SceneView.getCurrentViewpoint returned {0} instead of {1}",
                    new String[]{target.getClass().getName(), Point.class.getName()});
        }
    }

    /**
     * Exercise 2: Zoom by a factor.
     *
     * @param factor The zoom factor (0 to 1 to zoom out, > 1 to zoom in).
     */
    private void zoom(double factor) {
        if (threeD) {
            zoomScene(factor);
        } else {
            zoomMap(factor);
        }
    }

    /**
     * Exercise 2: Listener for the lock focus button.
     */
    public void imageButton_lockFocus_onClick(View view) {
        imageButton_lockFocus.setSelected(!imageButton_lockFocus.isSelected());
        if (imageButton_lockFocus.isSelected()) {
            Geometry target = getSceneTarget();
            if (target instanceof Point) {
                final Point targetPoint = (Point) target;
                final Camera currentCamera = sceneView.getCurrentViewpointCamera();
                Point currentCameraPoint = currentCamera.getLocation();
                if (null != currentCameraPoint) {
                    // Calculate distance to current target (Pythagorean theorem)
                    final double xyDistance = GeometryEngine.distanceGeodetic(targetPoint, currentCameraPoint,
                            new LinearUnit(LinearUnitId.METERS),
                            new AngularUnit(AngularUnitId.DEGREES),
                            GeodeticCurveType.GEODESIC
                    ).getDistance();
                    final double zDistance = currentCameraPoint.getZ();
                    final double distanceToTarget = Math.sqrt(Math.pow(xyDistance, 2.0) + Math.pow(zDistance, 2.0));

                    // Create and set camera controller
                    final OrbitLocationCameraController cameraController = new OrbitLocationCameraController(
                            (Point) target, distanceToTarget
                    );
                    cameraController.setCameraHeadingOffset(currentCamera.getHeading());
                    cameraController.setCameraPitchOffset(currentCamera.getPitch());
                    sceneView.setCameraController(cameraController);
                }
            } else {
                // This shouldn't happen, but in case it does...
                Logger.getLogger(MainActivity.class.getName()).log(Level.WARNING,
                        "SceneView.getCurrentViewpoint() returned {0} instead of {1}",
                        new String[]{target.getClass().getName(), Point.class.getName()});
            }
        } else {
            sceneView.setCameraController(new GlobeCameraController());
        }
    }

    /**
     * Exercise 4: Listener for buffer and query button.
     *
     * @param view The button.
     */
    public void imageButton_bufferAndQuery_onClick(View view) {
        imageButton_bufferAndQuery.setSelected(!imageButton_bufferAndQuery.isSelected());
        if (imageButton_bufferAndQuery.isSelected()) {
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView) {
                @Override
                public boolean onSingleTapConfirmed(MotionEvent event) {
                    bufferAndQuery(event);
                    return true;
                }
            });
            sceneView.setOnTouchListener(new DefaultSceneViewOnTouchListener(sceneView) {
                @Override
                public boolean onSingleTapConfirmed(MotionEvent event) {
                    bufferAndQuery(event);
                    return true;
                }
            });
        } else {
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView));
            sceneView.setOnTouchListener(new DefaultSceneViewOnTouchListener(sceneView));
        }
    }

    /**
     * Exercise 4: Buffer the tapped point and select features within that buffer.
     *
     * @param singleTapEvent The single tap event.
     * @return true if the event was consumed and false if it was not.
     */
    private void bufferAndQuery(MotionEvent singleTapEvent) {
        Point geoPoint = getGeoPoint(singleTapEvent);
        geoPoint = (Point) GeometryEngine.project(geoPoint, SpatialReference.create(3857));
        Polygon buffer = GeometryEngine.buffer(geoPoint, 1000.0);
        ListenableList<Graphic> graphics = (threeD ? bufferAndQuerySceneGraphics : bufferAndQueryMapGraphics).getGraphics();
        graphics.clear();
        graphics.add(new Graphic(buffer, BUFFER_SYMBOL));
        graphics.add(new Graphic(geoPoint, CLICK_SYMBOL));
        QueryParameters query = new QueryParameters();
        query.setGeometry(buffer);
        LayerList operationalLayers = threeD ?
                sceneView.getScene().getOperationalLayers() :
                mapView.getMap().getOperationalLayers();
        for (Layer layer : operationalLayers) {
            if (layer instanceof FeatureLayer) {
                ((FeatureLayer) layer).selectFeaturesAsync(query, FeatureLayer.SelectionMode.NEW);
            }
        }
    }

    /**
     * Exercise 4: Convert a single tap event to a geographic Point object.
     */
    private Point getGeoPoint(MotionEvent singleTapEvent) {
        android.graphics.Point screenPoint = new android.graphics.Point(
                Math.round(singleTapEvent.getX()),
                Math.round(singleTapEvent.getY()));
        return threeD ?
                sceneView.screenToBaseSurface(screenPoint) :
                mapView.screenToLocation(screenPoint);
    }

}
