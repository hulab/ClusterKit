// GoogleMapsViewController.swift
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
import GoogleMaps
import ClusterKit
import ExampleData

class GoogleMapsViewController: UIViewController, GMSMapViewDelegate, GMSMapViewDataSource {

    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.settings.compassButton = true
        
        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 200
        
        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1
        mapView.dataSource = self
        
        let paris = CLLocationCoordinate2D(latitude: 48.853, longitude: 2.35)
        let update = GMSCameraUpdate.setTarget(paris)
        mapView.moveCamera(update)
        
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
    
    // MARK: GMSMapViewDataSource
    
    func mapView(_ mapView: GMSMapView, markerFor cluster: CKCluster) -> GMSMarker {
        let marker = GMSMarker(position: cluster.coordinate)
        
        if cluster.count > 1 {
            marker.icon = UIImage(named: "cluster")
        } else {
            marker.icon = UIImage(named: "marker")
            marker.title = cluster.title
            marker.isDraggable = true
        }
        
        return marker;
    }
    
    // MARK: - How To Update Clusters
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        mapView.clusterManager.updateClustersIfNeeded()
    }
    
    // MARK: - How To Handle Selection/Deselection
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let cluster = marker.cluster, cluster.count > 1 {
            
            let padding = UIEdgeInsets.init(top: 40, left: 20, bottom: 44, right: 20)
            let cameraUpdate = GMSCameraUpdate.fit(cluster, with: padding)
            mapView.animate(with: cameraUpdate)
            return true
        }
        return false
    }
    
    public func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        
        if let annotation = marker.cluster?.firstAnnotation {
            mapView.clusterManager.selectAnnotation(annotation, animated: false)
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        
        if let annotation = marker.cluster?.firstAnnotation {
            mapView.clusterManager.deselectAnnotation(annotation, animated: false)
        }
    }
    
    // MARK: - How To Handle Drag and Drop
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        if let annotation = marker.cluster?.firstAnnotation as? MKPointAnnotation {
            annotation.coordinate = marker.position
        }
    }
}
