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
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://uzhome.no-ip.org:3000/api";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://huntr-api.herokuapp.com/";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://BAPKAG.local:3000/";

#ifdef DEV
#define API_SERVER_BASE_URL @"http://ec2-54-173-88-68.compute-1.amazonaws.com:3333"
//#elif defined(STAGE)
//#define API_SERVER_BASE_URL @"http://ec2-54-173-88-68.compute-1.amazonaws.com:3033"
#else
#define API_SERVER_BASE_URL @"http://ec2-54-173-88-68.compute-1.amazonaws.com:3000"
#endif

#define API_CRUD_VERSION 2

@interface SCSHuntrClient ()
@property (nonatomic , readonly) NSString * gameId;
@property (nonatomic , readonly) NSString * teamId;
@property (nonatomic , readonly) NSString * playerId;
@property (nonatomic , readonly) NSString * playerName;

@end

@implementation SCSHuntrClient

#pragma mark - init

+ (SCSHuntrClient *)sharedClient {
    static SCSHuntrClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SCSHuntrClient alloc] initWithBaseURLString:API_SERVER_BASE_URL];
    });
    
    return _sharedClient;
}

- (NSString *) gameId
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentGameId];
}

- (NSString *) teamId
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentTeamId];
}

- (NSString *) playerName
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentPlayerName];
}

- (NSString *) playerId
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentPlayerId];
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
    NSString * urlString;
    switch (API_CRUD_VERSION) {
        case 1:
        {
            urlString = [NSString stringWithFormat:@"%@/api/%@",API_SERVER_BASE_URL, endPoint];
            urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
            break;
        case 2:
            urlString = [NSString stringWithFormat:@"%@/api/v2/%@",API_SERVER_BASE_URL, endPoint];
            break;
        default:
            break;
    }
    
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
            SCSGame * game = [[SCSGame alloc]initWithJSON:responseObject];
            successBlock(game);
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
    NSString * endPoint;
    switch (API_CRUD_VERSION) {
        case 1:
            endPoint = [NSString stringWithFormat:@"game/scoreboard/%@",gameId];
            break;
        case 2:
            endPoint = [NSString stringWithFormat:@"games/%@/scoreboard",gameId];
            break;
        default:
            break;
    }
    
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
    NSString * endPoint;
    switch (API_CRUD_VERSION) {
        case 1:
            endPoint = [NSString stringWithFormat:@"team/%@",gameId];
            break;
        case 2:
            endPoint = [NSString stringWithFormat:@"games/%@/teams", gameId];
            break;
        default:
            break;
    }
    
        
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSTeam alloc]initWithJSON:obj]];
            }];
            
            NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"teamName" ascending:YES];
            NSArray * arrayResult = [NSArray new];
            arrayResult = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSort, nil]];
            successBlock(arrayResult);
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

- (void) addTeamToGame:(id)gameData successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * currentGameId = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_game"];
    NSString * endPoint;
    switch (API_CRUD_VERSION) {
        case 1:
            endPoint = [NSString stringWithFormat:@"team/%@",currentGameId];
            break;
        case 2:
            endPoint = [NSString stringWithFormat:@"games/%@/teams",self.gameId];
            break;
        default:
            break;
    }
    
    [self POST:[self urlStringWithEndPoint:endPoint] parameters:gameData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            /*
             {
                 "name": "Test B",
                 "_id": "571e5a46e70cc8ef0c4fca7e",
                 "players": [],
                 "ranking": 0,
                 "score": 0
             }
             */
            SCSTeam * newTeam  = [[SCSTeam alloc]initWithJSON:responseObject];
            successBlock(newTeam);
        }
        else  {
            failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)operation.response.statusCode]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

- (void) getPlayersByTeam:(NSString *)teamId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint ;
    switch (API_CRUD_VERSION) {
        case 1:
             endPoint = [NSString stringWithFormat:@"player/%@",teamId];
            break;
        case 2:
            endPoint = [NSString stringWithFormat:@"teams/%@/players",teamId];
            break;
        default:
            break;
    }
    
    
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
    NSString * currentPlayer= [[NSUserDefaults standardUserDefaults]objectForKey:kCurrentPlayerName];
    NSString * endPoint;
    switch (API_CRUD_VERSION) {
        case 1:
        {
            endPoint = [NSString stringWithFormat:@"player/%@/%@/token", teamId, currentPlayer];
            [self POST:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (responseObject) successBlock(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failureBlock([error description]);
            }];
        }
            break;
        case 2:{
            endPoint = [NSString stringWithFormat:@"teams/%@/players", teamId];
            [self POST:[self urlStringWithEndPoint:endPoint] parameters:[NSDictionary dictionaryWithObjectsAndKeys:currentPlayer,@"playerName", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (responseObject) successBlock(responseObject);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failureBlock([error description]);
            }];
        }
            break;
        default:
            break;
    }
}

- (void) postPlayerName:(NSString*)playerName withSuccessBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"teams/%@/players/%@", self.teamId, self.playerId];
    [self POST:[self urlStringWithEndPoint:endPoint] parameters:[NSDictionary dictionaryWithObjectsAndKeys:playerName, @"playerName", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject != nil){
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];

}

#pragma mark - Clues and Answers

- (void) getCluesByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
   
    NSString * endPoint = [NSString stringWithFormat:@"clues/%@",gameId];
     self.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    
    NSString * urlString = [NSString stringWithFormat:@"%@/api/%@",API_SERVER_BASE_URL, endPoint];
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void) getCluesWithSuccessBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    // -- 'api/v2/games/:gameID/clues'*/
    NSString * endPoint = [NSString stringWithFormat:@"games/%@/clues",self.gameId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject != nil){
            if ([responseObject isKindOfClass:[NSArray class]])
            {
                NSMutableArray * cluesList = [NSMutableArray new];
                [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                    SCSClue * clue = [[SCSClue alloc]initWithJSON:obj];
                    [cluesList addObject:clue];
                }];
                successBlock (cluesList);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock([error description]);
    }];
}

- (void) postAnswer:(id)answer withClue:(NSString*)clueId type:(NSString*)clueType successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
//    NSString * currentTeamId = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_team"];
    // --/api/v2/answers/clues/:clueID/teams/:teamID/players/:playerName/location
    // --/api/v2/answers/clues/:clueID/teams/:teamID/players/:playerName/picture
    NSString * endPoint = [NSString stringWithFormat:@"answers/clues/%@/teams/%@/players/%@/%@",clueId,self.teamId, self.playerId, [clueType lowercaseString]];

    if ([clueType isEqualToString:@"Location"]){
    NSLog(@"%@",[self urlStringWithEndPoint:endPoint]);
    [self POST:[self urlStringWithEndPoint:endPoint] parameters: answer success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    }
    else
    {
        NSLog(@"%@",[self urlStringWithEndPoint:endPoint]);

        NSData *imageData = UIImageJPEGRepresentation(answer, 0.5);
        NSError * error = nil;
        NSMutableURLRequest * request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[self urlStringWithEndPoint:endPoint] parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData){
            [formData appendPartWithFileData:imageData name:@"photoAnswer" fileName:@"answer.jpg" mimeType:@"image/jpeg"];
        }error:&error];
        
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"POST Answer JSON: %@", responseObject);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successBlock) successBlock(responseObject);
                
            });
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"POST Answer JSON:%@", [error localizedDescription]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) failureBlock([error description]);
            });
            
        }];
        [self.operationQueue addOperation:operation];
//        self.responseSerializer.acceptableContentTypes = [self.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
//
//        [self POST:[self urlStringWithEndPoint:endPoint] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//     
//            NSLog(@"%@", formData);
//            
//            NSData *imageData = UIImageJPEGRepresentation(answer, 0.5);
//            [formData appendPartWithFileData:imageData name:@"files" fileName:@"answer.jpg" mimeType:@"image/jpeg"];
//        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
//            successBlock(responseObject);
//
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            
//            NSLog(@"Error: %@ ***** %@", operation.responseString, error);
//            failureBlock(operation.responseString);
//
//        }];
    }
    
}

@end