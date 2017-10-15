// CKQuadTree.h
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

#import "CKAnnotationTree.h"

NS_ASSUME_NONNULL_BEGIN

/// Default node capacity
#define CK_QTREE_STDCAP 4

typedef struct hb_qtree hb_qtree_t;

/// :nodoc:
FOUNDATION_EXPORT hb_qtree_t *hb_qtree_new(MKMapRect rect, NSUInteger cap);
/// :nodoc:
FOUNDATION_EXPORT void hb_qtree_free(hb_qtree_t *tree);
/// :nodoc:
FOUNDATION_EXPORT void hb_qtree_insert(hb_qtree_t *tree, id<MKAnnotation> annotation);
/// :nodoc:
FOUNDATION_EXPORT void hb_qtree_remove(hb_qtree_t *tree, id<MKAnnotation> annotation);
/// :nodoc:
FOUNDATION_EXPORT void hb_qtree_clear(hb_qtree_t *tree);
/// :nodoc:
FOUNDATION_EXPORT void hb_qtree_find_in_range(hb_qtree_t *tree, MKMapRect range, void(^find)(id<MKAnnotation>annotation));

/**
 A quadtree is a tree data structure in which each internal node has exactly four children.
 It is used to partition {@see MKMapRectWorld} by recursively subdividing it into four quadrants or regions.
 
 The quadtree represents a partition of space in two dimensions by decomposing the region into four equal quadrants, subquadrants, and so on with each leaf node containing annotation corresponding to a specific rect. Each node in the tree either has maximum four children. The height of quadtrees that follow this decomposition strategy (i.e. subdividing subquadrants as long as there is interesting data in the subquadrant for which more refinement is desired) is sensitive to and dependent on the spatial distribution of interesting areas in the space being decomposed. The region quadtree is a type of trie. Regions are subdivided until each leaf contains at most a single point.
 */
@interface CKQuadTree : NSObject <CKAnnotationTree>

/**
 Initializes a CKQuadTree with the given annotations.
 
 @param annotations An annotations array.
 
 @return An initialized CKQuadTree.
 */
- (instancetype)initWithAnnotations:(NSArray<id<MKAnnotation>> *)annotations NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
