//
//  SCSPushNotificationManager.h
//  Huntr
//
//  Created by Justin Leger on 6/16/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern NSString * const SCSPushNotificationGameStatusUpdate;
//extern NSString * const SCSPushNotificationTeamStatusUpdate;
//extern NSString * const SCSPushNotificationClueStatusUpdate;
//extern NSString * const SCSPushNotificationAnswerStatusUpdate;
//extern NSString * const SCSPushNotificationPlayerStatusUpdate;

@interface SCSPushNotificationManager : NSObject


#pragma mark - Object Lifecycle

+ (SCSPushNotificationManager *)sharedClient;


#pragma mark - Application Delegate and Callback Helper

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

#pragma mark - User Action Functions

- (void)requestUserToRegisterWithPushNotifications;

@end
