//
//  SCSEnvironment.m
//  Hunter
//
//  Created by Joy Tao on 2/24/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSEnvironment.h"

@implementation SCSEnvironment
@synthesize currentPlayer = _currentPlayer;


+ (instancetype)sharedInstance
{
    static SCSEnvironment *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SCSEnvironment alloc] init];
    });
    
    return _sharedClient;
}

- (instancetype) init {
    self = [super init];
    if (self) {
//        [self loadUserDefaults];
    }
    return self;
}

- (BOOL) hasStartedGame {
    NSLog(@"%@",[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]);
    return [self hasRegisteredPlayer] && [self hasSelectedTeam] && [self hasSelectedGame];
}

- (BOOL) hasRegisteredPlayer
{
    NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_player"];
    if (string == nil || [string isEqual:[NSNull null]]
        || ([string respondsToSelector:@selector(length)] && [(NSData *)string length] == 0)
        || ([string respondsToSelector:@selector(count)] && [(NSArray *)string count] == 0))
        return NO;
    else
        return YES;
}

- (BOOL) hasSelectedTeam
{
    NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_team"];
    if (string == nil || [string isEqual:[NSNull null]]
        || ([string respondsToSelector:@selector(length)] && [(NSData *)string length] == 0)
        || ([string respondsToSelector:@selector(count)] && [(NSArray *)string count] == 0))
        return NO;
    else
        return YES;
}

- (BOOL) hasSelectedGame
{
    NSString * string = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_game"];
    if (string == nil || [string isEqual:[NSNull null]]
        || ([string respondsToSelector:@selector(length)] && [(NSData *)string length] == 0)
        || ([string respondsToSelector:@selector(count)] && [(NSArray *)string count] == 0))
        return NO;
    else
        return YES;
}

/*
- (void) loadUserDefaults
{
    NSDictionary * userDictionary = [[NSUserDefaults standardUserDefaults]objectForKey:@"com.sungard.userdefaults"];
    [userDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        [self.currentPlayer setValue:obj forKey:(NSString *)key];
    }];
}
*/
@end
