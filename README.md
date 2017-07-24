<p align="center">
  <img src="Resources/git_banner.png" width=434 />
</p>

<p align="center">
    <a href="https://travis-ci.org/hulab/ClusterKit">
        <img src="http://img.shields.io/travis/hulab/ClusterKit.svg?style=flat" alt="CI Status">
    </a>
    <a href="http://cocoapods.org/pods/ClusterKit">
        <img src="https://img.shields.io/cocoapods/v/ClusterKit.svg?style=flat" alt="Version">
    </a>
    <a href="http://cocoapods.org/pods/ClusterKit">
        <img src="https://img.shields.io/cocoapods/l/ClusterKit.svg?style=flat" alt="License">
    </a>
    <a href="http://cocoapods.org/pods/ClusterKit">
        <img src="https://img.shields.io/cocoapods/p/ClusterKit.svg?style=flat" alt="Platform">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat" alt="Carthage">
    </a>
</p>

----------------

ClusterKit is an elegant and efficiant clustering controller for maps. Its flexible architecture make it very customizable, you can use your own algorithm and even your own map provider. 

## Features

+ Native supports of **MapKit** and **GoogleMaps**.
+ Comes with 2 clustering algorithms, a Grid Based Algorithm and a Non Hierarchical Distance Based Algorithm.
+ Annotations are stored in a [QuadTree](https://en.wikipedia.org/wiki/Quadtree) for efficient region queries.
+ Cluster center can be switched to **Centroid**, **Nearest Centroid**, **Bottom**.
+ Handles pin **selection** as well as **drag and dropping**.
+ Written in Objective-C with full Swift interop support.

<p align="center" margin=20>
    <img src="Resources/apple_maps.gif" alt="Apple Plan" style="padding:20px;">
    <img src="Resources/google_maps.gif" alt="Google Maps" style="padding:20px;">
</p>

## Installation

### CocoaPods

ClusterKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod 'ClusterKit'
```

### Carthage

With [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

```ruby
github "hulab/ClusterKit"
```

### Maps

If you want to use ClusterKit with **Mapkit** or **GoogleMaps**, please follow the [Installation Guide](https://github.com/hulab/ClusterKit/wiki/Installation).

## Usage

If you want to try it, simply run:

```
pod try ClusterKit
```

Or clone the repo and run `pod install` from the [Examples](Examples) directory first.
> Provide the [Google API Key](https://console.developers.google.com) in the AppDelegate in order to try it with GoogleMaps.

### MapKit

##### Configure the cluster manager

```objective-c
CKNonHierarchicalDistanceBasedAlgorithm *algorithm = [CKNonHierarchicalDistanceBasedAlgorithm new];
self.mapView.clusterManager.algorithm = algorithm;
self.mapView.clusterManager.annotations = annotations;
```

##### Handle interactions in the map view's delegate

```objective-c
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [mapView.clusterManager updateClustersIfNeeded];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[CKCluster class]]) {
        CKCluster *cluster = view.annotation;
        
        if (cluster.count > 1) {
            [mapView showCluster:cluster animated:YES];
        }
    }
}
```

### GoogleMaps

##### Configure the cluster manager

```objective-c
CKGridBasedAlgorithm *algorithm = [CKGridBasedAlgorithm new];
self.mapView.clusterManager.algorithm = algorithm;
self.mapView.dataSource = self;
self.mapView.clusterManager.annotations = annotations;
```

##### Handle interactions in the map view's delegate

```objective-c
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    [mapView.clusterManager updateClustersIfNeeded];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (marker.cluster.count > 1) {
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitCluster:marker.cluster];
        [mapView animateWithCameraUpdate:cameraUpdate];
        return YES;
    }
    return NO;
}
```

##### Provide cluster marker in datasource

```objective-c
- (GMSMarker *)mapView:(GMSMapView *)mapView markerForCluster:(CKCluster *)cluster {
    GMSMarker *marker = [GMSMarker markerWithPosition:cluster.coordinate];
    
    if(cluster.count > 1) {
        marker.icon = <#Cluster icon#>;
    } else {
        marker.icon = <#Annotation icon#>;
    }
    
    return marker;
}
```

## Credits

Assets by [Hugo des Gayets](https://dribbble.com/hugodesgayets).

## License

ClusterKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
