#import <YandexMapKit/YMKMapKit.h>
#import <ClusterKit/ClusterKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The YMKMapViewDataSource protocol is adopted by an object that mediates the YMKMap’s data. The data source provides the placemarks that represent clusters on map.
 */
@protocol YMKMapViewDataSource <NSObject>

@optional
/**
 Asks the data source for a marker that represent the given cluster.

 @param mapView A map view object requesting the marker.
 @param cluster The cluster to represent.

 @return An object inheriting from GMSMarker that the map view can use for the specified cluster.
 */
- (__kindof YMKPlacemarkMapObject *)mapView:(YMKMapView *)mapView placemarkForCluster:(CKCluster *)cluster;

@end

/**
 YMKPlacemarkMapObject category adopting the CKAnnotation protocol.
 */
@interface YMKPlacemarkMapObject (ClusterKit)

/**
 The cluster that the marker is related to.
 */
@property (nonatomic, weak, nullable) CKCluster *cluster;

@end

@interface YMKMapView (ClusterKit) <CKMap>

/**
 Data source instance that adopt the YMKMapViewDataSource.
 */
@property(nonatomic, weak) IBOutlet id<YMKMapViewDataSource> dataSource;

/**
 Returns the placemark representing the given cluster.

 @param cluster The cluster for which to return the corresponding placemark.

 @return The value associated with cluster, or nil if no value is associated with cluster.
 */
- (nullable __kindof YMKPlacemarkMapObject *)placemarkForCluster:(CKCluster *)cluster;

- (YMKCameraPosition *)cameraPositionThatFits:(CKCluster *)cluster;

- (YMKCameraPosition *)cameraPositionThatFits:(CKCluster *)cluster edgePadding:(UIEdgeInsets)insets;

@end

@interface YMKPoint (ClusterKit)

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end

NS_ASSUME_NONNULL_END
