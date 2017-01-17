// MKMapView+ClusterKit.m
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
#import "MKMapView+ClusterKit.h"

@implementation MKMapView (ClusterKit)

- (void)showCluster:(CKCluster *)cluster animated:(BOOL)animated {
    [self showCluster:cluster edgePadding:UIEdgeInsetsZero animated:animated];
}

- (void)showCluster:(CKCluster *)cluster edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated {
    MKMapRect zoomRect = MKMapRectNull;
    for (id<CKAnnotation> annotation in cluster) {
        MKMapRect pointRect;
        pointRect.origin = MKMapPointForCoordinate(annotation.coordinate);
        pointRect.size = MKMapSizeMake(0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [self setVisibleMapRect:zoomRect edgePadding:insets animated:animated];
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
    return log2(360 * ((self.frame.size.width/256) / self.region.span.longitudeDelta));
}

- (void)addCluster:(CKCluster *)cluster {
    [self addAnnotation:cluster];
}

- (void)removeCluster:(CKCluster *)cluster {
    [self removeAnnotation:cluster];
}

- (void)moveCluster:(CKCluster *)cluster from:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to completion:(void (^__nullable)(BOOL finished))completion {
    
    cluster.coordinate = from;
    
    void (^animations)(void) = ^{
        cluster.coordinate = to;
    };
    
    if ([self.clusterManager.delegate respondsToSelector:@selector(clusterManager:performAnimations:completion:)]) {
        [self.clusterManager.delegate clusterManager:self.clusterManager
                                   performAnimations:animations
                                          completion:completion];
    } else {
        [UIView animateWithDuration:self.clusterManager.animationDuration
                              delay:0
                            options:self.clusterManager.animationOptions
                         animations:animations
                         completion:completion];
    }
}

- (void)selectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    [self selectAnnotation:cluster animated:animated];
}

- (void)deselectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    [self deselectAnnotation:cluster animated:animated];
}

@end
