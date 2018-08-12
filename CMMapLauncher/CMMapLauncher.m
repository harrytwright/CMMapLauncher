// CMMapLauncher.m
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

#import "CMMapLauncher.h"

#pragma mark Defines
#define OPEN_URL_OR_HANDLE_ERROR(url) \
[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) { \
if (handler) handler(success, success ? NULL : CMMakeError(CMErrorAppCouldNotBeOpened, CMErrorAppCouldNotBeOpenedReason)); \
}];

#define URL_FOR_APP \
[NSMutableString stringWithFormat:@"%@directions?%@", [self urlPrefixForMapApp:mapApp], [params componentsJoinedByString:@"&"]]

#define AddPercentEscape(url)\
[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]

// This cleans up code further down
#define CMMapLauncherMissingAppError \
[NSString stringWithFormat:@"%@ is not available on the device", [CMMapLauncher urlPrefixForMapApp:mapApp]]

#define CMErrorAppCouldNotBeOpenedReason \
[NSString stringWithFormat:@"UIApplication could not open %@", [CMMapLauncher urlPrefixForMapApp:mapApp]]

#define CMMapLauncherAppleMapsFailed \
[NSString stringWithFormat:@"[MKMapItem openMapsWithItems:launchOptions:] failed"]

#pragma mark - Private Method defines

NSError *CMMakeError(CMError error, NSString *reason) {
    NSMutableDictionary<NSErrorUserInfoKey, id> *userInfo = [NSMutableDictionary new];
    [userInfo setObject:reason forKey:NSLocalizedDescriptionKey];

    if (error == CMErrorAppIsNotInstalled) {
        [userInfo setObject:@"No application in the Launch Services database matches the input criteria." forKey:NSUnderlyingErrorKey];
    }

    return [NSError errorWithDomain:CMErrorDomain code:error userInfo:userInfo];
}

@interface CMMapLauncher ()

+ (NSString*)urlPrefixForMapApp:(CMMapApp)mapApp;
+ (NSString*)urlEncode:(NSString*)queryParam;
+ (NSString*)googleMapsStringForMapPoint:(CMMapPoint*)mapPoint;

@end

static NSString*const LOG_TAG = @"CMMapLauncher";
static BOOL debugEnabled;

#pragma mark -

@implementation CMMapLauncher

+ (void)initialize {
    debugEnabled = FALSE;
}

+ (void)enableLogging {
    debugEnabled = TRUE;
    [self logDebug:@"Debug logging enabled"];
}

+ (void)logDebug:(NSString*)msg {
    if(debugEnabled) {
        NSLog(@"%@: %@", LOG_TAG, msg);
    }
}

+ (void)logDebugURI:(NSString*)msg {
    [self logDebug:[NSString stringWithFormat:@"Launching URI: %@", msg]];
}

+ (NSString*)urlPrefixForMapApp:(CMMapApp)mapApp {
    switch (mapApp) {
        case CMMapAppAppleMaps:
            return nil;
        case CMMapAppCitymapper:
            return @"citymapper://";
        case CMMapAppGoogleMaps:
            return @"comgooglemaps://";
        case CMMapAppNavigon:
            return @"navigon://";
        case CMMapAppTheTransitApp:
            return @"transit://";
        case CMMapAppWaze:
            return @"waze://";
        case CMMapAppYandex:
            return @"yandexnavi://";
        case CMMapAppUber:
            return @"uber://";
        case CMMapAppTomTom:
            return @"tomtomhome://";
        case CMMapAppSygic:
            return @"com.sygic.aura://";
        case CMMapAppHereMaps:
            return @"here-route://";
        case CMMapAppMoovit:
            return @"moovit://";
    }
}

+ (NSString*)urlEncode:(NSString*)queryParam {
    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    //    NSString* newString = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)queryParam, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);

    NSCharacterSet *escapes = [NSCharacterSet characterSetWithCharactersInString:@"!*'();:@&=+$,/?%#[]"];
    NSString *newString = [queryParam stringByAddingPercentEncodingWithAllowedCharacters:escapes];

    if (newString) {
        return newString;
    }

    return @"";
}

+ (NSString*)extrasToQueryParams:(NSDictionary*)extras {
    NSString* queryParams = @"";
    NSEnumerator* keyEnum = [extras keyEnumerator];
    id key;
    while ((key = [keyEnum nextObject])) {
        id value = [extras objectForKey:key];
        queryParams = [NSString stringWithFormat:@"%@&%@=%@)", queryParams, key, [self urlEncode:value]];
    }
    return queryParams;
}

+ (NSString*)googleMapsStringForMapPoint:(CMMapPoint*)mapPoint {
    if (!mapPoint) {
        return @"";
    }

    if (mapPoint.isCurrentLocation && mapPoint.coordinate.latitude == 0.0 && mapPoint.coordinate.longitude == 0.0) {
        return @"";
    }

    if (mapPoint.name) {
        return [NSString stringWithFormat:@"%f,%f", mapPoint.coordinate.latitude, mapPoint.coordinate.longitude];
    }

    return [NSString stringWithFormat:@"%f,%f", mapPoint.coordinate.latitude, mapPoint.coordinate.longitude];
}

typedef NS_ENUM(NSInteger, CMMapLauncherInstalledState) {
    CMMapLauncherInstalledStateUninstalled,
    CMMapLauncherInstalledStateUnknown,
    CMMapLauncherInstalledStateInstalled,
};

/**
 A state checker for apps, just keeps the code cleaner
 */
+ (CMMapLauncherInstalledState)getStateOfMapApp:(CMMapApp)mapApp {
    if (mapApp == CMMapAppAppleMaps) {
        return CMMapLauncherInstalledStateInstalled;
    }

    NSString* urlPrefix = [CMMapLauncher urlPrefixForMapApp:mapApp];
    if (!urlPrefix) {
        [NSException raise:NSInvalidArgumentException format:@"This method was passed an invalid map application"];
    }

    NSArray<NSString *>* LSApplicationQueriesSchemes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSApplicationQueriesSchemes"];
    if (!LSApplicationQueriesSchemes || ![LSApplicationQueriesSchemes containsObject:[urlPrefix stringByReplacingOccurrencesOfString:@"://" withString:@""]]) {
        return CMMapLauncherInstalledStateUnknown;
    }

    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlPrefix]] ? CMMapLauncherInstalledStateInstalled : CMMapLauncherInstalledStateUninstalled;
}

/**
 This method just allows me to produce the correct end result error for the user.
 */
+ (BOOL)isMapAppInstalled:(CMMapApp)mapApp withError:(NSError **)error {
    CMMapLauncherInstalledState state = [self getStateOfMapApp:mapApp];

    switch (state) {
        case CMMapLauncherInstalledStateInstalled:
        {
            [self logDebug:[NSString stringWithFormat:@"%@ is installed on the device", [CMMapLauncher urlPrefixForMapApp:mapApp]]];
            return YES;
            break;
        }
        case CMMapLauncherInstalledStateUninstalled:
        {
            [self logDebug:[NSString stringWithFormat:@"%@ is not installed on the device", [CMMapLauncher urlPrefixForMapApp:mapApp]]];
            return NO;
            break;
        }
        case CMMapLauncherInstalledStateUnknown:
        {
            NSString* urlPrefix = [CMMapLauncher urlPrefixForMapApp:mapApp];
            NSString *errorMessage = [NSString stringWithFormat:@"This app is not allowed to query for scheme \"%@\"", urlPrefix];

            [self logDebug:errorMessage];
            if (error) { *error = CMMakeError(CMErrorLSApplicationQueriesSchemesIsMissing, errorMessage); }

            return NO;
            break;
        }
    }
}

#pragma mark - CMMapLauncher Public Methods

+ (BOOL)isMapAppInstalled:(CMMapApp)mapApp {
    return [CMMapLauncher isMapAppInstalled:mapApp withError:NULL];
}

+ (void)launchApp:(CMMapApp)mapApp
  forDirectionsTo:(CMMapPoint *)end
completionHandler:(CMMapLauncherURLHandler)handler
{
    [CMMapLauncher launchApp:mapApp forDirectionsTo:end directionsMode:CMDirectionModeDefault completionHandler:handler];
}

+ (void)launchApp:(CMMapApp)mapApp
forDirectionsFrom:(CMMapPoint *)start
               to:(CMMapPoint *)end
completionHandler:(CMMapLauncherURLHandler)handler
{
    [CMMapLauncher launchApp:mapApp forDirectionsFrom:start to:end directionsMode:CMDirectionModeDefault completionHandler:handler];
}

+ (void)launchApp:(CMMapApp)mapApp
  forDirectionsTo:(CMMapPoint *)end
   directionsMode:(CMDirectionMode)directionsMode
completionHandler:(CMMapLauncherURLHandler)handler
{
    [CMMapLauncher launchApp:mapApp forDirectionsFrom:[CMMapPoint currentLocation] to:end directionsMode:directionsMode completionHandler:handler];
}

+ (void)launchApp:(CMMapApp)mapApp
forDirectionsFrom:(CMMapPoint *)start
               to:(CMMapPoint *)end
   directionsMode:(CMDirectionMode)directionsMode
completionHandler:(CMMapLauncherURLHandler)handler
{
    [CMMapLauncher launchApp:mapApp forDirectionsFrom:start to:end directionsMode:directionsMode extras:NULL completionHandler:handler];
}

/// Main method
+ (void)launchApp:(CMMapApp)mapApp
forDirectionsFrom:(CMMapPoint *)start
               to:(CMMapPoint *)end
   directionsMode:(CMDirectionMode)directionsMode
           extras:(NSDictionary<NSString *, id> *)extras
completionHandler:(CMMapLauncherURLHandler)handler
{
    NSError *error;
    if (![CMMapLauncher isMapAppInstalled:mapApp withError:&error]) {
        handler(NO, (error != NULL) ? error : CMMakeError(CMErrorAppIsNotInstalled, CMMapLauncherMissingAppError));
        return;
    }

    switch (mapApp) {
        case CMMapAppAppleMaps:
        {
            // Check for iOS 6
            Class mapItemClass = [MKMapItem class];
            if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
                NSDictionary* launchOptions;
                launchOptions = @{MKLaunchOptionsDirectionsModeKey: directionsMode ?: MKLaunchOptionsDirectionsModeDriving};

                if (extras) {
                    NSEnumerator* keyEnum = [extras keyEnumerator];
                    id key;
                    while ((key = [keyEnum nextObject])) {
                        launchOptions = @{key: [extras objectForKey:key]};
                    }
                }

                [self logDebug:[NSString stringWithFormat:@"Launching Apple Maps from: %@ to: %@", start, end]];

                BOOL success = [MKMapItem openMapsWithItems:@[start.MKMapItem, end.MKMapItem] launchOptions:launchOptions];
                handler(success, success ? NULL : CMMakeError(CMErrorMKMapItemMethodReturnedFalse, CMMapLauncherAppleMapsFailed));
            } else {
                [NSException exceptionWithName:NSGenericException reason:@"Invalid iOS, not supporting iOS 9.3 or less" userInfo:NULL];
            }
            break;
        }
        case CMMapAppGoogleMaps:
        {
            NSMutableString* url = [[NSString stringWithFormat:@"%@?saddr=%@&daddr=%@",
                                     [self urlPrefixForMapApp:CMMapAppGoogleMaps],
                                     [CMMapLauncher googleMapsStringForMapPoint:start],
                                     [CMMapLauncher googleMapsStringForMapPoint:end]
                                     ] mutableCopy];

            if (directionsMode) {
                [url appendFormat:@"&directionsmode=%@", [directionsMode stringByReplacingOccurrencesOfString:@"MKLaunchOptionsDirectionsMode" withString:@""]];
            }

            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppCitymapper:
        {
            NSMutableArray* params = [NSMutableArray arrayWithCapacity:10];
            if (start && !start.isCurrentLocation) {
                [params addObject:[NSString stringWithFormat:@"startcoord=%f,%f", start.coordinate.latitude, start.coordinate.longitude]];
                if (start.name) {
                    [params addObject:[NSString stringWithFormat:@"startname=%@", [CMMapLauncher urlEncode:start.name]]];
                }
                if (start.address) {
                    [params addObject:[NSString stringWithFormat:@"startaddress=%@", [CMMapLauncher urlEncode:start.address]]];
                }
            }
            if (end && !end.isCurrentLocation) {
                [params addObject:[NSString stringWithFormat:@"endcoord=%f,%f", end.coordinate.latitude, end.coordinate.longitude]];
                if (end.name) {
                    [params addObject:[NSString stringWithFormat:@"endname=%@", [CMMapLauncher urlEncode:end.name]]];
                }
                if (end.address) {
                    [params addObject:[NSString stringWithFormat:@"endaddress=%@", [CMMapLauncher urlEncode:end.address]]];
                }
            }

            NSMutableString* url = URL_FOR_APP;
            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppTheTransitApp:
        {
            // http://thetransitapp.com/developers

            NSMutableArray* params = [NSMutableArray arrayWithCapacity:2];
            if (start && !start.isCurrentLocation) {
                [params addObject:[NSString stringWithFormat:@"from=%f,%f", start.coordinate.latitude, start.coordinate.longitude]];
            }
            if (end && !end.isCurrentLocation) {
                [params addObject:[NSString stringWithFormat:@"to=%f,%f", end.coordinate.latitude, end.coordinate.longitude]];
            }

            NSMutableString* url = URL_FOR_APP;
            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppNavigon:
        {
            // http://www.navigon.com/portal/common/faq/files/NAVIGON_AppInteract.pdf

            NSString* name = @"Destination";  // Doc doesn't say whether name can be omitted
            if (end.name) {
                name = end.name;
            }

            NSMutableString* url = [NSMutableString stringWithFormat:@"%@coordinate/%@/%f/%f",
                                    [self urlPrefixForMapApp:CMMapAppNavigon],
                                    [CMMapLauncher urlEncode:name], end.coordinate.longitude, end.coordinate.latitude];
            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppWaze:
        {
            NSMutableString* url = [NSMutableString stringWithFormat:@"%@?ll=%f,%f&navigate=yes",
                                    [self urlPrefixForMapApp:CMMapAppWaze],
                                    end.coordinate.latitude, end.coordinate.longitude];
            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppYandex:
        {
            NSMutableString* url = nil;
            if (start.isCurrentLocation) {
                url = [NSMutableString stringWithFormat:@"%@build_route_on_map?lat_to=%f&lon_to=%f",
                       [self urlPrefixForMapApp:CMMapAppYandex],
                       end.coordinate.latitude, end.coordinate.longitude];
            } else {
                url = [NSMutableString stringWithFormat:@"%@build_route_on_map?lat_to=%f&lon_to=%f&lat_from=%f&lon_from=%f",
                       [self urlPrefixForMapApp:CMMapAppYandex],
                       end.coordinate.latitude, end.coordinate.longitude, start.coordinate.latitude, start.coordinate.longitude];
            }

            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppUber:
        {
            NSMutableString* url = nil;
            if (start.isCurrentLocation) {
                url = [NSMutableString stringWithFormat:@"%@?action=setPickup&pickup=my_location&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@",
                       [self urlPrefixForMapApp:CMMapAppUber],
                       end.coordinate.latitude,
                       end.coordinate.longitude,
                       AddPercentEscape(end.name)];
            } else {
                url = [NSMutableString stringWithFormat:@"%@?action=setPickup&pickup[latitude]=%f&pickup[longitude]=%f&pickup[nickname]=%@&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@",
                       [self urlPrefixForMapApp:mapApp],
                       start.coordinate.latitude,
                       start.coordinate.longitude,
                       AddPercentEscape(start.name),
                       end.coordinate.latitude,
                       end.coordinate.longitude,
                       AddPercentEscape(end.name)];
            }

            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppTomTom:
        {
            NSMutableString* url = [NSMutableString stringWithFormat:@"tomtomhome:geo:action=navigateto&lat=%f&long=%f&name=%@",
                                    end.coordinate.latitude,
                                    end.coordinate.longitude,
                                    AddPercentEscape(end.name)];
            if (extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppSygic:
        {
            NSString* separator = @"%7C";
            NSMutableString* url = [NSMutableString stringWithFormat:@"%@coordinate%@%f%@%f%@%@",
                                    [self urlPrefixForMapApp:mapApp],
                                    separator,
                                    end.coordinate.longitude,
                                    separator,
                                    end.coordinate.latitude,
                                    separator,
                                    [directionsMode isEqual:MKLaunchOptionsDirectionsModeWalking] ? @"walk" : @"drive"];

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppHereMaps:
        {
            NSMutableString* startParam;
            if (start.isCurrentLocation) {
                startParam = (NSMutableString*) @"mylocation";
            } else {
                startParam = [NSMutableString stringWithFormat:@"%f,%f",
                              start.coordinate.latitude, start.coordinate.longitude];

                if (start.name) {
                    [startParam appendFormat:@",%@", AddPercentEscape(start.name)];
                }
            }

            NSMutableString* destParam = [NSMutableString stringWithFormat:@"%f,%f",
                                          end.coordinate.latitude, end.coordinate.longitude];

            if (end.name) {
                [destParam appendFormat:@",%@", AddPercentEscape(end.name)];
            }

            NSMutableString* url = [NSMutableString stringWithFormat:@"%@%@/%@",
                                    [self urlPrefixForMapApp:mapApp],
                                    startParam,
                                    destParam];

            if (extras) {
                [url appendFormat:@"?%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
        case CMMapAppMoovit:
        {
            NSMutableString* url = [NSMutableString stringWithFormat:@"%@directions", [self urlPrefixForMapApp:CMMapAppMoovit]];

            [url appendFormat:@"?dest_lat=%f&dest_lon=%f", end.coordinate.latitude, end.coordinate.longitude];

            if (end.name) {
                [url appendFormat:@"&dest_name=%@", AddPercentEscape(end.name)];
            }

            //            NSMutableString* startParam;
            if (!start.isCurrentLocation) {
                [url appendFormat:@"&orig_lat=%f&orig_lon=%f",
                 start.coordinate.latitude, start.coordinate.longitude];

                if (start.name) {
                    [url appendFormat:@"&orig_name=%@", AddPercentEscape(start.name)];
                }
            }

            if(extras) {
                [url appendFormat:@"%@", [self extrasToQueryParams:extras]];
            }

            [self logDebugURI:url];
            OPEN_URL_OR_HANDLE_ERROR(url)
            break;
        }
    }
}

@end
