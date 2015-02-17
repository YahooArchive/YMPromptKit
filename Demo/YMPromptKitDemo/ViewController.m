//
//  ViewController.m
//  YMPromptKitDemo
//
//  Created by Adam Kaplan on 1/7/15.
//  Copyright (c) 2015 Yahoo. All rights reserved.
//  Licensed under the terms of the Apache 2.0 License. See LICENSE file in the project root.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <YMPromptKit/YMPromptKit.h>
#import <EventKit/EventKit.h>

static NSString * const kCellIdentifier = @"Cell";

static NSString * const kAccessPhotos = @"Photos";
static NSString * const kAccessLocation = @"Location";
static NSString * const kAccessCalendar = @"Calendar";
static NSString * const kAccessReminders = @"Reminders";
static NSString * const kAccessCalendarReminders = @"Calendar & Reminders";
static NSString * const kAccessContacts = @"Contacts";
static NSString * const kAccessMicrophone = @"Microphone";
static NSString * const kAccessCamera = @"Camera";
static NSString * const kAccessNotifications = @"Remote Notifications";

@interface ViewController ()
@property (nonatomic) NSArray *permissions;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.permissions = @[
                         kAccessPhotos,
                         kAccessLocation,
                         kAccessCalendar,
                         kAccessReminders,
                         kAccessContacts,
                         kAccessMicrophone,
                         kAccessCamera,
                         kAccessNotifications
                         ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.permissions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.permissions[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = self.permissions[indexPath.row];
    YMPromptAccessType accessType = kYMPromptAccessTypePhotoLibrary;
    NSUInteger accessMode = 0;
    
    if ([title isEqualToString:kAccessCalendar]) {
        
        accessType = kYMPromptAccessTypeEvents;
        accessMode = EKEntityTypeEvent;
    
    } else if ([title isEqualToString:kAccessReminders]) {
        
        accessType = kYMPromptAccessTypeEvents;
        accessMode = EKEntityTypeReminder;
        
    } else if ([title isEqualToString:kAccessPhotos]) {
        
        accessType = kYMPromptAccessTypePhotoLibrary;
        
    } else if ([title isEqualToString:kAccessLocation]) {

        accessType = kYMPromptAccessTypeLocation;
        
    } else if ([title isEqualToString:kAccessMicrophone]) {

        accessType = kYMPromptAccessTypeMicrophone;
        
    } else if ([title isEqualToString:kAccessCamera]) {
        
        accessType = kYMPromptAccessTypeCamera;
        
    } else if ([title isEqualToString:kAccessContacts]) {

        accessType = kYMPromptAccessTypeContacts;
        
    } else if ([title isEqualToString:kAccessNotifications]) {

        accessType = kYMPromptAccessTypeNotifications;
        accessMode = YMPromptNotificationOptionTypeAlert;

    }
    
    NSLog(@"Requesting access to %@", title);
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.promptManager.presentingViewController = self;
    [delegate.promptManager requestAccess:accessType
                                    modes:accessMode
                        completionHandler:^(BOOL softPromptAccepted, BOOL osPromptAccepted, YMPromptAuthorizationStatus status) {
                            NSString *statusStr;
                            if (softPromptAccepted) {
                                if (osPromptAccepted) {
                                    statusStr = @"GRANTED on the OS level";
                                } else {
                                    statusStr = @"DENIED on the OS level";
                                }
                            } else {
                                if (status == YMPromptAuthorizationStatusAuthorized) {
                                    statusStr = @"already GRANTED on the OS level";
                                } else if (status == YMPromptAuthorizationStatusDenied) {
                                    statusStr = @"already DENIED on the OS level";
                                } else if (status == YMPromptAuthorizationStatusRestricted) {
                                    statusStr = @"already GRANTED on the OS level (restricted)";
                                } else if (status == YMPromptAuthorizationStatusNotDetermined) {
                                    statusStr = @"DENIED on the APP level";
                                }
                            }
                            NSLog(@"Access to %@ was %@", title, statusStr);
                        }];

}

@end
