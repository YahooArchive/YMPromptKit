//
//  YMPromptLocationHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptLocationHandler.h"
#import "YMPromptSystemAccessTypes.h"
#import <CoreLocation/CoreLocation.h>


@interface YMPromptLocationHandler () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableArray *pendingLocationCallbacks;
@end


@implementation YMPromptLocationHandler

- (instancetype)init {
    if (self = [super init]) {
        _pendingLocationCallbacks = [NSMutableArray array];
    }
    return self;
}

+ (NSString *)identifier {
    return kYMPromptAccessTypeLocation;
}

- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptLocationOptions)mode {
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusDenied:
            return YMPromptAuthorizationStatusDenied;
            
        case kCLAuthorizationStatusRestricted:
            return YMPromptAuthorizationStatusRestricted;
            
        case kCLAuthorizationStatusNotDetermined:
            return YMPromptAuthorizationStatusNotDetermined;
            
            //case kCLAuthorizationStatusAuthorizedAlways: // iOS 8+
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case kCLAuthorizationStatusAuthorized:
            return YMPromptAuthorizationStatusAuthorized;
#pragma clang diagnostic pop
            
        case kCLAuthorizationStatusAuthorizedWhenInUse: // iOS 8+
            if (mode == YMPromptLocationOptionAppInUse) {
                return YMPromptAuthorizationStatusAuthorized;
            } else {
                return YMPromptAuthorizationStatusDenied;
            }
    }
}

- (void)requestAccess:(YMPromptLocationOptions)mode onComplete:(void(^)(BOOL))onComplete {
    [self.pendingLocationCallbacks addObject:onComplete];
    
    // iOS 8.0 gate
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        if (mode == YMPromptLocationOptionAppInUse) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            [self.locationManager requestAlwaysAuthorization];
        }
    } else { // iOS 7 and earlier
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - Getters

- (CLLocationManager *)locationManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
    });
    return _locationManager;
}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BOOL granted = YES; // Check for failure insteead of success to avoid the iOS 8-only symbol madness.
    if (status == kCLAuthorizationStatusNotDetermined || status == kCLAuthorizationStatusDenied) {
        status = NO;
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.locationManager stopUpdatingLocation]; // For iOS <8x
        
        for (void(^onComplete)(BOOL) in self.pendingLocationCallbacks) {
            onComplete(granted);
        }
        [self.pendingLocationCallbacks removeAllObjects];
    });
}

@end
