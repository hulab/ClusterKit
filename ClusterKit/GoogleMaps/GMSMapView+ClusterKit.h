// GMSMapView+ClusterKit.h
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

#import <GoogleMaps/GoogleMaps.h>
#import <ClusterKit/CKMap.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The GMSMapViewDataSource protocol is adopted by an object that mediates the GMSMapView’s data. The data source provides the markers that represent clusters on map.
 */
@protocol GMSMapViewDataSource <NSObject>

@optional
/**
 Asks the data source for a marker that represent the given cluster.
 
 @param mapView A map view object requesting the marker.
 @param cluster The cluster to represent.
 
 @return An object inheriting from GMSMarker that the map view can use for the specified cluster.
 */
- (__kindof GMSMarker *)mapView:(GMSMapView *)mapView markerForCluster:(CKCluster *)cluster;

@end

/**
 GMSMarker category adopting the CKAnnotation protocol.
 */
@interface GMSMarker (ClusterKit)

/**
 The cluster that the marker is related to.
 */
@property (nonatomic, weak, nullable) CKCluster *cluster;

@end

/**
 GMSMapView category adopting the CKMap protocol.
 */
@interface GMSMapView (ClusterKit) <CKMap>

/**
 Data source instance that adopt the GMSMapViewDataSource.
 */
@property(nonatomic, weak) IBOutlet id<GMSMapViewDataSource> dataSource;

/**
 Returns the marker representing the given cluster.
 
 @param cluster The cluster for which to return the corresponding marker.
 
 @return The value associated with cluster, or nil if no value is associated with cluster.
 */
- (nullable __kindof GMSMarker *)markerForCluster:(CKCluster *)cluster;

@end

/**
 GMSCameraUpdate for modifying the camera to show the content of a cluster.
 */
@interface GMSCameraUpdate (ClusterKit)

/**
 Returns a GMSCameraUpdate that transforms the camera such that the specified cluster are centered on screen at the greatest possible zoom level. The bounds will have a default padding of 64 points.
 The returned camera update will set the camera's bearing and tilt to their default zero values (i.e., facing north and looking directly at the Earth).
 
 @param cluster The cluster to fit.
 
 @return The camera update that fit the given cluster.
 */
+ (GMSCameraUpdate *)fitCluster:(CKCluster *)cluster;

/**
 This is similar to fitCluster: but allows specifying the padding (in points) in order to inset the bounding box from the view's edges.
 
 @param cluster The cluster to fit.
 @param padding The padding that inset the bounding box. If the requested padding is larger than the view size in either the vertical or horizontal direction the map will be maximally zoomed out.
 
 @return The camera update that fit the given cluster.
 */
+ (GMSCameraUpdate *)fitCluster:(CKCluster *)cluster
                    withPadding:(CGFloat)padding;

/**
 This is similar to fitCluster: but allows specifying edge insets in order to inset the bounding box from the view's edges.
 
 @param cluster    The cluster to fit.
 @param edgeInsets The edge insets of the bounding box. If the requested edge insets are larger than the view size in either the vertical or horizontal direction the map will be maximally zoomed out.
 
 @return The camera update that fit the given cluster.
 */
+ (GMSCameraUpdate *)fitCluster:(CKCluster *)cluster
                 withEdgeInsets:(UIEdgeInsets)edgeInsets;

@end
                                 
NS_ASSUME_NONNULL_END
