// CKClusterManager.h
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

#import <UIKit/UIKit.h>

#import "CKGridBasedAlgorithm.h"
#import "CKNonHierarchicalDistanceBasedAlgorithm.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN const double kCKMarginFactorWorld;

@protocol CKMap;
@class CKClusterManager;

/**
 The delegate of a CKClusterManager object may adopt the CKClusterManagerDelegate protocol. Optional methods of the protocol allow the delegate to manage clustering and animations.
 */
@protocol CKClusterManagerDelegate <NSObject>

@optional

/**
 Asks the delegate if the cluster manager should clusterized the given annotation.
 
 @param clusterManager The cluster manager object requesting this information.
 @param annotation         The annotation to clusterized.
 
 @return Yes to permit clusterization of the given annotation.
 */
- (BOOL)clusterManager:(CKClusterManager *)clusterManager shouldClusterAnnotation:(id<MKAnnotation>)annotation;

/**
 Tells the delegate to perform an animation.
 
 @param clusterManager The cluster manager object requesting the animation.
 @param animations     A block object containing the animation. This block takes no parameters and has no return value. This parameter must not be NULL.
 @param completion     A block object to be executed when the animation sequence ends. This block has no return value and takes a single Boolean argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle. This parameter may be NULL.
 */
- (void)clusterManager:(CKClusterManager *)clusterManager performAnimations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;

@end

@interface CKClusterManager : NSObject

/**
 The total duration of the clusters animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
 */
@property (assign, nonatomic) CGFloat animationDuration;

/**
 A mask of options indicating how you want to perform the animations. For a list of valid constants, @see UIViewAnimationOptions.
 */
@property (assign, nonatomic) UIViewAnimationOptions animationOptions;

/**
 The cluster algorithm to use. @see CKClusterAlgorithm.
 */
@property (nonatomic,strong) __kindof CKClusterAlgorithm *algorithm;

/**
 A map object adopting the CKMap protocol.
 */
@property (nonatomic,weak) id<CKMap> map;

/**
 Delegate instance that adopt the CKClusterManagerDelegate protocol.
 */
@property (nonatomic,weak) id<CKClusterManagerDelegate> delegate;

/**
 The currently selected annotation.
 */
@property (nonatomic,readonly) id<MKAnnotation> selectedAnnotation;

/**
 The current cluster array.
 */
@property (nonatomic, readonly, copy) NSArray<CKCluster *> *clusters;

/**
 The maximum zoom level for clustering, 20 by default.
 */
@property (nonatomic) CGFloat maxZoomLevel;

/**
 The clustering margin factor. kCKMarginFactorWorld by default.
 */
@property (nonatomic) double marginFactor;

/**
 The annotations to clusterize.
 */
@property (nonatomic,copy) NSArray<id<MKAnnotation>> *annotations;

/**
 Adds an annotation.
 
 @param annotation The annotation to add.
 */
- (void)addAnnotation:(id<MKAnnotation>)annotation;

/**
 Adds annotations.
 
 @param annotations Annotations to add.
 */
- (void)addAnnotations:(NSArray<id<MKAnnotation>> *)annotations;

/**
 Removes an annotation.
 
 @param annotation The annotation to remove.
 */
- (void)removeAnnotation:(id<MKAnnotation>)annotation;

/**
 Removes annotations.
 
 @param annotations Annotations to remove.
 */
- (void)removeAnnotations:(NSArray<id<MKAnnotation>> *)annotations;

/**
 Selects an annotation. Look for the annotation in clusters and extract it if necessary.
 
 @param annotation   The annotation to be selected.
 */
- (void)selectAnnotation:(id<MKAnnotation>)annotation animated:(BOOL)animated;

/**
 Deselects an annotation.
 
 @param annotation   The annotation to be deselected.
 */
- (void)deselectAnnotation:(nullable id<MKAnnotation>)annotation animated:(BOOL)animated;

/**
 Updates displayed clusters.
 */
- (void)updateClusters;

/**
 Updates clusters if the area currently displayed has significantly moved.
 */
- (void)updateClustersIfNeeded;

@end

/**
 CKClusterAnimation defines a cluster animation from a start coordinate to an end coordinate on a map.
 */
@interface CKClusterAnimation : NSObject

/**
 The cluster to move.
 */
@property (nonatomic, readonly) CKCluster *cluster;

/**
 The cluster starting point.
 */
@property (nonatomic) CLLocationCoordinate2D from;

/**
 The cluster ending point.
 */
@property (nonatomic) CLLocationCoordinate2D to;

/**
 Initializes an animation for the given cluster.

 @param cluster The cluster to animate.
 @return The initialized CKClusterAnimation object.
 */
- (instancetype)initWithCluster:(CKCluster *)cluster NS_DESIGNATED_INITIALIZER;

/// :nodoc:
- (instancetype)init NS_UNAVAILABLE;
/// :nodoc:
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
