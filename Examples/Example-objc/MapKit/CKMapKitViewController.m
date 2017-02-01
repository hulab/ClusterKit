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

#import <ParisOpenData/ParisOpenData.h>
#import <ParisOpenDataUI/ParisOpenDataUI.h>

#import <ClusterKit/MKMapView+ClusterKit.h>

#import "CKMapKitViewController.h"

@interface CKMapKitViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation CKMapKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CKNonHierarchicalDistanceBasedAlgorithm *algorithm = [CKNonHierarchicalDistanceBasedAlgorithm new];
    algorithm.cellSize = 200;
    
    self.mapView.clusterManager.algorithm = algorithm;
    self.mapView.clusterManager.marginFactor = 1;
 
    [self loadMuseums];
}

- (void)didLoadPoints:(NSArray<CKPointObject *> *)points {
    self.mapView.clusterManager.annotations = points;
}

#pragma mark <MKMapViewDelegate>

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *identifier = @"annotation";
    MKAnnotationView *annotationView = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    if ([annotation isKindOfClass:[CKCluster class]]) {
        CKCluster *cluster = (CKCluster *)annotation;
        if (cluster.count > 1) {
            annotationView.canShowCallout = NO;
            annotationView.image = [UIImage imageNamed:@"cluster"];
            
        } else {
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"marker"];
        }
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [mapView.clusterManager updateClustersIfNeeded];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[CKCluster class]]) {
        CKCluster *cluster = (CKCluster *)view.annotation;
        
        if (cluster.count > 1) {
            UIEdgeInsets edgePadding = UIEdgeInsetsMake(40, 20, 44, 20);
            [self.mapView showCluster:cluster edgePadding:edgePadding animated:YES];
        }
    }
}

@end
