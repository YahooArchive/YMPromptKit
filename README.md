![logo](https://cloud.githubusercontent.com/assets/727953/6237605/548d7012-b6c2-11e4-97da-976398a5a7fa.png)

YMPromptKit
===========

YMPromptKit attempts to simplify your app code by providing flexible and extensible tools for soft prompting. Wait, what makes a prompt _soft_?

### The two types of prompts

1. **Hard Prompt** - A hard prompt is the typical dialog presented by iOS to obtain a user's permission for accessing a protected resource (such as their location or contacts). This prompt is considered hard because after showing it, the outcome cannot be easily changed.
2. **Soft Prompt** - A prompt is soft when its results are not locked in. A soft prompt may be displayed several times, affording the application a second (or third or fourth) chance to present it's value proposition to the user.

### Why you need soft prompts

The most well known hard prompt in iOS is that of push notifications. The value of these notifications cannot be overstated. Apps live and die by their ability – or lack of ability – to pop up highly relevant, immediately actionable alerts on your mobile device's screen. Unfortunately, once a user declines to allow you the right to push notifications at them, you have little recourse (few users will go through the trouble of manually re-enabling the feature). This has been [discussed at length](http://techcrunch.com/2014/04/04/the-right-way-to-ask-users-for-ios-permissions/).

Installation
===========

The easiest way to install is by using CocoaPods. The name of the pod is YMPromptKit.

```
pod 'YMPromptKit', '~> 1.0.0'
```

If you're not using CocoaPods, you need to add all of the classes in the `YMPromptKit/` directory.

YMPromptKit depends on [SDCAlertView](https://github.com/sberrevoets/SDCAlertView) by default (see next section).

#### Using iOS Native Alerts Without SDCAlertView

SDCAlertView adds both functional value & reliability to YMPromptKit. However, if you cannot use SDCAlertView, one of it's dependencies, or are having other issues with it, you may opt to use iOS native prompting with a simple pod reference:

```
pod 'YMPromptKit/NativeAlerts', '~> 1.0.0`
```

See [implementations notes](#implementation-notes)

Support
===========

YMPromptKit supports iOS 7.0 and higher.

Some features have degraded performance under iOS 7.0 due to reliance on APIs that were introduced in iOS 8.0. Where applicable, these differences are noted in the API comments.

Usage
===========

### For the impatient...

The demo app is provided in the [`Demo` folder](https://github.com/yahoo/YMPromptKit/tree/master/Demo). Check it out.

### Provided soft prompts

A number of iOS soft prompts are provided out-of-the-box for immediate use. These are:

1. Push Notifications
2. Location Services
3. Calendar Events & Reminders
4. Recording / Microphone Access
5. Photo Library
6. Address Book & Contacts

Additional proprietary prompts can also be added as needed, such as requesting a user to sign in, or invite a friend.

### Basic Push Notification Prompt

![basic prompt](https://cloud.githubusercontent.com/assets/727953/6240312/b7613fb2-b6da-11e4-929b-894e606332eb.png)

The very first thing you need to do is include the header file for YMPromptKit and allocate space for an instance of `YMPromptManager`
```objc
#import <YMPromptKit/YMPromptKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate>
@property (nonatomic, readonly) YMPromptManager *promptManager;
@end
```

Now get a reference to a `YMPromptManager`. The easiest way to do this is to create a prompt manager with all pre-configured prompt handlers already registered
```objc
_promptManager = [YMPromptManager createPromptManager];
```

The prompt manager requires a data source to tell it what to show the user. In this case, let's use ourself as the data source.
```objc
self.promptManager.dataSource = self;
```

To implement the data source, we need to provide one method to vend instances of `YMPrompt`. For this example, let's pretend that we only care about push notifications. Add the following method:
```objc
- (YMPrompt *)promptManager:(YMPromptManager *)manager
        promptForAccessType:(YMPromptAccessType)access
                      modes:(YMPromptAccessMode)modes {
                      
  if (access == kYMPromptAccessTypeNotifications) {
    YMPrompt *prompt = [YMPrompt promptWithTitle:@"Stock Alerts"
                                         message:@"Allow Yahoo Finance to send you important alerts"
                                                 @"about stocks you follow?"
                                      grantTitle:@"Yes"
                                       denyTitle:nil
                                     contentView:nil];
    return prompt;
  }
  
  return nil;
}
```

Now, when some code in your app asks the `YMPromptManager` to request access for push notifications, the prompt manager will get an instance of `YMPrompt` from us. The prompt we'll vend will have a custom title, message and grant permissions button label. The deny button title will not be specified; it will default to "Not Now".

Trigger the prompt from anywhere in your app, like this
```objc
[delegate.promptManager requestAccess:kYMPromptAccessTypeNotifications
                                modes:YMPromptNotificationOptionTypeAlert
                    completionHandler:^(BOOL softPromptAccepted, BOOL osPromptAccepted, YMPromptAuthorizationStatus status) {
                        if (softPromptAccepted) {
                            if (osPromptAccepted) {
                                // User accepted the soft prompt and the OS prompt. Win!
                            } else {
                                // User accepted the soft prompt, but denied the OS prompt. Lose :(
                            }
                        } else {
                            if (status == YMPromptAuthorizationStatusNotDetermined) {
                                // The user declined your soft prompt. Not a win, not a loss.
                            } else if (status == YMPromptAuthorizationStatusDenied) {
                                // Already denied access by the OS
                            } else if (status == YMPromptAuthorizationStatusRestricted) {
                                // Already authorized, but there is some OS restriction
                            } else if (status == YMPromptAuthorizationStatusAuthorized) {
                                // Already authorized by the OS
                            }
                        }
                    }];
```

For iOS 8, you must manually record the registration result with the prompt manager. In your app delegate record the notification registration result in `-application: didRegisterUserNotificationSettings:`. This is also the point when you can register for remote notifications.

```objc
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    BOOL success = (notificationSettings.types != UIUserNotificationTypeNone);
    [delegate.promptManager recordNotificationRegistrationResult:success];

    // Permission was granted, register for remote notifications
    [application registerForRemoteNotifications];
}
```

### Enforcing cadence with `YMPromptManagerDelegate`

Soft prompts are pretty great, but one sure method to maximize user opt-out rates is to pester the user with requests too often. YMPromptKit can help you achieve an appropriate prompting cadence right out of the box. Let's ensure that our example app does not ask for push notification permission more than once in a 48 hour period, or more than 3 times.

Add a delegate method to give the prompt manager some application-specific guidance
```objc
- (BOOL)promptManager:(YMPromptManager *)manager shouldRequestAccessType:(YMPromptAccessType)accessType
                modes:(YMPromptAccessMode)modes {
    
    NSArray *promptLog = [manager.log promptHistory:accessType];
    
    if (promptLog.count > 3) {
        return NO;                              // enforce the request limit
    } else if (promptLog.count) {
        NSDictionary *dict = promptLog[0];     // data for the most recent history entry
        NSDate *lastPromptDate = dict[kYMPromptLogDateKey];
        NSTimeInterval interval = -3600 * 48;   // 2 days, in seconds
        
        if ([lastPromptDate timeIntervalSinceNow] > interval) {
            return NO;                          // enforce the quiet period
        }
    }
    
    return YES;                                 // OK to display prompt!
}
```

The code above uses the prompt log to access the prompt history for the given access type. Each `YMPromptManager` has a `YMPromptLog` accessible via it's `log` property. Default prompt managers – those returned by `[YMPromptManager createPromptManager]` – always use the main prompt log available at `[YMPromptLog mainLog]`.

Just before a prompt is displayed, a `YMPromptManager` will add a date entry to it's `YMPromptLog` instance. The prompt log, therefore, represents the recent history of soft prompts (last 15 occurances of each type of prompt, by default). The history is periodically flushed to disk and persists across sessions.

### Tracking custom parameters in `YMPromptLog`

Although the dates of soft prompt occurances are enough to provide coarse control of cadence, it is each to imagine business requirements which cannot be satified by such limited data. To alleviate this issue, `YMPromptLog` can accept arbitrary NSPropertyListSerialization-compatible metadata to store with each event entry.

Let's add to the example a requirement that the five sessions must elapse between push notification soft prompts. To do this, implement the `YMPromptManagerDelegate` method:
```objc
- (NSDictionary *)promptManager:(YMPromptManager *)manager
          willRequestAccessType:(YMPromptAccessType)accessType
                          modes:(YMPromptAccessMode)modes {
    
    NSNumber *sessionNum = self.sessionNumber;
    
    return @{ @"session_number":  sessionNum };
}
```

Now, each event will have an associated dictionary that contains the session number of that it was displayed in. We can access this information and use it to apply application-specific logic from within the `-promptManager:shouldRequestAccessType:modes:` delegate method. Extending the previous example of that delegate method from above:
```objc
- (BOOL)promptManager:(YMPromptManager *)manager shouldRequestAccessType:(YMPromptAccessType)accessType
                modes:(YMPromptAccessMode)modes {
    
    NSArray *promptLog = [manager.log promptHistory:accessType];
    
    if (promptLog.count > 3) {
        return NO;                              // enforce the request limit
    } else if (promptLog.count) {
        NSDictionary *dict = promptLog[0];     // data for the most recent history entry
        NSDate *lastPromptDate = dict[kYMPromptLogDateKey];
        NSTimeInterval interval = -3600 * 48;   // 2 days, in seconds
        
        if ([lastPromptDate timeIntervalSinceNow] > interval) {
            return NO;                          // enforce the quiet period
        } else {
        
#pragma  >>> New example code starts here >>>

            NSDictionary *appData = dict[kYMPromptLogUserInfoKey];
            NSNumber *lastSessionNum = appData[@"session_number"];
            NSNumber *sessionNum = self.sessionNumber;
            
            if ([sessionNum integerValue] < [lastSessionNum integerValue] + 5) {
                return NO;                      // enforce minimum sessions betwen prompting
            }
        }
    }
    
    return YES;                                 // OK to display prompt!
}
```

### Embedding custom views in a prompt

YMPromptKit leverages [SDCAlertView](https://github.com/sberrevoets/SDCAlertView) to provide flexible, native iOS-like alerts. One key benefit afforded by this design is that soft prompts may include an embedded custom view – even on iOS 7.

![image in prompt](https://cloud.githubusercontent.com/assets/727953/6240249/e7d59d42-b6d9-11e4-8d9b-f0798779a7b6.png)

Let's add an image like the one shown above, using the running example:
```objc
- (YMPrompt *)promptManager:(YMPromptManager *)manager
        promptForAccessType:(YMPromptAccessType)access 
                      modes:(YMPromptAccessMode)modes {
                      
    UIImage *image = [UIImage imageNamed:@"push-notification.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 150, 150);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (access == kYMPromptAccessTypeNotifications) {
        
    YMPrompt *prompt = [YMPrompt promptWithTitle:@"Stock Alerts"
                                         message:@"Allow Yahoo Finance to send you important alerts"
                                                 @"about stocks you follow?"
                                      grantTitle:@"Yes"
                                       denyTitle:nil
                                     contentView:imageView];
    }
    return prompt;

```

Implementation Notes
===========

#### Dismissing Alerts Manually

SDCAlertView – which powers YMPromptKit – works by presenting alerts as modal view controllers. When the alerts are dismissed (i.e. via it's buttons), SDCAlertView calls YMPromptKit completion blocks, which then call the local app's completion blocks. Beware: __If you manually call `-dismissModalViewController`, the completion blocks will not be triggered.__

#### Tradeoffs When Using Native (Non-SDC) Alerts

- Custom alert subviews are not supported. If specified, they will be silently ignored.
- iOS7 does not support block-based alerting, which requires internal state to be maintained while a soft prompt is being displayed. If clients attempt to present additional soft prompts prior to receiving a completion callback, this internal state may become corrupted, resulting in undefined behavior.

Support & Contributing
===========

Report any bugs or send feature requests to the GitHub issues. Pull requests are very much welcomed. See [CONTRIBUTING](https://github.com/yahoo/YMPromptKit/blob/master/CONTRIBUTING.md) for details.

License
===========

Apache 2.0 license. See the [LICENSE](https://github.com/yahoo/YMPromptKit/blob/master/LICENSE) file for details.
