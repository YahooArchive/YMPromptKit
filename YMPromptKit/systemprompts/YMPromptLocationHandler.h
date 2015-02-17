//
//  YMPromptLocationHandler.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptable.h"
#import "YMPromptTypes.h"

@interface YMPromptLocationHandler : NSObject <YMPromptable>

@property (nonatomic) NSString *identifier;

/** See definition in YMPromptable, and YMPromptLocationOptions for details */
- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptLocationOptions)modes;

/** See definition in YMPromptable, and YMPromptLocationOptions for details */
- (void)requestAccess:(YMPromptLocationOptions)modes onComplete:(void(^)(BOOL))onComplete;

@end
