// MGLMapView+ClusterKit.m
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
#import "MGLMapView+ClusterKit.h"

MGLCoordinateBounds MGLCoordinateIncludingCoordinate(MGLCoordinateBounds bounds, CLLocationCoordinate2D coordinate) {
    
    CLLocationCoordinate2D sw = (CLLocationCoordinate2D) {
        .latitude = MIN(bounds.sw.latitude, coordinate.latitude),
        .longitude = MIN(bounds.sw.longitude, coordinate.longitude)
    };
    
    CLLocationCoordinate2D ne = (CLLocationCoordinate2D) {
        .latitude = MAX(bounds.ne.latitude, coordinate.latitude),
        .longitude = MAX(bounds.ne.longitude, coordinate.longitude)
    };
    return MGLCoordinateBoundsMake(sw, ne);
}

@implementation CKCluster (Mapbox)

@end

@implementation MGLMapView (ClusterKit)

- (MGLMapCamera *)cameraThatFitsCluster:(CKCluster *)cluster {
    return [self cameraThatFitsCluster:cluster edgePadding:UIEdgeInsetsZero];
}

- (MGLMapCamera *)cameraThatFitsCluster:(CKCluster *)cluster edgePadding:(UIEdgeInsets)insets {
    MGLCoordinateBounds bounds = MGLCoordinateBoundsMake(cluster.firstAnnotation.coordinate, cluster.firstAnnotation.coordinate);
    
    for (id<MKAnnotation> annotation in cluster) {
        bounds = MGLCoordinateIncludingCoordinate(bounds, annotation.coordinate);
    }
    
    return [self cameraThatFitsCoordinateBounds:bounds edgePadding:insets];
}

#pragma mark - <CKMap>

- (CKClusterManager *)clusterManager {
    CKClusterManager *clusterManager = objc_getAssociatedObject(self, @selector(clusterManager));
    if (!clusterManager) {
        clusterManager = [CKClusterManager new];
        clusterManager.map = self;
        objc_setAssociatedObject(self, @selector(clusterManager), clusterManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return clusterManager;
}

- (double)zoom {
    MGLCoordinateBounds bounds = self.visibleCoordinateBounds;
    double longitudeDelta = bounds.ne.longitude - bounds.sw.longitude;
    
    // Handle antimeridian crossing
    if (longitudeDelta < 0) {
        longitudeDelta = 360 + bounds.ne.longitude - bounds.sw.longitude;
    }
    
    return log2(360 * self.frame.size.width / (256 * longitudeDelta));
}

- (MKMapRect)visibleMapRect {
    MGLCoordinateBounds bounds = self.visibleCoordinateBounds;
    MKMapPoint sw = MKMapPointForCoordinate(bounds.sw);
    MKMapPoint ne = MKMapPointForCoordinate(bounds.ne);
    
    double x = sw.x;
    double y = ne.y;
    
    double width = ne.x - sw.x;
    double height = sw.y - ne.y;
    
    // Handle 180th Meridian
    if (width < 0) {
        width = ne.x + MKMapSizeWorld.width - sw.x;
    }
    if (height < 0) {
        height = sw.y + MKMapSizeWorld.height - ne.y;
    }
    
    return MKMapRectMake(x, y, width, height);
}

- (void)addClusters:(NSArray<CKCluster *> *)clusters {
    [self addAnnotations:clusters];
}

- (void)removeClusters:(NSArray<CKCluster *> *)clusters {
    [self removeAnnotations:clusters];
}

- (void)selectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    if (![self.selectedAnnotations containsObject:cluster]) {
        [self selectAnnotation:cluster animated:animated];
    }
}

- (void)deselectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    if ([self.selectedAnnotations containsObject:cluster]) {
        [self deselectAnnotation:cluster animated:animated];
    }
}

- (void)performAnimations:(NSArray<CKClusterAnimation *> *)animations completion:(void (^__nullable)(BOOL finished))completion {
    
    for (CKClusterAnimation *animation in animations) {
        animation.cluster.coordinate = animation.from;
    }
    
    void (^animationsBlock)(void) = ^{};
    
    for (CKClusterAnimation *animation in animations) {
        animationsBlock = ^{
            animationsBlock();
            animation.cluster.coordinate = animation.to;
        };
    }
    
    if ([self.clusterManager.delegate respondsToSelector:@selector(clusterManager:performAnimations:completion:)]) {
        [self.clusterManager.delegate clusterManager:self.clusterManager
                                   performAnimations:animationsBlock
                                          completion:^(BOOL finished) {
                                              if (completion) completion(finished);
                                          }];
    } else {
        [UIView animateWithDuration:self.clusterManager.animationDuration
                              delay:0
                            options:self.clusterManager.animationOptions
                         animations:animationsBlock
                         completion:completion];
    }
}

@end
