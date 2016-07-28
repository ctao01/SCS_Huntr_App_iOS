//
//  RegisterUserViewController.m
//  Huntr
//
//  Created by Justin Leger on 7/1/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "RegisterUserViewController.h"
#import "SCSHuntrRootViewController.h"
#import "AppDelegate.h"
#import "SCSRegisteredPlayer.h"
#import <SimpleAuth/SimpleAuth.h>

@implementation RegisterUserViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureAuthorizaionProviders];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate * appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate requestUserToRegisterWithPushNotifications];
}

#pragma mark - Private

- (void)configureAuthorizaionProviders {
    
    // consumer_key and consumer_secret are required
    
    NSDictionary * twitterConfiguration = @{@"consumer_key":    @"DbxTxob8nYFp4ckEyADEMWypZ",
                                            @"consumer_secret": @"0syUjrz5T0SposPR4tgRdD2Z88UESqTB8JEmeXmEIVBkr4ri6l"};
    
    SimpleAuth.configuration[@"twitter"] = twitterConfiguration;
    SimpleAuth.configuration[@"twitter-web"] = twitterConfiguration;
    
    NSDictionary * facebookConfiguration = @{@"app_id":     @"1047912565275705",
                                             @"app_secret": @"e558799f10e16dba4491ed3466949d4f"};
    
    // app_id is required
    SimpleAuth.configuration[@"facebook"] = facebookConfiguration;
    SimpleAuth.configuration[@"facebook-web"] = facebookConfiguration;
    
    // client_id, client_secret, and redirect_uri are required
    SimpleAuth.configuration[@"linkedin-web"] = @{@"client_id":     @"78trq7kw2uifbj",
                                                  @"client_secret": @"xETGqwEQg6Y74e1A",
                                                  @"redirect_uri":  @"https://com.appcoda.linkedin.oauth/oauth"};
}


//var deviceUUID = req.params.deviceUUID;
//
//var authToken = req.body.authToken;
//
//var authType = req.body.authType;
//var authID = req.body.authID;
//
//var playerName = req.body.playerName;
//var email = req.body.email;


- (void)registerPlayer:(NSDictionary *)playerInfo
{
//    NSString * deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kApnsDeviceToken];
    NSString * deviceUUID = [SCSHuntrEnviromentManager sharedManager].deviceUUID;   
    
    [[SCSHuntrClient sharedClient] registerPlayer:deviceUUID params:playerInfo withSuccessBlock:^(id response) {
        // Swtitch views.
        // Create a SCSRegisteredPlayer object.
        NSLog(@"\nResponse: %@", response);
        
//        SCSHuntrRootViewController *rootController =(SCSHuntrRootViewController*)[[(AppDelegate*)[[UIApplication sharedApplication]delegate] window]rootViewController];
        
        SCSHuntrRootViewController *rootController =(SCSHuntrRootViewController*)[[[UIApplication sharedApplication] delegate] window].rootViewController;
        [rootController showNavigationComponent];
        
        SCSRegisteredPlayer * registeredPlayer = [[SCSRegisteredPlayer alloc] initWithJSON:response];
        
        [SCSHuntrEnviromentManager sharedManager].registeredPlayer = registeredPlayer;
        
//        NSData *encodedRegisteredPlayer = [NSKeyedArchiver archivedDataWithRootObject:registeredPlayer];
//        [[NSUserDefaults standardUserDefaults] setObject:encodedRegisteredPlayer forKey:kCurrentPlayer];
//        [[NSUserDefaults standardUserDefaults] setObject:registeredPlayer.playerName forKey:kCurrentPlayerName];
//        [[NSUserDefaults standardUserDefaults] setObject:registeredPlayer.playerID forKey:kCurrentPlayerId];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failureBlock:^(NSString *errorString) {
        // Alert that user chould not be registered.
        NSLog(@"\nResponse Error:%@", errorString);
    }];
}


- (IBAction)registerUserFacebook:(id)sender {
    
    [SimpleAuth authorize:@"facebook" completion:^(id responseObject, NSError *error) {
        
        NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
        
        if (error && error.code == 102) {
            [SimpleAuth authorize:@"facebook-web" completion:^(id responseObject, NSError *error) {
                
                NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
                
                NSMutableDictionary * playerInfo = [self playerInfoFromFacebook:responseObject];
                
                if (!error && playerInfo) {
                    [self registerPlayer:playerInfo];
                }
                else {
                    // Deal with error or response object being a dictionary.
                }
            }];
        }
        else {
            
            NSMutableDictionary * playerInfo = [self playerInfoFromFacebook:responseObject];
            
            if (!error && playerInfo) {
                [self registerPlayer:playerInfo];
            }
            else {
                // Deal with error or response object being a dictionary.
            }
            
        }
    }];
}

- (IBAction)registerUserTwitter:(id)sender {
    
    [SimpleAuth authorize:@"twitter" completion:^(id responseObject, NSError *error) {
        
        NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
        
        if (error && error.code == 102) {
            [SimpleAuth authorize:@"twitter-web" completion:^(id responseObject, NSError *error) {
                NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
                
                NSMutableDictionary * playerInfo = [self playerInfoFromTwitter:responseObject];
                
                if (!error && playerInfo) {
                    [self registerPlayer:playerInfo];
                }
                else {
                    // Deal with error or response object being a dictionary.
                }
            }];
        }
        else {
            
            NSMutableDictionary * playerInfo = [self playerInfoFromTwitter:responseObject];
            
            if (!error && playerInfo) {
                [self registerPlayer:playerInfo];
            }
            else {
                // Deal with error or response object being a dictionary.
            }

        }
    }];
}

- (IBAction)registerUserLinkedIn:(id)sender {
    
    [SimpleAuth authorize:@"linkedin-web" completion:^(id responseObject, NSError *error) {
        
        NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
        
        NSMutableDictionary * playerInfo = [self playerInfoFromLinkedIn:responseObject];
        
        if (!error && playerInfo) {
            
            [[SCSHuntrClient sharedClient] getLinkedInInfo:playerInfo[@"authToken"] params:nil withSuccessBlock:^(id response) {
                
                NSLog(@"\nResponse: %@", response);
                
                if (response && [response isKindOfClass:[NSDictionary class]]) {
                    playerInfo[@"email"] = response[@"emailAddress"];
                }
                
                [self registerPlayer:playerInfo];
                
            } failureBlock:^(NSString *errorString) {
                
                [self registerPlayer:playerInfo];
            }];
        }
        else {
            // Deal with error or response object being a dictionary.
        }
    }];
}

- (NSMutableDictionary *)playerInfoFromLinkedIn:(id)responseObject
{
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary * playerInfo = [NSMutableDictionary new];
        
        NSDictionary * payload = (NSDictionary *) responseObject;
        
//        NSString * deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kApnsDeviceToken];
        NSString * authToken = payload[@"credentials"][@"token"];
        
        NSString * authType = payload[@"provider"];
        NSString * authID = payload[@"raw_info"][@"id"];
        
        NSString * firstName = payload[@"user_info"][@"first_name"];
        NSString * lastName = payload[@"user_info"][@"last_name"];
        NSString * playerName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
//        if (deviceUUID) playerInfo[@"deviceUUID"] = deviceUUID;
        if (authToken) playerInfo[@"authToken"] = authToken;
        
        if (authType) playerInfo[@"authType"] = authType;
        if (authID) playerInfo[@"authID"] = authID;
        
        if (playerName) playerInfo[@"playerName"] = playerName;
        
        NSLog(@"\playerInfo: %@", playerInfo);
        
        return playerInfo;
    }
    else {
        return nil;
    }
}

- (NSMutableDictionary *)playerInfoFromFacebook:(id)responseObject
{
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary * playerInfo = [NSMutableDictionary new];
        
        NSDictionary * payload = (NSDictionary *) responseObject;
        
        //        NSString * deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kApnsDeviceToken];
        NSString * authToken = payload[@"credentials"][@"token"];
        
        NSString * authType = payload[@"provider"];
        NSString * authID = payload[@"uid"];
        
        NSString * playerName = payload[@"info"][@"name"];
        NSString * email = payload[@"info"][@"email"];
        
        //        if (deviceUUID) playerInfo[@"deviceUUID"] = deviceUUID;
        if (authToken) playerInfo[@"authToken"] = authToken;
        
        if (authType) playerInfo[@"authType"] = authType;
        if (authID) playerInfo[@"authID"] = authID;
        
        if (playerName) playerInfo[@"playerName"] = playerName;
        if (email) playerInfo[@"email"] = email;
        
        NSLog(@"\playerInfo: %@", playerInfo);
        
        return playerInfo;
    }
    else {
        return nil;
    }
}

- (NSMutableDictionary *)playerInfoFromTwitter:(id)responseObject
{
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary * playerInfo = [NSMutableDictionary new];
        
        NSDictionary * payload = (NSDictionary *) responseObject;
        
        //        NSString * deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kApnsDeviceToken];
        NSString * authToken = payload[@"credentials"][@"token"];
        
        NSString * authType = payload[@"provider"];
        NSString * authID = payload[@"uid"];
        
        NSString * playerName = payload[@"info"][@"name"];
        NSString * email = payload[@"info"][@"email"];
        
        //        if (deviceUUID) playerInfo[@"deviceUUID"] = deviceUUID;
        if (authToken) playerInfo[@"authToken"] = authToken;
        
        if (authType) playerInfo[@"authType"] = authType;
        if (authID) playerInfo[@"authID"] = authID;
        
        if (playerName) playerInfo[@"playerName"] = playerName;
        if (email) playerInfo[@"email"] = email;
        
        NSLog(@"\playerInfo: %@", playerInfo);
        
        return playerInfo;
    }
    else {
        return nil;
    }
}

@end
