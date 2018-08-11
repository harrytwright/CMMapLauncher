//
//  CMMapPoint.h
//  CMMapLauncher
//
//  Created by Harry Wright on 30/07/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

///--------------------------
/// CMMapPoint (helper class)
///--------------------------

NS_SWIFT_NAME(MapPoint)
@interface CMMapPoint : NSObject

/**
 Determines whether this map point represents the user's current location.
 */
@property(nonatomic, assign) BOOL isCurrentLocation;

/**
 The geographical coordinate of the map point.
 */
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

/**
 The user-visible name of the given map point (optional, may be nil).
 */
@property(nonatomic, copy, nullable) NSString *name;

/**
 The address of the given map point (optional, may be nil).
 */
@property(nonatomic, copy, nullable) NSString *address;

/**
 Gives an MKMapItem corresponding to this map point object.
 */
@property(nonatomic, retain) MKMapItem *MKMapItem;

/**
 Creates a new CMMapPoint that signifies the current location.
 */
@property (class, strong, readonly) CMMapPoint *currentLocation;

/**
 Creates a new CMMapPoint with the given geographical coordinate.

 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 Creates a new CMMapPoint with the given name and coordinate.

 @param name The user-visible name of the new map point.
 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithName:(NSString *)name
                      coordinate:(CLLocationCoordinate2D)coordinate;

/**
 Creates a new CMMapPoint with the given name, address, and coordinate.

 @param name The user-visible name of the new map point.
 @param address The address string of the new map point.
 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithName:(NSString *)name
                         address:(NSString *)address
                      coordinate:(CLLocationCoordinate2D)coordinate;

/**
 Creates a new CMMapPoint with the given name, address, and coordinate.

 @param address The address string of the new map point.
 @param coordinate The geographical coordinate of the new map point.
 */
+ (CMMapPoint *)mapPointWithAddress:(NSString *)address
                         coordinate:(CLLocationCoordinate2D)coordinate;


+ (CMMapPoint *)mapPointWithMapItem:(MKMapItem *)mapItem
                               name:(NSString *)name
                            address:(NSString *)address
                         coordinate:(CLLocationCoordinate2D)coordinate;

@end

NS_ASSUME_NONNULL_END
