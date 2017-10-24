# Change Log
All notable changes to `ClusterKit` project will be documented in this file.

---

## [0.3.1](https://github.com/hulab/ClusterKit/releases/tag/0.3.0) - October 24, 2017

### Fixed

- **CKClusterManager.m**: Fix annotation selection.

## [0.3.0](https://github.com/hulab/ClusterKit/releases/tag/0.3.0) - October 18, 2017


> <span style="color:red"> **Breaking changes**: </span>
> 
> + <span style="color:red">Your model do not need to adopt the `CKAnnotation` protocol anymore, only `MKAnnotation`.</span>
> 
> + <span style="color:red">For **GoogleMaps**: don't forget to update the `GMSMapView+ClusterKit` files.</span>


### Fixed

- **[Issue #23](https://github.com/hulab/ClusterKit/issues/23)**: Fix flickering pin on MapKit when updating clusters.
Identical clusters are no more replaced and the clusters animation have been improved to be performed by batch.

### Added

- **Mapbox**: ClusterKit is now compatible with [Mapbox](https://www.mapbox.com/).

### Removed

- **CKAnnotation protocol**: CKAnnotation is no more accurate since we don't replace identical clusters.

### Updated

- **CKCluster**:  Compute the cluster bounds. Add cluster comparison methods.

## [0.2.0](https://github.com/hulab/ClusterKit/releases/tag/0.2.0) - July 24, 2017

### Added

- **CKQuadTree.m**: Drag and Drop support.

### Fixed

- **CKClusterManager.m**: Fix annotation selection/deselection.

## [0.1.3](https://github.com/hulab/ClusterKit/releases/tag/0.1.3) - July 5, 2017

### Updated

- **CKCluster.m**: Make the annotation array plubic.

### Fixed

- **CKCluster.m**: Fix empty cluster in annotation using `CKBottomCluster`.

## [0.1.2](https://github.com/hulab/ClusterKit/releases/tag/0.1.2) - May 3, 2017

### Updated

- Examples: Use geojson files as data set.

### Fixed

- **CKQuadTree.m**: Fix 180th meridian spanning.

## [0.1.1](https://github.com/hulab/ClusterKit/releases/tag/0.1.1) - February 1, 2017

### Updated

- README.md

### Fixed

- **CKNonHierarchicalDistanceBasedAlgorithm.m**: Fix cluster region on world bounds.

## [0.1.0](https://github.com/hulab/ClusterKit/releases/tag/0.1.0) - January 18, 2017

First official release.
