//
//  CMMapPoint.m
//  CMMapLauncher
//
//  Created by Harry Wright on 30/07/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#import "CMMapPoint.h"

///--------------------------
/// CMMapPoint (helper class)
///--------------------------

@implementation CMMapPoint

+ (CMMapPoint*)currentLocation {
    CMMapPoint* mapPoint = [[CMMapPoint alloc] init];
    mapPoint.isCurrentLocation = YES;
    return mapPoint;
}

+ (CMMapPoint*)mapPointWithCoordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint* mapPoint = [[CMMapPoint alloc] init];
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

+ (CMMapPoint*)mapPointWithName:(NSString*)name
                     coordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint* mapPoint = [[CMMapPoint alloc] init];
    mapPoint.name = name;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

+ (CMMapPoint*)mapPointWithName:(NSString*)name
                        address:(NSString*)address
                     coordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint* mapPoint = [[CMMapPoint alloc] init];
    mapPoint.name = name;
    mapPoint.address = address;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

+ (CMMapPoint*)mapPointWithAddress:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate {
    CMMapPoint* mapPoint = [[CMMapPoint alloc] init];
    mapPoint.address = address;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

- (NSString*)name {
    if (_isCurrentLocation) {
        return @"Current Location";
    }

    return _name;
}

- (MKMapItem*)MKMapItem {
    if (_isCurrentLocation) {
        return [MKMapItem mapItemForCurrentLocation];
    }

    MKPlacemark* placemark = [[MKPlacemark alloc] initWithCoordinate:_coordinate addressDictionary:nil];

    MKMapItem* item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = self.name;
    return item;
}

+ (CMMapPoint*)mapPointWithMapItem:(MKMapItem*)mapItem
                              name:(NSString*)name
                           address:(NSString*)address
                        coordinate:(CLLocationCoordinate2D)coordinate{
    CMMapPoint* mapPoint = [[CMMapPoint alloc] init];
    mapPoint.MKMapItem = mapItem;
    mapPoint.name = name;
    mapPoint.address = address;
    mapPoint.coordinate = coordinate;
    return mapPoint;
}

@end
