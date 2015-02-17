//
//  YMPromptTypes.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/9/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#ifndef YMPromptKit_YMPromptTypes_h
#define YMPromptKit_YMPromptTypes_h

// All YMPromptAccessTypes (including provided by clients) should be unique and namespaced. These
// keys are used to map persisted log data to concrete YMPromptable instances.
// A good strategy is <AppPrefix>_<Noun>. For an app called PrinterInkService, something like @"pks_printer"

/** This type is used for YMPromptable unique identifiers. */
typedef NSString* YMPromptAccessType;

/**
 * The authorization status for a YMPromptable. A value of YMPromptAuthorizationStatusNotDetermined
 * means that either the user has never been asked, or iOS does not provide a facility to obtain the
 * authorization status.
 * A value of YMPromptAuthorizationStatusRestricted indicates that access has been granted, but is
 * restricted in some context-specific way (such as by parental controls)
 */
typedef NS_ENUM(NSUInteger, YMPromptAuthorizationStatus) {
    YMPromptAuthorizationStatusAuthorized,
    YMPromptAuthorizationStatusDenied,
    YMPromptAuthorizationStatusRestricted,
    YMPromptAuthorizationStatusNotDetermined
};


/**
 * Mode represents a context-specific bitmask. Many of Apple's permissions systems have various options
 * for clients to choose from. For example while access to Photos currently has no options, access to
 * EventKit can be requested for either EKEntityEvent (calendar) or EKEntityReminder (reminders).
 */
typedef NSUInteger YMPromptAccessMode;

/**
 * Context-specific values for the `mode` parameter for kYMPromptAccessTypeLocation prompts.
 * On iOS 7, the only option available is YMPromptLocationOptionAlways.
 */
typedef NS_ENUM(NSUInteger, YMPromptLocationOptions) {
    YMPromptLocationOptionAppInUse,
    YMPromptLocationOptionAlways,
};

/**
 * Context-specific values for the `mode` parameter for kYMPromptAccessTypeLocation prompts.
 * On iOS 8, the YMPromptNotificationOptionTypeNewsstandContentAvailability option has no effect.
 */
typedef NS_OPTIONS(NSUInteger, YMPromptNotificationOptions) {
    YMPromptNotificationOptionTypeNone    = 0,
    YMPromptNotificationOptionTypeBadge   = 1 << 0,
    YMPromptNotificationOptionTypeSound   = 1 << 1,
    YMPromptNotificationOptionTypeAlert   = 1 << 2,
    YMPromptNotificationOptionTypeNewsstandContentAvailability = 1 << 3,
};

/**
 * Callback for soft prompt events. `softPromptAccepted` is true when the soft prompt was displayed
 * and agreed to by the user. `osPromptAccepted` is false when `softPromptAccepted` is false, or if
 * OS-level access was declined by the user. `status` provides the current authorization status.
 * It is possible for both boolean arguments to be false, and `status` to be in a determined state.
 * This occurs when the prompts were not needed because OS access was already granted or denied.
 */
typedef void(^YMPromptKitCompletionHandler)(BOOL softPromptAccepted, BOOL osPromptAccepted, YMPromptAuthorizationStatus status);

#endif
