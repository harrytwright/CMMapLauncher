//
//  CMMapApp.h
//  CMMapLauncher
//
//  Created by Harry Wright on 30/07/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#ifndef CMMapApp_h
#define CMMapApp_h

#import <Foundation/Foundation.h>

// This enumeration identifies the mapping apps
// that this launcher knows how to support.
typedef NS_ENUM(NSInteger, CMMapApp) {
    CMMapAppAppleMaps,  // Preinstalled Apple Maps
    CMMapAppCitymapper,     // Citymapper
    CMMapAppGoogleMaps,     // Standalone Google Maps App
    CMMapAppNavigon,        // Navigon
    CMMapAppTheTransitApp,  // The Transit App
    CMMapAppWaze,           // Waze
    CMMapAppYandex,         // Yandex Navigator
    CMMapAppUber,           // Uber
    CMMapAppTomTom,         // TomTom
    CMMapAppSygic,          // Sygic
    CMMapAppHereMaps,       // HERE Maps
    CMMapAppMoovit          // Moovit
} NS_SWIFT_NAME(MapLauncher.App);

#endif /* CMMapApp_h */
