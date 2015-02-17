//
//  YMPromptCameraHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 2/2/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptCameraHandler.h"
#import "YMPromptSystemAccessTypes.h"
#import <AVFoundation/AVFoundation.h>


@implementation YMPromptCameraHandler

+ (NSString *)identifier {
    return kYMPromptAccessTypeCamera;
}

- (instancetype)init {
    if (self = [super init]) {
        self->_mediaType = AVMediaTypeVideo;
    }
    return self;
}

@end
