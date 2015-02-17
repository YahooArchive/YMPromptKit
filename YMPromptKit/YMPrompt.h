//
//  YMPrompt.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/8/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

// A model representing a prompt
@interface YMPrompt : NSObject

/**
 * Optional. The title, analogous to UIAlertView's title. Either one or both of `title` and `message`
 * may be nil. If both are nil, a custom view must be provided in contentView
 */
@property (nonatomic) NSString *title;

/**
 * Optional. The title, analogous to UIAlertView's message. Either one or both of `title` and `message`
 * may be nil. If both are nil, a custom view must be provided in contentView
 */
@property (nonatomic) NSString *message;

/**
 * Optional. A custom view to be added to the alert. If provided, the view will be displayed below
 * the title area – below the message if that is not nil – and above the action buttons.
 * The height of this view determines the height of the resulting alert view, but the width is fixed
 * to the natural width of the alert view on the current device.
 */
@property (nonatomic) UIView *contentView;

/**
 * Optional. The title of the grant button, which is always displayed to the right of the deny button.
 * The default title is "OK"
 */
@property (nonatomic) NSString *grantButtonTitle;

/**
 * Optional. The title of the deny button, which is always displayed to the left of the grant button.
 * The default title is "Not Now"
 */
@property (nonatomic) NSString *denyButtonTitle;

/**
 * Returns a fully configured YMPrompt. At least one of title, message or contentView must be provided.
 */
+ (instancetype)promptWithTitle:(NSString *)title
                        message:(NSString *)message
                     grantTitle:(NSString *)grantTitle
                      denyTitle:(NSString *)denyTitle
                    contentView:(UIView *)view;

@end
