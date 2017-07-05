// CKCluster.m
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

#import <MapKit/MKGeometry.h>

#import "CKCluster.h"

double CKDistance(CLLocationCoordinate2D from, CLLocationCoordinate2D to) {
    MKMapPoint a = MKMapPointForCoordinate(from);
    MKMapPoint b = MKMapPointForCoordinate(to);
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
}

@implementation CKCluster {
    @protected
    NSMutableArray<id<CKAnnotation>> *_annotations;
}

@synthesize coordinate = _coordinate;

- (instancetype)init{
    self = [super init];
    if (self) {
        _annotations = [NSMutableArray array];
        _coordinate = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (NSArray<id<CKAnnotation>> *)annotations {
    return [_annotations copy];
}

- (NSUInteger)count {
    return _annotations.count;
}

- (id<CKAnnotation>)firstAnnotation {
    return _annotations.firstObject;
}

- (id<CKAnnotation>)lastAnnotation {
    return _annotations.firstObject;
}

- (id<CKAnnotation>)annotationAtIndex:(NSUInteger)index {
    return _annotations[index];
}

- (id<CKAnnotation>)objectAtIndexedSubscript:(NSUInteger)index {
    return _annotations[index];
}

- (void)addAnnotation:(id<CKAnnotation>)annotation {
    [_annotations addObject:annotation];
    annotation.cluster = self;
}

- (void)removeAnnotation:(id<CKAnnotation>)annotation {
    if (annotation.cluster == self) {
        [_annotations removeObject:annotation];
        annotation.cluster = nil;
    }
}

- (BOOL)containsAnnotation:(id<CKAnnotation>)annotation {
    return [_annotations containsObject:annotation];
}

#pragma mark <CKCluster>

+ (CKCluster *)clusterWithCoordinate:(CLLocationCoordinate2D)coordinate {
    CKCluster *cluster = [[self alloc] init];
    cluster.coordinate = coordinate;
    return cluster;
}

#pragma mark <MKAnnotation>

- (NSString *)title {
    if (_annotations.count == 1 && [_annotations.firstObject respondsToSelector:@selector(title)]) {
        return _annotations.firstObject.title;
    }
    return nil;
}

- (NSString *)subtitle {
    if (_annotations.count == 1 && [_annotations.firstObject respondsToSelector:@selector(subtitle)]) {
        return _annotations.firstObject.subtitle;
    }
    return nil;
}

#pragma mark <NSFastEnumeration>

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained [])buffer count:(NSUInteger)len {
    return [_annotations countByEnumeratingWithState:state objects:buffer count:len];
}

@end

@implementation CKCentroidCluster

- (void)addAnnotation:(id<CKAnnotation>)annotation {
    [super addAnnotation:annotation];
    self.coordinate = [self coordinateByAddingAnnotation:annotation];
}

- (void)removeAnnotation:(id<CKAnnotation>)annotation {
    if (annotation.cluster == self) {
        [super removeAnnotation:annotation];
        
        self.coordinate = [self coordinateByRemovingAnnotation:annotation];
    }
}

- (CLLocationCoordinate2D)coordinateByAddingAnnotation:(id<CKAnnotation>)annotation {
    if (self.count < 2) {
        return annotation.coordinate;
    }
    
    CLLocationDegrees latitude = self.coordinate.latitude * (self.count - 1);
    CLLocationDegrees longitude = self.coordinate.longitude * (self.count - 1);
    latitude += annotation.coordinate.latitude;
    longitude += annotation.coordinate.longitude;
    
    return CLLocationCoordinate2DMake(latitude / self.count, longitude / self.count);
}

- (CLLocationCoordinate2D)coordinateByRemovingAnnotation:(id<CKAnnotation>)annotation {
    if (self.count < 1) {
        return kCLLocationCoordinate2DInvalid;
    }
    
    CLLocationDegrees latitude = self.coordinate.latitude * (self.count + 1);
    CLLocationDegrees longitude = self.coordinate.longitude * (self.count + 1);
    latitude -= annotation.coordinate.latitude;
    longitude -= annotation.coordinate.longitude;
    
    return CLLocationCoordinate2DMake(latitude / self.count, longitude / self.count);
}


@end

@implementation CKNearestCentroidCluster {
    CLLocationCoordinate2D _center;
}

- (void)addAnnotation:(id<CKAnnotation>)annotation {
    if (annotation.cluster != self) {
        [_annotations addObject:annotation];
        annotation.cluster = self;
        
        _center = [self coordinateByAddingAnnotation:annotation];
        self.coordinate = [self coordinateByDistanceSort];
    }
}

- (void)removeAnnotation:(id<CKAnnotation>)annotation {
    if (annotation.cluster == self) {
        [_annotations removeObject:annotation];
        annotation.cluster = nil;
        
        _center = [self coordinateByRemovingAnnotation:annotation];
        self.coordinate = [self coordinateByDistanceSort];
    }
}

- (CLLocationCoordinate2D)coordinateByDistanceSort {
    [_annotations sortUsingComparator:^NSComparisonResult(id<CKAnnotation> _Nonnull obj1, id<CKAnnotation> _Nonnull obj2) {
        double d1 = CKDistance(self->_center, obj1.coordinate);
        double d2 = CKDistance(self->_center, obj2.coordinate);
        if (d1 > d2) return NSOrderedDescending;
        if (d1 < d2) return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    return _annotations.firstObject.coordinate;
}

@end

@implementation CKBottomCluster

- (void)addAnnotation:(id<CKAnnotation>)annotation {
    if (annotation.cluster != self) {
        NSUInteger index = [_annotations indexOfObject:annotation
                                     inSortedRange:NSMakeRange(0, _annotations.count)
                                           options:NSBinarySearchingInsertionIndex
                                   usingComparator:^NSComparisonResult(id<CKAnnotation> _Nonnull obj1, id<CKAnnotation> _Nonnull obj2) {
                                       if (obj1.coordinate.latitude > obj2.coordinate.latitude) return NSOrderedDescending;
                                       if (obj1.coordinate.latitude < obj2.coordinate.latitude) return NSOrderedAscending;
                                       return NSOrderedSame;
                                   }];
        
        [_annotations insertObject:annotation atIndex:index];
        annotation.cluster = self;
        
        self.coordinate = _annotations.firstObject.coordinate;
    }
}

- (void)removeAnnotation:(id<CKAnnotation>)annotation {
    if (annotation.cluster == self) {
        [_annotations removeObject:annotation];
        annotation.cluster = nil;
        
        self.coordinate = _annotations.firstObject.coordinate;
    }
}

@end
