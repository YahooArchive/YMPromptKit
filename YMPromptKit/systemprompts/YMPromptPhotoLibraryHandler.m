//
//  YMPromptPhotoLibraryHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptPhotoLibraryHandler.h"
#import "YMPromptSystemAccessTypes.h"
#import <AssetsLibrary/AssetsLibrary.h>


@implementation YMPromptPhotoLibraryHandler

+ (NSString *)identifier {
    return kYMPromptAccessTypePhotoLibrary;
}

- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptAccessMode)modes {
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusAuthorized:
            return YMPromptAuthorizationStatusAuthorized;
            break;
            
        case ALAuthorizationStatusDenied:
            return YMPromptAuthorizationStatusDenied;
            break;
            
        case ALAuthorizationStatusRestricted:
            return YMPromptAuthorizationStatusRestricted;
            break;
            
        case ALAuthorizationStatusNotDetermined:
        default:
            return YMPromptAuthorizationStatusNotDetermined;
            break;
    }
}

- (void)requestAccess:(YMPromptAccessMode)modes onComplete:(void(^)(BOOL))onComplete {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            onComplete(YES);
        }
        *stop = YES;
    } failureBlock:^(NSError *error) {
        onComplete(NO);
    }];
}

@end
