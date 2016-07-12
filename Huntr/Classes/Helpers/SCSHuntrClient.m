//
//  SCSHuntrClient.m
//  Huntr
//
//  Created by Andrew Olson on 6/4/14.
//  Copyright (c) 2013 SunGard Consulting Services. All rights reserved.
//

#import "SCSHuntrClient.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import "AFHTTPRequestOperationManager.h"
#import "SCSEnvironment.h"
#import "SCSGame.h"
#import "SCSClue.h"

//TODO: Add Prod/Dev schemes
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://uzhome.no-ip.org:3000/api";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://huntr-api.herokuapp.com/";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://BAPKAG.local:3000/";

#ifdef DEV
//#define API_SERVER_BASE_URL @"http://ec2-54-173-88-68.compute-1.amazonaws.com:3333"
#define API_SERVER_BASE_URL @"http://localhost:3000"
//#define API_SERVER_BASE_URL @"http://192.168.1.108:3000" // JML Home
//#define API_SERVER_BASE_URL @"http://172.19.192.158:3000"
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
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentGameId];
}

- (NSString *) teamId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentTeamId];
}

- (NSString *) playerName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentPlayerName];
}

- (NSString *) playerId
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentPlayerId];
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
        [unsingedSSLCertificatePolicy setValidatesDomainName:NO];
        self.securityPolicy = unsingedSSLCertificatePolicy;
        
        AFHTTPResponseSerializer * respSerializer = self.responseSerializer;
        NSMutableIndexSet *responseCodes = [respSerializer.acceptableStatusCodes mutableCopy];
        [responseCodes addIndex:304];
        respSerializer.acceptableStatusCodes = responseCodes;
        
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
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSGame alloc] initWithJSON:obj]];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(array);
            });
        }
        else {
            NSLog(@"the only one game: %@", responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock(@"No Games Found");
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

- (void) getGameById:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"games/%@",gameId];
    NSString * hostEndPoint = [self urlStringWithEndPoint:endPoint];
    [self GET:hostEndPoint parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;
        
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            SCSGame * game = [[SCSGame alloc] initWithJSON:responseObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(game);
            });
        }
        else
        {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
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
    
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;
        
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSTeam alloc] initWithJSON:obj]];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(array);
            });
        }
        else
        {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

#pragma mark - TEAM(S)
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
    
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;
        
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSTeam alloc] initWithJSON:obj]];
            }];
            
            NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"teamName" ascending:YES];
            NSArray * arrayResult = [NSArray new];
            arrayResult = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSort, nil]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(arrayResult);
            });
        }
        else
        {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

- (void) getAllTeamsWithSuccessBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"games/%@/teams", self.gameId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;
        
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSTeam alloc] initWithJSON:obj]];
            }];
            
            NSSortDescriptor * nameSort = [NSSortDescriptor sortDescriptorWithKey:@"teamName" ascending:YES];
            NSArray * arrayResult = [NSArray new];
            arrayResult = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameSort, nil]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(arrayResult);
            });
        }
        else
        {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

- (void) addTeamToGame:(id)gameData successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * currentGameId = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_game"];
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
    
    [self POST:[self urlStringWithEndPoint:endPoint] parameters:gameData progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;

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
            SCSTeam * newTeam  = [[SCSTeam alloc] initWithJSON:responseObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(newTeam);
            });
        }
        else  {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
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
    
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;

        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSPlayer alloc] initWithJSON:obj]];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(array);
            });
        }
        else
        {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

- (void) addPlayerToTeam:(NSString *)teamId successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * currentPlayer= [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentPlayerName];
    NSString * endPoint;
    switch (API_CRUD_VERSION) {
        case 1:
        {
            endPoint = [NSString stringWithFormat:@"player/%@/%@/token", teamId, currentPlayer];
            [self POST:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if (responseObject) successBlock(responseObject);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock([error description]);
                });
            }];
        }
            break;
        case 2:{
            endPoint = [NSString stringWithFormat:@"teams/%@/players", teamId];
            [self POST:[self urlStringWithEndPoint:endPoint] parameters:[NSDictionary dictionaryWithObjectsAndKeys:currentPlayer,@"playerName", nil] progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                if (responseObject)
                {
                    if ([[responseObject objectForKey:@"players"] isKindOfClass:[NSArray class]])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            successBlock([responseObject objectForKey:@"players"]);
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            failureBlock(responseObject);
                        });
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock([error description]);
                });
            }];
        }
            break;
        default:
            break;
    }
}

- (void) renamePlayerName:(NSString*)playerName withSuccessBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"teams/%@/players/%@", self.teamId, self.playerId];
    
    [self POST:[self urlStringWithEndPoint:endPoint] parameters:[NSDictionary dictionaryWithObjectsAndKeys:playerName, @"playerName", nil] progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject != nil) {
            NSLog(@"postPlayerName %@",responseObject);
            if ([responseObject objectForKey:@"updated"] != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock([responseObject objectForKey:@"updated"]);
                });
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

#pragma mark - Clues and Answers

- (void) getCluesByGame:(NSString *)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    self.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    NSMutableIndexSet *responseCodes = [self.responseSerializer.acceptableStatusCodes mutableCopy];
    [responseCodes addIndex:304];
    self.responseSerializer.acceptableStatusCodes = responseCodes;
    
    NSString * endPoint = [NSString stringWithFormat:@"clues/%@",gameId];
    NSString * urlString = [NSString stringWithFormat:@"%@/api/%@",API_SERVER_BASE_URL, endPoint];
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;

        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray * array = [NSMutableArray new];
            [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                [array addObject:[[SCSClue alloc] initWithJSON:obj]];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(array);
            });
        }
        else
        {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

- (void) getAnswersByTeam:(NSString *)teamId andGame:(NSString*)gameId successBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"answers/%@/%@",gameId,teamId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;

        if ([responseObject isKindOfClass:[NSArray class]])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(responseObject);
            });
        }
        else
        {
            NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
            dispatch_async(dispatch_get_main_queue(), ^{
                failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
            });
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

- (void) getCluesWithSuccessBlock:(SCSHuntrClientSuccessBlockArray)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    // -- 'api/v2/games/:gameID/clues'*/
    NSString * endPoint = [NSString stringWithFormat:@"games/%@/clues", self.gameId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject != nil) {
            if ([responseObject isKindOfClass:[NSArray class]])
            {
                NSMutableArray * cluesList = [NSMutableArray new];
                [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                    SCSClue * clue = [[SCSClue alloc] initWithJSON:obj];
                    [cluesList addObject:clue];
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock (cluesList);
                });
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}
- (void) getClueById:(NSString *)clueId  successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    // /api/v2/games/:gameID/clues/:clueID
    NSString * endPoint = [NSString stringWithFormat:@"games/%@/clues/%@", self.gameId, clueId];
    [self GET:[self urlStringWithEndPoint:endPoint] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSHTTPURLResponse *httpResponse = (id)task.response;
        
        if (responseObject != nil) {
            
            
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                SCSClue * clue = [[SCSClue alloc] initWithJSON:responseObject];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock(clue);
                });
            }
            else
            {
                NSLog(@"operation error:%ld",(long)[httpResponse statusCode]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
                });
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

- (void) postAnswer:(id)answer withClue:(SCSClue*)clue successBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    //    NSString * currentTeamId = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_team"];
    // --/api/v2/answers/clues/:clueID/teams/:teamID/players/:playerName/location
    // --/api/v2/answers/clues/:clueID/teams/:teamID/players/:playerName/picture
    //
    // app.post	('/api/v2/answers/clues/:clueID/teams/:teamID/players/:playerID/picture', submitPhotoAnswer);
    // app.post	('/api/v2/answers/clues/:clueID/teams/:teamID/players/:playerID/location', submitLocationAnswer);
    
    if (clue.clueType == SCSClueTypeLocation) {
        
        NSString * endPoint = [NSString stringWithFormat:@"answers/clues/%@/teams/%@/players/%@/location", clue.clueID, self.teamId, self.playerId];
        NSLog(@"%@",[self urlStringWithEndPoint:endPoint]);
        
        [self POST:[self urlStringWithEndPoint:endPoint] parameters:answer progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"POST Answer JSON: %@", responseObject);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successBlock) successBlock(responseObject);
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"POST Answer JSON:%@", [error localizedDescription]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) failureBlock([error description]);
            });
        }];
    }
    else if (clue.clueType == SCSClueTypePicture) {
        
        NSString * endPoint = [NSString stringWithFormat:@"answers/clues/%@/teams/%@/players/%@/picture", clue.clueID, self.teamId, self.playerId];
        NSLog(@"%@",[self urlStringWithEndPoint:endPoint]);
        
        NSData *imageData = UIImageJPEGRepresentation(answer, 0.5);
        
        [self POST:[self urlStringWithEndPoint:endPoint] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:imageData name:@"answer" fileName:@"answer.jpg" mimeType:@"image/jpeg"];
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"POST Answer JSON: %@", responseObject);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successBlock) successBlock(responseObject);
            });
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"POST Answer JSON:%@", [error localizedDescription]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failureBlock) failureBlock([error description]);
            });
        }];
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) failureBlock(@"Posting Answer with unknown clue type.");
        });
    }
}

- (void) registerDevice:(NSString*)deviceUUID params:(NSDictionary*)params withSuccessBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"devices/%@/register", deviceUUID];
    [self POST:[self urlStringWithEndPoint:endPoint] parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject != nil) {
            NSLog(@"registerDevice %@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(responseObject);
            });
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}



- (void) registerPlayer:(NSString*)deviceUUID params:(NSDictionary*)params withSuccessBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    NSString * endPoint = [NSString stringWithFormat:@"players/%@/register", deviceUUID];
    [self POST:[self urlStringWithEndPoint:endPoint] parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject != nil) {
            NSLog(@"registerPlayer %@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(responseObject);
            });
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}



- (void) getLinkedInInfo:(NSString*)authToken params:(NSDictionary*)params withSuccessBlock:(SCSHuntrClientSuccessBlock)successBlock failureBlock:(SCSHuntrClientFailureBlock)failureBlock
{
    AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [policy setValidatesDomainName:NO]; 
    
    NSString * endPoint = [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,first-name,last-name,maiden-name,email-address)?oauth2_access_token=%@&format=json", authToken];
    
    [self GET:endPoint parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (responseObject != nil) {
            NSLog(@"GET LinkedInInfo %@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(responseObject);
            });
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"GET LinkedInInfo Error:%@", [error localizedDescription]);
        dispatch_async(dispatch_get_main_queue(), ^{
            failureBlock([error description]);
        });
    }];
}

#pragma mark - Override Super GET and POST

//- (NSURLSessionDataTask *)GET:(NSString *)URLString
//                     parameters:(id)parameters
//                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
//                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
//{
//    AFHTTPResponseSerializer * respSerializer = self.responseSerializer;
//    NSMutableIndexSet *responseCodes = [respSerializer.acceptableStatusCodes mutableCopy];
//    [responseCodes addIndex:304];
//    respSerializer.acceptableStatusCodes = responseCodes;
//    
//    
//    
//    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
//    
////    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//    
//    NSURLSessionDataTask *task = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
//    
////    AFHTTPResponseSerializer * respSerializer = httpResponseSerializer;
//    [operation setResponseSerializer:respSerializer];
//    
//    [self.operationQueue addOperation:operation];
//    
//    return operation;
//}

//- (AFHTTPRequestOperation *)POST:(NSString *)URLString
//                      parameters:(id)parameters
//                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
//                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
//{
//    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
//    
////    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
//    
//    NSURLSessionDataTask *task = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
//    
//    AFHTTPResponseSerializer * respSerializer = httpResponseSerializer;
//    NSMutableIndexSet *responseCodes = [respSerializer.acceptableStatusCodes mutableCopy];
//    [responseCodes addIndex:304];
//    respSerializer.acceptableStatusCodes = responseCodes;
//    [operation setResponseSerializer:respSerializer];
//    
//    [self.operationQueue addOperation:operation];
//    
//    return operation;
//}

@end