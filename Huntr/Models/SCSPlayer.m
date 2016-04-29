//
//  SCSPlayer.m
//  HuntrGamer
//
//  Created by Andrew.Olson on 6/9/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import "SCSPlayer.h"

@implementation SCSPlayer

+ (NSArray *) initWithJSON:(NSArray *) json{
    NSMutableArray * playerArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary * playerValues in json){
        [playerArray addObject: [[SCSPlayer alloc] initWithJSON: playerValues]];
    }
    
    return playerArray;
}

- (id)initWithJSON:(NSDictionary *) json
{
    self = [super init];
    if (self) {
        _playerName =[json valueForKey:@"name"];
        _playerID =[json valueForKey:@"_id"];
        _breadcrumbs = [json valueForKey:@"breadcrumbs"];
    }
    return self;
}
@end
