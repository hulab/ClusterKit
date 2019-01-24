//
//  YandexMapViewController.swift
//  Example-swift
//
//  Created by petropavel on 24/01/2019.
//  Copyright © 2019 Hulab. All rights reserved.
//

import YandexMapKit
import ClusterKit
import ExampleData

class YandexMapViewController: UIViewController, YMKMapViewDataSource,
    YMKMapLoadedListener,
    YMKMapCameraListener,
    YMKMapObjectTapListener,
    YMKMapObjectDragListener {

    @IBOutlet weak var mapView: YMKMapView!

    private var isMapLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.dataSource = self

        let map = mapView.mapWindow.map

        map.setMapLoadedListenerWith(self)
        map.addCameraListener(with: self)

        let algorithm = CKNonHierarchicalDistanceBasedAlgorithm()
        algorithm.cellSize = 200

        mapView.clusterManager.algorithm = algorithm
        mapView.clusterManager.marginFactor = 1

        let paris = YMKPoint(latitude: 48.853, longitude: 2.35)

        map.move(with: YMKCameraPosition(target: paris, zoom: 0, azimuth: 0, tilt: 0))

        loadData()
    }

    func loadData() {
        let operation = CKGeoPointOperation()

        operation.setCompletionBlockWithSuccess({ (_, points) in
            self.mapView.clusterManager.annotations = points
        })

        operation.start()
    }

    // MARK: YMKMapViewDataSource

    func mapView(_ mapView: YMKMapView, placemarkFor cluster: CKCluster) -> YMKPlacemarkMapObject {
        let point = YMKPoint(coordinate: cluster.coordinate)
        let placemark: YMKPlacemarkMapObject

        let mapObjects = mapView.mapWindow.map.mapObjects

        if cluster.count > 1 {
            placemark = mapObjects.addPlacemark(with: point, image: #imageLiteral(resourceName: "cluster"))
        } else {
            placemark = mapObjects.addPlacemark(with: point, image: #imageLiteral(resourceName: "marker"))
        }

        placemark.isDraggable = true
        placemark.setDragListenerWith(self)
        placemark.addTapListener(with: self)

        return placemark
    }

    // MARK: YMKMapLoadedListener

    func onMapLoaded(with statistics: YMKMapLoadStatistics) {
        isMapLoaded = true
    }

    // MARK: - How To Update Clusters

    // MARK: YMKMapCameraListener

    func onCameraPositionChanged(with map: YMKMap,
                                 cameraPosition: YMKCameraPosition,
                                 cameraUpdateSource: YMKCameraUpdateSource,
                                 finished: Bool) {

        guard isMapLoaded, finished else {
            return
        }

        mapView.clusterManager.updateClustersIfNeeded()

        // workaround (https://github.com/yandex/mapkit-ios-demo/issues/23)
        // we need to wait some time to get actual visibleRegion for clusterization
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
//            self.mapView.clusterManager.updateClustersIfNeeded()
//        }
    }

    // MARK: - How To Handle Selection/Deselection

    // MARK: YMKMapObjectTapListener

    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject,
            let cluster = placemark.cluster else {
                return false
        }

        let padding = UIEdgeInsets(top: 40, left: 20, bottom: 44, right: 20)

        if cluster.count > 1 {
            mapView.mapWindow.map.move(with: mapView.cameraPositionThatFits(cluster, edgePadding: padding),
                                       animationType: YMKAnimation(type: .smooth, duration: 0.5),
                                       cameraCallback: { completed in
                                        if completed {
                                            self.mapView.clusterManager.updateClustersIfNeeded()
                                        }
            })
            return true
        } else if let annotation = cluster.firstAnnotation {
            mapView.clusterManager.selectAnnotation(annotation, animated: true)
            return true
        }

        return false
    }

    // MARK: - How To Handle Drag and Drop

    // MARK: YMKMapObjectDragListener

    func onMapObjectDragStart(with mapObject: YMKMapObject) {
        // nothing
    }

    func onMapObjectDrag(with mapObject: YMKMapObject, point: YMKPoint) {
        // nothing
    }

    func onMapObjectDragEnd(with mapObject: YMKMapObject) {
        guard let placemark = mapObject as? YMKPlacemarkMapObject,
            let annotation = placemark.cluster?.firstAnnotation as? MKPointAnnotation else {
                return
        }

        annotation.coordinate = placemark.geometry.coordinate
    }

}

private extension YMKPoint {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
