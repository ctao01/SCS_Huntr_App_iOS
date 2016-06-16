//
//  SCSPushNotificationManager.m
//  Huntr
//
//  Created by Justin Leger on 6/16/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSPushNotificationManager.h"

@implementation SCSPushNotificationManager

+ (SCSPushNotificationManager *)sharedClient {
    static SCSPushNotificationManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SCSPushNotificationManager alloc] init];
    });
    
    return _sharedClient;
}

@end
