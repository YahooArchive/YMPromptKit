//
//  SDCAlertController+YMPromptManagerLayout.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/12/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "SDCAlertController+YMPromptManagerLayout.h"
#import "YMPrompt.h"

#import "SDCAlertController.h"
#import "SDCAlertView.h" // for iOS 7 support
#import "UIView+SDCAutoLayout.h"

@implementation SDCAlertController (YMPromptManagerLayout)

+ (SDCAlertController *)YM_alertControllerWithPrompt:(YMPrompt *)prompt
                                         denyHandler:(void(^)(SDCAlertAction*))onDeny
                                        grantHandler:(void(^)(SDCAlertAction*))onGrant {
    
    NSString *title = prompt.title;
    NSString *message = prompt.message;
    if (!prompt.contentView && !title && !message) { // apply sensible defaults only if nothing was provided
        NSParameterAssert(title || message || prompt.contentView);
        title = @"Allow Access?";
    }
    
    SDCAlertController *alert = [self alertControllerWithTitle:title
                                                       message:message
                                                preferredStyle:SDCAlertControllerStyleAlert];
    
    if (prompt.contentView) {
        [alert.contentView addSubview:prompt.contentView];
        prompt.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UILayoutPriority priority = UILayoutPriorityDefaultHigh;
        NSString *formatV = [NSString stringWithFormat:@"V:|-[v(%f@%f)]-|", prompt.contentView.bounds.size.height, priority];
        [alert.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatV
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{ @"v": prompt.contentView }]];
        
        [prompt.contentView sdc_pinSize:prompt.contentView.frame.size];
        [prompt.contentView sdc_horizontallyCenterInSuperview];
    }
    
    [alert addAction:[SDCAlertAction actionWithTitle:prompt.denyButtonTitle
                                               style:SDCAlertActionStyleDefault
                                             handler:onDeny]];
    
    [alert addAction:[SDCAlertAction actionWithTitle:prompt.grantButtonTitle
                                               style:SDCAlertActionStyleRecommended
                                             handler:onGrant]];
    
    return alert;
}

@end
