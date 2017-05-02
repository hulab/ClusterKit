// MapKitViewController.swift
//
// Copyright © 2017 Hulab. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import MapKit
import ClusterKit
import ExampleData

class MapKitViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 200
        
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
        
        
        let paris = CLLocationCoordinate2D(latitude: 48.853, longitude: 2.35)
        mapView.setCenter(paris, animated: false)
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        let operation = CKGeoPointOperation()
        
        operation.setCompletionBlockWithSuccess({ (_, points) in
            self.mapView.clusterManager.annotations = points
        })
        
        operation.start()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") ??
            MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")

        if let cluster = annotation as? CKCluster {
            
            if cluster.count > 1 {
                annotationView.canShowCallout = false
                annotationView.image = UIImage(named: "cluster")
            } else {
                annotationView.canShowCallout = true
                annotationView.image = UIImage(named: "marker")
            }
        }
        return annotationView;
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapView.clusterManager.updateClustersIfNeeded()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let cluster = view.annotation as? CKCluster {
            if cluster.count > 1 {
                let edgePadding = UIEdgeInsetsMake(40, 20, 44, 20)
                mapView.show(cluster, edgePadding: edgePadding, animated: true)
            }
        }
    }
    
    
    
}
