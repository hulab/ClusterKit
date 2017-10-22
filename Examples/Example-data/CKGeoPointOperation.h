// CKGeoPointOperation.h
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
#import <MapKit/MapKit.h>
#import <ClusterKit/ClusterKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Operation to retrieve geopoints from the embed geojson file.
 */
@interface CKGeoPointOperation : NSOperation

/**
 The callback dispatch queue on success. If `NULL` (default), the main queue is used.
 
 The queue is retained while this operation is living
 */
@property (nonatomic, assign) dispatch_queue_t successCallbackQueue;

/**
 The callback dispatch queue on failure. If `NULL` (default), the main queue is used.
 
 The queue is retained while this operation is living
 */
@property (nonatomic, assign) dispatch_queue_t failureCallbackQueue;

/**
 The geopoints found in the geojson file.
 */
@property (nonatomic, nullable, readonly) NSArray<MKPointAnnotation *> *points;

/**
 The error, if any, that occurred during execution of the operation.
 */
@property (nonatomic, nullable, readonly) NSError *error;

/**
 Sets the `completionBlock` property with a block that executes either the specified success or failure block, depending on the state of the operation.
 
 @param success The block to be executed on the completion of a successful operation. This block has no return value and takes two arguments: the receiver operation and the resulted geopoints.
 @param failure The block to be executed on the completion of an unsuccessful operation. This block has no return value and takes two arguments: the receiver operation and the error that occurred during the execution of the operation.
 */
- (void)setCompletionBlockWithSuccess:(void (^)(CKGeoPointOperation *operation, NSArray<MKPointAnnotation *> *points))success
                              failure:(nullable void (^)(CKGeoPointOperation *operation, NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
