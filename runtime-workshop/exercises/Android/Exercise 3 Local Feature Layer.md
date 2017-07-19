# Exercise 3: Add a Local Feature Layer (Android)

This exercise walks you through adding a layer from a mobile map package to the map.

Prerequisites:
- Complete [Exercise 2](Exercise 2 Zoom Buttons.md), or get the Exercise 2 code solution compiling and running properly, preferably in an IDE.

If you need some help, you can refer to [the solution to this exercise](../../solutions/Android/Ex3_LocFeatLyr), available in this repository.

ArcGIS Runtime provides a variety of ways to add **operational layers** to the map--feature services, dynamic map services, offline geodatabases, and mobile map packages, for example. In this exercise, you will use the newest of these: a mobile map package.

1. Download the [D.C. Crime Data mobile map package (`DC_Crime_Data.mmpk`)](../../data/DC_Crime_Data.mmpk) that we have prepared for you. Transfer it to your Android device. Remember where it is; you might even want to use a file browser on your device to get the absolute path of the MMPK.

1. In `manifests/AndroidManifest.xml`, inside the `<manifest>` element but outside the `<application>` element, request READ_EXTERNAL_STORAGE permission:

    ```
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    ```
    
    _Note: in Android 6 and higher, in addition to the `uses-permission` element, a production app should include Java code to [request permissions at runtime](https://developer.android.com/training/permissions/requesting.html). Since this workshop is not about Android permissions, go to **Settings > _Apps > <your app> > Permissions** on your Android device and grant the **Storage** permission manually._

1. In your class, instantiate a constant called `MMPK_PATH` with the absolute path of the mobile map package you downloaded. In a real app, you might include this file as a resource in your app, but for this exercise, be lazy and just use the copy you put on the device in a previous step. In many cases, you may be able to use `Environment.getExternalStorageDirectory().getPath()` to get the first part of the path. For example, if you put `DC_Crime_Data.mmpk` in a directory called `data` in your device's normal storage directory, you can instantiate the path like this:

    ```
    private static final String MMPK_PATH =
            Environment.getExternalStorageDirectory().getPath() + "/data/DC_Crime_Data.mmpk";
    ```
    
1. At the end of your constructor, instantiate a `MobileMapPackage` with the mobile map package constant, and add an event handler to run when the mobile map package is done loading. Then load the mobile map package asynchronously:

    ```
    final MobileMapPackage mmpk = new MobileMapPackage(MMPK_PATH);
    mmpk.addDoneLoadingListener(new Runnable() {
        @Override
        public void run() {

        }
    });
    mmpk.loadAsync();
    ```
    
1. Inside the `addDoneLoadingListener` event handler method, get the `MobileMapPackage`'s maps. A mobile map package can contain multiple maps. `DC_Crime_Data.mmpk` only has one map, but it's a good idea to make sure there's at least one. If so, get the first map (index 0), and use it to set the `MapView`'s map. The map in this mobile map package has no basemap, so it's a good idea to set the basemap again. Here's the code that goes inside the event handler method:

    ```
    List<ArcGISMap> maps = mmpk.getMaps();
    if (0 < maps.size()) {
        map = maps.get(0);
        mapView.setMap(map);
    }
    map.setBasemap(Basemap.createNationalGeographic());
    ```
    
1. Run your app. Verify that the map zooms to Washington, D.C., and that a layer of crime incidents appears on top of the basemap. The incidents appear as red triangles, which is the symbology specified in the mobile map package:

    ![Mobile map package layer](05-mmpk-layer.png)
    
## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to add a local feature layer from a mobile map package to a map.

Ready for more? Choose from the following:

- [**Exercise 4: Buffer a Point and Query Features**](Exercise 4 Buffer and Query.md)
- **Bonus**: we used a mobile map package, but you can also add **feature services** to your map. Go to [ArcGIS Online](http://www.arcgis.com/home/index.html), find a feature service URL (hint: a feature service URL has the term `FeatureServer` at or near the end of the URL), and use the [`FeatureLayer`](https://developers.arcgis.com/android/beta/api-reference/reference/com/esri/arcgisruntime/layers/FeatureLayer.html) and [`ServiceFeatureTable`](https://developers.arcgis.com/android/beta/api-reference/reference/com/esri/arcgisruntime/datasource/arcgis/ServiceFeatureTable.html) classes to add the feature service to your map. You can refer to a [code sample](https://developers.arcgis.com/android/beta/sample-code/feature-layer-feature-service.htm) if you need it. Also, the [`ServiceFeatureTable`](https://developers.arcgis.com/android/beta/api-reference/reference/com/esri/arcgisruntime/datasource/arcgis/ServiceFeatureTable.html) documentation has a feature service URL in the Class Overview section that you can use instead of finding one in ArcGIS Online if desired. We could give that URL to you here, but that wouldn't force you to go look at the documentation, would it? :-)