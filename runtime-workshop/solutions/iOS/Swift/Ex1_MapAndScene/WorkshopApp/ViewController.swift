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

class ViewController: UIViewController {
    
    // Exercise 1: Specify elevation service URL
    let ELEVATION_IMAGE_SERVICE = "http://elevation3d.arcgis.com/arcgis/rest/services/WorldElevation3D/Terrain3D/ImageServer"

    // Exercise 1: Outlets from storyboard
    @IBOutlet weak var mapView: AGSMapView!
    @IBOutlet weak var sceneView: AGSSceneView!
    
    // Exercise 1: Declare threeD boolean
    fileprivate var threeD = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Exercise 1: Set 2D map's basemap
        mapView.map = AGSMap(basemap: AGSBasemap.topographicVector())
        
        // Exercise 1: Set up 3D scene's basemap and elevation
        sceneView.scene = AGSScene(basemapType: AGSBasemapType.imagery)
        let surface = AGSSurface()
        surface.elevationSources.append(AGSArcGISTiledElevationSource(url: URL(string: ELEVATION_IMAGE_SERVICE)!));
        sceneView.scene!.baseSurface = surface;
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


}
