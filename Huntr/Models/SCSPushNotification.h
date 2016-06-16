//
//  SCSPushNotification.h
//  Huntr
//
//  Created by Justin Leger on 6/15/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @typedef SCSPushNotificationType enum
 
 @abstract Push Notification Type: Indicates in what state was app when received it (Foreground, Background, Terminated)
 
 @discussion
 */
typedef NS_ENUM(NSInteger, SCSPushNotificationType) {
    SSCSPushNotificationTypeUnknown,
    SCSPushNotificationTypeFG,             // App was on Foreground
    SCSPushNotificationTypeBG,              // App was on Background
    SCSPushNotificationTypeTM               // App was terminated and launched again through Push notification
};

@interface SCSPushNotification : NSObject

@property (nonatomic) SCSPushNotificationType pushNotificationType;
@property (nonatomic) NSDictionary *userInfo;

@property (nonatomic, readonly) NSDictionary *aps;

@property (nonatomic, readonly) NSNumber *badge;
@property (nonatomic, readonly) NSString *sound;

@property (nonatomic, readonly) id alert;
@property (nonatomic, readonly) NSString *alertString;
@property (nonatomic, readonly) NSDictionary *alertDictionary;

@property (nonatomic, readonly) BOOL alertIsDictionary;
@property (nonatomic, readonly) BOOL alertIsString;

@property (nonatomic, readonly) BOOL contentAvaliable;

+ (SCSPushNotification *)pushNotificationWithType:(SCSPushNotificationType)pushNotificationType andUserInfo:(NSDictionary *)userInfo;

- (id)initWithType:(SCSPushNotificationType)pushNotificationType andUserInfo:(NSDictionary *)userInfo;

- (id)payloadValueWithKey:(NSString *)key;

@end
