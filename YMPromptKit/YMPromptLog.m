//
//  YMPromptLog.m
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/8/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptLog.h"

static NSString * const kYMPromptLogFileName = @"YMPromptData";
static NSString * const kYMPromptLogVersion = @"YMPromptLogVersion";
static NSString * const kYMPromptLogHistoryLimit = @"YMPromptLogHistoryLimit";
static NSUInteger kYMPromptLogDefaultMaximumHistory = 15;
static NSUInteger kYMPromptLogCurrentVersion = 1;

// Externs
NSString * const kYMPromptLogDateKey = @"date";
NSString * const kYMPromptLogUserInfoKey = @"user_info";

@interface YMPromptLog ()
@property (nonatomic, readonly) NSMutableDictionary *log;
@property (nonatomic, readonly) NSString *path;
@end


@implementation YMPromptLog

+ (instancetype)mainLog {
    static YMPromptLog *log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = [[self alloc] initWithLogName:kYMPromptLogFileName];
    });
    return log;
}

- (instancetype)initWithLogName:(NSString *)name {
    if (self = [super init]) {
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (docPaths.count < 1) {
            return nil;
        }
        
        _path = [[[docPaths firstObject] stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"plist"];
        NSData *data = [NSData dataWithContentsOfFile:_path];
        if (data.length) {
            _log = [NSPropertyListSerialization propertyListWithData:data
                                                             options:NSPropertyListMutableContainersAndLeaves
                                                              format:NULL
                                                               error:nil];
        }
        
        if (!_log || [_log[kYMPromptLogVersion] unsignedIntegerValue] < kYMPromptLogCurrentVersion) {
            _log = [NSMutableDictionary dictionary];
            _log[kYMPromptLogVersion] = @(kYMPromptLogCurrentVersion);
            [self performSelector:@selector(synchronize:) withObject:[_log copy] afterDelay:3.0];
        }
        
        _maximumHistoryEntries = [_log[kYMPromptLogHistoryLimit] unsignedIntegerValue];
        if (!_maximumHistoryEntries) {
            _maximumHistoryEntries = kYMPromptLogDefaultMaximumHistory;
        }
    }
    return self;
}

- (void)markSoftPromptShown:(YMPromptAccessType)key userInfo:(NSDictionary *)userInfo {
    NSMutableArray *typeData = self.log[key];
    
    if (!typeData) {
        typeData = [NSMutableArray arrayWithCapacity:self.maximumHistoryEntries];
        self.log[key] = typeData;
    } else if (typeData.count > self.maximumHistoryEntries) {
        [typeData removeObjectsInRange:NSMakeRange(self.maximumHistoryEntries, typeData.count - self.maximumHistoryEntries)];
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[kYMPromptLogDateKey] = [NSDate date];
    if (userInfo) {
        data[kYMPromptLogUserInfoKey] = userInfo;
    }
    [typeData insertObject:data atIndex:0]; // this way it's sorted by default. NSArray can do this efficiently.
    [self _synchronizeAfterDelay];
}

- (NSArray *)promptHistory:(YMPromptAccessType)key {
    return [self.log[key] copy];
}

- (void)setMaximumHistoryEntries:(NSUInteger)maximumHistoryEntries {
    _maximumHistoryEntries = maximumHistoryEntries;
    self.log[kYMPromptLogHistoryLimit] = @(maximumHistoryEntries);
    [self _synchronizeAfterDelay];
}

- (void)synchronize {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    return [self synchronize:[self.log copy]];
}

- (void)_synchronizeAfterDelay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSDictionary *log = [self.log copy];
    [self performSelector:@selector(synchronize:) withObject:log afterDelay:3.0];
}

- (void)synchronize:(NSDictionary *)data {
    [self.log writeToFile:self.path atomically:YES];
}

@end
