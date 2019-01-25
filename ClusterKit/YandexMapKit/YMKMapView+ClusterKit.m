#import <objc/runtime.h>
#import "YMKMapView+ClusterKit.h"
#import <MapKit/MapKit.h>

@implementation YMKPlacemarkMapObject (ClusterKit)

- (CKCluster *)cluster {
    return objc_getAssociatedObject(self, @selector(cluster));
}

- (void)setCluster:(CKCluster *)cluster {
    objc_setAssociatedObject(self, @selector(cluster), cluster, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface YMKMapView ()

@property (nonatomic,readonly) NSMapTable<CKCluster *, YMKPlacemarkMapObject *> *placemarks;

@end


@implementation YMKMapView (ClusterKit)

- (YMKCameraPosition *)cameraPositionThatFits:(CKCluster *)cluster {
    return [self cameraPositionThatFits:cluster edgePadding:UIEdgeInsetsMake(64, 64, 64, 64)];
}

- (YMKCameraPosition *)cameraPositionThatFits:(CKCluster *)cluster edgePadding:(UIEdgeInsets)insets {
    YMKScreenPoint *nePixel = [YMKScreenPoint screenPointWithX:-INFINITY y:-INFINITY];
    YMKScreenPoint *swPixel = [YMKScreenPoint screenPointWithX:INFINITY y:INFINITY];

    double viewportHeight = self.frame.size.height;

    for (id<MKAnnotation> annotation in cluster) {
        YMKPoint *point = [YMKPoint pointWithLatitude:annotation.coordinate.latitude
                                            longitude:annotation.coordinate.longitude];
        YMKScreenPoint *pixel = [self.mapWindow worldToScreenWithWorldPoint:point];
        nePixel = [YMKScreenPoint screenPointWithX:MAX(nePixel.x, pixel.x)
                                                 y:MAX(nePixel.y, viewportHeight - pixel.y)];

        swPixel = [YMKScreenPoint screenPointWithX:MIN(swPixel.x, pixel.x)
                                                 y:MIN(swPixel.y, viewportHeight - pixel.y)];
    }

    double width = nePixel.x - swPixel.x;
    double height = nePixel.y - swPixel.y;

    CGSize size = self.frame.size;

    // Calculate the zoom level.
    double minScale = INFINITY;
    if (width > 0 || height > 0) {
        double scaleX = (double)size.width / width;
        double scaleY = (double)size.height / height;
        scaleX -= (insets.left + insets.right) / width;
        scaleY -= (insets.top + insets.bottom) / height;
        minScale = MIN(scaleX, scaleY);
    }
    
    double newZoom = self.zoom + log2(minScale);
    double minZoom = 0;
    double maxZoom = 18;
    newZoom = MIN(MAX(newZoom, minZoom), maxZoom);

    YMKScreenPoint* centerPixel = [YMKScreenPoint screenPointWithX:nePixel.x + swPixel.x
                                                                 y:nePixel.y + swPixel.y];

    centerPixel = [YMKScreenPoint screenPointWithX:centerPixel.x + insets.right / minScale
                                                 y:centerPixel.y + insets.top / minScale];

    centerPixel = [YMKScreenPoint screenPointWithX:centerPixel.x - insets.left / minScale
                                                 y:centerPixel.y - insets.bottom / minScale];

    centerPixel = [YMKScreenPoint screenPointWithX:centerPixel.x / 2.f
                                                 y:centerPixel.y / 2.f];

    centerPixel = [YMKScreenPoint screenPointWithX:centerPixel.x
                                                 y:viewportHeight - centerPixel.y];

    YMKPoint *coordinatePoint = [self.mapWindow screenToWorldWithScreenPoint:centerPixel];

    return [YMKCameraPosition cameraPositionWithTarget:coordinatePoint
                                                  zoom:newZoom
                                               azimuth:0.f
                                                  tilt:0.f];
}

- (CKClusterManager *)clusterManager {
    CKClusterManager *clusterManager = objc_getAssociatedObject(self, @selector(clusterManager));
    if (!clusterManager) {
        clusterManager = [CKClusterManager new];
        clusterManager.map = self;
        objc_setAssociatedObject(self, @selector(clusterManager), clusterManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return clusterManager;
}

- (double)zoom {
    YMKVisibleRegion *visibleRegion = self.mapWindow.map.visibleRegion;
    CLLocationCoordinate2D southWest = visibleRegion.bottomLeft.coordinate;
    CLLocationCoordinate2D northEast = visibleRegion.topRight.coordinate;

    double longitudeDelta = northEast.longitude - southWest.longitude;

    // Handle antimeridian crossing
    if (longitudeDelta < 0) {
        longitudeDelta = 360 + northEast.longitude - southWest.longitude;
    }

    return log2(360 * self.frame.size.width / (256 * longitudeDelta));
}

- (MKMapRect)visibleMapRect {
    YMKVisibleRegion *visibleRegion = self.mapWindow.map.visibleRegion;

    MKMapPoint sw = MKMapPointForCoordinate(visibleRegion.bottomLeft.coordinate);
    MKMapPoint ne = MKMapPointForCoordinate(visibleRegion.topRight.coordinate);

    double x = sw.x;
    double y = ne.y;

    double width = ne.x - sw.x;
    double height = sw.y - ne.y;

    // Handle antimeridian crossing
    if (width < 0) {
        width = ne.x + MKMapSizeWorld.width - sw.x;
    }
    if (height < 0) {
        height = sw.y + MKMapSizeWorld.height - ne.y;
    }

    return MKMapRectMake(x, y, width, height);
}

- (id<YMKMapViewDataSource>)dataSource {
    return objc_getAssociatedObject(self, @selector(dataSource));
}

- (void)setDataSource:(id<YMKMapViewDataSource>)dataSource {
    objc_setAssociatedObject(self, @selector(dataSource), dataSource, OBJC_ASSOCIATION_ASSIGN);
}

- (id<YMKMapViewDelegate>)delegate {
    return objc_getAssociatedObject(self, @selector(delegate));
}

- (void)setDelegate:(id<YMKMapViewDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_ASSIGN);
}

- (NSMapTable<CKCluster *, YMKPlacemarkMapObject *> *)placemarks {
    NSMapTable *placemarks = objc_getAssociatedObject(self, @selector(placemarks));
    if (!placemarks) {
        placemarks = [NSMapTable strongToStrongObjectsMapTable];
        objc_setAssociatedObject(self, @selector(placemarks), placemarks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return placemarks;
}

- (YMKPlacemarkMapObject *)placemarkForCluster:(CKCluster *)cluster {
    return [self.placemarks objectForKey:cluster];
}

- (void)addCluster:(CKCluster *)cluster {
    YMKPlacemarkMapObject *placemark = nil;
    if ([self.dataSource respondsToSelector:@selector(mapView:placemarkForCluster:)]) {
        placemark = [self.dataSource mapView:self placemarkForCluster:cluster];
    } else {
        YMKPoint *clusterPoint = [YMKPoint pointWithLatitude:cluster.coordinate.latitude
                                                   longitude:cluster.coordinate.longitude];
        placemark = [self.mapWindow.map.mapObjects addPlacemarkWithPoint:clusterPoint];
        if(cluster.count > 1) {
            YMKIconStyle * style = [YMKIconStyle iconStyleWithAnchor:nil
                                                        rotationType:nil
                                                              zIndex:nil
                                                                flat:nil
                                                             visible:nil
                                                               scale:@2
                                                        tappableArea:nil];
            [placemark setIconStyleWithStyle:style];
        }
    }

    placemark.cluster = cluster;
    placemark.zIndex = 1;
    [self.placemarks setObject:placemark forKey:cluster];
}

- (void)removeCluster:(CKCluster *)cluster {
    YMKPlacemarkMapObject *placemark = [self placemarkForCluster:cluster];
    if (placemark) {
        [self.mapWindow.map.mapObjects removeWithMapObject:placemark];
    }
    [self.placemarks removeObjectForKey:cluster];
}

- (void)addClusters:(NSArray<CKCluster *> *)clusters {
    for (CKCluster *cluster in clusters) {
        [self addCluster:cluster];
    }
}

- (void)removeClusters:(NSArray<CKCluster *> *)clusters {
    for (CKCluster *cluster in clusters) {
        [self removeCluster:cluster];
    }
}

- (void)selectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    // handle selection in YMKMapObjectTapListener
}

- (void)deselectCluster:(CKCluster *)cluster animated:(BOOL)animated {
    // handle selection in YMKMapObjectTapListener
}

- (void)performAnimations:(NSArray<CKClusterAnimation *> *)animations completion:(void (^__nullable)(BOOL finished))completion {

    void (^animationsBlock)(void) = ^{};

    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        if (completion) completion(finished);
    };

    for (CKClusterAnimation *animation in animations) {
        YMKPlacemarkMapObject *placemark = [self placemarkForCluster:animation.cluster];


        placemark.zIndex = 0;
        placemark.geometry = [YMKPoint pointWithLatitude:animation.from.latitude
                                               longitude:animation.from.longitude];

        animationsBlock = ^{
            animationsBlock();
            placemark.geometry = [YMKPoint pointWithLatitude:animation.to.latitude
                                                   longitude:animation.to.longitude];
        };

        completionBlock = ^(BOOL finished){
            placemark.zIndex = 1;
            completionBlock(finished);
        };
    }

    if ([self.clusterManager.delegate respondsToSelector:@selector(clusterManager:performAnimations:completion:)]) {
        [self.clusterManager.delegate clusterManager:self.clusterManager
                                   performAnimations:animationsBlock
                                          completion:completionBlock];
    } else {
        // actually, it didn't work (https://github.com/yandex/mapkit-ios-demo/issues/21)
        [UIView animateWithDuration:self.clusterManager.animationDuration
                              delay:0
                            options:self.clusterManager.animationOptions
                         animations:animationsBlock
                         completion:completion];
    }
}

@end

@implementation YMKPoint (ClusterKit)

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

@end
