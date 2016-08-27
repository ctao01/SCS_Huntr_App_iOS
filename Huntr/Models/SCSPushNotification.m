//
//  SCSPushNotification.m
//  Huntr
//
//  Created by Justin Leger on 6/15/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSPushNotification.h"

@implementation SCSPushNotification

+ (SCSPushNotification *)pushNotificationWithUserInfo:(NSDictionary *)userInfo
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    SCSPushNotificationType pnType;
    
    // Detect if APN is received on Background or Foreground state
    if (state == UIApplicationStateActive) {
        NSLog(@"UIApplicationStateActive: %@", [userInfo description]);
        pnType = SCSPushNotificationTypeFG;
    }
    else if (state == UIApplicationStateInactive) {
        NSLog(@"UIApplicationStateInactive: %@", [userInfo description]);
        pnType = SCSPushNotificationTypeBG;
    }
    else if (state == UIApplicationStateBackground) {
        NSLog(@"UIApplicationStateBackground: %@", [userInfo description]);
        pnType = SCSPushNotificationTypeBG;
    }
    else {
        NSLog(@"Unknown State: %@", [userInfo description]);
        pnType = SSCSPushNotificationTypeUnknown;
    }
    
    SCSPushNotification * pushNotification = [self pushNotificationWithUserInfo:userInfo andType:pnType];
    
    return pushNotification;
}

+ (SCSPushNotification *)pushNotificationWithUserInfo:(NSDictionary *)userInfo andType:(SCSPushNotificationType)pushNotificationType
{
    SCSPushNotification * pushNotification = [[SCSPushNotification alloc] initWithdUserInfo:userInfo andType:pushNotificationType];
    return pushNotification;
}

- (id)initWithdUserInfo:(NSDictionary *)userInfo andType:(SCSPushNotificationType)pushNotificationType
{
    self = [super init];
    if (self) {
        self.pushNotificationType = pushNotificationType;
        self.userInfo = userInfo;
    }
    return self;
}

- (NSDictionary *) aps
{
    if (self.userInfo != nil) {
        NSDictionary * aps = self.userInfo[@"aps"];
        if (aps) return aps;
    }
    return nil;
}

- (NSNumber *) badge
{
    if (self.aps != nil) {
        NSNumber * badge = (NSNumber *)self.aps[@"badge"];
        if (badge) return badge;
    }
    return nil;
}

- (NSString *) sound
{
    if (self.aps != nil) {
        NSString * sound = (NSString *)self.aps[@"sound"];
        if (sound && sound.length > 0) return sound;
    }
    return nil;
}

- (BOOL) contentAvaliable
{
    if (self.aps != nil) {
        NSNumber * contentAvaliable = (NSNumber *)self.aps[@"content-available"];
        if (contentAvaliable) return contentAvaliable.boolValue;
    }
    return NO;
}

- (id) alert
{
    if (self.aps != nil) {
         return self.aps[@"alert"];
    }
    return nil;
}

- (BOOL) alertIsDictionary
{
    if (self.aps != nil) {
        return [self.alert isKindOfClass:[NSDictionary class]];
    }
    return NO;
}

- (BOOL) alertIsString
{
    if (self.aps != nil) {
        return [self.alert isKindOfClass:[NSString class]];
    }
    return NO;
}

- (NSDictionary *) alertDictionary
{
    if (self.alertIsDictionary) {
        return (NSDictionary *)self.alert;
    }
    return nil;
}

- (NSString *) alertString
{
    NSString * alertString;
    
    if (self.alertIsString) {
        alertString = (NSString *)self.alert;
    } else if (self.alertIsDictionary) {
        alertString =  (NSString *)self.alertDictionary[@"body"];
    }
    
    if (alertString.length > 0) {
        return alertString;
    }
    return nil;
}


- (id)payloadValueWithKey:(NSString *)key
{
    if (self.userInfo != nil && key != nil) {
        id payloadValue = self.userInfo[key];
        if (payloadValue) return payloadValue;
    }
    return nil;
}

@end
