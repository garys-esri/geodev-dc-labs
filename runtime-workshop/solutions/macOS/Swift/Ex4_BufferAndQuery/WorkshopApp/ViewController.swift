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

class ViewController: NSViewController {
    
    // Exercise 1: Specify elevation service URL
    let ELEVATION_IMAGE_SERVICE = "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"
    
    // Exercise 3: Specify mobile map package path
    fileprivate let MMPK_PATH = URL(string: Bundle.main.path(forResource: "DC_Crime_Data", ofType:"mmpk")!)

    // Exercise 1: Outlets from storyboard
    @IBOutlet var parentView: NSView!
    @IBOutlet var mapView: AGSMapView!
    @IBOutlet weak var sceneView: AGSSceneView!
    @IBOutlet weak var button_toggle2d3d: NSButton!
    
    // Exercise 1: Declare threeD boolean
    fileprivate var threeD = false
    
    // Exercise 4: Declare buffer and query touch delegates
    fileprivate let bufferAndQueryTouchDelegateMap: BufferAndQueryTouchDelegate
    fileprivate let bufferAndQueryTouchDelegateScene: BufferAndQueryTouchDelegate
    
    // Exercise 4: Declare and instantiate graphics overlays for buffer and query
    fileprivate let bufferAndQueryMapGraphics = AGSGraphicsOverlay()
    fileprivate let bufferAndQuerySceneGraphics = AGSGraphicsOverlay()
    
    required init?(coder: NSCoder) {
        // Exercise 4: Instantiate buffer and query touch delegate
        self.bufferAndQueryTouchDelegateMap = BufferAndQueryTouchDelegate(graphics: bufferAndQueryMapGraphics)
        self.bufferAndQueryTouchDelegateScene = BufferAndQueryTouchDelegate(graphics: bufferAndQuerySceneGraphics)
        
        super.init(coder: coder)
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
        
        /**
         Exercise 3: Open a mobile map package (.mmpk) and
         add its operational layers to the scene
         */
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
                
                // Here is the intended way of getting the layers' viewpoint:
                // self.sceneView.setViewpoint(thisMap.initialViewpoint!)
                // However, AGSMap.initialViewpoint is returning nil in ArcGIS Runtime
                // for macOS. Therefore, let's hard-code the coordinates for Washington, D.C.
                self.sceneView.setViewpoint(AGSViewpoint(latitude: 38.909, longitude: -77.016, scale: 150000))
                
                // Rotate the camera
                let viewpoint = self.sceneView.currentViewpoint(with: AGSViewpointType.centerAndScale)
                let targetPoint = viewpoint?.targetGeometry as! AGSPoint
                let camera = self.sceneView.currentViewpointCamera()
                        .rotateAroundTargetPoint(targetPoint, deltaHeading: 45, deltaPitch: 65, deltaRoll: 0)
                self.sceneView.setViewpointCamera(camera)
            }
            self.mapView.map!.basemap = AGSBasemap.topographicVector()
        }
        
        // Exercise 4: Add a graphics overlay to the map and scene for the click and buffer
        mapView.graphicsOverlays.add(bufferAndQueryMapGraphics)
        sceneView.graphicsOverlays.add(bufferAndQuerySceneGraphics)
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
        sceneView.touchDelegate = (NSOnState == button_bufferAndQuery.state) ? bufferAndQueryTouchDelegateScene : nil
    }

}
