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
    NSMutableSet<CKCluster *> *_clusters;
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
        _clusters = [NSMutableSet set];
        
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
        return [_clusters setByAddingObject:self.selectedCluster].allObjects;
    }
    return _clusters.allObjects;
}

#pragma mark Manage Annotations

- (void)setAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    self.tree = [[CKQuadTree alloc] initWithAnnotations:annotations];
    self.tree.delegate = self;
    [self updateClusters];
}

- (NSArray<id<MKAnnotation>> *)annotations {
    return self.tree ? self.tree.annotations : @[];
}

- (void)addAnnotation:(id<MKAnnotation>)annotation {
    self.annotations = [self.annotations arrayByAddingObject:annotation];
}

- (void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    self.annotations = [self.annotations arrayByAddingObjectsFromArray:annotations];
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation {
    NSMutableArray *annotations = [self.annotations mutableCopy];
    [annotations removeObject:annotation];
    self.annotations = annotations;
}

- (void)removeAnnotations:(NSArray<id<MKAnnotation>> *)annotations {
    NSMutableArray *_annotations = [self.annotations mutableCopy];
    [_annotations removeObjectsInArray:annotations];
    self.annotations = _annotations;
}

- (void)selectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated {
    
    if (annotation) {
        CKCluster *cluster = [self clusterForAnnotation:annotation];
        
        if (!cluster || cluster.count > 1) {
            [cluster removeAnnotation:annotation];
            
            cluster = [self.algorithm clusterWithCoordinate:annotation.coordinate];
            [cluster addAnnotation:annotation];
            [self.map addClusters:@[cluster]];
        }
        
        [self setSelectedCluster:cluster animated:animated];
    }
}

- (void)deselectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated {
    
    if (!annotation || annotation == self.selectedAnnotation) {
        [self setSelectedCluster:nil animated:animated];
    }
}

- (id<MKAnnotation>)selectedAnnotation {
    return self.selectedCluster.firstAnnotation;
}

#pragma mark - Private

- (void)updateMapRect:(MKMapRect)visibleMapRect animated:(BOOL)animated {
    if (!self.tree || MKMapRectIsNull(visibleMapRect) || MKMapRectIsEmpty(visibleMapRect)) {
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
    
    NSMutableSet *newClusters = [NSMutableSet setWithArray:clusters];
    NSMutableSet *oldClusters = [NSMutableSet setWithSet:_clusters];
    
    [oldClusters minusSet:newClusters];
    [newClusters minusSet:_clusters];
    
    NSComparisonResult zoomOrder = MKMapSizeCompare(_visibleMapRect.size, visibleMapRect.size);
    _visibleMapRect = visibleMapRect;
    
    switch (zoomOrder) {
        case NSOrderedAscending:
            [self collapse:oldClusters.allObjects to:newClusters.allObjects in:visibleMapRect];
            break;
            
        case NSOrderedDescending:
            [self expand:newClusters.allObjects from:oldClusters.allObjects in:visibleMapRect];
            break;
            
        default:
            [self.map addClusters:newClusters.allObjects];
            [self.map removeClusters:oldClusters.allObjects];
            break;
    }
    
    [_clusters minusSet:oldClusters];
    [_clusters unionSet:newClusters];
}

- (void)setSelectedCluster:(CKCluster *)selectedCluster animated:(BOOL)animated {
    if (selectedCluster == self.selectedCluster) {
        return;
    }
    
    CKCluster *prev = self.selectedCluster;
    self.selectedCluster = selectedCluster;
    
    if (prev) {
        [_clusters addObject:prev];
        [self.map deselectCluster:prev animated:animated];
    }
    
    if (selectedCluster) {
        [_clusters removeObject:selectedCluster];
        [self.map selectCluster:selectedCluster animated:animated];
    }
}

- (CKCluster *)clusterForAnnotation:(id<MKAnnotation>)annotation {
    if ([self.selectedCluster containsAnnotation:annotation]) {
        return self.selectedCluster;
    }
    
    for (CKCluster *cluster in _clusters) {
        if ([cluster containsAnnotation:annotation]) {
            return cluster;
        }
    }
    return nil;
}

- (void)expand:(NSArray<CKCluster *> *)newClusters from:(NSArray<CKCluster *> *)oldClusters in:(MKMapRect)rect {
    id<CKAnnotationTree> tree = [[CKQuadTree alloc] initWithAnnotations:newClusters];
    
    [self.map addClusters:newClusters];
    
    NSMutableSet *animations = [NSMutableSet set];
    
    for (CKCluster *oldCluster in oldClusters) {
        
        NSArray *neighbors = [tree annotationsInRect:oldCluster.bounds];
        for (CKCluster *neighbor in neighbors) {
            
            if (!MKMapRectContainsPoint(rect, MKMapPointForCoordinate(oldCluster.coordinate)) &&
                !MKMapRectContainsPoint(rect, MKMapPointForCoordinate(neighbor.coordinate))) {
                continue;
            }
            
            CKClusterAnimation *animation = [animations member:neighbor];
            
            if (!animation) {
                animation = [[CKClusterAnimation alloc] initWithCluster:neighbor];
                animation.from = oldCluster.coordinate;
                animation.to = neighbor.coordinate;
                [animations addObject:animation];
                continue;
            }
            
            if (CKDistance(animation.from, animation.to) > CKDistance(oldCluster.coordinate, neighbor.coordinate)) {
                animation.from = oldCluster.coordinate;
                animation.to = neighbor.coordinate;
            }
        }
    }
    
    [self.map performAnimations:animations.allObjects completion:nil];
    [self.map removeClusters:oldClusters];
}

- (void)collapse:(NSArray<CKCluster *> *)oldClusters to:(NSArray<CKCluster *> *)newClusters in:(MKMapRect)rect {
    id<CKAnnotationTree> tree = [[CKQuadTree alloc] initWithAnnotations:oldClusters];
    
    [self.map addClusters:newClusters];
    
     NSMutableSet *animations = [NSMutableSet set];
    
    for (CKCluster *newCluster in newClusters) {
        
        NSArray *neighbors = [tree annotationsInRect:newCluster.bounds];
        for (CKCluster *neighbor in neighbors) {
            
            if (!MKMapRectContainsPoint(rect, MKMapPointForCoordinate(newCluster.coordinate)) &&
                !MKMapRectContainsPoint(rect, MKMapPointForCoordinate(neighbor.coordinate))) {
                continue;
            }
            
            CKClusterAnimation *animation = [animations member:neighbor];
            
            if (!animation) {
                animation = [[CKClusterAnimation alloc] initWithCluster:neighbor];
                animation.from = neighbor.coordinate;
                animation.to = newCluster.coordinate;
                [animations addObject:animation];
                continue;
            }
            
            if (CKDistance(animation.from, animation.to) > CKDistance(neighbor.coordinate, newCluster.coordinate)) {
                animation.from = neighbor.coordinate;
                animation.to = newCluster.coordinate;
            }
        }
    }
    
    [self.map performAnimations:animations.allObjects completion:^(BOOL finished) {
        [self.map removeClusters:oldClusters];
    }];
}

#pragma mark <KPAnnotationTreeDelegate>

- (BOOL)annotationTree:(id<CKAnnotationTree>)annotationTree shouldExtractAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == self.selectedAnnotation) {
        return NO;
    }
    if ([self.delegate respondsToSelector:@selector(clusterManager:shouldClusterAnnotation:)]) {
        return [self.delegate clusterManager:self shouldClusterAnnotation:annotation];
    }
    return YES;
}

@end

@implementation CKClusterAnimation

- (instancetype)initWithCluster:(CKCluster *)cluster {
    self = [super init];
    if (self) {
        _cluster = cluster;
        _from = kCLLocationCoordinate2DInvalid;
        _to = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (object == self) {
        return YES;
    }
    if ([object isKindOfClass:[CKCluster class]]) {
        return [_cluster isEqualToCluster:object];
    }
    if (![object isKindOfClass:[CKClusterAnimation class]]) {
        return NO;
    }
    CKClusterAnimation *obj = object;
    return [_cluster isEqualToCluster:obj->_cluster];
}

- (NSUInteger)hash {
    return _cluster.hash;
}

@end
