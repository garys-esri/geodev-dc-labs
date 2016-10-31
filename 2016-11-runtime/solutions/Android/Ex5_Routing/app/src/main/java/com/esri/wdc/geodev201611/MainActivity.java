package com.esri.wdc.geodev201611;

import android.app.Activity;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageButton;

import com.esri.arcgisruntime.concurrent.ListenableFuture;
import com.esri.arcgisruntime.datasource.QueryParameters;
import com.esri.arcgisruntime.geometry.GeometryEngine;
import com.esri.arcgisruntime.geometry.Point;
import com.esri.arcgisruntime.geometry.Polygon;
import com.esri.arcgisruntime.geometry.SpatialReference;
import com.esri.arcgisruntime.layers.FeatureLayer;
import com.esri.arcgisruntime.layers.Layer;
import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.LayerList;
import com.esri.arcgisruntime.mapping.mobilemappackage.MobileMapPackage;
import com.esri.arcgisruntime.mapping.view.DefaultMapViewOnTouchListener;
import com.esri.arcgisruntime.mapping.view.Graphic;
import com.esri.arcgisruntime.mapping.view.GraphicsOverlay;
import com.esri.arcgisruntime.mapping.view.MapView;
import com.esri.arcgisruntime.security.UserCredential;
import com.esri.arcgisruntime.symbology.SimpleFillSymbol;
import com.esri.arcgisruntime.symbology.SimpleLineSymbol;
import com.esri.arcgisruntime.symbology.SimpleMarkerSymbol;
import com.esri.arcgisruntime.tasks.route.RouteParameters;
import com.esri.arcgisruntime.tasks.route.RouteResult;
import com.esri.arcgisruntime.tasks.route.RouteTask;
import com.esri.arcgisruntime.tasks.route.Stop;
import com.esri.arcgisruntime.util.ListenableList;

import java.util.List;
import java.util.concurrent.ExecutionException;

public class MainActivity extends Activity {

    // Exercise 3: Instantiate mobile map package (MMPK) path
    private static final String MMPK_PATH = Environment.getExternalStorageDirectory().getPath() + "/data/DC_Crime_Data.mmpk";

    // Exercise 4: Instantiate symbols
    private static final SimpleMarkerSymbol CLICK_SYMBOL =
            new SimpleMarkerSymbol(SimpleMarkerSymbol.Style.CIRCLE, 0xFFffa500, 10);
    private static final SimpleFillSymbol BUFFER_SYMBOL =
            new SimpleFillSymbol(SimpleFillSymbol.Style.NULL, 0xFFFFFFFF,
                    new SimpleLineSymbol(SimpleLineSymbol.Style.SOLID, 0xFFFFA500, 3));

    // Exercise 5: Instantiate symbols
    private static final SimpleMarkerSymbol ROUTE_ORIGIN_SYMBOL =
            new SimpleMarkerSymbol(SimpleMarkerSymbol.Style.TRIANGLE, 0xC000FF00, 10);
    private static final SimpleMarkerSymbol ROUTE_DESTINATION_SYMBOL =
            new SimpleMarkerSymbol(SimpleMarkerSymbol.Style.SQUARE, 0xC0FF0000, 10);
    private static final SimpleLineSymbol ROUTE_LINE_SYMBOL =
            new SimpleLineSymbol(SimpleLineSymbol.Style.SOLID, 0xC0550055, 5);

    // Exercise 5: Instantiate logging tag
    private static final String TAG = MainActivity.class.getSimpleName();

    // Exercise 1: Declare and instantiate fields
    private MapView mapView = null;
    private ArcGISMap map = new ArcGISMap();

    // Exercise 4: Declare fields
    private ImageButton imageButton_bufferAndQuery = null;
    private final GraphicsOverlay bufferAndQueryGraphics = new GraphicsOverlay();

    // Exercise 5: Declare and instantiate fields
    private ImageButton imageButton_routing = null;
    private final GraphicsOverlay routeGraphics = new GraphicsOverlay();
    private Point originPoint = null;
    private RouteTask routeTask = null;
    private RouteParameters routeParameters = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Exercise 1: Set up the map
        mapView = (MapView) findViewById(R.id.mapView);
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
                }
                map.setBasemap(Basemap.createNationalGeographic());
            }
        });
        mmpk.loadAsync();

        // Exercise 4: Set field values
        imageButton_bufferAndQuery = (ImageButton) findViewById(R.id.imageButton_bufferAndQuery);

        // Exercise 4: Add graphics overlay to map
        mapView.getGraphicsOverlays().add(bufferAndQueryGraphics);

        // Exercise 5: Set field values
        imageButton_routing = (ImageButton) findViewById(R.id.imageButton_routing);

        // Exercise 5: Add route graphics overlay to map
        mapView.getGraphicsOverlays().add(routeGraphics);

        // Exercise 5: Create routing objects
        routeTask = new RouteTask("http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World");
        /**
         * Note: for ArcGIS Online routing, this tutorial uses a username and password
         * in the source code for simplicity. For security reasons, you would not
         * do it this way in a real app. Instead, you would do one of the following:
         * - Use an OAuth 2.0 user login
         * - Use an OAuth 2.0 app login (not directly supported in ArcGIS Runtime Quartz as of Beta 2)
         * - Challenge the user for credentials
         */
        // Don't share this code without removing plain text username and password!!!
        routeTask.setCredential(new UserCredential("theUsername", "thePassword"));
        try {
            routeParameters = routeTask.generateDefaultParametersAsync().get();
        } catch (InterruptedException | ExecutionException e) {
            routeTask = null;
            Log.e(TAG, "Could not get route parameters", e);
        }
        if (null != routeParameters) {
            routeParameters.setReturnDirections(false);
            routeParameters.setReturnRoutes(true);
            routeParameters.setReturnStops(false);
        } else {
            imageButton_routing.setEnabled(false);
        }
    }

    /**
     * Exercise 1: Resume the MapView when the Activity resumes.
     */
    @Override
    protected void onResume() {
        mapView.resume();
        super.onResume();
    }

    /**
     * Exercise 1: Pause the MapView when the Activity pauses.
     */
    @Override
    protected void onPause() {
        mapView.pause();
        super.onPause();
    }

    /**
     * Exercise 1: Dispose the MapView when the Activity is destroyed.
     */
    @Override
    protected void onDestroy() {
        mapView.dispose();
        super.onDestroy();
    }

    /**
     * Exercise 2: Listener for zoom out button.
     * @param view The button.
     */
    public void imageButton_zoomOut_onClick(View view) {
        zoom(0.5);
    }

    /**
     * Exercise 2: Listener for zoom in button.
     * @param view The button.
     */
    public void imageButton_zoomIn_onClick(View view) {
        zoom(2.0);
    }

    /**
     * Exercise 2: Zoom by a factor.
     * @param factor The zoom factor (0 to 1 to zoom out, > 1 to zoom in).
     */
    private void zoom(double factor) {
        mapView.setViewpointScaleAsync(mapView.getMapScale() / factor);
    }

    /**
     * Exercise 4: Listener for buffer and query button.
     * @param view The button.
     */
    public void imageButton_bufferAndQuery_onClick(View view) {
        imageButton_bufferAndQuery.setSelected(!imageButton_bufferAndQuery.isSelected());
        if (imageButton_bufferAndQuery.isSelected()) {
            imageButton_routing.setSelected(false);
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView) {
                @Override
                public boolean onSingleTapConfirmed(MotionEvent event) {
                    bufferAndQuery(event);
                    return true;
                }
            });
        } else {
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView));
        }
    }

    /**
     * Exercise 4: Buffer the tapped point and select features within that buffer.
     * @param singleTapEvent The single tap event.
     * @return true if the event was consumed and false if it was not.
     */
    private void bufferAndQuery(MotionEvent singleTapEvent) {
        Point geoPoint = getGeoPoint(singleTapEvent);
        geoPoint = (Point) GeometryEngine.project(geoPoint, SpatialReference.create(3857));
        Polygon buffer = GeometryEngine.buffer(geoPoint, 1000.0);
        ListenableList<Graphic> graphics = bufferAndQueryGraphics.getGraphics();
        graphics.clear();
        graphics.add(new Graphic(buffer, BUFFER_SYMBOL));
        graphics.add(new Graphic(geoPoint, CLICK_SYMBOL));

        QueryParameters query = new QueryParameters();
        query.setGeometry(buffer);
        LayerList operationalLayers = mapView.getMap().getOperationalLayers();
        for (Layer layer : operationalLayers) {
            if (layer instanceof FeatureLayer) {
                ((FeatureLayer) layer).selectFeaturesAsync(query, FeatureLayer.SelectionMode.NEW);
            }
        };
    }

    /**
     * Exercise 4: Convert a single tap event to a geographic Point object.
     */
    private Point getGeoPoint(MotionEvent singleTapEvent) {
        android.graphics.Point screenPoint = new android.graphics.Point(
                Math.round(singleTapEvent.getX()),
                Math.round(singleTapEvent.getY()));
        return mapView.screenToLocation(screenPoint);
    }

    /**
     * Exercise 5: Listener for routing button.
     * @param view The button.
     */
    public void imageButton_routing_onClick(View view) {
        imageButton_routing.setSelected(!imageButton_routing.isSelected());
        if (imageButton_routing.isSelected()) {
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView) {
                @Override
                public boolean onSingleTapConfirmed(MotionEvent event) {
                    addStopToRoute(event);
                    return true;
                }
            });
            imageButton_bufferAndQuery.setSelected(false);
        } else {
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView));
        }
    }

    /**
     * Exercise 5: Add a stop to the route, and calculate the route if we have enough stops.
     * @param singleTapEvent The single tap event with the stop's geometry.
     */
    private void addStopToRoute(MotionEvent singleTapEvent) {
        final ListenableList<Graphic> graphics = routeGraphics.getGraphics();
        Point point = getGeoPoint(singleTapEvent);
        if (point.hasZ()) {
            point = new Point(point.getX(), point.getY(), point.getSpatialReference());
        }
        if (null == originPoint) {
            originPoint = point;
            graphics.clear();
            graphics.add(new Graphic(originPoint, ROUTE_ORIGIN_SYMBOL));
        } else {
            graphics.add(new Graphic(point, ROUTE_DESTINATION_SYMBOL));
            routeParameters.getStops().clear();
            for (Point p : new Point[]{ originPoint, point }) {
                routeParameters.getStops().add(new Stop(p));
            }
            final ListenableFuture<RouteResult> solveFuture = routeTask.solveAsync(routeParameters);
            solveFuture.addDoneListener(new Runnable() {
                @Override
                public void run() {
                    RouteResult routeResult = null;
                    try {
                        routeResult = solveFuture.get();
                        if (0 < routeResult.getRoutes().size()) {
                            graphics.add(new Graphic(routeResult.getRoutes().get(0).getRouteGeometry(), ROUTE_LINE_SYMBOL));
                        }
                    } catch (InterruptedException | ExecutionException e) {
                        Log.e(TAG, "Could not get solved route", e);
                    }
                }
            });
            originPoint = null;
        }
    }

}
