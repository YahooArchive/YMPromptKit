//
//  AppDelegate.h
//  YMPromptKitDemo
//
//  Created by Adam Kaplan on 1/7/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import <UIKit/UIKit.h>

@class YMPromptManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly) YMPromptManager *promptManager;

@property (nonatomic, readonly) NSNumber *sessionNumber;

@end

