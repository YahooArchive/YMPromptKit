//
//  YMPromptAddressBookHandler.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptAddressBookHandler.h"
#import "YMPromptSystemAccessTypes.h"
#import <AddressBook/AddressBook.h>

@implementation YMPromptAddressBookHandler

+ (NSString *)identifier {
    return kYMPromptAccessTypeContacts;
}

- (YMPromptAuthorizationStatus)authorizationStatus:(YMPromptAccessMode)modes {
    switch (ABAddressBookGetAuthorizationStatus()) {
        case kABAuthorizationStatusAuthorized:
            return YMPromptAuthorizationStatusAuthorized;
            
        case kABAuthorizationStatusDenied:
            return YMPromptAuthorizationStatusDenied;
            
        case kABAuthorizationStatusRestricted:
            return YMPromptAuthorizationStatusRestricted;
            
        case kABAuthorizationStatusNotDetermined:
            return YMPromptAuthorizationStatusNotDetermined;
    }
}

- (void)requestAccess:(YMPromptAccessMode)modes onComplete:(void(^)(BOOL))onComplete {
    ABAddressBookRequestAccessWithCompletion(NULL, ^(bool granted, CFErrorRef error) {
        if (onComplete) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                onComplete(granted);
            });
        }
    });
}

@end
