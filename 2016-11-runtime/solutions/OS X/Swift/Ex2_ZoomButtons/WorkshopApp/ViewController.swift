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

class ViewController: NSViewController {
    
    // Exercise 1: Specify elevation service URL
    let ELEVATION_IMAGE_SERVICE = "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"

    // Exercise 1: Outlets from storyboard
    @IBOutlet var parentView: NSView!
    @IBOutlet var mapView: AGSMapView!
    @IBOutlet weak var sceneView: AGSSceneView!
    @IBOutlet weak var button_toggle2d3d: NSButton!
    
    // Exercise 1: Declare threeD boolean
    private var threeD = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Exercise 1: Set 2D map's basemap
        mapView.map = AGSMap(basemap: AGSBasemap.nationalGeographicBasemap())
        
        // Exercise 1: Set up 3D scene's basemap and elevation
        sceneView.scene = AGSScene(basemapType: AGSBasemapType.Imagery)
        let surface = AGSSurface()
        surface.elevationSources.append(AGSArcGISTiledElevationSource(URL: NSURL(string: ELEVATION_IMAGE_SERVICE)!));
        sceneView.scene!.baseSurface = surface;
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

}
