//
//  UIViewController+YMPromptHelpers.h
//  Pods
//
//  Created by Adam Kaplan on 1/30/15.
//
//

#import <UIKit/UIKit.h>

/** Static helpers for choosing an appropriate root view controller.
 * This code was taken from SDCAlertView for when that library is not available at runtime.
 */
@interface UIViewController (YMPromptHelpers)

+ (UIViewController *)YMPrompt_currentViewController;

+ (UIViewController *)YMPrompt_topViewControllerForViewController:(UIViewController *)rootViewController;

@end
