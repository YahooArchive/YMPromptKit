//
//  YMPromptMicrophoneHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptMicrophoneHandler.h"
#import "YMPromptSystemAccessTypes.h"
#import <AVFoundation/AVFoundation.h>


@implementation YMPromptMicrophoneHandler

+ (NSString *)identifier {
    return kYMPromptAccessTypeMicrophone;
}

- (instancetype)init {
    if (self = [super init]) {
        self->_mediaType = AVMediaTypeAudio;
    }
    return self;
}

@end
