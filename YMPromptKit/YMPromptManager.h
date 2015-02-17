//
//  YMPromptManager.h
//  YMPromptKit
//
//  Created by Adam Kaplan on 1/7/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "YMPromptable.h"
#import "YMPromptTypes.h"

#define YMPromptDeprecated(VERSION,REASON)  __attribute__((deprecated("(since " #VERSION ") " #REASON)))

@class YMPromptManager;

@protocol YMPromptManagerDelegate <NSObject>

@optional

/**
 * This callback is triggered just be a soft prompt for a protected resource is to be displayed.
 * It gives the delegate a chance to stop the prompt by applying application-specific logic.
 * For example, the delegate may check the manager.log to ensure that this prompt is being shown
 * at an appropriate cadence so as not to pester the user:
 *
 *      - (BOOL)promptManager:(YMPromptManager *)manager shouldRequestAccessType:(YMPromptAccessType)accessType modes:(YMPromptAccessMode)modes {
 *          NSArray *history = [manager.log promptHistory:accessType];
 *          if (history.count > 3) {
 *
 *              // never ask more than 3 times
 *              return NO;
 *
 *          } else if (history.count) {
 *
 *              // get the last prompt date
 *              NSDate *lastPromptDate = history[0];
 *              NSTimeInterval promptInterval = -3600 * 24 * 2; // 2 days
 *
 *              if ([lastPromptDate timeIntervalSinceNow] > promptInterval) {
 *                  // enforce 2-day quiet period
 *                  return NO;
 *              }
 *
 *          }
 *          return YES; // The prompt may be displaed: it has not been displayed 3 times, or within the past 2 days
 *      }
 *
 */
- (BOOL)promptManager:(YMPromptManager *)manager shouldRequestAccessType:(YMPromptAccessType)accessType
                modes:(YMPromptAccessMode)modes;

/**
 * Called at the moment prior to prompting the user. The delegate may use this callback to make any
 * changes to the application environment or interface in perparation for the access request dialog
 * (which is displayed modally, similar to iOS's UIAlert)
 * Optionally return a dictionary of additional tracking data, which will persisted along with the
 * current date and time in the manager's YMPromptLog.
 * The returned dictionary must conform to the `userInfo` parameter of -[YMPromptLog markSoftPromptShown:userInfo:].
 */
- (NSDictionary *)promptManager:(YMPromptManager *)manager
          willRequestAccessType:(YMPromptAccessType)accessType
                          modes:(YMPromptAccessMode)modes;

@end


@class YMPrompt, YMPromptLog;

@protocol YMPromptManagerDataSource <NSObject>
@required

/**
 * Called when the YMPromptManager `manager` needs a YMPrompt to display to the user for the specified
 * YMPromptAccessType. The meaning of the `modes` parameter depends on the context of the YMPromptAccessType
 * (see the header for the specified type for details). This method must not return nil.
 */
- (YMPrompt *)promptManager:(YMPromptManager *)manager
        promptForAccessType:(YMPromptAccessType)access
                      modes:(YMPromptAccessMode)modes;

@end


@interface YMPromptManager : NSObject

/**
 * The data source of this YMPromptManager. The data source provides custom YMPrompt instances to
 * display, and therefore cannot be nil.
 */
@property (nonatomic, weak) id<YMPromptManagerDataSource> dataSource;

/**
 * Optional. The delegate for this YMPromptManager. Though optional, the delegate is where app-specific
 * go/no-go decisions to display a soft prompt happen.
 */
@property (nonatomic, weak) id<YMPromptManagerDelegate> delegate;

/**
 * The list of registered YMPromptable instances. The order of the elements is indeterminate.
 */
@property (nonatomic) NSArray *registeredPrompts;

/**
 * The default value of this property is the shared instance returned by +[YMPromptLog mainLog] if 
 * this instance was created with +[YMPromptManager promptManager], otherwise it is nil.
 */
@property (nonatomic) YMPromptLog *log;

/**
 * Optionally specify the view controller from which to present prompts. If this property is nil,
 * a suitable view controller will be chosen (currently SDCAlertController will select the main
 * window's root view controller).
 *
 * iOS 8+ only, no effect under iOS 7.x because UIAlertController doesn't exist.
 */
@property (nonatomic, weak) UIViewController *presentingViewController;

/**
 * Obtain a new instance of YMPromptManager configured with all of the supported system prompts
 * and the shared log returned by +[YMPromptLog mainLog].
 */
+ (instancetype)createPromptManager;
+ (instancetype)promptManager YMPromptDeprecated(0.2.0, "Ownership of the returned object is unclear. Use +createPromptManager instead.");

/**
 * Request access to the protected resource specified by `type`. The meaning of the `modes` parameter
 * depends on the context of the requested `YMPromptAccessType`. The `onComplete` parameter is called
 * with arguments that match the result of the soft prompt flow.
 */
- (void)requestAccess:(YMPromptAccessType)type
                modes:(YMPromptAccessMode)modes
    completionHandler:(YMPromptKitCompletionHandler)onComplete;

/**
 * Register a new prompt. If `promptable.identifier` is already registered to another handler, it will be replaced.
 */
- (id<YMPromptable>)registerPrompt:(id<YMPromptable>)promptable;

/**
 * Call this method from your AppDelegate to provide the results of a push notification registeration
 * request. Apple does not provide any notification or callback hooks for these events as of iOS 8.0
 */
- (void)recordNotificationRegistrationResult:(BOOL)didSucceed;

/**
 * Returns the prompt registered for the given identifier, or nil if no such prompt is registered.
 */
- (id<YMPromptable>)promptForIdentifier:(NSString *)identifier;

@end
