// CKNonHierarchicalDistanceBasedAlgorithm.m
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

#import "CKNonHierarchicalDistanceBasedAlgorithm.h"

@interface CKCandidate : NSObject
@property (nonatomic) CGFloat distance;
@property (nonatomic, strong) CKCluster *cluster;
@end

MKMapRect CKCreateRectFromSpan(CLLocationCoordinate2D center, double span);

@implementation CKNonHierarchicalDistanceBasedAlgorithm

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cellSize = 100;
    }
    return self;
}

- (NSArray<CKCluster *> *)clustersInRect:(MKMapRect)rect zoom:(double)zoom tree:(id<CKAnnotationTree>)tree {
    
    // The width and height of the square around a point that we'll consider later
    CGFloat zoomSpecificSpan = 100 * self.cellSize / pow(2, zoom + 8);
    
    NSMutableArray<CKCluster *> *clusters = [[NSMutableArray alloc] init];
    
    NSMapTable<id<MKAnnotation>, CKCandidate *> *visited = [NSMapTable strongToStrongObjectsMapTable];

    @synchronized(tree) {
        
        NSArray *annotations = [tree annotationsInRect:rect];
        
        for (id<MKAnnotation> annotation in annotations) {
            
            if ([visited objectForKey:annotation]) {
                continue;
            }
            
            CKCluster *cluster = [self clusterWithCoordinate:annotation.coordinate];
            [clusters addObject:cluster];
            
            MKMapRect clusterRect = CKCreateRectFromSpan(annotation.coordinate, zoomSpecificSpan);
            NSArray *neighbors  = [tree annotationsInRect:clusterRect];
            
            for (id<MKAnnotation> neighbor in neighbors) {
                
                CKCandidate *candidate = [visited objectForKey:neighbor];
                
                CGFloat distance = CKDistance(neighbor.coordinate, cluster.coordinate);
                
                if (candidate) {
                    if (candidate.distance < distance) {
                        continue;
                    }
                    [candidate.cluster removeAnnotation:neighbor];
                } else {
                    candidate = [[CKCandidate alloc] init];
                    [visited setObject:candidate forKey:neighbor];
                }
                
                candidate.cluster = cluster;
                candidate.distance = distance;
                [cluster addAnnotation:neighbor];
            }
        }
    }
    
    return clusters;
}

@end

@implementation CKCandidate

@end

MKMapRect CKCreateRectFromSpan(CLLocationCoordinate2D center, CLLocationDegrees span) {
    double halfSpan = span / 2;
    
    CLLocationDegrees latitude = MIN(center.latitude + halfSpan, 90);
    CLLocationDegrees longitude = MAX(center.longitude - halfSpan, -180);
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
    
    latitude = MAX(center.latitude - halfSpan, -90);
    longitude = MIN(center.longitude + halfSpan, 180);
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(latitude, longitude));
    
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}
