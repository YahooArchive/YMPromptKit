//
//  YMPromptNotificationsHandler.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptable.h"

@interface YMPromptNotificationsHandler : NSObject <YMPromptable>

@property (nonatomic) NSString *identifier;

/** See definition in YMPromptable */
- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptNotificationOptions)modes;

/** See definition in YMPromptable */
- (void)requestAccess:(YMPromptNotificationOptions)modes onComplete:(void(^)(BOOL))onComplete;

/** Call this method to record the result of a remote push notification registration attempt. */
- (void)recordNotificationRegistrationResult:(BOOL)didSucceed;

@end
