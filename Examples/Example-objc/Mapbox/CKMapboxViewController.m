// CKMapboxViewController.m
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

#import <ExampleData/ExampleData.h>
#import <ClusterKit/MGLMapView+ClusterKit.h>

#import "CKMapboxViewController.h"

NSString * const MBXMapViewDefaultAnnotationViewReuseIdentifier = @"annotation";
NSString * const MBXMapViewDefaultClusterAnnotationViewReuseIdentifier = @"cluster";

@interface CKMapboxViewController () <MGLMapViewDelegate>
@property (weak, nonatomic) IBOutlet MGLMapView *mapView;
@end

@implementation CKMapboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CKNonHierarchicalDistanceBasedAlgorithm *algorithm = [CKNonHierarchicalDistanceBasedAlgorithm new];
    algorithm.cellSize = 200;
    
    self.mapView.clusterManager.algorithm = algorithm;
    self.mapView.clusterManager.marginFactor = 1;
    
    [self loadData];
}

- (void)loadData {
    CKGeoPointOperation *operation = [[CKGeoPointOperation alloc] init];
    
    [operation setCompletionBlockWithSuccess:^(CKGeoPointOperation * _Nonnull operation, NSArray<MKPointAnnotation *> *points) {
        self.mapView.clusterManager.annotations = points;
    } failure:nil];
    
    [operation start];
}

#pragma mark <MGLMapViewDelegate>

- (MGLAnnotationView *)mapView:(MGLMapView *)mapView viewForAnnotation:(id<MGLAnnotation>)annotation {
    CKCluster *cluster = (CKCluster *)annotation;
    
    if (cluster.count > 1) {
        MGLAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:MBXMapViewDefaultClusterAnnotationViewReuseIdentifier];
        if (view) {
            return view;
        }
        return [[MBXClusterView alloc] initWithAnnotation:cluster reuseIdentifier:MBXMapViewDefaultClusterAnnotationViewReuseIdentifier];
    }
    
    MGLAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:MBXMapViewDefaultAnnotationViewReuseIdentifier];
    if (view) {
        return view;
    }
    return [[MBXClusterView alloc] initWithAnnotation:cluster reuseIdentifier:MBXMapViewDefaultAnnotationViewReuseIdentifier];
}

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id<MGLAnnotation>)annotation {
    CKCluster *cluster = (CKCluster *)annotation;
    return cluster.count == 1;
}

#pragma mark How To Update Clusters

- (void)mapView:(MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [mapView.clusterManager updateClustersIfNeeded];
}

#pragma mark How To Handle Selection/Deselection

- (void)mapView:(MGLMapView *)mapView didSelectAnnotation:(nonnull id<MGLAnnotation>)annotation {
    CKCluster *cluster = (CKCluster *)annotation;
    
    if (cluster.count > 1) {
        UIEdgeInsets edgePadding = UIEdgeInsetsMake(40, 20, 44, 20);
        MGLMapCamera *camera = [mapView cameraThatFitsCluster:cluster edgePadding:edgePadding];
        [mapView setCamera:camera animated:YES];
    } else {
        [mapView.clusterManager selectAnnotation:cluster.firstAnnotation animated:NO];
    }
}

- (void)mapView:(MGLMapView *)mapView didDeselectAnnotation:(nonnull id<MGLAnnotation>)annotation{
    CKCluster *cluster = (CKCluster *)annotation;
    [mapView.clusterManager deselectAnnotation:cluster.firstAnnotation animated:NO];
}

@end

@implementation MBXAnnotationView

- (instancetype)initWithAnnotation:(id<MGLAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImage *image = [UIImage imageNamed:@"marker"];
        self.imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.imageView];
        self.frame = self.imageView.frame;
        
        self.draggable = YES;
        self.centerOffset = CGVectorMake(0.5, 1);
    }
    return self;
}


- (void)setDragState:(MGLAnnotationViewDragState)dragState animated:(BOOL)animated {
    [super setDragState:dragState animated:NO];
    
    switch (dragState) {
        case MGLAnnotationViewDragStateStarting: {
            [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:.4 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveLinear animations:^{
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
            } completion:nil];
            break;
        }
        case MGLAnnotationViewDragStateEnding: {
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
            [UIView animateWithDuration:.4 delay:0 usingSpringWithDamping:.4 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveLinear animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:nil];
            break;
        }
        default:
            break;
    }
}

@end

@implementation MBXClusterView

- (instancetype)initWithAnnotation:(id<MGLAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImage *image = [UIImage imageNamed:@"cluster"];
        self.imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:self.imageView];
        self.frame = self.imageView.frame;
    
        self.centerOffset = CGVectorMake(0.5, 1);
    }
    return self;
}

@end
