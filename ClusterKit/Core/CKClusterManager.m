// CKClusterManager.m
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

#import "CKClusterManager.h"
#import "CKQuadTree.h"
#import "CKMap.h"

const double kCKMarginFactorWorld = -1;

BOOL CLLocationCoordinateEqual(CLLocationCoordinate2D coordinate1, CLLocationCoordinate2D coordinate2) {
    return (fabs(coordinate1.latitude - coordinate2.latitude) <= DBL_EPSILON &&
            fabs(coordinate1.longitude - coordinate2.longitude) <= DBL_EPSILON);
}

@interface CKClusterManager () <CKAnnotationTreeDelegate>
@property (nonatomic,strong) id<CKAnnotationTree> tree;
@property (nonatomic,strong) CKCluster *selectedCluster;
@property (nonatomic) MKMapRect visibleMapRect;
@end

@implementation CKClusterManager {
    NSMutableArray<CKCluster *> *_clusters;
    dispatch_queue_t _queue;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.algorithm = [CKClusterAlgorithm new];
        self.maxZoomLevel = 20;
        self.marginFactor = kCKMarginFactorWorld;
        self.animationDuration = .5;
        self.animationOptions = UIViewAnimationOptionCurveEaseOut;
        _clusters = [NSMutableArray new];
        
        _queue = dispatch_queue_create("com.hulab.cluster", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)setMap:(id<CKMap>)map {
    _map = map;
    _visibleMapRect = map.visibleMapRect;
}

- (void)updateClustersIfNeeded {
    if (!self.map) return;
    
    MKMapRect visibleMapRect = self.map.visibleMapRect;
    
    // Zoom update
    if (fabs(self.visibleMapRect.size.width - visibleMapRect.size.width) > 0.1f) {
        [self updateMapRect:visibleMapRect animated:(self.animationDuration > 0)];
        
    } else if (self.marginFactor != kCKMarginFactorWorld) {
        
        // Translation update
        if(fabs(self.visibleMapRect.origin.x - visibleMapRect.origin.x) > self.visibleMapRect.size.width * self.marginFactor / 2||
           fabs(self.visibleMapRect.origin.y - visibleMapRect.origin.y) > self.visibleMapRect.size.height* self.marginFactor / 2 ) {
            [self updateMapRect:visibleMapRect animated:NO];
        }
    }
}

- (void)updateClusters {
    if (!self.map) return;
    
    MKMapRect visibleMapRect = self.map.visibleMapRect;
    
    BOOL animated = (self.animationDuration > 0) && fabs(self.visibleMapRect.size.width - visibleMapRect.size.width) > 0.1f;
    [self updateMapRect:visibleMapRect animated:animated];
}

- (NSArray<CKCluster *> *)clusters {
    if (self.selectedCluster) {
        return [_clusters arrayByAddingObject:self.selectedCluster];
    }
    return _clusters.copy;
}

#pragma mark Manage Annotations

- (void)setAnnotations:(NSArray<id<CKAnnotation>> *)annotations {
    self.tree = [[CKQuadTree alloc] initWithAnnotations:annotations];
    self.tree.delegate = self;
    [self updateClusters];
}

- (NSArray<id<CKAnnotation>> *)annotations {
    return self.tree ? self.tree.annotations : @[];
}

- (void)addAnnotation:(id<CKAnnotation>)annotation {
    self.annotations = [self.annotations arrayByAddingObject:annotation];
}

- (void)addAnnotations:(NSArray<id<CKAnnotation>> *)annotations {
    self.annotations = [self.annotations arrayByAddingObjectsFromArray:annotations];
}

- (void)removeAnnotation:(id<CKAnnotation>)annotation {
    NSMutableArray *annotations = [self.annotations mutableCopy];
    [annotations removeObject:annotation];
    self.annotations = annotations;
}

- (void)removeAnnotations:(NSArray<id<CKAnnotation>> *)annotations {
    NSMutableArray *_annotations = [self.annotations mutableCopy];
    [_annotations removeObjectsInArray:annotations];
    self.annotations = _annotations;
}

- (void)selectAnnotation:(id<CKAnnotation>)annotation animated:(BOOL)animated {
    
    if (annotation) {
        CKCluster *cluster = nil;
        
        if (!annotation.cluster || annotation.cluster.count > 1) {
            cluster = [self.algorithm clusterWithCoordinate:annotation.coordinate];
            [cluster addAnnotation:annotation];
            [self.map addCluster:cluster];
        } else {
            cluster = annotation.cluster;
        }
        
        [self setSelectedCluster:cluster animated:animated];
    }
}

- (void)deselectAnnotation:(id<CKAnnotation>)annotation animated:(BOOL)animated {
    
    if (!annotation || annotation == self.selectedAnnotation) {
        [self setSelectedCluster:nil animated:animated];
    }
}

- (id<CKAnnotation>)selectedAnnotation {
    return self.selectedCluster.firstAnnotation;
}

- (void)setSelectedCluster:(CKCluster *)selectedCluster animated:(BOOL)animated {
    if (selectedCluster == _selectedCluster) {
        return;
    }
    
    CKCluster *prev = _selectedCluster;
    _selectedCluster = selectedCluster;
    
    if (prev) {
        [_clusters addObject:prev];
        [self.map deselectCluster:prev animated:animated];
    }
    
    if (selectedCluster) {
        [_clusters removeObject:selectedCluster];
        [self.map selectCluster:selectedCluster animated:animated];
    }
    
}

#pragma mark - Private

- (void)updateMapRect:(MKMapRect)visibleMapRect animated:(BOOL)animated {
    
    if (! self.tree || MKMapRectIsNull(visibleMapRect) || MKMapRectIsEmpty(visibleMapRect)) {
        return;
    }
    
    MKMapRect clusterMapRect = MKMapRectWorld;
    if (self.marginFactor != kCKMarginFactorWorld) {
        clusterMapRect = MKMapRectInset(visibleMapRect,
                                        -self.marginFactor * visibleMapRect.size.width,
                                        -self.marginFactor * visibleMapRect.size.height);
    }
    
    double zoom = self.map.zoom;
    CKClusterAlgorithm *algorithm = (zoom < self.maxZoomLevel)? self.algorithm : [CKClusterAlgorithm new];
    NSArray *clusters = [algorithm clustersInRect:clusterMapRect zoom:zoom tree:self.tree];
    
    NSMutableArray *toRemove = _clusters.mutableCopy;
    
    for (CKCluster *newCluster in clusters) {
        
        [self.map addCluster:newCluster];
        
        if (!MKMapRectContainsPoint(visibleMapRect, MKMapPointForCoordinate(newCluster.coordinate)) ||
            !animated) {
            continue;
        }
        
        for (CKCluster *oldCluster in _clusters) {
            
            if (!MKMapRectContainsPoint(clusterMapRect, MKMapPointForCoordinate(oldCluster.coordinate))) {
                continue;
            }
            
            if (CLLocationCoordinateEqual(newCluster.coordinate, oldCluster.coordinate)) {
                continue;
            }
            
            if ([oldCluster containsAnnotation:newCluster.firstAnnotation]) {
                
                [self.map moveCluster:newCluster
                                 from:oldCluster.coordinate
                                   to:newCluster.coordinate
                           completion:^(BOOL finished) {
                           }];
                
            } else if ([newCluster containsAnnotation:oldCluster.firstAnnotation]) {
                
                [self.map moveCluster:oldCluster
                                 from:oldCluster.coordinate
                                   to:newCluster.coordinate
                           completion:^(BOOL finished) {
                               [self.map removeCluster:oldCluster];
                           }];
                
                [toRemove removeObject:oldCluster];
            }
        }
    }
    
    for (CKCluster *cluster in toRemove) {
        [self.map removeCluster:cluster];
    }
    
    _clusters = clusters.mutableCopy;
    _visibleMapRect = visibleMapRect;
}

#pragma mark <KPAnnotationTreeDelegate>

- (BOOL)annotationTree:(id<CKAnnotationTree>)annotationTree shouldExtractAnnotation:(id<CKAnnotation>)annotation {
    if (annotation == self.selectedAnnotation) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(clusterManager:shouldClusterAnnotation:)]) {
        return [self.delegate clusterManager:self shouldClusterAnnotation:annotation];
    }
    return YES;
}

@end
