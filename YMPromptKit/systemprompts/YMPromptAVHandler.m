//
//  YMPromptAVHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 2/2/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptAVHandler.h"
#import <AVFoundation/AVFoundation.h>

@implementation YMPromptAVHandler

// Modes is reserved for future use. Clients must pass 0.
- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptAccessMode)modes {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:_mediaType];
    switch(status) {
        case AVAuthorizationStatusAuthorized:
            return YMPromptAuthorizationStatusAuthorized;
            
        case AVAuthorizationStatusRestricted:
            return YMPromptAuthorizationStatusRestricted;
            
        case AVAuthorizationStatusDenied:
            return YMPromptAuthorizationStatusDenied;
            
        case AVAuthorizationStatusNotDetermined:
        default:
            return YMPromptAuthorizationStatusNotDetermined;
    }
}

// Modes is reserved for future use. Clients must pass 0.
- (void)requestAccess:(YMPromptAccessMode)modes onComplete:(void(^)(BOOL))onComplete {
    [AVCaptureDevice requestAccessForMediaType:_mediaType completionHandler:onComplete];
}

@end
