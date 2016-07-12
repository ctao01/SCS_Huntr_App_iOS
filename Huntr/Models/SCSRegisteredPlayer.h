//
//  SCSRegisteredPlayer.h
//  Huntr
//
//  Created by Justin Leger on 7/11/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSPlayer.h"

@interface SCSRegisteredPlayer : SCSPlayer

@property (retain, nonatomic) NSString *authToken;
@property (retain, nonatomic) NSString *authType;
@property (retain, nonatomic) NSString *authID;
@property (retain, nonatomic) NSString *email;

@end
