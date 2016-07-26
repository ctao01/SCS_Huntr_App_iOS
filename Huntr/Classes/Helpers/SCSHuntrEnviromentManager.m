//
//  SCSHuntrEnviromentManager.m
//  Huntr
//
//  Created by Justin Leger on 7/16/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSHuntrEnviromentManager.h"


@interface SCSHuntrEnviromentManager() {
    NSMutableDictionary * _playerGameDataStore;
}

@property (nonatomic, readonly) NSMutableDictionary * playerGameDataStore;
@property (nonatomic, readonly) NSMutableDictionary * playerGameData;

@end




@implementation SCSHuntrEnviromentManager

@synthesize registeredPlayer = _registeredPlayer;
@synthesize deviceUUID = _deviceUUID;
@synthesize activeGameID = _activeGameID;
//@synthesize activeTeamID = _activeTeamID;


#pragma mark - Object Lifecycle

+ (instancetype)sharedManager
{
    static SCSHuntrEnviromentManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SCSHuntrEnviromentManager alloc] init];
    });
    
    return _sharedManager;
}


#pragma mark - APNS and Device UUID

-(NSString *) deviceUUID
{
    if (_deviceUUID != nil && _deviceUUID.length > 0) return _deviceUUID;
    
    NSString * deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:kDeviceUUID];
    
    if (deviceUUID != nil && deviceUUID.length > 0) {
        _deviceUUID = deviceUUID;
    }
    
    return _deviceUUID;
}

- (void) setDeviceUUID:(NSString *)deviceUUID
{
    if (_deviceUUID == deviceUUID) return;
    
    _deviceUUID = deviceUUID;
    
    if (deviceUUID != nil && deviceUUID.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceUUID forKey:kDeviceUUID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDeviceUUID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL) isDeviceAPNSApproved
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kApnsUserApproval];
}

- (void) approveDeviceAPNS
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kApnsUserApproval];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Game Properties

- (BOOL) hasActiveGame
{
    return self.activeGameID != nil ? YES : NO;
}


-(NSString *) activeGameID
{
    if (_activeGameID != nil && _activeGameID.length > 0) return _activeGameID;
    
    NSString * activeGameID = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentGameId];
    
    if (activeGameID != nil && activeGameID.length > 0) {
        _activeGameID = activeGameID;
    }
    
    return _activeGameID;
}

- (void) setActiveGameID:(NSString *)activeGameID
{
    if (_activeGameID == activeGameID) return;
    
    _activeGameID = activeGameID;
    
    if (activeGameID != nil && activeGameID.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:activeGameID forKey:kCurrentGameId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentGameId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) setActiveGame:(SCSGame *)activeGame
{
    if (_activeGame == activeGame) return;
    
    _activeGame = activeGame;
    
    self.activeGameID = activeGame ? activeGame.gameID : nil;
}


#pragma mark - Team Properties

- (BOOL) hasActiveTeam
{
    return self.activeGameID != nil && self.activeTeamID != nil ? YES : NO;
}

-(NSString *) activeTeamID
{
    return [self playerTeamIDForGameID:self.activeGameID];
}

//-(NSString *) activeTeamID
//{
//    if (_activeTeamID != nil && _activeTeamID.length > 0) return _activeTeamID;
//    
//    NSString * activeTeamID = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentTeamId];
//    
//    if (activeTeamID != nil && activeTeamID.length > 0) {
//        _activeTeamID = activeTeamID;
//    }
//    
//    return _activeTeamID;
//}
//
//- (void) setActiveTeamID:(NSString *)activeTeamID
//{
//    if (_activeTeamID == activeTeamID) return;
//    
//    _activeTeamID = activeTeamID;
//    
//    if (activeTeamID != nil && activeTeamID.length > 0) {
//        [[NSUserDefaults standardUserDefaults] setObject:activeTeamID forKey:kCurrentTeamId];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    else {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentTeamId];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//}
//
//- (void) setActiveTeam:(SCSTeam *)activeTeam
//{
//    if (_activeTeam == activeTeam) return;
//    
//    _activeTeam = activeTeam;
//    
//    self.activeGameID = activeTeam ? activeTeam.teamID : nil;
//}


#pragma mark - Player Actions and Properties

- (void) setRegisteredPlayer:(SCSRegisteredPlayer *)registeredPlayer
{
    if (_registeredPlayer == registeredPlayer) return;
    
    _registeredPlayer = registeredPlayer;
    
    if (registeredPlayer != nil) {
        NSData *encodedRegisteredPlayer = [NSKeyedArchiver archivedDataWithRootObject:registeredPlayer];
        [[NSUserDefaults standardUserDefaults] setObject:encodedRegisteredPlayer forKey:kCurrentPlayer];
        [[NSUserDefaults standardUserDefaults] setObject:registeredPlayer.playerName forKey:kCurrentPlayerName];
        [[NSUserDefaults standardUserDefaults] setObject:registeredPlayer.playerID forKey:kCurrentPlayerId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentPlayer];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentPlayerName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentPlayerId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (SCSRegisteredPlayer *) registeredPlayer
{
    if (_registeredPlayer == nil)  {
        
        NSData * storedPlayer = [[NSUserDefaults standardUserDefaults] dataForKey:kCurrentPlayer];
        SCSRegisteredPlayer * decodedRegisteredPlayer = (SCSRegisteredPlayer *)[NSKeyedUnarchiver unarchiveObjectWithData:storedPlayer];
        _registeredPlayer = decodedRegisteredPlayer;
        
    }
    
    return _registeredPlayer;
}

- (void) joinGameID:(NSString *)gameID withTeamID:(NSString *)teamID
{
    NSString * playerID = self.registeredPlayer.playerID;
    
    [self setPlayerID:playerID object:teamID forKey:gameID];
}

- (NSString *) playerTeamIDForGameID:(NSString *)gameID
{
    NSString * teamID = self.playerGameData[gameID];
    return teamID;
}

- (BOOL) isPlayerMemberOfGameID:(NSString *)gameID andTeamID:(NSString *)teamID
{
    return [teamID isEqualToString:[self playerTeamIDForGameID:gameID]];
}

- (BOOL) isPlayerMemberOfGameID:(NSString *)gameID
{
    return [self playerTeamIDForGameID:gameID] ? YES : NO;
}

- (BOOL) isPlayerMemberOfTeamID:(NSString *)teamID
{
    return [teamID isEqualToString:[self playerTeamIDForGameID:self.activeGameID]];
}

- (NSMutableDictionary *) playerGameData
{
    NSString * playerID = self.registeredPlayer.playerID;
    
    if (playerID) {
        id playerGameData = self.playerGameDataStore[playerID];
        
        if (!playerGameData) playerGameData = [NSMutableDictionary new];
        
        if (![playerGameData isMemberOfClass:[NSMutableDictionary class]]) {
            playerGameData = [(NSDictionary*)playerGameData mutableCopy];
        }
        
        self.playerGameDataStore[playerID] = playerGameData;
        
        return playerGameData;
    }
    
    return nil;
}

- (NSMutableDictionary *) playerGameDataStore
{
    if (_playerGameDataStore == nil) {
        NSMutableDictionary * playerGameDataStore = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPlayerGameDataStore].mutableCopy;
        if (!playerGameDataStore) playerGameDataStore = [NSMutableDictionary new];
        _playerGameDataStore = playerGameDataStore;
        
        NSLog(@"%@", _playerGameDataStore);
    }
    
    return _playerGameDataStore;
}

- (void) setPlayerID:(NSString *)playerID object:(id)object forKey:(NSString*)key
{
    NSAssert(playerID, @"playerID must not be nil");
    NSAssert(object, @"object must not be nil");
    NSAssert(key, @"key must not be nil");
    
    if (playerID && object && key) {
        
        self.playerGameData[key] = object;
//        self.playerGameDataStore[playerID] = self.playerGameData;
        
        [[NSUserDefaults standardUserDefaults] setObject:self.playerGameDataStore forKey:kPlayerGameDataStore];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"%@", self.playerGameDataStore);
    }
}

//- (SCSTeam *) activeGameTeamWithId:(NSString *)teamID
//{
//    if (self.activeGame == nil) return nil;
//    
//    __block SCSTeam * activeGameTeam = nil;
//    
//    [self.activeGame.teamList enumerateObjectsUsingBlock:^(SCSTeam * _Nonnull team, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([team.teamID isEqualToString:teamID]) {
//            activeGameTeam = team;
//            *stop = YES;
//        }
//    }];
//    
//    return activeGameTeam;
//}

@end
