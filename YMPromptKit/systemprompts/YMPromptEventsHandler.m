//
//  YMPromptEventsHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptEventsHandler.h"
#import "YMPromptSystemAccessTypes.h"

@implementation YMPromptEventsHandler

+ (NSString *)identifier {
    return kYMPromptAccessTypeEvents;
}

- (YMPromptAuthorizationStatus)authorizationStatus:(EKEntityType)entityType {
    switch ([EKEventStore authorizationStatusForEntityType:entityType]) {
        case EKAuthorizationStatusAuthorized:
            return YMPromptAuthorizationStatusAuthorized;
            
        case EKAuthorizationStatusDenied:
            return YMPromptAuthorizationStatusDenied;
            
        case EKAuthorizationStatusRestricted:
            return YMPromptAuthorizationStatusRestricted;
            
        case EKAuthorizationStatusNotDetermined:
            return YMPromptAuthorizationStatusNotDetermined;
    }
}

- (void)requestAccess:(EKEntityType)entityType onComplete:(void(^)(BOOL))onComplete {
    [[EKEventStore new] requestAccessToEntityType:entityType completion:^(BOOL granted, NSError *error) {
        onComplete(granted);
    }];
}

@end

