//
//  EnvironmentManger.m
//  Huntr
//
//  Created by Joy Tao on 4/21/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "EnvironmentConstants.h"
#import "EnvironmentManger.h"

@implementation EnvironmentManger

+ (instancetype)sharedManager
{
    static EnvironmentManger *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[EnvironmentManger alloc] init];
    });
    
    return _sharedManager;
}


//TODO --
/*
 key: kCurrentGame (SCSGame)
 key: kCurrentTeam (teamId)
 key: kCurrentPlayerName (playerName)
 */

- (BOOL) hasJoinedGame:(NSString *)gameId
{
    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    if (joinedGames != nil)
    {
        NSArray * joinedGameIds = [joinedGames allKeys];
        return [joinedGameIds containsObject:gameId];
    }
    return NO;
}

- (NSString *) playerNameInGame:(NSString *)gameId
{
    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    return  [[joinedGames objectForKey:gameId] objectForKey:kPlayerName];
}

- (BOOL) hasJoinedTeam:(NSString *)teamId
{
    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    NSString * currentSelectedGame = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentGameId];
    
    NSDictionary * info = [joinedGames objectForKey:currentSelectedGame];
    if (info != nil) {
        NSString * joinedTeam = [info objectForKey:kTeamId];
        return ([joinedTeam isEqualToString: teamId]);
    }
    return NO;
}

//- (BOOL) hasJoinedTeam:(NSString *)teamId inGame:(NSString *)gameId
//{
//    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
//    NSDictionary * info = [joinedGames objectForKey:gameId];
//    if (info != nil) {
//        NSString * joinedTeam = [info objectForKey:kTeamId];
//        return ([joinedTeam isEqualToString: teamId]);
//    }
//    return NO;
//}

- (BOOL) isReadyForGame
{
    NSString * gameId = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentGameId];
    NSString * teamId = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamId];
    NSString * playerName = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentPlayerName];

    return (gameId != nil) && (teamId != nil) && (playerName != nil);
}


- (void) registerGame:(NSString *)gameId
{
    [[NSUserDefaults standardUserDefaults] setObject:gameId forKey:kCurrentGameId];

    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    if (joinedGames == nil) {
        NSDictionary * info = [NSDictionary new];
        NSDictionary * new = [NSDictionary dictionaryWithObjectsAndKeys:info,gameId, nil];
        [[NSUserDefaults standardUserDefaults]setObject:new forKey:KJoinedGames];
        
    }
    else
    {
        if([joinedGames objectForKey: gameId] == nil)
        {
            NSDictionary * info = [NSDictionary new];
            NSMutableDictionary * joinedGames = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames]];
            [joinedGames setObject:info forKey:gameId];
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:KJoinedGames];
            [[NSUserDefaults standardUserDefaults]setObject:mutableJoinedGames forKey:KJoinedGames];
        }
    }
    
}

- (void) registerPlayerName:(NSString *)playerName
{
    [[NSUserDefaults standardUserDefaults]setObject:playerName forKey:kCurrentPlayerName];
    
    NSString * selectedGameId = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentGameId];
    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    if (joinedGames == nil)
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:playerName,kPlayerName, nil];
        joinedGames = [NSDictionary dictionaryWithObjectsAndKeys:info ,selectedGameId, nil];
        [[NSUserDefaults standardUserDefaults]setObject:joinedGames forKey:KJoinedGames];
    }
    else
    {
        NSMutableDictionary * updatedInfo = [NSMutableDictionary dictionaryWithDictionary:[joinedGames objectForKey:selectedGameId]];
        [updatedInfo setObject:playerName forKey:kPlayerName];
        
        
        NSMutableDictionary * updatedGame = [NSMutableDictionary dictionaryWithDictionary:joinedGames];
        [updatedGame setObject:updatedInfo forKey:selectedGameId];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:KJoinedGames];
        [[NSUserDefaults standardUserDefaults]setObject:updatedGame forKey:KJoinedGames];
    }
}
/*
- (void) registerGame:(NSString *)gameId withPlayerName:(NSString *)playerName
{
    // List all games the user has joined
    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    if (joinedGames == nil)
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:playerName,kPlayerName, nil];
        joinedGames = [NSDictionary dictionaryWithObjectsAndKeys:info , gameId, nil];
        [[NSUserDefaults standardUserDefaults]setObject:joinedGames forKey:KJoinedGames];
    }
    else
    {
        NSMutableDictionary * updatedInfo = [NSMutableDictionary dictionaryWithDictionary:[joinedGames objectForKey:gameId]];
        [updatedInfo setObject:playerName forKey:kPlayerName];
        
        
        NSMutableDictionary * updatedGame = [NSMutableDictionary dictionaryWithDictionary:joinedGames];
        [updatedGame setObject:updatedInfo forKey:gameId];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:KJoinedGames];
        [[NSUserDefaults standardUserDefaults]setObject:updatedGame forKey:KJoinedGames];
    }
    
    
}*/

- (void) registerTeam:(NSString *)teamId
{
    [[NSUserDefaults standardUserDefaults]setObject:teamId forKey:kCurrentTeamId];
    
    NSString * selectedGameId = [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentGameId];

    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    if (joinedGames == nil)
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:teamId, kTeamId, nil];
        joinedGames = [NSDictionary dictionaryWithObjectsAndKeys:info, selectedGameId, nil];
        [[NSUserDefaults standardUserDefaults]setObject:joinedGames forKey:KJoinedGames];
    }
    else
    {
        NSMutableDictionary * updatedInfo = [NSMutableDictionary dictionaryWithDictionary:[joinedGames objectForKey:selectedGameId]];
        [updatedInfo setObject:teamId forKey:kTeamId];
        
        NSMutableDictionary * updatedGame = [NSMutableDictionary dictionaryWithDictionary:joinedGames];
        [updatedGame setObject:updatedInfo forKey:selectedGameId];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:KJoinedGames];
        [[NSUserDefaults standardUserDefaults]setObject:updatedGame forKey:KJoinedGames];
    }

}


/*
- (void) joinGame:(NSString *)gameId withTeamId:(NSString *)teamId
{
    // List all games the user has joined
    NSDictionary * joinedGames = [[NSUserDefaults standardUserDefaults]objectForKey:KJoinedGames];
    if (joinedGames == nil)
    {
        NSDictionary * info = [NSDictionary dictionaryWithObjectsAndKeys:teamId, kTeamId, nil];
        joinedGames = [NSDictionary dictionaryWithObjectsAndKeys:info , gameId, nil];
        [[NSUserDefaults standardUserDefaults]setObject:joinedGames forKey:KJoinedGames];
    }
    else
    {
        NSMutableDictionary * updatedInfo = [NSMutableDictionary dictionaryWithDictionary:[joinedGames objectForKey:gameId]];
        [updatedInfo setObject:teamId forKey:kTeamId];
        
        NSMutableDictionary * updatedGame = [NSMutableDictionary dictionaryWithDictionary:joinedGames];
        [updatedGame setObject:updatedInfo forKey:gameId];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:KJoinedGames];
        [[NSUserDefaults standardUserDefaults]setObject:updatedGame forKey:KJoinedGames];
    }
}
*/
@end
