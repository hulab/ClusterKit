// CKGridBasedAlgorithmTest.m
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
#import <ClusterKit/CKGridBasedAlgorithm.h>
#import <ClusterKit/CKQuadTree.h>

#import "CKAnnotation.h"

@interface CKGridBasedAlgorithmTest : XCTestCase
@property (nonatomic,strong) id<CKAnnotationTree> tree;
@end

@implementation CKGridBasedAlgorithmTest

- (void)setUp {
    [super setUp];
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (double x = 0; x < MKMapSizeWorld.width; x += MKMapSizeWorld.width / 100) {
        for (double y = 0; y < MKMapSizeWorld.height; y += MKMapSizeWorld.height / 100) {
            
            MKMapPoint point = MKMapPointMake(x, y);
            CKAnnotation *annotation = [CKAnnotation new];
            annotation.coordinate = MKCoordinateForMapPoint(point);
            [annotations addObject:annotation];
        }
    }
    
    self.tree = [[CKQuadTree alloc] initWithAnnotations:annotations];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testZoom1Performance {
    
    CKGridBasedAlgorithm *algorithm = [CKGridBasedAlgorithm new];
    
    [self measureBlock:^{
        NSArray *clusters = [algorithm clustersInRect:MKMapRectWorld zoom:1 tree:self.tree];
        XCTAssertTrue(clusters.count, @"No cluster");
    }];
}

- (void)testZoom2Performance {
    
    CKGridBasedAlgorithm *algorithm = [CKGridBasedAlgorithm new];
    
    [self measureBlock:^{
        NSArray *clusters = [algorithm clustersInRect:MKMapRectWorld zoom:2 tree:self.tree];
        XCTAssertTrue(clusters.count, @"No cluster");
    }];
}

- (void)testZoom4Performance {
    
    CKGridBasedAlgorithm *algorithm = [CKGridBasedAlgorithm new];
    
    [self measureBlock:^{
        NSArray *clusters = [algorithm clustersInRect:MKMapRectWorld zoom:4 tree:self.tree];
        XCTAssertTrue(clusters.count, @"No cluster");
    }];
}

- (void)testZoom8Performance {
    
    CKGridBasedAlgorithm *algorithm = [CKGridBasedAlgorithm new];
    
    [self measureBlock:^{
        NSArray *clusters = [algorithm clustersInRect:MKMapRectWorld zoom:8 tree:self.tree];
        XCTAssertTrue(clusters.count, @"No cluster");
    }];
}

- (void)testZoom16Performance {
    
    CKGridBasedAlgorithm *algorithm = [CKGridBasedAlgorithm new];
    
    [self measureBlock:^{
        NSArray *clusters = [algorithm clustersInRect:MKMapRectWorld zoom:16 tree:self.tree];
        XCTAssertTrue(clusters.count, @"No cluster");
    }];
}

@end
