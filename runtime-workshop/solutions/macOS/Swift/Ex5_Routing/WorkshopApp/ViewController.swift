/*******************************************************************************
 * Copyright 2016-2017 Esri
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
class BufferAndQueryTouchDelegate: NSObject, AGSGeoViewTouchDelegate {
    
    // Exercise 4: Declare symbols for click and buffer
    fileprivate let CLICK_AND_BUFFER_COLOR = NSColor(red: 1.0, green: 0.647, blue: 0.0, alpha: 1.0)
    fileprivate let CLICK_SYMBOL: AGSMarkerSymbol
    fileprivate let BUFFER_SYMBOL: AGSFillSymbol
    
    // Exercise 4: Declare the graphics overlay
    fileprivate let graphicsOverlay: AGSGraphicsOverlay
    
    // Exercise 4: Store the graphics overlay
    init(graphics: AGSGraphicsOverlay) {
        self.graphicsOverlay = graphics
        
        // Exercise 4: Instantiate symbols for click and buffer
        CLICK_SYMBOL = AGSSimpleMarkerSymbol(
            style: AGSSimpleMarkerSymbolStyle.circle,
            color: CLICK_AND_BUFFER_COLOR,
            size: 10)
        BUFFER_SYMBOL = AGSSimpleFillSymbol(
            style: AGSSimpleFillSymbolStyle.null,
            color: NSColor(deviceWhite: 1, alpha: 0),
            outline: AGSSimpleLineSymbol(
                style: AGSSimpleLineSymbolStyle.solid,
                color: CLICK_AND_BUFFER_COLOR,
                width: 3))
    }
    
    /**
     Exercise 4: Method that runs when buffer and query is active and the user clicks the map.
     */
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        // Buffer by 1000 meters
        let buffer = AGSGeometryEngine.geodeticBufferGeometry(
            mapPoint, distance: 1000.0, distanceUnit: AGSLinearUnit.meters(), maxDeviation: 1,
            curveType: AGSGeodeticCurveType.geodesic)
        
        // Show click and buffer as graphics
        graphicsOverlay.graphics.removeAllObjects()
        graphicsOverlay.graphics.add(AGSGraphic(geometry: buffer, symbol: BUFFER_SYMBOL))
        graphicsOverlay.graphics.add(AGSGraphic(geometry: mapPoint, symbol: CLICK_SYMBOL))
        
        // Run the query
        let query = AGSQueryParameters()
        query.geometry = buffer
        let operationalLayers : [AGSFeatureLayer]
        let mapView = geoView as? AGSMapView
        operationalLayers = mapView!.map!.operationalLayers.flatMap { $0 as? AGSFeatureLayer }
        for layer in operationalLayers {
            layer.selectFeatures(withQuery: query, mode: AGSSelectionMode.new, completion: nil)
        }
    }
    
}

/**
 * Exercise 5: A touch delegate for routing.
 */
class RoutingTouchDelegate: NSObject, AGSGeoViewTouchDelegate {
    
    // Exercise 5: Declare and instantiate symbols for click and buffer
    private let ROUTE_ORIGIN_SYMBOL = AGSSimpleMarkerSymbol(
        style: AGSSimpleMarkerSymbolStyle.triangle,
        color: NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
        size: 10)
    private let ROUTE_DESTINATION_SYMBOL = AGSSimpleMarkerSymbol(
        style: AGSSimpleMarkerSymbolStyle.square,
        color: NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
        size: 10)
    private let ROUTE_LINE_SYMBOL = AGSSimpleLineSymbol(
        style: AGSSimpleLineSymbolStyle.solid,
        color: NSColor(red: 0.333, green: 0.0, blue: 0.333, alpha: 1.0),
        width: 5)
    
    // Exercise 5: Declare routing fields
    private let routeGraphics: AGSGraphicsOverlay
    private let routeTask: AGSRouteTask
    private let routeParameters: AGSRouteParameters
    private var originPoint: AGSPoint? = nil
    
    init(
        graphics: AGSGraphicsOverlay,
        routeTask: AGSRouteTask,
        routeParameters: AGSRouteParameters) {
        self.routeGraphics = graphics
        self.routeTask = routeTask
        self.routeParameters = routeParameters
    }
    
    // Allow a client to reset the routing process
    func reset() {
        originPoint = nil
        routeGraphics.graphics.removeAllObjects()
    }
    
    /**
     Exercise 5: Method that runs when routing is active and the user clicks the map or scene.
     */
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        let graphics = routeGraphics.graphics
        var point = mapPoint
        if point.hasZ {
            point = AGSPoint(x: point.x, y: point.y, spatialReference: point.spatialReference)
        }
        if (nil == originPoint) {
            originPoint = point
            graphics.removeAllObjects()
            graphics.add(AGSGraphic(geometry: point, symbol: ROUTE_ORIGIN_SYMBOL))
        } else {
            graphics.add(AGSGraphic(geometry: point, symbol: ROUTE_DESTINATION_SYMBOL))
            routeParameters.clearStops()
            var stops: [AGSStop] = []
            for p in [ originPoint, point ] {
                stops.append(AGSStop(point: p!))
            }
            routeParameters.setStops(stops)
            routeTask.solveRoute(with: routeParameters, completion: { (routeResult, err) in
                if 0 < (routeResult?.routes.count)! {
                    graphics.add(AGSGraphic(
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
    fileprivate let ELEVATION_IMAGE_SERVICE = "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
    
    // Exercise 3: Specify operational layer paths
    fileprivate let MMPK_PATH = URL(string: Bundle.main.path(forResource: "DC_Crime_Data", ofType:"mmpk")!)
    fileprivate let SCENE_SERVICE_URL = URL(string: "https://www.arcgis.com/home/item.html?id=a7419641a50e412c980cf242c29aa3c0")
    
    // Exercise 1: Outlets from storyboard
    @IBOutlet var parentView: NSView!
    @IBOutlet var mapView: AGSMapView!
    @IBOutlet weak var sceneView: AGSSceneView!
    @IBOutlet weak var button_toggle2d3d: NSButton!
    
    // Exercise 5: Outlets from storyboard
    @IBOutlet weak var button_bufferAndQuery: NSButton!
    @IBOutlet weak var button_routing: NSButton!
    
    // Exercise 1: Declare threeD boolean
    fileprivate var threeD = false

    // Exercise 4: Declare buffer and query touch delegate
    fileprivate let bufferAndQueryTouchDelegateMap: BufferAndQueryTouchDelegate
    
    // Exercise 4: Declare and instantiate graphics overlay for buffer and query
    fileprivate let bufferAndQueryMapGraphics = AGSGraphicsOverlay()
    
    // Exercise 5: Declare routing touch delegate
    private var routingTouchDelegateMap: RoutingTouchDelegate?
    private var routingTouchDelegateScene: RoutingTouchDelegate?
    
    // Exercise 5: Declare and instantiate graphics overlays for routing
    private let routingMapGraphics = AGSGraphicsOverlay()
    private let routingSceneGraphics = AGSGraphicsOverlay()
    
    required init?(coder: NSCoder) {
        // Exercise 4: Instantiate buffer and query touch delegate
        self.bufferAndQueryTouchDelegateMap = BufferAndQueryTouchDelegate(graphics: bufferAndQueryMapGraphics)
        
        super.init(coder: coder)
        
        // Exercise 5: Instantiate routing objects
        let routeTask = AGSRouteTask(url: URL(string: "http://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!)
        /**
         Note: for ArcGIS Online routing, this tutorial uses a username and password
         in the source code for simplicity. For security reasons, you would not
         do it this way in a real app. Instead, you would do one of the following:
         - Use an OAuth 2.0 user login
         - Use an OAuth 2.0 app login
         - Challenge the user for credentials
         */
        // Don't share this code without removing plain text username and password!!!
        routeTask.credential = AGSCredential(user: "myUsername", password: "myPassword")
        routeTask.defaultRouteParameters { (routeParameters, err) in
            var routingTouchDelegateMap: RoutingTouchDelegate? = nil
            var routingTouchDelegateScene: RoutingTouchDelegate? = nil
            if nil == routeParameters {
                self.button_routing.isEnabled = false
            } else {
                routingTouchDelegateMap = RoutingTouchDelegate(graphics: self.routingMapGraphics, routeTask: routeTask, routeParameters: routeParameters!)
                routingTouchDelegateScene = RoutingTouchDelegate(graphics: self.routingSceneGraphics, routeTask: routeTask, routeParameters: routeParameters!)
            }
            self.routingTouchDelegateMap = routingTouchDelegateMap
            self.routingTouchDelegateScene = routingTouchDelegateScene
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Exercise 1: Set 2D map's basemap
        mapView.map = AGSMap(basemap: AGSBasemap.topographicVector())
        
        // Exercise 1: Set up 3D scene's basemap and elevation
        sceneView.scene = AGSScene(basemapType: AGSBasemapType.imagery)
        let surface = AGSSurface()
        surface.elevationSources.append(AGSArcGISTiledElevationSource(url: URL(string: ELEVATION_IMAGE_SERVICE)!));
        sceneView.scene!.baseSurface = surface;
        
        /**
         Exercise 3: Open a mobile map package (.mmpk) and
         add its operational layers to the map
         */
        let mmpk = AGSMobileMapPackage(fileURL: MMPK_PATH!)
        mmpk.load {(error) in
            if 0 < mmpk.maps.count {
                self.mapView.map = mmpk.maps[0]
            }
            self.mapView.map!.basemap = AGSBasemap.topographicVector()
        }
        
        // Exercise 3: Add a scene layer to the scene
        let sceneLayer = AGSArcGISSceneLayer(url: SCENE_SERVICE_URL!)
        sceneLayer.load{(error) in
            self.sceneView.setViewpoint(AGSViewpoint(targetExtent: sceneLayer.fullExtent!))
            // Rotate the camera
            let viewpoint = self.sceneView.currentViewpoint(with: AGSViewpointType.centerAndScale)
            let targetPoint = viewpoint?.targetGeometry
            let camera = self.sceneView.currentViewpointCamera().rotateAroundTargetPoint(targetPoint as! AGSPoint, deltaHeading: 45.0, deltaPitch: 65.0, deltaRoll: 0.0)
            self.sceneView.setViewpointCamera(camera)
        }
        self.sceneView.scene?.operationalLayers.add(sceneLayer)
        
        // Exercise 4: Add a graphics overlay to the map for the click and buffer
        mapView.graphicsOverlays.add(bufferAndQueryMapGraphics)
        
        // Exercise 5: Add a graphics overlay to the map and scene for the routing
        mapView.graphicsOverlays.add(routingMapGraphics)
        sceneView.graphicsOverlays.add(routingSceneGraphics)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func button_toggle2d3d_onAction(_ sender: NSButton) {
        // Exercise 1: Toggle the button
        threeD = !threeD
        button_toggle2d3d.image = NSImage(named: threeD ? "two_d" : "three_d")
        
        // Exercise 1: Toggle between the 2D map and the 3D scene
        mapView.isHidden = threeD
        sceneView.isHidden = !threeD
    }
    
    /**
     Exercise 2: zoom in
     */
    @IBAction func button_zoomIn_onAction(_ sender: NSButton) {
        zoom(2)
    }
    
    /**
     Exercise 2: zoom out
     */
    @IBAction func button_zoomOut_onAction(_ sender: NSButton) {
        zoom(0.5)
    }
    
    /**
     Exercise 2: lock focus
     */
    @IBAction func button_lockFocus_onAction(_ sender: NSButton) {
        if (NSOnState == sender.state) {
            let target = getSceneTarget()
            if (target is AGSPoint) {
                let targetPoint = target as! AGSPoint
                let currentCamera = sceneView.currentViewpointCamera()
                let currentCameraPoint = currentCamera.location
                let xyDistance = AGSGeometryEngine.geodeticDistanceBetweenPoint1(
                    targetPoint,
                    point2: currentCameraPoint,
                    distanceUnit: AGSLinearUnit.meters(),
                    azimuthUnit: AGSAngularUnit.degrees(),
                    curveType: AGSGeodeticCurveType.geodesic)?.distance
                let zDistance = currentCameraPoint.z
                let distanceToTarget = (pow(xyDistance!, 2) + pow(zDistance, 2)).squareRoot();
                let cameraController = AGSOrbitLocationCameraController(targetLocation: targetPoint, distance: distanceToTarget)
                cameraController.cameraHeadingOffset = currentCamera.heading
                cameraController.cameraPitchOffset = currentCamera.pitch
                sceneView.cameraController = cameraController
            }
        } else {
            sceneView.cameraController = AGSGlobeCameraController()
        }
    }

    
    /**
     Exercise 2: determine whether to call zoomMap or zoomScene
     */
    fileprivate func zoom(_ factor: Double) {
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
    fileprivate func zoomMap(_ factor: Double) {
        mapView.setViewpointScale(mapView.mapScale / factor,
                                  completion: nil);
    }
    
    /**
     Exercise 2: Get the AGSSceneView viewpoint target.
     */
    fileprivate func getSceneTarget() -> AGSGeometry {
        return (sceneView.currentViewpoint(with: AGSViewpointType.centerAndScale)?.targetGeometry)!
    }
    
    /**
     Exercise 2: Utility method for zooming the 3D scene
     
     - parameters:
     - factor: The zoom factor (greater than 1 to zoom in, less than 1 to zoom out)
     */
    fileprivate func zoomScene(_ factor: Double) {
        let target = getSceneTarget() as! AGSPoint
        let camera = sceneView.currentViewpointCamera().zoomTowardTargetPoint(target, factor: factor)
        sceneView.setViewpointCamera(camera, duration: 0.5, completion: nil)
    }
    
    /**
     Exercise 4: Enable a map click for buffer and query
     */
    @IBAction func button_bufferAndQuery_onAction(_ button_bufferAndQuery: NSButton) {
        mapView.touchDelegate = (NSOnState == button_bufferAndQuery.state) ? bufferAndQueryTouchDelegateMap : nil
        sceneView.touchDelegate = nil

        // Exercise 5: Unselect the routing button
        if NSOnState == button_bufferAndQuery.state {
            button_routing.state = NSOffState
        }
    }

    /**
     Exercise 5: Enable a map click for routing
     */
    @IBAction func button_routing_onAction(_ button_routing: NSButton) {
        mapView.touchDelegate = (NSOnState == button_routing.state) ? routingTouchDelegateMap : nil
        sceneView.touchDelegate = (NSOnState == button_routing.state) ? routingTouchDelegateScene : nil
        
        // Exercise 5: Unselect the buffer and query button
        if NSOnState == button_routing.state {
            button_bufferAndQuery.state = NSOffState
        }
        
        if (nil != routingTouchDelegateMap) {
            routingTouchDelegateMap!.reset()
        }
        if (nil != routingTouchDelegateScene) {
            routingTouchDelegateScene!.reset()
        }
    }
    
}
