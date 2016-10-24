package com.esri.wdc.geodev201611;

import android.app.Activity;
import android.os.Bundle;
import android.os.Environment;
import android.view.View;

import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.mobilemappackage.MobileMapPackage;
import com.esri.arcgisruntime.mapping.view.MapView;

import java.util.List;

public class MainActivity extends Activity {

    // Exercise 3: Instantiate mobile map package (MMPK) path
    private static final String MMPK_PATH = Environment.getExternalStorageDirectory().getPath() + "/data/DC_Crime_Data.mmpk";

    // Exercise 1: Declare and instantiate fields
    private MapView mapView = null;
    private ArcGISMap map = new ArcGISMap();

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
        mmpk.addDoneLoadingListener(() -> {
            List<ArcGISMap> maps = mmpk.getMaps();
            if (0 < maps.size()) {
                map = maps.get(0);
                mapView.setMap(map);
            }
            map.setBasemap(Basemap.createNationalGeographic());
        });
        mmpk.loadAsync();
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

}
