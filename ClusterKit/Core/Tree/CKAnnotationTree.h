// CKAnnotationTree.h
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
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CKAnnotationTree;

/**
 The delegate of a CKAnnotationTree object may adopt the KPAnnotationTreeDelegate protocol. Optional method of the protocol allow the delegate to manage annotation extraction.
 */
@protocol CKAnnotationTreeDelegate <NSObject>

@optional

/**
 Asks the delegate if the annotation tree should extract the given annotation.
 
 @param annotationTree The annotation tree object requesting this information.
 @param annotation     The annotation to extract.
 
 @return Yes to permit the extraction of the given annotation.
 */
- (BOOL)annotationTree:(id<CKAnnotationTree>)annotationTree shouldExtractAnnotation:(id<MKAnnotation>)annotation;

@end

/**
 The annotation tree protocol.
 */
@protocol CKAnnotationTree <NSObject>

@property (nonatomic, weak) id<CKAnnotationTreeDelegate> delegate;

/**
 The tree's annotation set.
 */
@property (nonatomic, readonly) NSArray<id<MKAnnotation>> *annotations;

/**
 Initializes a KPAnnotationTree object.
 
 @param annotations An annotations array.
 
 @return The initialized KPAnnotationTree object.
 */
- (instancetype)initWithAnnotations:(NSArray<id<MKAnnotation>> *)annotations;

/**
 Extracts annotations from a rect.
 
 @param rect The map rect.
 
 @return The annotation array.
 */
- (NSArray<id<MKAnnotation>> *)annotationsInRect:(MKMapRect)rect;

@end

NS_ASSUME_NONNULL_END
