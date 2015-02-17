//
//  UIViewController+YMPromptHelpers.m
//  Pods
//
//  Created by Adam Kaplan on 1/30/15.
//
//

#import "UIViewController+YMPromptHelpers.h"

@implementation UIViewController (YMPromptHelpers)

+ (UIViewController *)YMPrompt_currentViewController {
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    return [self YMPrompt_topViewControllerForViewController:rootViewController];
}

+ (UIViewController *)YMPrompt_topViewControllerForViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self YMPrompt_topViewControllerForViewController:navigationController.visibleViewController];
    }
    
    if (rootViewController.presentedViewController) {
        return [self YMPrompt_topViewControllerForViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}

@end
