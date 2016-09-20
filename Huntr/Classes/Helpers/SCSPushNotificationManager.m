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

#import "SCSHuntrRootViewController.h"
#import "RegisterUserViewController.h"

#import <TSMessages/TSMessageView.h>
@interface SCSPushNotification ()

@end

@implementation SCSPushNotificationManager


- (void)performPushNotification:(SCSPushNotification *)pushNotification
{
    /*
     aps =     {
         "content-available" = 1;
     };
     messageFrom = "Game Master";
     payload =     {
         gameID = 57883313c327d30ac28b5f03;
         teamID = 57c5a31fdbf6599b475dcecb;
         type = TSUPN;
     };
     */
    
//    TSUPN GSUPN CSUPN ASUPN PSUPN
    
    NSDictionary * postPayload = nil;
    if (pushNotification) postPayload = @{@"pn":pushNotification};
    
    if ([pushNotification.payload[@"type"] isEqualToString:@"GSUPN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationGameStatusUpdate object:self userInfo:postPayload];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self handelGameStatusUpdatePushNotification:pushNotification];
        });
        
    }
    else if ([pushNotification.payload[@"type"] isEqualToString:@"TSUPN"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationTeamStatusUpdate object:self userInfo:postPayload];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self handleTeamStatusUpdatePushNotification:pushNotification];
        });

    }
    
    else if ([pushNotification.payload[@"type"] isEqualToString:@"PAPN"] ||
             [pushNotification.payload[@"type"] isEqualToString:@"PRPN"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationTeamStatusUpdate object:self userInfo:postPayload];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self handlePlayersOnTeamStatusUpdatePushNotification:pushNotification];
        });
    }
    else if ([pushNotification.payload[@"type"] isEqualToString:@"CSUPN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationClueStatusUpdate object:self userInfo:postPayload];
    }
    else if ([pushNotification.payload[@"type"] isEqualToString:@"ASUPN"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationAnswerStatusUpdate object:self userInfo:postPayload];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationTeamStatusUpdate object:self userInfo:postPayload];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self handleAnswerStatusUpdatePushNotification:pushNotification];
        });
        
    }
    else if ([pushNotification.payload[@"type"] isEqualToString:@"PSUPN"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SCSPushNotificationPlayerStatusUpdate object:self userInfo:postPayload];
    }
}


#pragma mark - Object Lifecycle

+ (SCSPushNotificationManager *)sharedClient {
    static SCSPushNotificationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SCSPushNotificationManager alloc] init];
        [TSMessage addCustomDesignFromFileWithName:@"SCSMessageDesign.json"];
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidRegisterForRemoteNotificationsWithDeviceToken object:nil];
        
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidRegisterForRemoteNotificationsWithDeviceToken object:nil];
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
        
        UIViewController * vc = [(UINavigationController *)kAppWindow.rootViewController visibleViewController];
        [UIAlertController showAlertInViewController:vc withTitle:@"Received Push Notification" message:notification.alertBody cancelButtonTitle:@"Ok" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:nil];
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
        
//        [self promptUserToRegisterPushNotifications];
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

- (void) handelGameStatusUpdatePushNotification:(SCSPushNotification *) notification
{
    NSString * gameId = notification.payload[@"gameID"];
    [[SCSHuntrClient sharedClient]getGameById:gameId successBlock:^(id response) {
        
        NSString * gameName = [(SCSGame*)response gameName];
        SCSGameStatus status = [(SCSGame*)response status];
        NSString * subtitle;
        if (status == SCSGameStatusNotStarted){
            subtitle = [NSString stringWithFormat:@"New game \"%@\" created !!!", gameName];
        }
        else if (status == SCSGameStatusInProgress) {
            subtitle = [NSString stringWithFormat:@"Game \"%@\" begins!!!", gameName];
        }
        else if (status == SCSGameStatusCompleted ) {
            subtitle = [NSString stringWithFormat:@"Game \"%@\" is end!!!", gameName];

        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [TSMessage showNotificationWithTitle:@"Huntr Notification"
                                        subtitle:NSLocalizedString(subtitle, nil)
                                            type:TSMessageNotificationTypeMessage];
        });
        
    } failureBlock:nil];

}

- (void) handleTeamStatusUpdatePushNotification:(SCSPushNotification *) notification
{
    NSString * gameId = notification.payload[@"gameID"];
    NSString * teamId = notification.payload[@"teamID"];
    
    [[SCSHuntrClient sharedClient]getGameById:gameId successBlock:^(id response) {
        
        __block NSString * gameName = [(SCSGame*)response gameName];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SCSHuntrClient sharedClient]getTeamById:teamId gameId:gameId successBlock:^(id response) {
                NSString *  teamName = response;
                NSString * subtitle  =[NSString stringWithFormat:@"Team %@ added into Game %@", teamName, gameName];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TSMessage showNotificationWithTitle:@"Huntr Notification"
                                                subtitle:NSLocalizedString(subtitle, nil)
                                                    type:TSMessageNotificationTypeMessage];
                });
                
                
            } failureBlock:nil];
            
        });
    } failureBlock:nil];

}

- (void) handlePlayersOnTeamStatusUpdatePushNotification:(SCSPushNotification *) notification
{
    NSString * gameId = notification.payload[@"gameID"];
    NSString * playerId = notification.payload[@"playerID"];
    NSString * teamId = notification.payload[@"teamID"];
    NSString * type = notification.payload[@"type"];
    
    [[SCSHuntrClient sharedClient]getTeamById:teamId gameId:gameId successBlock:^(id response) {
        __block NSString * teamName = response;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SCSHuntrClient sharedClient] getPlayerById:playerId successBlock:^(id response) {
                NSString * playerName = response;
                NSString * subtitle = nil;
                if ([type isEqualToString:@"PAPN"])
                {
                    subtitle = [NSString stringWithFormat:@"%@ just joins %@", playerName, teamName];
                }
                else
                {
                    subtitle = [NSString stringWithFormat:@"oops %@ left %@", playerName, teamName];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TSMessage showNotificationWithTitle:@"Huntr Notification"
                                                subtitle:NSLocalizedString(subtitle, nil)
                                                    type:TSMessageNotificationTypeMessage];
                });
                

                
            } failureBlock:nil];
        });
    } failureBlock:nil];
}

- (void) handleAnswerStatusUpdatePushNotification:(SCSPushNotification *) notification
{
    NSString * gameId = notification.payload[@"gameID"];
    NSString * clueId = notification.payload[@"clueID"];
    NSString * teamId = notification.payload[@"teamID"];
    NSString * answerId = notification.payload[@"answerID"];
    
    BOOL isFirstAnswer = (answerId == nil);
    
    [[SCSHuntrClient sharedClient]getTeamById:teamId gameId:gameId successBlock:^(id response) {
        __block NSString * teamName = response;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SCSHuntrClient sharedClient]getClueById:clueId successBlock:^(id response) {
                NSString * subtitle;
                SCSClueState status = [(SCSClue*)response clueState];
                NSString * desc = [(SCSClue*)response clueDescription];
                if (isFirstAnswer)
                {
                    subtitle = [NSString stringWithFormat:@"Hurry up ~~~ \"%@\" is the  first team submit answer to clue \"%@\"", teamName, desc];

                }
                else
                {
                    if (status == SCSClueStateAnswerAccepted) {
                        subtitle = [NSString stringWithFormat:@"Wee ~~~ Team \"%@\" earend points from \"%@\"", teamName, desc];
                    }
                    else if (status == SCSClueStateAnswerPendingReview) {
                        subtitle = [NSString stringWithFormat:@"Good Job ! Your team has submitted answer to clue"];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TSMessage showNotificationWithTitle:@"Huntr Notification"
                                                subtitle:NSLocalizedString(subtitle, nil)
                                                    type:TSMessageNotificationTypeMessage];
                });

            } failureBlock:nil];
        });
    } failureBlock:nil];
}


@end
