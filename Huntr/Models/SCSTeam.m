//
//  SCSTeam.m
//  HuntrGamer
//
//  Created by Andrew.Olson on 6/8/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import "SCSTeam.h"
#import "SCSPlayer.h"

@implementation SCSTeam

+ (NSArray *) initWithJSON:(NSArray *) json{
    NSMutableArray * teamArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary * teamValues in json){
        [teamArray addObject: [[SCSTeam alloc] initWithJSON: teamValues]];
    }
    
    return teamArray;
}

- (id)initWithJSON:(NSDictionary *) json
{
    self = [super init];
    if (self) {
        _teamName =[json valueForKey:@"name"];
        _teamID =[json valueForKey:@"_id"];
        _ranking = [json valueForKey:@"ranking"];
        _score = [json valueForKey:@"score"];
        _playerList = [SCSPlayer initWithJSON: [json valueForKey: @"players"]];
    }
    return self;
}
@end
