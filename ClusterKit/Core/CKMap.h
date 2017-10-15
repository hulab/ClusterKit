// CKMap.h
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
#import "CKClusterManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The CKMap protocol is used to provide cluster instructions and get informations from a map. To use this protocol, you adopt it in any custom objects that represent a map.
 @discussion An object that adopts this protocol must implement all methods and properties.
 */
@protocol CKMap <NSObject>

@required

/**
 The cluster manager that gonna create, delete and move clusters.
 */
@property (nonatomic,readonly) CKClusterManager *clusterManager;

/**
 The area currently displayed by the map view.
 */
@property (nonatomic,readonly) MKMapRect visibleMapRect;

/**
 * Zoom uses an exponentional scale, where zoom 0 represents the entire world as a
 * 256 x 256 square. Each successive zoom level increases magnification by a factor of 2. So at
 * zoom level 1, the world is 512x512, and at zoom level 2, the entire world is 1024x1024.
 */
@property (nonatomic,readonly) double zoom;

/**
 Selects the specified cluster.
 
 @param cluster  The cluster object to select.
 @param animated If YES, animates the view selection.
 */
- (void)selectCluster:(CKCluster *)cluster animated:(BOOL)animated;

/**
 Deselects the specified cluster.
 
 @param cluster  The cluster object to deselect.
 @param animated If YES, animates the view deselection.
 */
- (void)deselectCluster:(CKCluster *)cluster animated:(BOOL)animated;

/**
 Removes clusters from the map.
 
 @param clusters The clusters array to remove.
 */
- (void)removeClusters:(NSArray<CKCluster *> *)clusters;

/**
 Adds clusters from the map.
 
 @param clusters The clusters array to add.
 */
- (void)addClusters:(NSArray<CKCluster *> *)clusters;

/**
 Perfoms the specidied cluster animations.

 @param animations The animations to perfom.
 @param completion A block object to be executed when the move sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the moves actually finished before the completion handler was called. This parameter may be nil.
 */
- (void)performAnimations:(NSArray<CKClusterAnimation *> *)animations completion:(void (^__nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
