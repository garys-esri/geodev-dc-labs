package com.esri.wdc.geodev201611;

import android.app.Activity;
import android.graphics.ColorFilter;
import android.graphics.PorterDuff;
import android.os.Bundle;
import android.os.Environment;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageButton;
import android.widget.Toast;

import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.mobilemappackage.MobileMapPackage;
import com.esri.arcgisruntime.mapping.view.DefaultMapViewOnTouchListener;
import com.esri.arcgisruntime.mapping.view.MapView;

import java.util.List;

public class MainActivity extends Activity {

    // Exercise 3: Instantiate mobile map package (MMPK) path
    private static final String MMPK_PATH = Environment.getExternalStorageDirectory().getPath() + "/data/DC_Crime_Data.mmpk";

    // Exercise 1: Declare and instantiate fields
    private MapView mapView = null;
    private ArcGISMap map = new ArcGISMap();

    // Exercise 4: Declare fields
    private ImageButton imageButton_bufferAndQuery = null;
    private ColorFilter colorFilter_imageButton_bufferAndQuery = null;
    private boolean bufferSelected = false;

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
        colorFilter_imageButton_bufferAndQuery = imageButton_bufferAndQuery.getColorFilter();
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
        bufferSelected = !bufferSelected;
        imageButton_bufferAndQuery.setSelected(bufferSelected);
        if (bufferSelected) {
            imageButton_bufferAndQuery.setColorFilter(0xFF888888, PorterDuff.Mode.DARKEN);
        } else {
            imageButton_bufferAndQuery.setColorFilter(colorFilter_imageButton_bufferAndQuery);
        }
//        imageButton_bufferAndQuery.setBackgroundColor(bufferSelected ? 0xFF888888 : 0x00000000);
//        imageButton_bufferAndQuery.setImageDrawable(getResources().getDrawable(
//                bufferSelected ? R.drawable.location_selected : R.drawable.location));

//        mapView.setOnClickListener(bufferSelected ? this::bufferAndQuery : null);
        if (bufferSelected) {
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView) {
                @Override
                public boolean onSingleTapConfirmed(MotionEvent event) {
                    bufferAndQuery(mapView, event);
                    return true;
                }
            });
        } else {
            mapView.setOnTouchListener(new DefaultMapViewOnTouchListener(this, mapView));
        }
    }

    /**
     * Exercise 4: Buffer the tapped point and select features within that buffer.
     * @param mapView The View (MapView) that was tapped.
     * @param touchEvent The touch event.
     * @return true if the event was consumed and false if it was not.
     */
    private void bufferAndQuery(MapView mapView, MotionEvent touchEvent) {
        Toast.makeText(this, "View is of type " + mapView.getClass().getName(), Toast.LENGTH_LONG).show();
    }

}
