//
//  SCSHuntrClient.m
//  Huntr
//
//  Created by Andrew Olson on 6/4/14.
//  Copyright (c) 2013 SunGard Consulting Services. All rights reserved.
//

#import "SCSHuntrClient.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFHTTPRequestOperationManager.h"
#import "SCSEnvironment.h"
#import "SCSGame.h"

//TODO: Add Prod/Dev schemes
static NSString * const kSCSHuntrAPIBaseURLString = @"http://uzhome.no-ip.org:3000/api";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://huntr-api.herokuapp.com/";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://BAPKAG.local:3000/";

@implementation SCSHuntrClient

#pragma mark - init
+ (SCSHuntrClient *)sharedClient {
    static SCSHuntrClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SCSHuntrClient alloc] initWithBaseURLString:kSCSHuntrAPIBaseURLString];
    });
    
    return _sharedClient;
}


- (id) initWithBaseURLString:(NSString *) urlString {
    self = [super initWithBaseURL:[NSURL URLWithString:urlString]];
    if (self) {
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable:
                    NSLog(@"No Connection");
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    NSLog(@"WIFI");
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    NSLog(@"3G");
                    break;
                default:
                    NSLog(@"Unknown network status");
                    break;
            }
        }];
        
        AFSecurityPolicy * unsingedSSLCertificatePolicy = [[AFSecurityPolicy alloc] init];
        [unsingedSSLCertificatePolicy setAllowInvalidCertificates:YES];
        self.securityPolicy = unsingedSSLCertificatePolicy;
        
        [self.reachabilityManager startMonitoring];
        
    }
    
    return self;
}

- (NSString* ) urlStringWithEndPoint:(NSString *)endPoint
{
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",kSCSHuntrAPIBaseURLString, endPoint];
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return  urlString;
}

#pragma mark - Public

- (BOOL) checkReachability:(SCSHuntrClientFailureBlock) failureBlock {
    if (![self.reachabilityManager isReachable]) {
        if (failureBlock) {
            //Network reachability failed
        }
        return NO;
    }
    return YES;
}

#pragma makr - GAME(S)
- (void) getAllGames:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = @"games/simple";
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSGame alloc]initWithJSON:obj]];
            }];
            successBlock(array);
        }
        else {
            NSLog(@"the only one game: %@", responseObject);
            failureBlock(@"");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

- (void) getGameById:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"games/%@",gameId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"game: %@", responseObject);
        }
        else
        {
            NSLog(@"operation error:%ld",[operation.responseObject statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)operation.response.statusCode]);
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

- (void) getScoreboardByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"game/scoreboard/%@",gameId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSTeam alloc]initWithJSON:obj]];
            }];
            successBlock(array);
        }
        else
        {
            NSLog(@"operation error:%ld",[operation.responseObject statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)operation.response.statusCode]);
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

#pragma makr - TEAM(S)
- (void) getAllTeamsByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"team/%@",gameId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSTeam alloc]initWithJSON:obj]];
            }];
            successBlock(array);
        }
        else
        {
            NSLog(@"operation error:%ld",[operation.responseObject statusCode]);
            failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)operation.response.statusCode]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}


- (void) addTeamToGame:(id)gameData successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * currentGameId = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_game"];
    NSString * endPoint = [NSString stringWithFormat:@"team/%@",currentGameId];

    [self POST:[self urlStringWithEndPoint:endPoint] parameters:gameData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) successBlock((NSArray*)responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

- (void) getPlayersByTeam:(NSString *)teamId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"player/%@",teamId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSPlayer alloc]initWithJSON:obj]];
            }];
            successBlock(array);
        }
        else
        {
            NSLog(@"operation error:%ld",[operation.responseObject statusCode]);
            failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)operation.response.statusCode]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];


}

- (void) addPlayerToTeam:(NSString *)teamId successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * currentPlayer= [[NSUserDefaults standardUserDefaults]objectForKey:@"current_player"];

    NSString * endPoint = [NSString stringWithFormat:@"player/%@/%@/token", teamId, currentPlayer];
    
    [self POST:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) successBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

#pragma mark - Clues and Answers

- (void) getCluesByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"clues/%@",gameId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSClue alloc]initWithJSON:obj]];
            }];
            successBlock(array);
        }
        else
        {
            NSLog(@"operation error:%ld",[operation.responseObject statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)operation.response.statusCode]);
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

- (void) getAnswersByTeam:(NSString *)teamId andGame:(NSString*)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"answers/%@/%@",gameId,teamId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            successBlock(responseObject);
        }
        else
        {
            NSLog(@"operation error:%ld",[operation.responseObject statusCode]);
            failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)operation.response.statusCode]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];

}

- (void) postAnswer:(id)answer withClue:(NSString*)clueId type:(NSString*)clueType successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * currentTeamId = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_team"];

    NSString * endPoint = [NSString stringWithFormat:@"answers/%@/%@/%@/%@",clueType,clueId,currentTeamId, [[SCSEnvironment sharedInstance]currentPlayer]];
    [self POST:[self urlStringWithEndPoint:endPoint] parameters: answer success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end