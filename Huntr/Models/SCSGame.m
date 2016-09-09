//
//  SCSGame.m
//  HuntrGamer
//
//  Created by Andrew.Olson on 6/7/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import "SCSGame.h"

#import "SCSTeam.h"

#import "SCSClue.h"

@implementation SCSGame

- (id)initWithJSON:(NSDictionary *) json
{
    self = [super init];
    if (self) {
        
        _gameID = [json valueForKey:@"_id"];
        _gameName = [json valueForKey:@"name"];
        _startDate = [self dateForApiTimeString: [json valueForKey:@"startDate"]];
        _endDate = [self dateForApiTimeString: [json valueForKey:@"endDate"]];
        
//        _gameStatus = [json valueForKey:@"status"];
//        _status = [(NSString*)[json valueForKey:@"status"] statusEnumFromString];
        
        _teamList = [SCSTeam initWithJSON:[json valueForKey:@"teams"]];
        _clueList = [SCSClue initWithJSON:[json valueForKey:@"clues"]];
    }
    return self;
}

- (SCSTeam *) teamWithId:(NSString *)teamID
{
    __block SCSTeam * activeGameTeam = nil;
    
    [self.teamList enumerateObjectsUsingBlock:^(SCSTeam * _Nonnull team, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([team.teamID isEqualToString:teamID]) {
            activeGameTeam = team;
            *stop = YES;
        }
    }];
    
    return activeGameTeam;
}

- (SCSGameStatus) status
{
//    if (self.endDate == nil || self.startDate == nil)
//        return SCSGameStatusNotStarted;
//    if (self.endDate != nil) {
//        NSTimeInterval endTimeInterval = self.endDate ? self.endDate.timeIntervalSince1970 : DBL_MAX;
//        NSTimeInterval nowTimeInterval = [NSDate new].timeIntervalSince1970;
//        if (nowTimeInterval > endTimeInterval)
//                   return SCSGameStatusCompleted;
//        else
//            return SCSGameStatusInProgress;
//    }
    
// Need to change server or app
    NSTimeInterval nowTimeInterval = [NSDate new].timeIntervalSince1970;
    NSTimeInterval startTimeInterval = self.startDate ? self.startDate.timeIntervalSince1970 : DBL_MAX;
    NSTimeInterval endTimeInterval = self.endDate ? self.endDate.timeIntervalSince1970 : DBL_MAX;
    
    if (nowTimeInterval < startTimeInterval)
        return SCSGameStatusNotStarted;
    if (nowTimeInterval > endTimeInterval)
        return SCSGameStatusCompleted;
    if (nowTimeInterval < endTimeInterval && nowTimeInterval >= startTimeInterval)
        return SCSGameStatusInProgress;
    
    return SCSGameStatusUnknown;
}

- (NSString *) statusText
{
    SCSGameStatus status = self.status;
    
    if (status == SCSGameStatusNotStarted) {
        return @"Not Started";
    }
    else if (status == SCSGameStatusCompleted) {
        return @"Completed";
    }
    else if (status == SCSGameStatusInProgress) {
        return @"In Progress";
    }
    
    return @"Unknown";
}

@end

