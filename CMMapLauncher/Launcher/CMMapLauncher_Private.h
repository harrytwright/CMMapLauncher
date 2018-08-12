//
//  CMMapLauncher+Private.h
//  CMMapLauncher
//
//  Created by Harry Wright on 12/08/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#import "CMMapLauncher.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMMapLauncher ()
+ (NSString*)urlPrefixForMapApp:(CMMapApp)mapApp;
+ (BOOL)isMapAppInstalled:(CMMapApp)mapApp withError:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
