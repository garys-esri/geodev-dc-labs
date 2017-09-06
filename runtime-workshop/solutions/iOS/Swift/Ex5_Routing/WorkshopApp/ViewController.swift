/*******************************************************************************
 * Copyright 2017 Esri
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

import ArcGIS
import UIKit

// Exercise 4: A touch delegate for the buffer and query
class BufferAndQueryTouchDelegate: NSObject, AGSGeoViewTouchDelegate {
    
    fileprivate let CLICK_AND_BUFFER_COLOR = UIColor(red: 1.0, green: 0.647, blue: 0.0, alpha: 1.0)
    fileprivate let CLICK_SYMBOL: AGSMarkerSymbol
    fileprivate let BUFFER_SYMBOL: AGSFillSymbol
    
    fileprivate let graphicsOverlay: AGSGraphicsOverlay
    
    init(graphics: AGSGraphicsOverlay) {
        self.graphicsOverlay = graphics
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
    }
    
    func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
        let buffer = AGSGeometryEngine.geodeticBufferGeometry(
            mapPoint,
            distance: 1000.0,
            distanceUnit: AGSLinearUnit.meters(),
            maxDeviation: 1,
            curveType: AGSGeodeticCurveType.geodesic)
        graphicsOverlay.graphics.removeAllObjects()
        graphicsOverlay.graphics.add(AGSGraphic(geometry: buffer, symbol: BUFFER_SYMBOL))
        graphicsOverlay.graphics.add(AGSGraphic(geometry: mapPoint, symbol: CLICK_SYMBOL))
        
        let query = AGSQueryParameters()
        query.geometry = buffer
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
    }
    
}

// Exercise 5: A touch delegate for routing
class RoutingTouchDelegate: NSObject, AGSGeoViewTouchDelegate {
    
    private let ROUTE_ORIGIN_SYMBOL = AGSSimpleMarkerSymbol(
        style: AGSSimpleMarkerSymbolStyle.triangle,
        color: UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.753),
        size: 10)
    private let ROUTE_DESTINATION_SYMBOL = AGSSimpleMarkerSymbol(
        style: AGSSimpleMarkerSymbolStyle.square,
        color: UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.753),
        size: 10)
    private let ROUTE_LINE_SYMBOL = AGSSimpleLineSymbol(
        style: AGSSimpleLineSymbolStyle.solid,
        color: UIColor(red: 0.333, green: 0.0, blue: 0.333, alpha: 0.753),
        width: 5)
    
    private let routeGraphics: AGSGraphicsOverlay
    private var originPoint: AGSPoint? = nil
    private let routeTask: AGSRouteTask
    private let routeParameters: AGSRouteParameters
    
    init(
        graphics: AGSGraphicsOverlay,
        routeTask: AGSRouteTask,
        routeParameters: AGSRouteParameters) {
        self.routeGraphics = graphics
        self.routeTask = routeTask
        self.routeParameters = routeParameters
    }
    
    func reset() {
        originPoint = nil
        routeGraphics.graphics.removeAllObjects()
    }
    
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
            })
            originPoint = nil
        }
    }
    
}

class ViewController: UIViewController {
    
    // Exercise 1: Specify elevation service URL
    let ELEVATION_IMAGE_SERVICE = "https://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"

    // Exercise 1: Outlets from storyboard
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var sceneView: AGSSceneView!
    
    // Exercise 5: Button outlets for toggling
    @IBOutlet weak var button_bufferAndQuery: UIButton!
    @IBOutlet weak var button_routing: UIButton!
    
    // Exercise 1: Declare threeD boolean
    fileprivate var threeD = false
    
    // Exercise 2: Mobile map package path
    fileprivate let MMPK_PATH = URL(string: Bundle.main.path(forResource: "DC_Crime_Data", ofType:"mmpk")!)
    
    // Exercise 4: Fields for buffering and querying
    fileprivate let bufferAndQueryTouchDelegateMap: BufferAndQueryTouchDelegate
    fileprivate let bufferAndQueryTouchDelegateScene: BufferAndQueryTouchDelegate
    fileprivate let bufferAndQueryMapGraphics = AGSGraphicsOverlay()
    fileprivate let bufferAndQuerySceneGraphics = AGSGraphicsOverlay()
    
    // Exercise 5: Fields for routing
    private var routingTouchDelegateMap: RoutingTouchDelegate?
    private var routingTouchDelegateScene: RoutingTouchDelegate?
    private let routingMapGraphics = AGSGraphicsOverlay()
    private let routingSceneGraphics = AGSGraphicsOverlay()
    
    // Exercise 4: Initializer to support buffer and query
    required init?(coder: NSCoder) {
        self.bufferAndQueryTouchDelegateMap = BufferAndQueryTouchDelegate(graphics: bufferAndQueryMapGraphics)
        self.bufferAndQueryTouchDelegateScene = BufferAndQueryTouchDelegate(graphics: bufferAndQuerySceneGraphics)
        super.init(coder: coder)
        
        // Exercise 5: Initialize routing touch delegates
        let routeTask = AGSRouteTask(url: URL(string: "https://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!)
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
        surface.elevationSources.append(AGSArcGISTiledElevationSource(url: URL(string: ELEVATION_IMAGE_SERVICE)!))
        sceneView.scene!.baseSurface = surface
        
        // Exercise 3: Add mobile map package to 2D map
        let mmpk = AGSMobileMapPackage(fileURL: MMPK_PATH!)
        mmpk.load {(error) in
            if 0 < mmpk.maps.count {
                self.mapView.map = mmpk.maps[0]
            }
            self.mapView.map!.basemap = AGSBasemap.topographicVector()
        }
        
        // Exercise 3: Add mobile map package's layers to 3D scene
        let sceneMmpk = AGSMobileMapPackage(fileURL: MMPK_PATH!)
        sceneMmpk.load {(error) in
            if 0 < sceneMmpk.maps.count {
                let thisMap = sceneMmpk.maps[0]
                var layers = [AGSLayer]()
                for layer in thisMap.operationalLayers {
                    layers.append(layer as! AGSLayer)
                }
                thisMap.operationalLayers.removeAllObjects()
                self.sceneView.scene?.operationalLayers.addObjects(from: layers)
                self.sceneView.setViewpoint(AGSViewpoint(latitude: 38.909, longitude: -77.016, scale: 150000))
                self.sceneView.viewpointChangedHandler = {() -> Void in
                    self.sceneView.viewpointChangedHandler = nil
                    let viewpoint = self.sceneView.currentViewpoint(with: AGSViewpointType.centerAndScale)
                    let targetPoint = viewpoint?.targetGeometry as! AGSPoint
                    let camera = self.sceneView.currentViewpointCamera()
                        .rotateAroundTargetPoint(targetPoint, deltaHeading: 45, deltaPitch: 65, deltaRoll: 0)
                    self.sceneView.setViewpointCamera(camera)
                }
            }
        }
        
        // Exercise 4: Add buffer and query graphics layers
        mapView.graphicsOverlays.add(bufferAndQueryMapGraphics)
        sceneView.graphicsOverlays.add(bufferAndQuerySceneGraphics)
        
        // Exercise 5: Add routing graphics layers
        mapView.graphicsOverlays.add(routingMapGraphics)
        sceneView.graphicsOverlays.add(routingSceneGraphics)
    }
    
    // Exercise 1: 2D/3D button action
    @IBAction func button_toggle2d3d_onAction(_ sender: UIButton) {
        // Exercise 1: Toggle the button
        threeD = !threeD
        sender.setImage(UIImage(named: threeD ? "two_d" : "three_d"), for: UIControlState.normal)
        
        // Exercise 1: Toggle between the 2D map and the 3D scene
        mapView.isHidden = threeD
        sceneView.isHidden = !threeD
    }
    
    // Exercise 2: Zoom in button action
    @IBAction func button_zoomIn_onAction(_ sender: UIButton) {
        zoom(2.0);
    }
    
    // Exercise 2: Zoom out button action
    @IBAction func button_zoomOut_onAction(_ sender: UIButton) {
        zoom(0.5);
    }
    
    // Exercise 2: Lock focus button action
    @IBAction func button_lockFocus_onAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
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
                let distanceToTarget = (pow(xyDistance!, 2) + pow(zDistance, 2)).squareRoot()
                let cameraController = AGSOrbitLocationCameraController(targetLocation: targetPoint, distance: distanceToTarget)
                cameraController.cameraHeadingOffset = currentCamera.heading
                cameraController.cameraPitchOffset = currentCamera.pitch
                sceneView.cameraController = cameraController
            }
        } else {
            sceneView.cameraController = AGSGlobeCameraController()
        }
    }
    
    // Exercise 4: Buffer and query
    @IBAction func button_bufferAndQuery_onAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        mapView.touchDelegate = sender.isSelected ? bufferAndQueryTouchDelegateMap : nil
        sceneView.touchDelegate = sender.isSelected ? bufferAndQueryTouchDelegateScene : nil
        
        // Exercise 5: Unselect the routing button if the buffer and query button is selected
        if (sender.isSelected) {
            button_routing.isSelected = false
        }
    }
    
    // Exercise 5: Routing
    @IBAction func button_routing_onAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        mapView.touchDelegate = sender.isSelected ? routingTouchDelegateMap : nil
        sceneView.touchDelegate = sender.isSelected ? routingTouchDelegateScene : nil
        
        if (sender.isSelected) {
            button_bufferAndQuery.isSelected = false
        }
        
        if (nil != routingTouchDelegateMap) {
            routingTouchDelegateMap!.reset()
        }
        if (nil != routingTouchDelegateScene) {
            routingTouchDelegateScene!.reset()
        }
    }
    
    // Exercise 2: Get the target of the current scene
    fileprivate func getSceneTarget() -> AGSGeometry {
        return (sceneView.currentViewpoint(with: AGSViewpointType.centerAndScale)?.targetGeometry)!
    }
    
    // Exercise 2: Zoom the 2D map
    fileprivate func zoomMap(_ factor: Double) {
        mapView.setViewpointScale(mapView.mapScale / factor)
    }
    
    // Exercise 2: Zoom the 3D scene
    fileprivate func zoomScene(_ factor: Double) {
        let target = getSceneTarget() as! AGSPoint
        let camera = sceneView.currentViewpointCamera().zoomTowardTargetPoint(target, factor: factor)
        sceneView.setViewpointCamera(camera, duration: 0.5, completion: nil)
    }
    
    // Exercise 2: Generic zoom method
    fileprivate func zoom(_ factor: Double) {
        if (threeD) {
            zoomScene(factor);
        } else {
            zoomMap(factor);
        }
    }

}
