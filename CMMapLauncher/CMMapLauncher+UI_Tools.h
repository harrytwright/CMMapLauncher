//
//  CMMapLauncher+UI_Tools.h
//  CMMapLauncher
//
//  Created by Harry Wright on 12/08/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#import "CMMapLauncher.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSArray<NSNumber *>* CMMapAppArray;

// Make a FOREACH macro
#define FE_1(WHAT, X) WHAT(X)
#define FE_2(WHAT, X, ...) WHAT(X)FE_1(WHAT, __VA_ARGS__)
#define FE_3(WHAT, X, ...) WHAT(X)FE_2(WHAT, __VA_ARGS__)
#define FE_4(WHAT, X, ...) WHAT(X)FE_3(WHAT, __VA_ARGS__)
#define FE_5(WHAT, X, ...) WHAT(X)FE_4(WHAT, __VA_ARGS__)
#define FE_6(WHAT, X, ...) WHAT(X)FE_5(WHAT, __VA_ARGS__)
#define FE_7(WHAT, X, ...) WHAT(X)FE_6(WHAT, __VA_ARGS__)
#define FE_8(WHAT, X, ...) WHAT(X)FE_7(WHAT, __VA_ARGS__)
#define FE_9(WHAT, X, ...) WHAT(X)FE_8(WHAT, __VA_ARGS__)
#define FE_10(WHAT, X, ...) WHAT(X)FE_9(WHAT, __VA_ARGS__)
#define FE_11(WHAT, X, ...) WHAT(X)FE_10(WHAT, __VA_ARGS__)
#define FE_12(WHAT, X, ...) WHAT(X)FE_11(WHAT, __VA_ARGS__)
//... repeat as needed

#define GET_MACRO(_1,_2,_3,_4,_5,_6,_7,_8,_9,_10,_11,_12,NAME,...) NAME
#define FOR_EACH(action,...) \
GET_MACRO(__VA_ARGS__,FE_12,FE_11,FE_10,FE_9,FE_8,FE_7,FE_6,FE_5,FE_4,FE_3,FE_2,FE_1)(action,__VA_ARGS__)

#define ENCODE(X) @(X),
#define CM_MAP_APPS_CRRATE_ARRAY(...) @[FOR_EACH(ENCODE, __VA_ARGS__)]

@interface CMMapLauncher (UI_Tools)

+ (void)openActionSheetForApps:(CMMapAppArray)apps
            withDirectionsFrom:(CMMapPoint *)from
                            to:(CMMapPoint *)to
                 directionMode:(CMDirectionMode)directionMode
             completionHandler:(CMMapLauncherURLHandler)handler
NS_REFINED_FOR_SWIFT;

//+ (void)test:(CMMapApp[_Nonnull])apps;

@end

NS_ASSUME_NONNULL_END
