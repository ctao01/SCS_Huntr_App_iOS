//
//  SCSHuntrEnviromentManager.h
//  Huntr
//
//  Created by Justin Leger on 7/16/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCSRegisteredPlayer.h"
#import "SCSPlayer.h"
#import "SCSGame.h"
#import "SCSTeam.h"

@interface SCSHuntrEnviromentManager : NSObject


#pragma mark - Object Lifecycle

+ (instancetype)sharedManager;


#pragma mark - APNS and Device UUID

@property (nonatomic, strong) NSString * deviceUUID;

@property (nonatomic, readonly) BOOL isDeviceAPNSApproved;
- (void) approveDeviceAPNS;


#pragma mark - Game Properties

@property (nonatomic, readonly) BOOL hasActiveGame;
@property (nonatomic, strong) NSString * activeGameID;
@property (nonatomic, strong) SCSGame * activeGame;


#pragma mark - Team Properties

@property (nonatomic, readonly) BOOL hasActiveTeam;
@property (nonatomic, readonly) NSString * activeTeamID;


#pragma mark - Player Actions and Properties

@property (nonatomic, strong) SCSRegisteredPlayer * registeredPlayer;

- (void) joinGameID:(NSString *)gameID withTeamID:(NSString *)teamID;

- (NSString *) playerTeamIDForGameID:(NSString *)gameID;

- (BOOL) isPlayerMemberOfGameID:(NSString *)gameID;
- (BOOL) isPlayerMemberOfGameID:(NSString *)gameID andTeamID:(NSString *)teamID;

- (BOOL) isPlayerMemberOfTeamID:(NSString *)teamID;

@end
