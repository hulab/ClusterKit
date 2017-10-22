// CKGridBasedAlgorithm.m
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

#import "CKGridBasedAlgorithm.h"

@implementation CKGridBasedAlgorithm

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cellSize = 100;
        [self registerClusterClass:[CKCentroidCluster class]];
    }
    return self;
}

- (NSArray<CKCluster *> *)clustersInRect:(MKMapRect)rect zoom:(double)zoom tree:(id<CKAnnotationTree>)tree {
    NSMutableDictionary<NSNumber *, CKCluster *> *clusters = [[NSMutableDictionary alloc] init];
    
    @synchronized(tree) {
        NSArray *annotations = [tree annotationsInRect:rect];
        
        // Divide the whole map into a numCells x numCells grid and assign annotations to them.
        long numCells = (long)ceil(256 * pow(2, zoom) / self.cellSize);
        
        for (id<MKAnnotation> annotation in annotations) {
            
            MKMapPoint point = MKMapPointForCoordinate(annotation.coordinate);
            NSUInteger col = numCells * point.x / MKMapSizeWorld.width;
            NSUInteger row = numCells * point.y / MKMapSizeWorld.height;
            
            NSNumber *key = @(numCells * row + col);
            CKCluster *cluster = clusters[key];
            if (cluster == nil) {
                cluster = [self clusterWithCoordinate:annotation.coordinate];
                clusters[key] = cluster;
            }
            [cluster addAnnotation:annotation];
        }
    }
    
    return clusters.allValues;
}

@end
