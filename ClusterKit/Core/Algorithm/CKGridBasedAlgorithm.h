// CKGridBasedAlgorithm.h
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
 A simple grid-based clustering algorithm with O(n) performance.
 
 The great advantage of grid-based clustering is its significant reduction of the computational complexity, especially for clustering very large data sets. The grid-based clustering approach differs from the conventional clustering algorithms in that it is concerned not with the data points but with the value space that surrounds the data points.
 
 This grid-based implementation consists of the following the steps:
 
 1. Iterate througth the annotations found in the given rect.
 2. Associate each annotation to a grid cell. The rect is partitioned in a finite number of cells using the cell size property at the given zoom level.
 3. Annotation are added to a centroid cluster {@see CKCentroidCluster} by default.
 */
@interface CKGridBasedAlgorithm : CKClusterAlgorithm

/**
 The grid cell size.
 */
@property (nonatomic) CGFloat cellSize;

@end
