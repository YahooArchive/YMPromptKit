//
//  YMPromptManager.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/7/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptManager.h"
#import "YMPrompt.h"
#import "YMPromptLog.h"

#import "YMPromptPhotoLibraryHandler.h"
#import "YMPromptLocationHandler.h"
#import "YMPromptEventsHandler.h"
#import "YMPromptAddressBookHandler.h"
#import "YMPromptMicrophoneHandler.h"
#import "YMPromptNotificationsHandler.h"
#import "YMPromptCameraHandler.h"

#ifdef YMPROMPTKIT_SDCALERT_ENABLE
#import <SDCAlertView/SDCAlertController.h>
#import "SDCAlertController+YMPromptManagerLayout.h"
#elif YMPROMPTKIT_NATIVEALERT_ENABLE
#import <UIKit/UIKit.h>
#import "UIViewController+YMPromptHelpers.h"
#endif

void(^fallbackOnCompleteHandler)(BOOL,BOOL,YMPromptAuthorizationStatus) = ^(BOOL a,BOOL b, YMPromptAuthorizationStatus c) { };


@interface YMPromptManager ()
@property (nonatomic) NSMutableDictionary *promptHandlers;
@end

#ifndef YMPROMPTKIT_SDCALERT_ENABLE // iOS 7-only delegate and properties
@interface YMPromptManager () <UIAlertViewDelegate>
@property (nonatomic, strong) void(^onDeny)(void);
@property (nonatomic, strong) void(^onGrant)(void);
@end
#endif

@implementation YMPromptManager

+ (instancetype)createPromptManager {
    YMPromptManager *manager = [[self alloc] init];
    manager.log = [YMPromptLog mainLog];
    
    [manager registerPrompt:[YMPromptPhotoLibraryHandler new]];
    [manager registerPrompt:[YMPromptLocationHandler new]];
    [manager registerPrompt:[YMPromptEventsHandler new]];
    [manager registerPrompt:[YMPromptAddressBookHandler new]];
    [manager registerPrompt:[YMPromptMicrophoneHandler new]];
    [manager registerPrompt:[YMPromptNotificationsHandler new]];
    [manager registerPrompt:[YMPromptCameraHandler new]];
    
    return manager;
}

+ (instancetype)promptManager {
    return [self createPromptManager];
}

- (instancetype)init {
    if (self = [super init]) {
        _promptHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)requestAccess:(YMPromptAccessType)type modes:(YMPromptAccessMode)modes completionHandler:(YMPromptKitCompletionHandler)onComplete {
    
    if (!onComplete) { // easier to check this once than everywhere.
        onComplete = fallbackOnCompleteHandler;
    }
    
    YMPromptAuthorizationStatus existingStatus = [self _authorizationStatus:type modes:modes];
    if (existingStatus != YMPromptAuthorizationStatusNotDetermined) {
        // Always trigger the hard prompt code paths. No hard prompt should be shown because permission
        // is already granted. This helps to ensure that weird context-specific flows are always triggered
        // such as the `didRegisterUserNotificationSettings` callback in the AppDelegate.
        [self _requestAccess:type modes:modes onComplete:nil];
        return onComplete(NO, NO, existingStatus); // indicate success
    }
    
    if ([self.delegate respondsToSelector:@selector(promptManager:shouldRequestAccessType:modes:)]
        && ![self.delegate promptManager:self shouldRequestAccessType:type modes:modes]) {
        return; // app delegate callback decided not to show the prompt at this moment - no callback in this case
    }
    
    [self showSoftPromptType:type modes:modes onComplete:^(BOOL softPromptAccepted, BOOL osPromptAccepted) {
        onComplete(softPromptAccepted, osPromptAccepted, [self _authorizationStatus:type modes:modes]);
    }];
}

- (void)showSoftPromptType:(YMPromptAccessType)type modes:(YMPromptAccessMode)modes onComplete:(void(^)(BOOL,BOOL))onComplete {
    NSParameterAssert(onComplete);
    
    YMPrompt *prompt = [self.dataSource promptManager:self promptForAccessType:type modes:modes];
    __weak YMPromptManager *weakSelf = self;

    void(^preShowBlock)(void) = ^{
        NSDictionary *contextParams;
        if ([weakSelf.delegate respondsToSelector:@selector(promptManager:willRequestAccessType:modes:)]) {
            contextParams = [self.delegate promptManager:weakSelf willRequestAccessType:type modes:modes];
        }
        [weakSelf.log markSoftPromptShown:type userInfo:contextParams];
    };
    
    void(^denyBlock)(void) = ^{
        onComplete(NO, NO);
    };

    void(^grantBlock)(void) = ^{
        [weakSelf _requestAccess:type modes:modes onComplete:^(BOOL accepted) {
            onComplete(YES, accepted);
        }];
    };
    
    [self showSoftPrompt:prompt beforePrompt:preShowBlock onDeny:denyBlock onGrant:grantBlock];
}

#ifdef YMPROMPTKIT_SDCALERT_ENABLE  /*********** SDCAlertView is available ***********/

- (void)showSoftPrompt:(YMPrompt *)prompt beforePrompt:(void(^)())beforeShow onDeny:(void(^)())onDeny onGrant:(void(^)())onGrant {
    NSParameterAssert(prompt);
    NSParameterAssert(beforeShow);
    NSParameterAssert(onDeny);
    NSParameterAssert(onGrant);
    
    SDCAlertController *alert = [SDCAlertController YM_alertControllerWithPrompt:prompt denyHandler:^(SDCAlertAction *action) {
        onDeny();
    } grantHandler:^(SDCAlertAction *action) {
        onGrant();
    }];
    
    beforeShow();
    
    if (self.presentingViewController && !alert.legacyAlertView) {
        [self.presentingViewController presentViewController:alert animated:YES completion:nil];
    } else {
        [alert presentWithCompletion:nil];
    }
}

#elif YMPROMPTKIT_NATIVEALERT_ENABLE  /********* SDCAlertView is NOT available *********/

// Use iOS 7 or 8 native alerting system. No support for custom alert views.
- (void)showSoftPrompt:(YMPrompt *)prompt beforePrompt:(void(^)())beforeShow onDeny:(void(^)())onDeny onGrant:(void(^)())onGrant {
    NSParameterAssert(prompt);
    NSParameterAssert(beforeShow);
    NSParameterAssert(onDeny);
    NSParameterAssert(onGrant);
    
    // iOS 8.0+
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt.title
                                                                       message:prompt.message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        __weak UIAlertController *weakAlert = alert;
        
        UIAlertAction *denyAction = [UIAlertAction actionWithTitle:prompt.denyButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:onDeny];
            onDeny();
        }];
        
        UIAlertAction *grantAction = [UIAlertAction actionWithTitle:prompt.grantButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakAlert dismissViewControllerAnimated:YES completion:onGrant];
            onGrant();
        }];
        
        [alert addAction:denyAction];
        [alert addAction:grantAction];
        
        beforeShow();
        
        UIViewController *presentingController = self.presentingViewController ?: [UIViewController YMPrompt_currentViewController];
        [presentingController presentViewController:alert animated:YES completion:nil];
    }
    else { // iOS 7
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prompt.title
                                                        message:prompt.message
                                                       delegate:self
                                              cancelButtonTitle:prompt.denyButtonTitle
                                              otherButtonTitles:prompt.grantButtonTitle, nil];
        self.onDeny = onDeny;
        self.onGrant = onGrant;
        beforeShow();
        [alert show];
    }
}

// iOS 7 delegate methods
- (void)alertViewCancel:(UIAlertView *)alertView {
    // Clear out the internal state in advance of triggering callback in case the client triggers
    // another soft prompt in the callback stack
    // This method is called when the system or app cancels an alert.
    void(^onDeny)() = self.onDeny;
    self.onGrant = nil;
    self.onDeny = nil;
    if (onDeny) {
        onDeny();
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    void(^action)();
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        action = self.onDeny ?: self.onDeny;
    } else {
        action = self.onGrant ?: self.onGrant;
    }

    // Clear out the internal state in advance of triggering callback in case the client triggers
    // another soft prompt in the callback stack
    self.onGrant = nil;
    self.onDeny = nil;
    if (action) {
        action();
    }
}

#else

- (void)showSoftPrompt:(YMPrompt *)prompt beforePrompt:(void(^)())beforeShow onDeny:(void(^)())onDeny onGrant:(void(^)())onGrant {
    // This stub exists to permit the Pods Core subspec to compile without errors on `pod lib lint`
    NSAssert(false, @"Invalid code path. Must define either `YMPROMPTKIT_SDCALERT_ENABLE` or `YMPROMPTKIT_NATIVEALERT_ENABLE`");
}

#endif                              /********* End SDCAlertView conditional *********/

- (void)recordNotificationRegistrationResult:(BOOL)didSucceed {
    YMPromptNotificationsHandler *handler = self.promptHandlers[[YMPromptNotificationsHandler identifier]];
    [handler recordNotificationRegistrationResult:didSucceed];
}

#pragma mark - Prompt Registration

- (NSArray *)registeredPrompts {
    return [self.promptHandlers allValues];
}

- (id<YMPromptable>)registerPrompt:(id<YMPromptable>)promptable {
    NSParameterAssert(promptable);
    if (!promptable) {
        return nil;
    }
    
    YMPromptAccessType key = [[promptable class] identifier];
    id<YMPromptable> previous = self.promptHandlers[key];
    self.promptHandlers[key] = promptable;
    return previous;
}

- (id<YMPromptable>)promptForIdentifier:(NSString *)identifier {
    NSParameterAssert(identifier);
    if (!identifier) {
        return nil;
    }
    return self.promptHandlers[identifier];
}

#pragma mark - Private Helpers

- (YMPromptAuthorizationStatus)_authorizationStatus:(YMPromptAccessType)accessType modes:(YMPromptAccessMode)modes {
    id<YMPromptable> handler = self.promptHandlers[accessType];
    NSAssert(handler, @"No handler registered for prompt access type %@", accessType);
    return [handler authorizationStatus:modes];
}

- (void)_requestAccess:(YMPromptAccessType)accessType modes:(YMPromptAccessMode)modes onComplete:(void(^)(BOOL))onComplete {
    id<YMPromptable> handler = self.promptHandlers[accessType];
    NSAssert(handler, @"No handler registered for prompt access type %@", accessType);
    [handler requestAccess:modes onComplete:onComplete];
}

@end
