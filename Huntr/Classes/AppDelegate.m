//
//  AppDelegate.m
//  Hunter
//
//  Created by Joy Tao on 2/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "AppDelegate.h"
#import "SCSEnvironment.h"
#import "NSString+UUID.h"

#import "SCSPushNotification.h"
#import "SCSHuntrRootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Huntrv2" bundle:[NSBundle mainBundle]];
//    UIViewController *vc =[storyboard instantiateInitialViewController];
    
    // Let the device know we want to receive push notifications
//    [self requestUserToRegisterWithPushNotifications];
    
    // Handle APN on Terminated state, app launched because of APN
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (payload) {
//        [self.pnListVC addPushNotifWithType:PushNotifTypeTM andUserInfo:payload];
        SCSPushNotification * pn = [SCSPushNotification pushNotificationWithType:SCSPushNotificationTypeTM andUserInfo:payload];
    }
    
    // Set root view controller and make windows visible
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.rootViewController = vc;
//    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    NSLog(@"My token is: %@", deviceToken);
    
    NSString *deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kDeviceUUID];
    
    if (!deviceUUID) {
        deviceUUID = [NSString stringWithNewUUID];
        [[NSUserDefaults standardUserDefaults] setObject:deviceUUID forKey:kDeviceUUID];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kApnsUserApproval];
        [[NSUserDefaults standardUserDefaults] synchronize];
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

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);
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
    
    UIApplicationState state = application.applicationState;
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
    
    SCSPushNotification * pn = [SCSPushNotification pushNotificationWithType:pnType andUserInfo:userInfo];
    
    if([userInfo[@"aps"][@"content-available"] intValue] == 1) //it's the silent notification
    {
        [self fireLocalNotification:@"Silent Push"];
    }
    else {
        [self fireLocalNotification:@"Loud Push"];
    }
    
#endif
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
#if !TARGET_IPHONE_SIMULATOR
    
    
    UIApplicationState state = application.applicationState;
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
    
    SCSPushNotification * pn = [SCSPushNotification pushNotificationWithType:pnType andUserInfo:userInfo];
    
    if([userInfo[@"aps"][@"content-available"] intValue] == 1) //it's the silent notification
    {
        if (completionHandler) completionHandler(UIBackgroundFetchResultNewData);
        [self fireLocalNotification:@"Silent Push"];
    }
    else {
        if (completionHandler) completionHandler(UIBackgroundFetchResultNoData);
        [self fireLocalNotification:@"Loud Push"];
    }
    
#endif
}

- (void) fireLocalNotification:(NSString*)alertBody
{
    // Fire off the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    //    localNotification.fireDate = nil;
    localNotification.alertBody = alertBody;
    //    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


-(void) requestUserToRegisterWithPushNotifications
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kApnsUserApproval]) {

        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"Huntr Notification" message:@"In order for Huntr to function properly, please accept the push notification request when prompted." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * thankYouAction = [UIAlertAction actionWithTitle:@"Thank You" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self promptUserToRegisterPushNotifications];
        }];
        
        [alertVC addAction:thankYouAction];
        alertVC.preferredAction = thankYouAction;
        
        [self.window.rootViewController presentViewController:alertVC animated:YES completion:nil];
    
    }
    else {
    
        [self promptUserToRegisterPushNotifications];
    }
}



-(void) promptUserToRegisterPushNotifications
{
#if !TARGET_IPHONE_SIMULATOR
  // Let the device know we want to receive push notifications
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}


@end
