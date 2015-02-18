//
//  AppDelegate.m
//  YMPromptKitDemo
//
//  Created by Adam Kaplan on 1/7/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "AppDelegate.h"
#import <YMPromptKit/YMPromptKit.h>
#import <EventKit/EventKit.h>

@interface AppDelegate () <YMPromptManagerDataSource, YMPromptManagerDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _promptManager = [YMPromptManager createPromptManager];
    self.promptManager.dataSource = self;
    self.promptManager.delegate = self;
    
    NSInteger lastSessionNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"session_number"];
    [[NSUserDefaults standardUserDefaults] setInteger:lastSessionNumber + 1 forKey:@"session_number"];
    _sessionNumber = @(lastSessionNumber + 1);
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"Registered user notification settings %d", (int)notificationSettings.types);

    BOOL success = (notificationSettings.types != UIUserNotificationTypeNone);
    [self.promptManager recordNotificationRegistrationResult:success];
    if (success) {
        // Permission was granted, register for remote notifications
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for remote notifications with error: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Registered for remote notifications");
}

#pragma mark - YMPromptManagerDataSource

- (YMPrompt *)promptManager:(YMPromptManager *)manager promptForAccessType:(YMPromptAccessType)access modes:(YMPromptAccessMode)modes {
    UIImage *image = [UIImage imageNamed:@"push-notification.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 150, 150);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    YMPrompt *prompt;
    if (access == kYMPromptAccessTypePhotoLibrary) {
        prompt = [YMPrompt promptWithTitle:@"Photos Access"
                                   message:@"Allow access to photo library?"
                                grantTitle:nil
                                 denyTitle:nil
                               contentView:imageView];
    }
    else if (access == kYMPromptAccessTypeEvents) {
        
        NSString *message = @"???";
        if (modes == EKEntityTypeEvent) {
            message = @"Events";
        } else if (modes == EKEntityTypeReminder) {
            message = @"Reminders";
        }
        prompt = [YMPrompt promptWithTitle:@"Access Needed"
                                   message:message
                                grantTitle:nil denyTitle:nil contentView:nil];
    }
    else if (access == kYMPromptAccessTypeMicrophone) {
        
        prompt = [YMPrompt promptWithTitle:@"Microphone Access"
                                   message:@"We need to record stuff"
                                grantTitle:nil denyTitle:nil contentView:nil];
    }
    else if (access == kYMPromptAccessTypeCamera) {
        
        prompt = [YMPrompt promptWithTitle:@"Camera"
                                   message:@"I want to watch you."
                                grantTitle:@"😀"
                                 denyTitle:@"😵"
                               contentView:nil];
    }
    else if (access == kYMPromptAccessTypeContacts) {
        
        prompt = [YMPrompt promptWithTitle:@"Gimme some contacts!!!"
                                   message:nil
                                grantTitle:nil denyTitle:nil contentView:nil];
    }
    else if (access == kYMPromptAccessTypeLocation) {
        
        prompt = [YMPrompt promptWithTitle:@"Location Required"
                                   message:@"Allow access? :)"
                                grantTitle:@"OK" denyTitle:@"No" contentView:nil];
    }
    else if (access == kYMPromptAccessTypeNotifications) {
        
        prompt = [YMPrompt promptWithTitle:@"YMPromptKit"
                                   message:@"iOS Soft Prompt Toolkit"
                                grantTitle:@"😀"
                                 denyTitle:@"😵"
                               contentView:nil];
    }
    return prompt;
}

#pragma mark - YMPromptManagerDelegate

- (BOOL)promptManager:(YMPromptManager *)manager shouldRequestAccessType:(YMPromptAccessType)accessType
                modes:(YMPromptAccessMode)modes {
    
    NSArray *promptLog = [manager.log promptHistory:accessType];
    
    if (promptLog.count > 3) {
        return NO;                              // enforce the request limit
    } else if (promptLog.count) {
        NSDictionary *dict = promptLog[0];     // data for the most recent history entry
        NSDate *lastPromptDate = dict[kYMPromptLogDateKey];
        NSTimeInterval interval = -3600 * 48;   // 2 days, in seconds
        
        if (!lastPromptDate) {
            return YES;
        }
        
        if ([lastPromptDate timeIntervalSinceNow] > interval) {
            return NO;                          // enforce the quiet period
        } else {
#pragma Example:
            NSDictionary *appData = dict[kYMPromptLogUserInfoKey];
            NSInteger lastSessionNum = [(NSNumber*)appData[@"session_number"] integerValue];
            NSInteger sessionNum = [self.sessionNumber integerValue];
            
            if (sessionNum < lastSessionNum + 5) {
                return NO;                      // enforce minimum sessions betwen prompting
            }
        }
    }
    
    return YES;                                 // OK to display prompt!
}

- (NSDictionary *)promptManager:(YMPromptManager *)manager
          willRequestAccessType:(YMPromptAccessType)accessType
                          modes:(YMPromptAccessMode)modes {
    
    NSNumber *sessionNum = self.sessionNumber;
    
    return @{ @"session_number":  sessionNum };
}

@end
