//
//  NSObject+CMError.m
//  CMMapLauncher
//
//  Created by Harry Wright on 11/08/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#import "CMConstants.h"
#import <MapKit/MapKit.h>

/// MKLaunchOptionsDirectionsMode*** are literally what there constant is ??
CMDirectionMode const CMDirectionModeDefault = @"MKLaunchOptionsDirectionsModeDefault";

CMDirectionMode const CMDirectionModeDriving = @"MKLaunchOptionsDirectionsModeDriving";

CMDirectionMode const CMDirectionModeWalking = @"MKLaunchOptionsDirectionsModeWalking";

CMDirectionMode const CMDirectionModeTransit = @"MKLaunchOptionsDirectionsModeTransit";

NSString * const CMErrorDomain = @"CMMapLauncher";
