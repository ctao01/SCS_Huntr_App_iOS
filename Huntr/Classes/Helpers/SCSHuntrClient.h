//
//  SCSHuntrClient.h
//  Huntr
//
//  Created by Andrew Olson on 6/4/14.
//  Copyright (c) 2013 SunGard Consulting Services. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "SCSPlayer.h"

#define API_VERSION 2.0

typedef enum {
    HTTPStatusCodeSuccess = 200,
    HTTPStatusCodeBadRequest = 400,
    HTTPStatusCodeUnauthorized = 401,
    HTTPStatusCodeForbidden = 403,
    HTTPStatusCodeNotFound = 404,
    HTTPStatusCodeServerError = 500,
    HTTPStatusCodeUnknown = 0
} HTTPStatusCode;

typedef void (^SCSHuntrClientSuccessBlock)(id response);
typedef void (^SCSHuntrClientSuccessBlockArray)(NSArray * arrayResult);
typedef void (^SCSHuntrClientFailureBlock)(NSString * errorString);

@interface SCSHuntrClient : AFHTTPRequestOperationManager

+ (SCSHuntrClient *)sharedClient;

@property (retain, nonatomic) NSString * pushToken;

/*CRUD - Version 1.0 */

- (void) getAllGames:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) getGameById:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) getScoreboardByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) getAllTeamsByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) getAllTeamsWithSuccessBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;

- (void) addTeamToGame:(id)gameData successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) getPlayersByTeam:(NSString *)teamId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) addPlayerToTeam:(NSString *)teamId successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) renamePlayerName:(NSString*)playerName withSuccessBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;


- (void) getCluesByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) getCluesWithSuccessBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;


- (void) getAnswersByTeam:(NSString *)teamId andGame:(NSString*)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;
- (void) postAnswer:(id)answer withClue:(NSString*)clueId type:(NSString*)clueType successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;

/*CRUD - Version 2.0 */

- (void) registerDevice:(NSString*)deviceUUID params:(NSDictionary*)params withSuccessBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock;

@end
