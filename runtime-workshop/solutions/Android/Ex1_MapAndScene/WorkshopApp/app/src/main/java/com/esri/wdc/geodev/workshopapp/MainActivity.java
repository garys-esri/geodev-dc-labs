package com.esri.wdc.geodev.workshopapp;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;

import com.esri.arcgisruntime.mapping.ArcGISMap;
import com.esri.arcgisruntime.mapping.ArcGISScene;
import com.esri.arcgisruntime.mapping.ArcGISTiledElevationSource;
import com.esri.arcgisruntime.mapping.Basemap;
import com.esri.arcgisruntime.mapping.view.MapView;
import com.esri.arcgisruntime.mapping.view.SceneView;

public class MainActivity extends Activity {

    // Exercise 1: Specify elevation service URL
    private static final String ELEVATION_IMAGE_SERVICE =
            "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer";

    // Exercise 1: Declare and instantiate fields
    private MapView mapView = null;
    private ArcGISMap map = new ArcGISMap();
    private SceneView sceneView = null;
    private ArcGISScene scene = new ArcGISScene();
    private ImageButton imageButton_toggle2d3d = null;
    private boolean threeD = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Exercise 1: Set up the 2D map.
        mapView = findViewById(R.id.mapView);
        map.setBasemap(Basemap.createTopographicVector());
        mapView.setMap(map);

        // Exercise 1: Set up the 3D scene.
        sceneView = findViewById(R.id.sceneView);
        map.addDoneLoadingListener(new Runnable() {
            @Override
            public void run() {
                scene.setBasemap(Basemap.createImagery());
                sceneView.setScene(scene);
                scene.getBaseSurface().getElevationSources().add(new ArcGISTiledElevationSource(ELEVATION_IMAGE_SERVICE));
            }
        });
    }

    /**
     * Exercise 1: Resume the MapView and SceneView when the Activity resumes.
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
     * Exercise 1: Pause the MapView and SceneView when the Activity pauses.
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
     * Exercise 1: Dispose the MapView and SceneView when the Activity is destroyed.
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
}
