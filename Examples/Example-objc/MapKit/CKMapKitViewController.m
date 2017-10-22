// CKMapKitViewController.m
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
#import <ClusterKit/MKMapView+ClusterKit.h>

#import "CKMapKitViewController.h"

NSString * const CKMapViewDefaultAnnotationViewReuseIdentifier = @"annotation";
NSString * const CKMapViewDefaultClusterAnnotationViewReuseIdentifier = @"cluster";

@interface CKMapKitViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation CKMapKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CKNonHierarchicalDistanceBasedAlgorithm *algorithm = [CKNonHierarchicalDistanceBasedAlgorithm new];
    algorithm.cellSize = 100;
    
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

#pragma mark <MKMapViewDelegate>

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    CKCluster *cluster = (CKCluster *)annotation;
    
    if (cluster.count > 1) {
        MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:CKMapViewDefaultClusterAnnotationViewReuseIdentifier];
        if (view) {
            return view;
        }
        return [[CKClusterView alloc] initWithAnnotation:cluster reuseIdentifier:CKMapViewDefaultClusterAnnotationViewReuseIdentifier];
    }
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:CKMapViewDefaultAnnotationViewReuseIdentifier];
    if (view) {
        return view;
    }
    return [[CKClusterView alloc] initWithAnnotation:cluster reuseIdentifier:CKMapViewDefaultAnnotationViewReuseIdentifier];
}

#pragma mark - How To Update Clusters

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [mapView.clusterManager updateClustersIfNeeded];
}

#pragma mark - How To Handle Selection/Deselection

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    CKCluster *cluster = (CKCluster *)view.annotation;
    
    if (cluster.count > 1) {
        UIEdgeInsets edgePadding = UIEdgeInsetsMake(40, 20, 44, 20);
        [mapView showCluster:cluster edgePadding:edgePadding animated:YES];
    } else {
        [mapView.clusterManager selectAnnotation:cluster.firstAnnotation animated:NO];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    CKCluster *cluster = (CKCluster *)view.annotation;
    [mapView.clusterManager deselectAnnotation:cluster.firstAnnotation animated:NO];
}

#pragma mark - How To Handle Drag and Drop

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    CKCluster *cluster = (CKCluster *)view.annotation;
    
    switch (newState) {
            
        case MKAnnotationViewDragStateEnding:
            cluster.firstAnnotation.coordinate = cluster.coordinate;
            view.dragState = MKAnnotationViewDragStateNone;
            [view setDragState:MKAnnotationViewDragStateNone animated:YES];
            break;
            
        case MKAnnotationViewDragStateCanceling:
            [view setDragState:MKAnnotationViewDragStateNone animated:YES];
            break;
            
        default:
            break;
    }
}

@end

@implementation CKAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.canShowCallout = YES;
        self.draggable = YES;
        self.image = [UIImage imageNamed:@"marker"];
    }
    return self;
}


@end

@implementation CKClusterView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.image = [UIImage imageNamed:@"cluster"];
    }
    return self;
}

@end
