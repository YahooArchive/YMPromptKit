//
//  YMPromptNotificationsHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptNotificationsHandler.h"
#import "YMPromptSystemAccessTypes.h"


@interface YMPromptNotificationsHandler ()
@property (nonatomic) NSMutableArray *pendingNotificationsCallbacks;
@end


@implementation YMPromptNotificationsHandler

+ (NSString *)identifier {
    return kYMPromptAccessTypeNotifications;
}

- (instancetype)init {
    if (self = [super init]) {
        _pendingNotificationsCallbacks = [NSMutableArray array];
    }
    return self;
}

- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptNotificationOptions)modes {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(currentUserNotificationSettings)]) { // iOS 8
        if ([app currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
            return YMPromptAuthorizationStatusNotDetermined;
        } else {
            return YMPromptAuthorizationStatusAuthorized;
        }
    } else { // pre-iOS 8
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (0 == (app.enabledRemoteNotificationTypes & UIRemoteNotificationTypeNone)) {
            return YMPromptAuthorizationStatusNotDetermined;
        } else {
            return YMPromptAuthorizationStatusAuthorized;
        }
#pragma clang diagnostic pop
    }
}

- (void)requestAccess:(YMPromptNotificationOptions)modes onComplete:(void(^)(BOOL))onComplete {
    if (onComplete) {
        [_pendingNotificationsCallbacks addObject:onComplete];
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    if ([app respondsToSelector:@selector(registerForRemoteNotifications)]) { // iOS 8
        UIUserNotificationType userNotificationTypes = [self _userNotificationTypeForAccessModes:modes];
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [app registerUserNotificationSettings:settings];
    } else { // iOS 7
        // Hack alert: iOS 7 calls no methods when a user declines the push popup. To figure out when to
        // send the success/failure callbacks, one trick is to observe that the app became active when
        // the popup was dismissed. It will probably work most in more situations and there is no alternative.
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          if (weakSelf) {
                                                              [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
                                                              BOOL authorized = [weakSelf authorizationStatus:modes] == YMPromptAuthorizationStatusAuthorized;
                                                              [weakSelf recordNotificationRegistrationResult:authorized];
                                                          }
                                                      }];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType remoteNotificationType = [self _remoteNotificationTypeForAccessModes:modes];
        [app registerForRemoteNotificationTypes:remoteNotificationType];
#pragma clang diagnostic pop
    }
}

- (void)recordNotificationRegistrationResult:(BOOL)didSucceed {
    for (void(^onComplete)(BOOL) in self.pendingNotificationsCallbacks) {
        NSAssert(onComplete, @"Null completion callback for notification permission request");
        if (onComplete) { // extra cautious
            onComplete(didSucceed);
        }
    }
    [self.pendingNotificationsCallbacks removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Helpers

- (UIRemoteNotificationType)_remoteNotificationTypeForAccessModes:(YMPromptNotificationOptions)modes {
    UIRemoteNotificationType notificationType = UIRemoteNotificationTypeNone;
    if ((modes & YMPromptNotificationOptionTypeAlert) == YMPromptNotificationOptionTypeAlert) {
        notificationType |= UIRemoteNotificationTypeAlert;
    }
    if ((modes & YMPromptNotificationOptionTypeBadge) == YMPromptNotificationOptionTypeBadge) {
        notificationType |= UIRemoteNotificationTypeBadge;
    }
    if ((modes & YMPromptNotificationOptionTypeSound) == YMPromptNotificationOptionTypeSound) {
        notificationType |= UIRemoteNotificationTypeSound;
    }
    if ((modes & YMPromptNotificationOptionTypeNewsstandContentAvailability) == YMPromptNotificationOptionTypeNewsstandContentAvailability) {
        notificationType |= UIRemoteNotificationTypeNewsstandContentAvailability;
    }
    return notificationType;
}

- (UIUserNotificationType)_userNotificationTypeForAccessModes:(YMPromptNotificationOptions)modes {
    UIUserNotificationType notificationType = UIUserNotificationTypeNone;
    if ((modes & YMPromptNotificationOptionTypeAlert) == YMPromptNotificationOptionTypeAlert) {
        notificationType |= UIUserNotificationTypeAlert;
    }
    if ((modes & YMPromptNotificationOptionTypeBadge) == YMPromptNotificationOptionTypeBadge) {
        notificationType |= UIUserNotificationTypeBadge;
    }
    if ((modes & YMPromptNotificationOptionTypeSound) == YMPromptNotificationOptionTypeSound) {
        notificationType |= UIUserNotificationTypeSound;
    }
    return notificationType;
}

@end
