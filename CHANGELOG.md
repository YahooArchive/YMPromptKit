HEAD
====

* Added licence note to file headers (@adamkaplan)

0.2.0 (2015-02-04)
==================

* Work around iOS 7s lack of delegate method for failing to register for notifications (@adamkaplan)
* Add support for camera & microphone permissions in iOS 7+ (@adamkaplan)
* Moved `SystemPrompts` into a sub-spec (@adamkaplan)
* Deprecated `+promptManager` in favor of `+createPromptManager` (@adamkaplan)
* Check currentUserNotificationSettings on iOS8, not remote notification registration status (@adamkaplan)
* Made 'SDCAlerts` and `NativeAlerts` sub-specs to allow the option of native alert views (@adamkaplan)
* Fixed system access for notifications not being requested on iOS 8 (@dcaunt)

0.1.2 (2015-01-29)
==================

* Added UIKit import to main header (@ihuxley)

0.1.1 (2015-01-27)
==================

* Fixed completion handler being called twice for photo library (@dcaunt)

0.1.0 (2015-01-27)
==================

* Added `promptForIdentifier:(NSString *)identifier` method to retrieve promptables by identifier (@dcaunt)
* Changed log property of `YMPromptManager` to mutable (@dcaunt)

0.0.1 (2015-01-21)
==================

* Initial code and demo (@adamkaplan)
