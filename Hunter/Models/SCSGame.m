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
        _gameID =[json valueForKey:@"_id"];
        _gameName =[json valueForKey:@"name"];
        _startDate = [self dateForApiTimeString: [json valueForKey:@"startDate"]];
        _endDate =[self dateForApiTimeString: [json valueForKey:@"endDate"]];
        _gameStatus =[json valueForKey:@"status"];
        
        _teamList = [SCSTeam initWithJSON: [json valueForKey: @"teams" ]];
        _clueList = [SCSClue initWithJSON:[json valueForKey:@"clues"]];
        
        
    }
    return self;
}
@end

