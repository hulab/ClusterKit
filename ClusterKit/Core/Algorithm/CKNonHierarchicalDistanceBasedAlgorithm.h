// CKNonHierarchicalDistanceBasedAlgorithm.h
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

/**
 A simple clustering algorithm with O(nlog n) performance.
 
 Non-hierarchical distance analysis aims to find a grouping of annotations which minimises the distance between an annotation and its cluster. These algorithm will iteratively assign annotations to different groups while searching for the optimal distance.
 
 1. Iterate througth the annotations that are not yet clusterized found in the given rect.
 2. Create a cluster with the center of the annotation.
 3. Add all items that are within a certain distance to the cluster.
 4. Move any items out of an existing cluster if they are closer to another cluster.
 
 CKNonHierarchicalDistanceBasedAlgorithm is an objective-c implementation of the non-hierarchical distance based clustering algorithm used by Google maps.
 @see https://github.com/googlemaps/android-maps-utils/blob/master/library/src/com/google/maps/android/clustering/algo/NonHierarchicalDistanceBasedAlgorithm.java
 */
@interface CKNonHierarchicalDistanceBasedAlgorithm : CKClusterAlgorithm

/**
 Cell size around a point.
 */
@property (nonatomic) CGFloat cellSize;

@end
