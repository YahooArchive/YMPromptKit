//
//  YMPromptSystemAccessTypes.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 2/4/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptTypes.h"

#ifndef Pods_YMPromptSystemAccessTypes_h
#define Pods_YMPromptSystemAccessTypes_h

/** Unique identifier for the photo library Promptable */
extern YMPromptAccessType const kYMPromptAccessTypePhotoLibrary;
/** Unique identifier for the calendar events/reminders Promptable */
extern YMPromptAccessType const kYMPromptAccessTypeEvents;
/** Unique identifier for the contacts Promptable */
extern YMPromptAccessType const kYMPromptAccessTypeContacts;
/** Unique identifier for the location Promptable */
extern YMPromptAccessType const kYMPromptAccessTypeLocation;
/** Unique identifier for the microphone/recording Promptable */
extern YMPromptAccessType const kYMPromptAccessTypeMicrophone;
/** Unique identifier for the camera Promptable */
extern YMPromptAccessType const kYMPromptAccessTypeCamera;
/** Unique identifier for the remote notifications Promptable */
extern YMPromptAccessType const kYMPromptAccessTypeNotifications;

#endif
