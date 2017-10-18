// CKClusterAlgorithm.m
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

#import "CKClusterAlgorithm.h"

@implementation CKClusterAlgorithm  {
    Class<CKCluster> _clusterClass;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _clusterClass = [CKCluster class];
    }
    return self;
}

- (NSArray<CKCluster *> *)clustersInRect:(MKMapRect)rect zoom:(double)zoom tree:(id<CKAnnotationTree>)tree {
    NSArray *annotations = [tree annotationsInRect:rect];
    NSMutableArray *clusters = [NSMutableArray arrayWithCapacity:annotations.count];
    
    for (id<MKAnnotation> annotation in annotations) {
        CKCluster *cluster = [self clusterWithCoordinate:annotation.coordinate];
        [cluster addAnnotation:annotation];
        [clusters addObject:cluster];
    }
    return clusters;
}

@end

@implementation CKClusterAlgorithm (CKCluster)

- (void)registerClusterClass:(Class)clusterClass {
    NSAssert([clusterClass conformsToProtocol:@protocol(CKCluster)], @"Can only register class conforming to CKCluster.");
    _clusterClass = clusterClass;
}

- (CKCluster *)clusterWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [_clusterClass clusterWithCoordinate:coordinate];
}

@end
