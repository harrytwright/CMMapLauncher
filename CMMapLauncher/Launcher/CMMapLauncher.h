// CMMapLauncher.h
// Last updated 2013-08-26
//
// Copyright (c) 2013 Citymapper Ltd. All rights reserved.
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

// README
//
// This pair of classes simplifies the process of launching various mapping
// applications to display directions.  Here's the simplest use case:
//
// CLLocationCoordinate2D bigBen =
//     CLCLLocationCoordinate2DMake(51.500755, -0.124626);
// [CMMapLauncher launchMapApp:CMMapAppAppleMaps
//             forDirectionsTo:[CMMapPoint mapPointWithName:@"Big Ben"
//                                               coordinate:bigBen]];

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "CMMapApp.h"
#import "CMConstants.h"
#import "CMMapPoint.h"

//#if __has_include("CMMapLauncher+UI_Tools.h")
//#import "CMMapLauncher+UI_Tools.h"
//#endif

@class CMMapPoint;

NS_ASSUME_NONNULL_BEGIN

///---------------------------
/// CMMapLauncher (main class)
///---------------------------

/**
 An updated completion handler from the URL opening method in UIApplication
 */
typedef void(^CMMapLauncherURLHandler)(BOOL success, NSError *_Nullable error);

/**
 CMMapLauncher allows for the launch of Navigation apps easier.
 */
NS_SWIFT_NAME(MapLauncher)
@interface CMMapLauncher : NSProxy

/**
 Enables debug logging which logs resulting URL scheme to console
 */
+ (void)enableLogging;

/**
 Determines whether the given mapping app is installed.

 @param mapApp An enumeration value identifying a mapping application.

 @return YES if the specified app is installed, NO otherwise.
 */
+ (BOOL)isMapAppInstalled:(CMMapApp)mapApp;

/**
 Launches the specified mapping application with directions
 from the user's current location to the specified endpoint.

 @param mapApp  An enumeration value identifying a mapping application.
 @param end     The destination of the desired directions.
 @param handler The return from +[UIApplication canOpenURL]
 */
+ (void)launchApp:(CMMapApp)mapApp
  forDirectionsTo:(CMMapPoint *)end
completionHandler:(CMMapLauncherURLHandler __nullable)handler
NS_SWIFT_NAME(launch(_:to:completionHandler:));

/**
 Launches the specified mapping application with directions
 between the two specified endpoints.

 @param mapApp  An enumeration value identifying a mapping application.
 @param start   The starting point of the desired directions.
 @param end     The destination of the desired directions.
 @param handler The return from +[UIApplication canOpenURL]
 */
+ (void)launchApp:(CMMapApp)mapApp
forDirectionsFrom:(CMMapPoint *)start
               to:(CMMapPoint *)end
completionHandler:(CMMapLauncherURLHandler __nullable)handler
NS_SWIFT_NAME(launch(_:from:to:completionHandler:));

/**
 Launches the specified mapping application with directions
 from the user's current location to the specified endpoint
 and using the specified transport mode.

 @param mapApp          An enumeration value identifying a mapping application.
 @param end             The destination of the desired directions.
 @param directionsMode  The mode of transport required using the CMDirectionMode enumeration
 @param handler         The return from +[UIApplication canOpenURL]
 */
+ (void)launchApp:(CMMapApp)mapApp
  forDirectionsTo:(CMMapPoint *)end
   directionsMode:(CMDirectionMode)directionsMode
completionHandler:(CMMapLauncherURLHandler __nullable)handler
NS_SWIFT_NAME(launch(_:to:by:completionHandler:));

/**
 Launches the specified mapping application with directions
 between the two specified endpoints
 and using the specified transport mode.

 @param mapApp          An enumeration value identifying a mapping application.
 @param start           The starting point of the desired directions.
 @param end             The destination of the desired directions.
 @param directionsMode  Transport mode to use when getting directions.
 @param handler         The return from +[UIApplication canOpenURL]
 */
+ (void)launchApp:(CMMapApp)mapApp
forDirectionsFrom:(CMMapPoint *)start
               to:(CMMapPoint *)end
   directionsMode:(CMDirectionMode)directionsMode
completionHandler:(CMMapLauncherURLHandler __nullable)handler
NS_SWIFT_NAME(launch(_:from:to:by:completionHandler:));

/**
 Launches the specified mapping application with directions
 between the two specified endpoints
 and using the specified transport mode
 and including app-specific extra parameters

 @param mapApp          An enumeration value identifying a mapping application.
 @param start           The starting point of the desired directions.
 @param end             The destination of the desired directions.
 @param directionsMode  Transport mode to use when getting directions.
 @param extras          A key/value map of app-specific extra parameters to pass to launched app
 @param handler         The return from +[UIApplication canOpenURL]
 */
+ (void)launchApp:(CMMapApp)mapApp
forDirectionsFrom:(CMMapPoint *)start
               to:(CMMapPoint *)end
   directionsMode:(CMDirectionMode)directionsMode
           extras:(NSDictionary<NSString *, id> * __nullable)extras
completionHandler:(CMMapLauncherURLHandler __nullable)handler
NS_SWIFT_NAME(launch(_:from:to:by:extras:completionHandler:));

@end

NS_ASSUME_NONNULL_END
