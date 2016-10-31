package com.esri.wdc.geodev201611;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;

import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.view.MapView;

public class MainActivity extends Activity {

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
}
