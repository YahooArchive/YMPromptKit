//
//  YMPromptLog.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/8/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptManager.h"


extern NSString * const kYMPromptLogDateKey;
extern NSString * const kYMPromptLogUserInfoKey;


@interface YMPromptLog : NSObject

/**
 * Set the maximum history entries to persist. This feature ensures that the soft prompt log does not
 * grow unbounded. History is pruned on modification, so changing this value has no immediate effect.
 * The default value is 15. The value, once specified, will be persisted.
 */
@property (nonatomic) NSUInteger maximumHistoryEntries;

/**
 * Returns the main, shared log used by YMPromptKit. You may access this shared instance as needed.
 */
+ (instancetype)mainLog;

/**
 * Initializes a new YMPromptLog. Instances created using this method will not affect YMPromptKit,
 * which always uses +[YMPromptLog mainLog] to obtain an instance.
 */
- (instancetype)initWithLogName:(NSString *)name NS_DESIGNATED_INITIALIZER;

/**
 * Record that the specified soft prompt type was displayed to the user. Contextual data may be provided
 * using the userInfo parameter. The userInfo dictionary must contain only objects which can be
 * serialized using NSJSONSerialization (NSData, NSDate, NSNumber, NSString, NSArray, or NSDictionary)
 */
- (void)markSoftPromptShown:(YMPromptAccessType)key userInfo:(NSDictionary *)userInfo;

/**
 * Provides the history for the specified prompt ordered by time, starting with the most recent event.
 * The entries are of type NSDictionary, with the date stored at kYMPromptLogDateKey and app provided
 * contextural data stored in kYMPromptLogUserInfoKey
 */
- (NSArray *)promptHistory:(YMPromptAccessType)type;

/**
 * Because this method is automatically invoked automatically – a few seconds after the last
 * modification – use it method only if you cannot wait for the automatic synchronization (for example,
 * if your application is about to exit). Changes on disk are not reverse-synchronized back to the
 * running cache, this method is write-only.
 */
- (void)synchronize;

@end
