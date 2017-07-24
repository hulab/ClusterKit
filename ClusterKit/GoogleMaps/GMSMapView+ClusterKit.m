// GMSMapView+ClusterKit.m
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

#import <objc/runtime.h>
#import "GMSMapView+ClusterKit.h"

@implementation GMSMarker (ClusterKit)

- (CKCluster *)cluster {
    return objc_getAssociatedObject(self, @selector(cluster));
}

- (void)setCluster:(CKCluster *)cluster {
    objc_setAssociatedObject(self, @selector(cluster), cluster, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface GMSMapView ()
@property (nonatomic,readonly) NSMapTable<CKCluster *, GMSMarker *> *markers;
@end

@implementation GMSMapView (ClusterKit)

- (CKClusterManager *)clusterManager {
    CKClusterManager *clusterManager = objc_getAssociatedObject(self, @selector(clusterManager));
    if (!clusterManager) {
        clusterManager = [CKClusterManager new];
        clusterManager.map = self;
        objc_setAssociatedObject(self, @selector(clusterManager), clusterManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return clusterManager;
}

- (id<GMSMapViewDataSource>)dataSource {
    return objc_getAssociatedObject(self, @selector(dataSource));
}

- (GMSMarker *)markerForCluster:(CKCluster*)cluster {
    return [self.markers objectForKey:cluster];
}

- (void)setDataSource:(id<GMSMapViewDataSource>)dataSource {
    objc_setAssociatedObject(self, @selector(dataSource), dataSource, OBJC_ASSOCIATION_ASSIGN);
}

- (NSMapTable<CKCluster *,GMSMarker *> *)markers {
    NSMapTable *markers = objc_getAssociatedObject(self, @selector(markers));
    if (!markers) {
        markers = [NSMapTable strongToStrongObjectsMapTable];
        objc_setAssociatedObject(self, @selector(markers), markers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return markers;
}

- (MKMapRect)visibleMapRect {    
    GMSCoordinateBounds * bounds = [[GMSCoordinateBounds alloc] initWithRegion:self.projection.visibleRegion];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((bounds.southWest.latitude + bounds.northEast.latitude) / 2,
                                                               (bounds.southWest.longitude + bounds.northEast.longitude) / 2);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(bounds.northEast.latitude - bounds.southWest.latitude,
                                                 bounds.northEast.longitude - bounds.southWest.longitude);
    
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(center.latitude + span.latitudeDelta / 2,
                                                                      center.longitude - span.longitudeDelta / 2));
    
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(center.latitude - span.latitudeDelta / 2,
                                                                      center.longitude + span.longitudeDelta / 2));
    
    return MKMapRectMake(MIN(a.x, b.x), MIN(a.y, b.y), ABS(a.x - b.x), ABS(a.y - b.y));
}

- (double)zoom {
    return self.camera.zoom;
}

- (void)addCluster:(CKCluster *)cluster {
    GMSMarker *marker = nil;
    if ([self.dataSource respondsToSelector:@selector(mapView:markerForCluster:)]) {
        marker = [self.dataSource mapView:self markerForCluster:cluster];
    } else {
        marker = [GMSMarker markerWithPosition:cluster.coordinate];
        if(cluster.count > 1) {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
        }
    }

    marker.cluster = cluster;
    marker.zIndex = 1;
    marker.map = self;
    [self.markers setObject:marker forKey:cluster];
}

- (void)removeCluster:(CKCluster *)cluster {
    GMSMarker *marker = [self.markers objectForKey:cluster];
    marker.map = nil;
    [self.markers removeObjectForKey:cluster];
}

- (void)moveCluster:(CKCluster *)cluster from:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to completion:(void (^__nullable)(BOOL finished))completion {
    
    GMSMarker *marker = [self.markers objectForKey:cluster];
    marker.zIndex = 0;
    marker.position = from;
    
    void (^animations)(void) = ^{
        marker.layer.latitude = to.latitude;
        marker.layer.longitude = to.longitude;
    };
    
    void (^block)(void) = ^{
        marker.zIndex = 1;
        completion(YES);
    };
    
    if ([self.clusterManager.delegate respondsToSelector:@selector(clusterManager:performAnimations:completion:)]) {
        [self.clusterManager.delegate clusterManager:self.clusterManager
                                   performAnimations:animations
                                          completion:^(BOOL finished) {
                                              marker.zIndex = 1;
                                              completion(finished);
                                          }];
    } else {
        CAMediaTimingFunction *curve = nil;
        switch (self.clusterManager.animationOptions) {
            case UIViewAnimationOptionCurveEaseInOut:
                curve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                break;
            case UIViewAnimationOptionCurveEaseIn:
                curve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                break;
            case UIViewAnimationOptionCurveEaseOut:
                curve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                break;
            case UIViewAnimationOptionCurveLinear:
                curve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                break;
            default:
                curve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        }
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:self.clusterManager.animationDuration];
        [CATransaction setAnimationTimingFunction:curve];
        [CATransaction setCompletionBlock:block];
        animations();
        [CATransaction commit];
    }
}

- (void)selectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    GMSMarker *marker = [self.markers objectForKey:cluster];
    if (marker != self.selectedMarker) {
        marker.map = self;
        self.selectedMarker = marker;
    }
}

- (void)deselectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    GMSMarker *marker = [self.markers objectForKey:cluster];
    if (marker == self.selectedMarker) {
        self.selectedMarker = nil;
    }
}

@end

@implementation GMSCameraUpdate (ClusterKit)

+ (GMSCameraUpdate *)fitCluster:(CKCluster *)cluster {
    return [self fitCluster:cluster withPadding:64];
}

+ (GMSCameraUpdate *)fitCluster:(CKCluster *)cluster withPadding:(CGFloat)padding {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    return [self fitCluster:cluster withEdgeInsets:edgeInsets];
}

+ (GMSCameraUpdate *)fitCluster:(CKCluster *)cluster withEdgeInsets:(UIEdgeInsets)edgeInsets {
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:cluster.coordinate coordinate:cluster.coordinate];
    
    for (id<CKAnnotation> marker in cluster) {
        bounds = [bounds includingCoordinate:marker.coordinate];
    }
    return [GMSCameraUpdate fitBounds:bounds withEdgeInsets:edgeInsets];
}

@end
