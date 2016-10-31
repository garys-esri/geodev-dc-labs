//
//  ViewController.swift
//  Ex1MapAndScene
//
//  Created by Gary Sheppard on 10/21/16.
//  Copyright © 2016 Esri. All rights reserved.
//

import UIKit
import ArcGIS

class ViewController: UIViewController {

    @IBOutlet weak var mapView: AGSMapView!
    
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


}

