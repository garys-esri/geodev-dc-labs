# Exercise 4: Buffer a Point and Query Features (iOS/Swift)

This exercise walks you through the following:
- Get the user to click a point
- Display the clicked point and a buffer around it
- Query for features within the buffer

Prerequisites:
- Complete [Exercise 3](Exercise%203%20Operational%20Layers.md), or get the Exercise 3 code solution compiling and running properly in Xcode.

If you need some help, you can refer to [the solution to this exercise](../../../solutions/iOS/Swift/Ex4_BufferAndQuery), available in this repository.

## Get the user to click a point

You can use ArcGIS Runtime to detect when and where the user interacts with the map, either with the mouse or with a touchscreen. In this exercise, you just need the user to click or tap a point. You could detect every user click, but instead, we will let the user activate and deactivate this capability with a toggle button.

1. In `Main.storyboard`, add a **Button** to the left of the 2D/3D toggle button. Use the `location` image for this button and `gray_background` for the button's background. To make it appear as a toggle button, change **State Config** to **Selected** and use `location_selected` as the image and `gray_background` as the background. Make the size 50x50.

1. Open `ViewController.swift` in the Assistant Editor. Right-click and drag the button to create an **Action** connection in `ViewController`, then close the Assistant Editor:

    ```
    @IBAction func button_bufferAndQuery_onAction(_ sender: UIButton) {
    }
    ```

1. In `button_bufferAndQuery_onAction(UIButton)`, toggle the selected state of the button:

    ```
    sender.isSelected = !sender.isSelected
    ```

1. ArcGIS Runtime for iOS uses **touch delegates** to capture user actions on the map. In `ViewController.swift`, after the `import` statements but before the `ViewController` class declaration, declare a new touch delegate class. In this exercise, we call this class `BufferAndQueryTouchDelegate`. In a production app, you might put this class in its own Swift file. For this exercise, it’s fine to put this class in `ViewController.swift`. Here is the class declaration to add:

    ```
    class BufferAndQueryTouchDelegate: NSObject, AGSGeoViewTouchDelegate {
    }
    ```

1. In your new delegate class, add a `geoView` method to get a user’s tap on the screen. You will write most of the code for this method later, but for now, just do a `print`:

    ```
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        print("Clicked on map or scene!")
    }
    ```

1. This delegate class will use an `AGSGraphicsOverlay` to display the point that the user clicks and the buffer around it. In `BufferAndQueryTouchDelegate`, declare a field to store a graphics overlay:

    ```
    fileprivate let graphicsOverlay: AGSGraphicsOverlay
    ```

1. In your delegate class, implement an initializer that accepts an `AGSGraphicsOverlay` as a parameter:

    ```
    init(graphics: AGSGraphicsOverlay) {
        self.graphicsOverlay = graphics
    }
    ```

1. In `ViewController`, declare two fields of the type of your new delegate class, one for the map and one for the scene:

    ```
    fileprivate let bufferAndQueryTouchDelegateMap: BufferAndQueryTouchDelegate
    fileprivate let bufferAndQueryTouchDelegateScene: BufferAndQueryTouchDelegate
    ```

1. In `ViewController`, declare and instantiate two fields of type `AGSGraphicOverlay`, one for the map and one for the scene. These are the graphics overlays you will use to display the point that the user clicks and the buffer around it. Later, you will add these overlays to the map and scene. For now, just declare and instantiate them:

    ```
    fileprivate let bufferAndQueryMapGraphics = AGSGraphicsOverlay()
    fileprivate let bufferAndQuerySceneGraphics = AGSGraphicsOverlay()
    ```

1. Implement an initializer for your `ViewController` class. In this initializer, instantiate the delegates you declared above, and don’t forget to call `super.init`:

    ```
    required init?(coder: NSCoder) {
        self.bufferAndQueryTouchDelegateMap = BufferAndQueryTouchDelegate(graphics: bufferAndQueryMapGraphics)
        self.bufferAndQueryTouchDelegateScene = BufferAndQueryTouchDelegate(graphics: bufferAndQuerySceneGraphics)
        super.init(coder: coder)
    }
    ```
    
1. Go back to your action method for the buffer and query toggle button (we called it `button_bufferAndQuery_onAction`). This method runs when the user toggles the button on or off. If the button is toggled on, we need to tell the mapView and sceneView to use our touch delegates. If the button is toggled off, we need to tell the map view and scene view to do nothing in particular when the user clicks the map or scene by setting its touch delegate to `nil`:

    ```
    mapView.touchDelegate = sender.isSelected ? bufferAndQueryTouchDelegateMap : nil
    sceneView.touchDelegate = sender.isSelected ? bufferAndQueryTouchDelegateScene : nil
    ```
    
1. In Xcode, open the Debug area, and then run your app. Verify that a new toggle button appears and that your `print` prints text when and only when the toggle button is toggled on and you click the map:

    ![Buffer and query toggle button](08-buffer-query-toggle-button.png)
    
## Display the clicked point and a buffer around it

You need to buffer the clicked point and display both the point and the buffer as graphics on the map.

1. In `BufferAndQueryTouchDelegate`, declare and instantiate a constant `UIColor` for drawing the click and buffer. Here we use an opaque yellow/orange color. Also declare an `AGSMarkerSymbol` and an `AGSFillSymbol`:

    ```
    fileprivate let CLICK_AND_BUFFER_COLOR = UIColor(red: 1.0, green: 0.647, blue: 0.0, alpha: 1.0)
    fileprivate let CLICK_SYMBOL: AGSMarkerSymbol
    fileprivate let BUFFER_SYMBOL: AGSFillSymbol
    ```

1. In the `BufferAndQueryTouchDelegate` initializer (i.e. the `init` method), instantiate the symbols you just declared, using the color you just instantiated:

    ```
    CLICK_SYMBOL = AGSSimpleMarkerSymbol(
        style: AGSSimpleMarkerSymbolStyle.circle,
        color: CLICK_AND_BUFFER_COLOR,
        size: 10)
    BUFFER_SYMBOL = AGSSimpleFillSymbol(
        style: AGSSimpleFillSymbolStyle.null,
        color: UIColor(white: 1, alpha: 0),
        outline: AGSSimpleLineSymbol(
            style: AGSSimpleLineSymbolStyle.solid,
            color: CLICK_AND_BUFFER_COLOR,
            width: 3))
    ```

1. In `ViewController.viewDidLoad`, add the graphics overlays to the map view and the scene view`:

    ```
    mapView.graphicsOverlays.add(bufferAndQueryMapGraphics)
    sceneView.graphicsOverlays.add(bufferAndQuerySceneGraphics)
    ```
    
1. In `BufferAndQueryTouchDelegate.geoView`, you need to replace your `print` with code to create a buffer and display the point and buffer as graphics. First, create a 1000-meter buffer using `AGSGeometryEngine`:

    ```
    let buffer = AGSGeometryEngine.geodeticBufferGeometry(
            mapPoint,
            distance: 1000.0,
            distanceUnit: AGSLinearUnit.meters(),
            maxDeviation: 1,
            curveType: AGSGeodeticCurveType.geodesic)
    ```

1. After creating the buffer, add the point and buffer as graphics. Clear the graphics first and then add the point and buffer as new `AGSGraphic` objects:

    ```
    graphicsOverlay.graphics.removeAllObjects()
    graphicsOverlay.graphics.add(AGSGraphic(geometry: buffer, symbol: BUFFER_SYMBOL))
    graphicsOverlay.graphics.add(AGSGraphic(geometry: mapPoint, symbol: CLICK_SYMBOL))
    ```

1. Run your app. Verify that if you toggle the buffer and select button and then click the map, the point you clicked and a 1000-meter buffer around it appear on the map:

    ![Click and buffer graphics](09-click-and-buffer-graphics.png)
    
    ![Click and buffer graphics](10-click-and-buffer-graphics-scene.jpg)
    
## Query for features within the buffer

There are a few different ways to query and/or select features in ArcGIS Runtime. Here we will use `AGSFeatureLayer.selectFeaturesWithQuery`, which both highlights selected features on the map and provides a list of the selected features.

1. In `BufferAndQueryTouchDelegate.geoView`, after creating the buffer and adding graphics, instantiate an `AGSQueryParameters` object with the buffer geometry:

    ```
    let query = AGSQueryParameters()
    query.geometry = buffer
    ```
    
1. For each of the `AGSFeatureLayer` objects in the operational layers of the map, call `AGSFeatureLayer.selectFeaturesWithQuery`. Use `AGSSelectionMode.New` to do a new selection, as opposed to adding to or removing from the current selection. You must cast `geoView` depending on whether it is a `AGSMapView` or a `AGSSceneView`. Add this code after instantiating the query object and setting its geometry:

    ```
    let operationalLayers : [AGSFeatureLayer]
    if geoView is AGSMapView {
        let mapView = geoView as? AGSMapView
        operationalLayers = mapView!.map!.operationalLayers.flatMap { $0 as? AGSFeatureLayer }
    } else {
        let sceneView = geoView as? AGSSceneView
        operationalLayers = sceneView!.scene!.operationalLayers.flatMap { $0 as? AGSFeatureLayer }
    }
    for layer in operationalLayers {
        layer.selectFeatures(withQuery: query, mode: AGSSelectionMode.new, completion: nil)
    }
    ```
    
1. Run your app. Verify on the map that features within the clicked buffer are highlighted on the map:

    ![Selected features](11-selected-features.png)
    
    ![Selected features](11a-selected-features-scene.jpg)
    
## How did it go?

If you have trouble, **refer to the solution code**, which is linked near the beginning of this exercise. You can also **submit an issue** in this repo to ask a question or report a problem. If you are participating live with Esri presenters, feel free to **ask a question** of the presenters.

If you completed the exercise, congratulations! You learned how to get a user's input on the map, buffer a point, display graphics on the map, and select features based on a query.

Ready for more? Choose from the following:

- [**Exercise 5: Routing**](Exercise%205%20Routing.md)
- **Bonus**
    - We selected features but didn't do anything with the selected features' attributes. The call to [`selectFeaturesWithQuery`](https://developers.arcgis.com/ios/latest/api-reference/interface_a_g_s_feature_layer.html#ae655af6edce13c49c841f0556dc6d561) allows you to specify a completion, where you can iterate through selected features. See if you can look at the feature attributes to get more information about the selected features.
    - Try setting properties on the `AGSQueryParameters` object to change the query's behavior. For example, maybe you want to select all features that are _outside_ the buffer instead of those that are inside. How would you do that by adding just one line of code? What other interesting things can you do with `AGSQueryParameters`?
