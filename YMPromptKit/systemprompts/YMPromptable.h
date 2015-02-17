//
//  YMPromptable.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptTypes.h"

@protocol YMPromptable <NSObject>

/** A unique identifier for this type of Promptable. */
+ (NSString *)identifier;

/** Unless otherwise indicated, `modes` is reserved for future use and clients must pass 0. */
- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptAccessMode)modes;

/** Unless otherwise indicated, `modes` is reserved for future use and clients must pass 0. */
- (void)requestAccess:(YMPromptAccessMode)modes onComplete:(void(^)(BOOL))onComplete;

@end
