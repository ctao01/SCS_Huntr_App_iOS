//
//  AppDelegate.m
//  Hunter
//
//  Created by Joy Tao on 2/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "AppDelegate.h"
//#import "SCSEnvironment.h"
#import "NSString+UUID.h"

#import "SCSPushNotificationManager.h"
#import "SCSPushNotification.h"

#import "SCSHuntrRootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Huntrv2" bundle:[NSBundle mainBundle]];
    //    UIViewController *vc =[storyboard instantiateInitialViewController];
    
    
    // Handle APN on Terminated state, app launched because of APN
    [[SCSPushNotificationManager sharedClient] application:application didFinishLaunchingWithOptions:launchOptions];
    
    
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

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [[SCSPushNotificationManager sharedClient] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [[SCSPushNotificationManager sharedClient] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

/**
  * Local Notification Received while application was open.
  */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[SCSPushNotificationManager sharedClient] application:application didReceiveLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[SCSPushNotificationManager sharedClient] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[SCSPushNotificationManager sharedClient] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}


@end
