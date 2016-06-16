//
//  SCSPushNotification.m
//  Huntr
//
//  Created by Justin Leger on 6/15/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSPushNotification.h"

@implementation SCSPushNotification


+ (SCSPushNotification *)pushNotificationWithType:(SCSPushNotificationType)pushNotificationType andUserInfo:(NSDictionary *)userInfo
{
    SCSPushNotification * pushNotification = [[SCSPushNotification alloc] initWithType:pushNotificationType andUserInfo:userInfo];
    return pushNotification;
}

- (id)initWithType:(SCSPushNotificationType)pushNotificationType andUserInfo:(NSDictionary *)userInfo
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
