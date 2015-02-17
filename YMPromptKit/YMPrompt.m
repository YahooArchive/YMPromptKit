//
//  YMPrompt.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/8/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPrompt.h"

@implementation YMPrompt

+ (instancetype)promptWithTitle:(NSString *)title
                        message:(NSString *)message
                     grantTitle:(NSString *)grantTitle
                      denyTitle:(NSString *)denyTitle
                    contentView:(UIView *)view {
    
    return [[self alloc] initWithTitle:title
                               message:message
                            grantTitle:grantTitle
                             denyTitle:denyTitle
                           contentView:view];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                   grantTitle:(NSString *)grantTitle
                    denyTitle:(NSString *)denyTitle
                  contentView:(UIView *)view {
    
    if (self = [super init]) {
        NSAssert(title.length || message.length || view, @"At least one of a title, message or custom view is required for YMPrompt");
        
        _title = title;
        _message = message;
        _contentView = view;
        
        if (grantTitle) {
            _grantButtonTitle = grantTitle;
        } else {
            _grantButtonTitle = @"OK";
        }
        
        if (denyTitle) {
            _denyButtonTitle = denyTitle;
        } else {
            _denyButtonTitle = @"Not Now";
        }
    }
    return self;
}

@end
