//
//  SDCAlertController+YMPromptManagerLayout.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/12/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "SDCAlertController.h"

@class YMPrompt;

@interface SDCAlertController (YMPromptManagerLayout)

/**
 * Configures an SDCAlertController with the title, message and content view of the provided prompt.
 * the deny and grant handlers are assigned to the deny/grant actions in the resulting SDCAlert.
 */
+ (SDCAlertController *)YM_alertControllerWithPrompt:(YMPrompt *)prompt
                                         denyHandler:(void(^)(SDCAlertAction*))onDeny
                                        grantHandler:(void(^)(SDCAlertAction*))onGrant;

@end
