// CKClusterAlgorithm.h
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

#import <Foundation/Foundation.h>
#import "CKAnnotationTree.h"
#import "CKCluster.h"

NS_ASSUME_NONNULL_BEGIN

/**
 CKClusterAlgorithm represents a cluster algorithm parent class.
 */
@interface CKClusterAlgorithm : NSObject

/**
 Returns an array of clusters for the given map rect at a certain zoom.
 
 @param rect The map rect in which the clusters will be computed.
 @param zoom The zoom value at which the clusters will be computed.
 @param tree The tree where containing the annotations.
 
 @return The list of cluster.
 */
- (NSArray<CKCluster *> *)clustersInRect:(MKMapRect)rect zoom:(double)zoom tree:(id<CKAnnotationTree>)tree;

@end

/**
 CKClusterAlgorithm for CKCluster class registration.
 The algorithm will use the registrated class to instantiate a cluster.
 */
@interface CKClusterAlgorithm (CKCluster)

/**
 Registers a CKCluster class initializer.

 @param clusterClass The CKCluster class initializer.
 */
- (void)registerClusterClass:(Class<CKCluster>)clusterClass;

/**
 Instantiates a cluster using the registered class.

 @param coordinate The cluster coordinate.
 @return The newly-initialized cluster.
 */
- (__kindof CKCluster *)clusterWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END
