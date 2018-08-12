//
//  CMMapLauncher+UI_Tools.m
//  CMMapLauncher
//
//  Created by Harry Wright on 12/08/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CMMapLauncher+UI_Tools.h"
#import "CMMapLauncher_Private.h"

#define CREATE_ACTION(NAME, ...)\
[UIAlertAction actionWithTitle:NAME style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) \
    __VA_ARGS__ \
]

#define CREATE_ALERT_CONTROLLER \
[UIAlertController alertControllerWithTitle:NULL message:NULL preferredStyle:UIAlertControllerStyleActionSheet];

#define ROOT_VIEW_CONTROLLER \
[UIApplication sharedApplication].keyWindow.rootViewController

@implementation CMMapLauncher (UI_Tools)

+ (void)openActionSheetForApps:(CMMapAppArray)apps
            withDirectionsFrom:(CMMapPoint *)from
                            to:(CMMapPoint *)to
                 directionMode:(CMDirectionMode)directionMode
             completionHandler:(CMMapLauncherURLHandler)handler
{
    if (apps.count == 0) {
        return;
    }

    UIAlertController *controller = CREATE_ALERT_CONTROLLER;

    for (NSNumber *value in apps) {
        NSString *_key = [CMMapLauncher urlPrefixForMapApp:value.integerValue];
        NSString *key = [_key stringByReplacingOccurrencesOfString:@"://" withString:@""].capitalizedString;

        UIAlertAction *action = CREATE_ACTION(key, {
            [CMMapLauncher launchApp:value.integerValue
                 forDirectionsFrom:from
                                to:to
                    directionsMode:directionMode
                 completionHandler:handler];
        });
        
        [controller addAction:action];
    }

    [ROOT_VIEW_CONTROLLER presentViewController:controller animated:true completion:NULL];
}

@end
