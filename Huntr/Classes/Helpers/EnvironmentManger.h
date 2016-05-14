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
- (BOOL) hasJoinedTeam:(NSString *)teamId;

- (BOOL) isReadyForGame;

- (void) registerGame:(NSString *)gameId;
- (void) registerPlayerName:(NSString *)playerName;
- (void) registerTeam:(NSString *)teamId;

- (NSString *) playerNameInGame:(NSString *)gameId;

@end
