// MKMapView+ClusterKit.h
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

#import <MapKit/MapKit.h>
#import <ClusterKit/ClusterKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MKMapView category adopting the CKMap protocol.
 */
@interface MKMapView (ClusterKit) <CKMap>

/**
 Shows the specified cluster centered on screen at the greatest possible zoom level.
 
 @param cluster  The cluster to show.
 @param animated Specify YES if you want the map view to animate the transition to the cluster rectangle or NO if you want the map to center on the specified cluster immediately.
 */
- (void)showCluster:(CKCluster *)cluster animated:(BOOL)animated;

/**
 Shows the specified cluster centered on screen at the greatest possible zoom level with the given edge padding.
 
 @param cluster  The cluster to show.
 @param insets   The amount of additional space (measured in screen points) to make visible around the specified rectangle.
 @param animated Specify YES if you want the map view to animate the transition to the cluster rectangle or NO if you want the map to center on the specified cluster immediately.
 */
- (void)showCluster:(CKCluster *)cluster edgePadding:(UIEdgeInsets)insets animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
