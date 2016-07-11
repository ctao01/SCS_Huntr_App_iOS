//
//  RegisterUserViewController.m
//  Huntr
//
//  Created by Justin Leger on 7/1/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "RegisterUserViewController.h"
#import <SimpleAuth/SimpleAuth.h>

@implementation RegisterUserViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureAuthorizaionProviders];
}

#pragma mark - Private

- (void)configureAuthorizaionProviders {
    
    // consumer_key and consumer_secret are required
    
    NSDictionary * twitterConfiguration = @{@"consumer_key":@"DbxTxob8nYFp4ckEyADEMWypZ",
                                            @"consumer_secret":@"0syUjrz5T0SposPR4tgRdD2Z88UESqTB8JEmeXmEIVBkr4ri6l"};
    
    SimpleAuth.configuration[@"twitter-web"] = @{
                                                 @"consumer_key" : @"KEY",
                                                 @"consumer_secret" : @"SECRET"
                                                 };
    
    SimpleAuth.configuration[@"twitter"] = twitterConfiguration;
    SimpleAuth.configuration[@"twitter-web"] = twitterConfiguration;
    
    NSDictionary * facebookConfiguration = @{@"app_id":@"1047912565275705", @"app_secret":@"e558799f10e16dba4491ed3466949d4f"};
    
    // app_id is required
    SimpleAuth.configuration[@"facebook"] = facebookConfiguration;
    SimpleAuth.configuration[@"facebook-web"] = facebookConfiguration;
    
    // client_id, client_secret, and redirect_uri are required
    SimpleAuth.configuration[@"linkedin-web"] = @{@"client_id":@"78trq7kw2uifbj", @"client_secret":@"xETGqwEQg6Y74e1A", @"redirect_uri":@"https://com.appcoda.linkedin.oauth/oauth"};
}      

- (IBAction)registerUserFacebook:(id)sender {
    [SimpleAuth authorize:@"facebook" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
        
        if (error && error.code == 102) {
            [SimpleAuth authorize:@"facebook-web" completion:^(id responseObject, NSError *error) {
                NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
            }];
        }
    }];
}

- (IBAction)registerUserTwitter:(id)sender {
    [SimpleAuth authorize:@"twitter" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
        
        if (error && error.code == 102) {
            [SimpleAuth authorize:@"twitter-web" completion:^(id responseObject, NSError *error) {
                NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
            }];
        }
    }];
}

- (IBAction)registerUserLinkedIn:(id)sender {
    [SimpleAuth authorize:@"linkedin-web" completion:^(id responseObject, NSError *error) {
        NSLog(@"\nResponse: %@\nError:%@", responseObject, error);
    }];
}

@end
