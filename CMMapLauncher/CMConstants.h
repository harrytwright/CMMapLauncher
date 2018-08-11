//
//  NSObject+CMError.h
//  CMMapLauncher
//
//  Created by Harry Wright on 11/08/2018.
//  Copyright © 2018 Citymapper. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// For compatibility with Xcode 7, before extensible string enums were introduced,
#ifdef NS_EXTENSIBLE_STRING_ENUM
#define CM_EXTENSIBLE_STRING_ENUM NS_EXTENSIBLE_STRING_ENUM
#define CM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(_, extensible_string_enum) NS_SWIFT_NAME(extensible_string_enum)
#else
#define CM_EXTENSIBLE_STRING_ENUM
#define CM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(fully_qualified, _) NS_SWIFT_NAME(fully_qualified)
#endif

#if __has_attribute(ns_error_domain) && (!defined(__cplusplus) || !__cplusplus || __cplusplus >= 201103L)
#define CM_ERROR_ENUM(type, name, domain) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wignored-attributes\"") \
NS_ENUM(type, __attribute__((ns_error_domain(domain))) name) \
_Pragma("clang diagnostic pop")
#else
#define CM_ERROR_ENUM(type, name, domain) NS_ENUM(type, name)
#endif

extern NSString * const CMErrorDomain;

///---------------------------
/// CMError (helper enum)
///---------------------------

typedef CM_ERROR_ENUM(NSInteger, CMError, CMErrorDomain) {
    CMErrorAppIsNotInstalled = 404,
    CMErrorAppCouldNotBeOpened = 403,
    CMErrorMKMapItemMethodReturnedFalse = 401,
} NS_SWIFT_NAME(MapLauncher.Error);

///---------------------------
/// CMDirectionMode (helper enum)
///---------------------------

/**
 The mode of transport to be used, is realted to `MKLaunchOptionsDirectionsMode...`
 */
typedef NSString * CMDirectionMode NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(MapLauncher.DirectionMode);

/**
 <#Description#>
 */
extern CMDirectionMode const CMDirectionModeDefault
CM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(CMDirectionModeDefault, default);

/**
 <#Description#>
 */
extern CMDirectionMode const CMDirectionModeDriving
CM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(CMDirectionModeDriving, driving);

/**
 <#Description#>
 */
extern CMDirectionMode const CMDirectionModeWalking
CM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(CMDirectionModeWalking, walking);

/**
 <#Description#>
 */
extern CMDirectionMode const CMDirectionModeTransit
CM_EXTENSIBLE_STRING_ENUM_CASE_SWIFT_NAME(CMDirectionModeTransit, transit);

NS_ASSUME_NONNULL_END
