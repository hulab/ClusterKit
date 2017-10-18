// CKGeoPointOperation.m
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

#import <objc/runtime.h>
#import <GeoJSONSerialization/GeoJSONSerialization.h>

#import "CKGeoPointOperation.h"

@implementation CKGeoPointOperation

@synthesize points = _points;
@synthesize error = _error;

- (void)main {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *URL = [bundle URLForResource:@"stations" withExtension:@"geojson"];
    
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSDictionary *geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSError *error = nil;
    _points = [GeoJSONSerialization shapesFromGeoJSONFeatureCollection:geoJSON error:&error];
    _error = error;
}

- (void)setCompletionBlock:(void (^)(void))completionBlock {
    if (!completionBlock) {
        [super setCompletionBlock:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [super setCompletionBlock:^ {
            completionBlock();
            [weakSelf setCompletionBlock:nil];
        }];
    }
}

- (void)setCompletionBlockWithSuccess:(void (^)(CKGeoPointOperation *operation, NSArray<MKPointAnnotation *> *points))success
                              failure:(void (^)(CKGeoPointOperation *operation, NSError *error))failure {
    
    __weak __typeof(self) const weakSelf = self;
    self.completionBlock = ^{
        __typeof(self) const strongSelf = weakSelf; // Retain object, so we for sure have something to pass to the success and/or failure blocks.
        if(strongSelf) {
            
            if (strongSelf.error) {
                if (failure) {
                    dispatch_async(strongSelf.failureCallbackQueue ?: dispatch_get_main_queue(), ^{
                        failure(strongSelf, strongSelf.error);
                    });
                }
            } else {
                dispatch_async(strongSelf.successCallbackQueue ?: dispatch_get_main_queue(), ^{
                    success(strongSelf, strongSelf.points);
                });
            }
        }
    };
}

@end
