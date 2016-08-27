//
//  SCSPushNotificationManager.m
//  Huntr
//
//  Created by Justin Leger on 6/16/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSPushNotificationManager.h"
#import "SCSPushNotification.h"

#import "NSString+UUID.h"

NSString * const SCSPushNotificationGameStatusUpdate = @"SCSPushNotificationGameStatusUpdate";
NSString * const SCSPushNotificationTeamStatusUpdate = @"SCSPushNotificationTeamStatusUpdate";
NSString * const SCSPushNotificationClueStatusUpdate = @"SCSPushNotificationClueStatusUpdate";
NSString * const SCSPushNotificationAnswerStatusUpdate = @"SCSPushNotificationAnswerStatusUpdate";
NSString * const SCSPushNotificationPlayerStatusUpdate = @"SCSPushNotificationPlayerStatusUpdate";

@implementation SCSPushNotificationManager

- (void)performPushNotification:(SCSPushNotification *)pushNotification
{
//    TSUPN GSUPN CSUPN ASUPN PSUPN
    
    NSDictionary * postPayload = nil;
    if (pushNotification) postPayload = @{@"pn":pushNotification};
    
    if ([pushNotification.aps[@"type"] isEqualToString:@"GSUPN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationGameStatusUpdate object:self userInfo:postPayload];
    }
    else if ([pushNotification.aps[@"type"] isEqualToString:@"TSUPM"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationTeamStatusUpdate object:self userInfo:postPayload];
    }
    else if ([pushNotification.aps[@"type"] isEqualToString:@"CSUPN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationClueStatusUpdate object:self userInfo:postPayload];
    }
    else if ([pushNotification.aps[@"type"] isEqualToString:@"ASUPN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationAnswerStatusUpdate object:self userInfo:postPayload];
    }
    else if ([pushNotification.aps[@"type"] isEqualToString:@"PSUPN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationPlayerStatusUpdate object:self userInfo:postPayload];
    }
}


#pragma mark - Object Lifecycle

+ (SCSPushNotificationManager *)sharedClient {
    static SCSPushNotificationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SCSPushNotificationManager alloc] init];
    });
    
    return _sharedClient;
}


#pragma mark - Application Delegate and Callback Helper

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (payload) {
        SCSPushNotification * pn = [SCSPushNotification pushNotificationWithUserInfo:payload andType:SCSPushNotificationTypeTM];
        [self performPushNotification:pn];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
    NSString *deviceUUID = [SCSHuntrEnviromentManager sharedManager].deviceUUID;
    
    if (!deviceUUID) {
        deviceUUID = [NSString stringWithNewUUID];
        [SCSHuntrEnviromentManager sharedManager].deviceUUID = deviceUUID;
        [[SCSHuntrEnviromentManager sharedManager] approveDeviceAPNS];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *token = [deviceToken description];
    token           = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token           = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
    UIUserNotificationType rnTypes = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    
    // Set the defaults to disabled unless we find otherwise...
    NSString *pushAlert = (rnTypes & UIUserNotificationTypeAlert) ? @"enabled" : @"disabled";
    NSString *pushBadge = (rnTypes & UIUserNotificationTypeBadge) ? @"enabled" : @"disabled";
    NSString *pushSound = (rnTypes & UIUserNotificationTypeSound) ? @"enabled" : @"disabled";
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kApnsDeviceToken];
    [[NSUserDefaults standardUserDefaults] setObject:pushAlert forKey:kApnsAlertEnabled];
    [[NSUserDefaults standardUserDefaults] setObject:pushBadge forKey:kApnsBadgeEnabled];
    [[NSUserDefaults standardUserDefaults] setObject:pushSound forKey:kApnsSoundEnabled];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Get Bundle Info for Remote Registration (handy if you have more than one app)
    NSString *clientID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceName = dev.name;
    NSString *deviceModel = dev.model;
    NSString *deviceSystemVersion = dev.systemVersion;
    
    NSDictionary *deviceData = @{
                                 @"deviceUUID": deviceUUID,
                                 @"deviceToken": token,
                                 @"clientID": clientID,
                                 
                                 @"appName": appName,
                                 @"appVersion": appVersion,
                                 @"deviceName": deviceName,
                                 @"deviceModel": deviceModel,
                                 @"deviceVersion": deviceSystemVersion,
                                 
                                 @"pushBadge": pushBadge,
                                 @"pushAlert": pushAlert,
                                 @"pushSound": pushSound,
#ifdef DEV
                                 @"development": @"true",
#else
                                 @"development": @"false",
#endif
                                 @"status": @"active"
                                 };
    
    [[SCSHuntrClient sharedClient] registerDevice:deviceUUID params:deviceData withSuccessBlock:^(id response) {
        NSLog(@"registerDevice: %@",response);
    } failureBlock:^(NSString *errorString) {
        NSLog(@"registerDevice error: %@",errorString);
    }];
    
#endif
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    
#if TARGET_IPHONE_SIMULATOR
    [[SCSHuntrEnviromentManager sharedManager] approveDeviceAPNS];
#endif
}

/**
 * Local Notification Received while application was open.
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
#if !TARGET_IPHONE_SIMULATOR
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Received Push Notification"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
#endif
    //    if (notification) [[UZNotificationManager sharedManager] didReceiveLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#if !TARGET_IPHONE_SIMULATOR
    
    SCSPushNotification * pn = [SCSPushNotification pushNotificationWithUserInfo:userInfo];
    [self performPushNotification:pn];
    
    if([userInfo[@"aps"][@"content-available"] intValue] == 1) //it's the silent notification
    {
//        [self fireLocalNotification:@"Silent Push"];
    }
    else {
//        [self fireLocalNotification:@"Loud Push"];
    }
    
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    SCSPushNotification * pn = [SCSPushNotification pushNotificationWithUserInfo:userInfo];
    [self performPushNotification:pn];
    
    if([userInfo[@"aps"][@"content-available"] intValue] == 1) //it's the silent notification
    {
        if (completionHandler) completionHandler(UIBackgroundFetchResultNewData);
//        [self fireLocalNotification:@"Silent Push"];
    }
    else {
        if (completionHandler) completionHandler(UIBackgroundFetchResultNoData);
//        [self fireLocalNotification:@"Loud Push"];
    }
}


#pragma mark - User Action Functions

- (void)requestUserToRegisterWithPushNotifications
{
    //    if (![[NSUserDefaults standardUserDefaults] boolForKey:kApnsUserApproval]) {
    if ( ![SCSHuntrEnviromentManager sharedManager].isDeviceAPNSApproved ) {
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Huntr Notification" message:@"In order for Huntr to function properly, please accept the push notification request when prompted." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * thankYouAction = [UIAlertAction actionWithTitle:@"Thank You" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self promptUserToRegisterPushNotifications];
        }];
        
        [alertVC addAction:thankYouAction];
        alertVC.preferredAction = thankYouAction;
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
        
    }
    else {
        
        [self promptUserToRegisterPushNotifications];
    }
}

- (void)promptUserToRegisterPushNotifications
{
//#if !TARGET_IPHONE_SIMULATOR
    // Let the device know we want to receive push notifications
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
//#endif
}


#pragma mark - Private Helpers

- (void)fireLocalNotification:(NSString*)alertBody
{
    // Fire off the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    //    localNotification.fireDate = nil;
    localNotification.alertBody = alertBody;
    //    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
