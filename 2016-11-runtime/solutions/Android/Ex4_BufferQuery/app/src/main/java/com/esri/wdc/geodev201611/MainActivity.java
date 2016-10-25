package com.esri.wdc.geodev201611;

import android.app.Activity;
import android.os.Bundle;
import android.os.Environment;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageButton;

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
import com.esri.arcgisruntime.symbology.SimpleFillSymbol;
import com.esri.arcgisruntime.symbology.SimpleLineSymbol;
import com.esri.arcgisruntime.symbology.SimpleMarkerSymbol;
import com.esri.arcgisruntime.util.ListenableList;

import java.util.List;

public class MainActivity extends Activity {

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

    // Exercise 4: Declare fields
    private ImageButton imageButton_bufferAndQuery = null;
    private final GraphicsOverlay bufferAndQueryGraphics = new GraphicsOverlay();

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
        Point geoPoint = mapView.screenToLocation(screenPoint);
        return geoPoint;
    }

}
