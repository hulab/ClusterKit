//
//  CKYandexMapViewController.m
//  Example-objc
//
//  Created by petropavel on 23/01/2019.
//  Copyright © 2019 Hulab. All rights reserved.
//

#import <ExampleData/ExampleData.h>

#import <YandexMapKit/YMKMapKit.h>
#import <ClusterKit/ClusterKit.h>

#import "YMKMapView+ClusterKit.h"

#import "CKYandexMapViewController.h"

@interface CKYandexMapViewController () <YMKMapViewDataSource,
    YMKMapLoadedListener,
    YMKMapCameraListener,
    YMKMapObjectTapListener,
    YMKMapObjectDragListener>

@property (weak, nonatomic) IBOutlet YMKMapView *mapView;

@property (nonatomic) BOOL isMapLoaded;

@end

@implementation CKYandexMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isMapLoaded = NO;

    YMKMap *map = self.mapView.mapWindow.map;

    self.mapView.dataSource = self;
    [map setMapLoadedListenerWithMapLoadedListener:self];
    [map addCameraListenerWithCameraListener:self];

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

#pragma mark <YMKMapViewDataSource>

- (YMKPlacemarkMapObject *)mapView:(YMKMapView *)mapView placemarkForCluster:(CKCluster *)cluster {
    YMKPlacemarkMapObject *placemark;

    CLLocationCoordinate2D clusterCoordinate = cluster.coordinate;

    YMKPoint *point = [YMKPoint pointWithLatitude:clusterCoordinate.latitude
                                        longitude:clusterCoordinate.longitude];

    if(cluster.count > 1) {
        placemark = [mapView.mapWindow.map.mapObjects addPlacemarkWithPoint:point
                                                                      image:[UIImage imageNamed:@"cluster"]];
    } else {
        placemark = [mapView.mapWindow.map.mapObjects addPlacemarkWithPoint:point
                                                                      image:[UIImage imageNamed:@"marker"]];
        placemark.draggable = YES;
    }

    [placemark addTapListenerWithTapListener:self];
    [placemark setDragListenerWithDragListener:self];

    return placemark;
}

#pragma mark <YMKMapLoadedListener>

- (void)onMapLoadedWithStatistics:(YMKMapLoadStatistics *)statistics {
    self.isMapLoaded = YES;
}

#pragma mark - How To Update Clusters

#pragma mark <YMKMapCameraListener>

- (void)onCameraPositionChangedWithMap:(YMKMap *)map
                        cameraPosition:(YMKCameraPosition *)cameraPosition
                    cameraUpdateSource:(YMKCameraUpdateSource)cameraUpdateSource
                              finished:(BOOL)finished {

    if (self.isMapLoaded && finished) {
        [self.mapView.clusterManager updateClustersIfNeeded];

        // workaround (https://github.com/yandex/mapkit-ios-demo/issues/23)
        // we need to wait some time to get actual visibleRegion for clusterization
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//            [self.mapView.clusterManager updateClustersIfNeeded];
//        });
    }
}

#pragma mark - How To Handle Selection/Deselection

#pragma mark <YMKMapObjectTapListener>

- (BOOL)onMapObjectTapWithMapObject:(YMKMapObject *)mapObject point:(YMKPoint *)point {
    if ([mapObject isKindOfClass:[YMKPlacemarkMapObject class]]) {
        YMKPlacemarkMapObject *placemark = (YMKPlacemarkMapObject *)mapObject;
        UIEdgeInsets padding = UIEdgeInsetsMake(40, 20, 44, 20);

        YMKCameraPosition *cameraPosition = [self.mapView cameraPositionThatFits:placemark.cluster
                                                                     edgePadding:padding];\

        YMKAnimation *animation = [YMKAnimation animationWithType:YMKAnimationTypeSmooth
                                                         duration:0.5f];

        [self.mapView.mapWindow.map moveWithCameraPosition:cameraPosition
                                             animationType:animation
                                            cameraCallback:^(BOOL completed) {
                                                if (completed) {
                                                    [self.mapView.clusterManager updateClustersIfNeeded];
                                                }
                                            }];

        return YES;
    }

    return NO;
}

#pragma mark - How To Handle Drag and Drop

#pragma mark <YMKMapObjectDragListener>

- (void)onMapObjectDragStartWithMapObject:(YMKMapObject *)mapObject {
    // nothing
}

- (void)onMapObjectDragWithMapObject:(YMKMapObject *)mapObject point:(YMKPoint *)point {
    // nothing
}

- (void)onMapObjectDragEndWithMapObject:(YMKMapObject *)mapObject {
    if ([mapObject isKindOfClass:[YMKPlacemarkMapObject class]]) {
        YMKPlacemarkMapObject *placemark = (YMKPlacemarkMapObject *)mapObject;
        placemark.cluster.firstAnnotation.coordinate = placemark.geometry.coordinate;
    }
}

@end
