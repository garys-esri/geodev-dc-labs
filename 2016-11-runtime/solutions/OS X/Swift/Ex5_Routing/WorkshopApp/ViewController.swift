/*******************************************************************************
 * Copyright 2016 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/
import Cocoa

import ArcGIS

/**
 Exercise 4: A touch delegate for buffering and querying.
 */
class BufferAndQueryTouchDelegate: NSObject, AGSMapViewTouchDelegate {
    
    // Exercise 4: Declare symbols for click and buffer
    private let CLICK_AND_BUFFER_COLOR = NSColor(red: 1.0, green: 0.647, blue: 0.0, alpha: 1.0)
    private let CLICK_SYMBOL: AGSMarkerSymbol
    private let BUFFER_SYMBOL: AGSFillSymbol
    
    // Exercise 4: Declare the graphics overlay
    private let graphicsOverlay: AGSGraphicsOverlay
    
    // Exercise 4: Store the graphics overlay
    init(mapGraphics: AGSGraphicsOverlay) {
        self.graphicsOverlay = mapGraphics
        
        // Exercise 4: Instantiate symbols for click and buffer
        CLICK_SYMBOL = AGSSimpleMarkerSymbol(
            style: AGSSimpleMarkerSymbolStyle.Circle,
            color: CLICK_AND_BUFFER_COLOR,
            size: 10)
        BUFFER_SYMBOL = AGSSimpleFillSymbol(
            style: AGSSimpleFillSymbolStyle.Null,
            color: NSColor(deviceWhite: 1, alpha: 0),
            outline: AGSSimpleLineSymbol(
                style: AGSSimpleLineSymbolStyle.Solid,
                color: CLICK_AND_BUFFER_COLOR,
                width: 3))
    }
    
    /**
     Exercise 4: Method that runs when buffer and query is active and the user clicks the map.
     */
    func mapView(mapView: AGSMapView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        // Buffer by 1000 meters
        let buffer = AGSGeometryEngine.geodesicBufferGeometry(
            mapPoint, distance: 1000.0, distanceUnit: AGSLinearUnit.meters(), maxDeviation: 1,
            curveType: AGSGeodeticCurveType.Geodesic)
        
        // Show click and buffer as graphics
        graphicsOverlay.graphics.removeAllObjects()
        graphicsOverlay.graphics.addObject(AGSGraphic(geometry: buffer, symbol: BUFFER_SYMBOL))
        graphicsOverlay.graphics.addObject(AGSGraphic(geometry: mapPoint, symbol: CLICK_SYMBOL))
        
        // Run the query
        let query = AGSQueryParameters()
        query.geometry = buffer
        let operationalLayers = mapView.map?.operationalLayers.flatMap { $0 as? AGSFeatureLayer }
        for layer in operationalLayers! {
            layer.selectFeaturesWithQuery(query, mode: AGSSelectionMode.New, completion: nil)
        }
    }
    
}

/**
 * Exercise 5: A touch delegate for routing.
 */
class RoutingTouchDelegate: NSObject, AGSMapViewTouchDelegate {
    
    // Exercise 5: Declare and instantiate symbols for click and buffer
    private let ROUTE_ORIGIN_SYMBOL = AGSSimpleMarkerSymbol(
        style: AGSSimpleMarkerSymbolStyle.Triangle,
        color: NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.753),
        size: 10)
    private let ROUTE_DESTINATION_SYMBOL = AGSSimpleMarkerSymbol(
        style: AGSSimpleMarkerSymbolStyle.Square,
        color: NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.753),
        size: 10)
    private let ROUTE_LINE_SYMBOL = AGSSimpleLineSymbol(
        style: AGSSimpleLineSymbolStyle.Solid,
        color: NSColor(red: 0.333, green: 0.0, blue: 0.333, alpha: 0.753),
        width: 5)
    
    // Exercise 5: Declare routing fields
    private let mapRouteGraphics: AGSGraphicsOverlay
    private let routeTask: AGSRouteTask
    private let routeParameters: AGSRouteParameters
    private var originPoint: AGSPoint? = nil
    
    init(
        mapGraphics: AGSGraphicsOverlay,
        routeTask: AGSRouteTask,
        routeParameters: AGSRouteParameters) {
        self.mapRouteGraphics = mapGraphics
        self.routeTask = routeTask
        self.routeParameters = routeParameters
    }
    
    // Allow a client to reset the routing process
    func reset() {
        originPoint = nil
        mapRouteGraphics.graphics.removeAllObjects()
    }
    
    /**
     Exercise 5: Method that runs when routing is active and the user clicks the map.
     */
    func mapView(mapView: AGSMapView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        let graphics = mapRouteGraphics.graphics
        var point = mapPoint
        if point.hasZ {
            point = AGSPoint(x: point.x, y: point.y, spatialReference: point.spatialReference)
        }
        if (nil == originPoint) {
            originPoint = point
            graphics.removeAllObjects()
            graphics.addObject(AGSGraphic(geometry: point, symbol: ROUTE_ORIGIN_SYMBOL))
        } else {
            graphics.addObject(AGSGraphic(geometry: point, symbol: ROUTE_DESTINATION_SYMBOL))
            routeParameters.clearStops()
            var stops: [AGSStop] = []
            for p in [ originPoint, point ] {
                stops.append(AGSStop(point: p!))
            }
            routeParameters.setStops(stops)
            routeTask.solveRouteWithParameters(routeParameters, completion: { (routeResult, err) in
                if 0 < routeResult?.routes.count {
                    graphics.addObject(AGSGraphic(
                        geometry: routeResult!.routes[0].routeGeometry,
                        symbol: self.ROUTE_LINE_SYMBOL))
                }
                self.originPoint = nil
            })
        }
    }
}

class ViewController: NSViewController {
    
    // Exercise 1: Specify elevation service URL
    let ELEVATION_IMAGE_SERVICE = "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
    
    // Exercise 3: Specify mobile map package path
    private let MMPK_PATH = NSBundle.mainBundle().pathForResource("DC_Crime_Data", ofType:"mmpk")

    // Exercise 1: Outlets from storyboard
    @IBOutlet var parentView: NSView!
    @IBOutlet var mapView: AGSMapView!
    @IBOutlet weak var sceneView: AGSSceneView!
    @IBOutlet weak var button_toggle2d3d: NSButton!
    
    // Exercise 5: Outlets from storyboard
    @IBOutlet weak var button_bufferAndQuery: NSButton!
    @IBOutlet weak var button_routing: NSButton!
    
    // Exercise 1: Declare threeD boolean
    private var threeD = false
    
    // Exercise 4: Declare buffer and query touch delegate
    private let bufferAndQueryTouchDelegate: BufferAndQueryTouchDelegate
    
    // Exercise 4: Declare and instantiate graphics overlay for buffer and query
    private let bufferAndQueryMapGraphics = AGSGraphicsOverlay()
    
    // Exercise 5: Declare routing touch delegate
    private var routingTouchDelegate: RoutingTouchDelegate?
    
    // Exercise 5: Declare and instantiate graphics overlay for routing
    private let routingMapGraphics = AGSGraphicsOverlay()
    
    required init?(coder: NSCoder) {
        // Exercise 4: Instantiate buffer and query touch delegate
        self.bufferAndQueryTouchDelegate = BufferAndQueryTouchDelegate(mapGraphics: bufferAndQueryMapGraphics)
        
        super.init(coder: coder)
        
        // Exercise 5: Instantiate routing objects
        let routeTask = AGSRouteTask(URL: NSURL(string: "http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!)
        /**
         Note: for ArcGIS Online routing, this tutorial uses a username and password
         in the source code for simplicity. For security reasons, you would not
         do it this way in a real app. Instead, you would do one of the following:
         - Use an OAuth 2.0 user login
         - Use an OAuth 2.0 app login (not directly supported in ArcGIS Runtime Quartz as of Beta 1)
         - Challenge the user for credentials
         */
        // Don't share this code without removing plain text username and password!!!
        routeTask.credential = AGSCredential(user: "myUsername", password: "myPassword")
        routeTask.defaultRouteParametersWithCompletion { (routeParameters, err) in
            var routingTouchDelegate: RoutingTouchDelegate? = nil
            if nil == routeParameters {
                self.button_routing.enabled = false
            } else {
                routingTouchDelegate = RoutingTouchDelegate(mapGraphics: self.routingMapGraphics, routeTask: routeTask, routeParameters: routeParameters!)
            }
            self.routingTouchDelegate = routingTouchDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Exercise 1: Set 2D map's basemap
        mapView.map = AGSMap(basemap: AGSBasemap.nationalGeographicBasemap())
        
        // Exercise 1: Set up 3D scene's basemap and elevation
        sceneView.scene = AGSScene(basemapType: AGSBasemapType.Imagery)
        let surface = AGSSurface()
        surface.elevationSources.append(AGSArcGISTiledElevationSource(URL: NSURL(string: ELEVATION_IMAGE_SERVICE)!));
        sceneView.scene!.baseSurface = surface;
        
        /**
         Exercise 3: Open a mobile map package (.mmpk) and
         add its operational layers to the map
         */
        let mmpk = AGSMobileMapPackage(path: MMPK_PATH!)
        mmpk.loadWithCompletion { [weak self] (error: NSError?) in
            if 0 < mmpk.maps.count {
                self!.mapView.map = mmpk.maps[0]
            }
            self!.mapView.map!.basemap = AGSBasemap.nationalGeographicBasemap()
        }
        
        /**
         Exercise 3: Open a mobile map package (.mmpk) and
         add its operational layers to the scene
         */
        let sceneMmpk = AGSMobileMapPackage(path: MMPK_PATH!)
        sceneMmpk.loadWithCompletion { [weak self] (error: NSError?) in
            if 0 < sceneMmpk.maps.count {
                let thisMap = sceneMmpk.maps[0]
                var layers = [AGSLayer]()
                for layer in thisMap.operationalLayers {
                    layers.append(layer as! AGSLayer)
                }
                thisMap.operationalLayers.removeAllObjects()
                self!.sceneView.scene?.operationalLayers.addObjectsFromArray(layers)
                
                // Here is the intended way of getting the layers' viewpoint:
                // self!.sceneView.setViewpoint(thisMap.initialViewpoint!)
                // However, AGSMap.initialViewpoint is not working in ArcGIS Runtime
                // Quartz Beta 1, and the Runtime development team is researching the
                // issue. Therefore, let's hard-code the coordinates for Washington, D.C.
                self!.sceneView.setViewpoint(AGSViewpoint(latitude: 38.909, longitude: -77.016, scale: 150000))
                
                // Rotate the camera
                let viewpoint = self!.sceneView.currentViewpointWithType(AGSViewpointType.CenterAndScale)
                let targetPoint = viewpoint?.targetGeometry as! AGSPoint
                let camera = self!.sceneView.currentViewpointCamera()
                        .rotateAroundTargetPoint(targetPoint, deltaHeading: 45, deltaPitch: 65, deltaRoll: 0)
                self!.sceneView.setViewpointCamera(camera)
            }
            self!.mapView.map!.basemap = AGSBasemap.nationalGeographicBasemap()
        }
        
        // Exercise 4: Add a graphics overlay to the map for the click and buffer
        mapView.graphicsOverlays.addObject(bufferAndQueryMapGraphics)
        
        // Exercise 5: Add a graphics overlay to the map for the routing
        mapView.graphicsOverlays.addObject(routingMapGraphics)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func button_toggle2d3d_onAction(sender: NSButton) {
        // Exercise 1: Toggle the button
        threeD = !threeD
        button_toggle2d3d.image = NSImage(named: threeD ? "two_d" : "three_d")
        
        // Exercise 1: Toggle between the 2D map and the 3D scene
        mapView.hidden = threeD
        sceneView.hidden = !threeD
    }
    
    /**
     Exercise 2: zoom in
     */
    @IBAction func button_zoomIn_onAction(sender: NSButton) {
        zoom(2)
    }
    
    /**
     Exercise 2: zoom out
     */
    @IBAction func button_zoomOut_onAction(sender: NSButton) {
        zoom(0.5)
    }
    
    /**
     Exercise 2: determine whether to call zoomMap or zoomScene
     */
    private func zoom(factor: Double) {
        if (threeD) {
            zoomScene(factor);
        } else {
            zoomMap(factor);
        }
    }
    
    /**
     Exercise 2: Utility method for zooming the 2D map
     
     - parameters:
        - factor: The zoom factor (greater than 1 to zoom in, less than 1 to zoom out)
     */
    private func zoomMap(factor: Double) {
        mapView.setViewpointScale(mapView.mapScale / factor,
                                  completion: nil);
    }
    
    /**
     Exercise 2: Utility method for zooming the 3D scene
     
     - parameters:
        - factor: The zoom factor (greater than 1 to zoom in, less than 1 to zoom out)
     */
    private func zoomScene(factor: Double) {
        let target = sceneView.currentViewpointWithType(AGSViewpointType.CenterAndScale)?.targetGeometry as! AGSPoint
        let camera = sceneView.currentViewpointCamera().zoomTowardTargetPoint(target, factor: factor)
        sceneView.setViewpointCamera(camera, duration: 0.5, completion: nil)
    }
    
    /**
     Exercise 4: Enable a map click for buffer and query
     */
    @IBAction func button_bufferAndQuery_onAction(button_bufferAndQuery: NSButton) {
        mapView.touchDelegate = (NSOnState == button_bufferAndQuery.state) ? bufferAndQueryTouchDelegate : nil
        /**
         NOTE: In Quartz Beta 1, AGSSceneView does not have a touchDelegate property.
         This capability will be there in the Quartz release.
         */
        
        // Exercise 5: Unselect the routing button
        if NSOnState == button_bufferAndQuery.state {
            button_routing.state = NSOffState
        }
    }

    /**
     Exercise 5: Enable a map click for routing
     */
    @IBAction func button_routing_onAction(button_routing: NSButton) {
        mapView.touchDelegate = (NSOnState == button_routing.state) ? routingTouchDelegate : nil
        
        // Exercise 5: Unselect the buffer and query button
        if NSOnState == button_routing.state {
            button_bufferAndQuery.state = NSOffState
        }
        
        if (nil != routingTouchDelegate) {
            routingTouchDelegate!.reset()
        }
    }
    
}
