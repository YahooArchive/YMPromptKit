//
//  YMPromptEventsHandler.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptable.h"
#import <EventKit/EventKit.h>

@interface YMPromptEventsHandler : NSObject <YMPromptable>

/** See definition in YMPromptable, and EKEntityType for details */
- (YMPromptAuthorizationStatus)authorizationStatus:(EKEntityType)modes;

/** See definition in YMPromptable, and EKEntityType for details */
- (void)requestAccess:(EKEntityType)modes onComplete:(void(^)(BOOL))onComplete;

@end