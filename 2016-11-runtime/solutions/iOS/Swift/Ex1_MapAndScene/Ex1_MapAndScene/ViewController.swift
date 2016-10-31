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

import UIKit
import ArcGIS

class ViewController: UIViewController {
    
    // Exercise 1: Connect map and scene views to controller
    @IBOutlet weak var mapView: AGSMapView!
    
    // Exercise 1: Connect 2D/3D toggle button to controller
    @IBOutlet weak var button_toggle2d3d: UIButton!
    
    var threeD = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Exercise 1: Set up the 2D map, since we will display that first
        self.mapView.map = AGSMap(
            basemapType: .NationalGeographic,
            latitude: 0,
            longitude: 0,
            levelOfDetail: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     * Exercise 1: Toggle between 2D map and 3D scene
     */
    @IBAction func button_toggle2d3d_onAction(sender: UIButton) {
        threeD = !threeD
        button_toggle2d3d.setImage(UIImage(named: threeD ? "two-d" : "three-d"), forState: UIControlState.Normal)
    }

}

