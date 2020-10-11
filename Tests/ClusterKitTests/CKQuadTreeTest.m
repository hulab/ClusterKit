// CKQuadTreeTest.m
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

#import <XCTest/XCTest.h>
#import <ClusterKit/CKQuadTree.h>

#import "CKAnnotation.h"

@interface CKQuadTreeTest : XCTestCase
@property (nonatomic,strong) NSArray *annotations;
@property (nonatomic,assign) hb_qtree_t *tree;
@end

@implementation CKQuadTreeTest

- (void)setUp {
    [super setUp];
    self.tree = hb_qtree_new(MKMapRectWorld, CK_QTREE_STDCAP);
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (double x = 0; x < MKMapSizeWorld.width; x += MKMapSizeWorld.width / 100) {
        for (double y = 0; y < MKMapSizeWorld.height; y += MKMapSizeWorld.height / 100) {
            
            MKMapPoint point = MKMapPointMake(x, y);
            CKAnnotation *annotation = [CKAnnotation new];
            annotation.coordinate = MKCoordinateForMapPoint(point);
            [annotations addObject:annotation];
            
            hb_qtree_insert(self.tree, annotation);
        }
    }
    self.annotations = annotations.copy;
}

- (void)tearDown {
    hb_qtree_free(self.tree);
    [super tearDown];
}

- (void)testQueryPerformance {
    MKMapRect rect = MKMapRectInset(MKMapRectWorld, MKMapSizeWorld.width / 4, MKMapSizeWorld.height / 4);
    
    [self measureBlock:^{
        hb_qtree_find_in_range(self.tree, rect, ^(id<MKAnnotation>  _Nonnull annotation) {});
    }];
}

- (void)testQueryResult {
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    MKMapRect nw, ne, sw, se;
    
    MKMapRectDivide(MKMapRectWorld, &nw, &ne, MKMapSizeWorld.width / 2, CGRectMaxXEdge);
    MKMapRectDivide(nw, &nw, &sw, MKMapSizeWorld.height / 2, CGRectMaxYEdge);
    MKMapRectDivide(ne, &ne, &se, MKMapSizeWorld.height / 2, CGRectMaxYEdge);
    
    hb_qtree_find_in_range(self.tree, nw, ^(id<MKAnnotation>  _Nonnull annotation) {
        [annotations addObject:annotation];
    });
    
    XCTAssertTrue(annotations.count == (self.annotations.count / 4), @"Tree should have find a quarter of annotations");
    
    hb_qtree_find_in_range(self.tree, ne, ^(id<MKAnnotation>  _Nonnull annotation) {
        [annotations addObject:annotation];
    });
    
    XCTAssertTrue(annotations.count == (self.annotations.count / 2), @"Tree should have find a quarter of annotations");
    
    hb_qtree_find_in_range(self.tree, sw, ^(id<MKAnnotation>  _Nonnull annotation) {
        [annotations addObject:annotation];
    });
    
    XCTAssertTrue(annotations.count == 3 * (self.annotations.count / 4), @"Tree should have find a quarter of annotations");
    
    hb_qtree_find_in_range(self.tree, se, ^(id<MKAnnotation>  _Nonnull annotation) {
        [annotations addObject:annotation];
    });
    
    XCTAssertTrue(annotations.count == self.annotations.count, @"Tree should have find a quarter of annotations");
}

@end
