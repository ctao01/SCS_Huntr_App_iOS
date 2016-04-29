//
//  EnvironmentManger.h
//  Huntr
//
//  Created by Joy Tao on 4/21/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnvironmentManger : NSObject

+ (instancetype)sharedManager;

- (BOOL) hasJoinedGame:(NSString*)gameId;
- (BOOL) hasJoinedTeam:(NSString *)teamId inGame:(NSString *)gameId;
- (BOOL) isReadyForGame;

- (void) joinGame:(NSString *)gameId;
- (void) registerGame:(NSString *)gameId withPlayerName:(NSString *)playerName;
- (void) joinGame:(NSString *)gameId withTeamId:(NSString *)teamId;

//@property (nonatomic , readonly) NSDictionary *  currentGame;


@end
