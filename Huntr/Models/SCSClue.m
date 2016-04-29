//
//  SCSClue.m
//  HuntrGamer
//
//  Created by Trey Chadwell on 6/8/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import "SCSClue.h"

@implementation SCSClue


+ (NSArray *) initWithJSON:(NSArray *) json{
    NSMutableArray * clueArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary * clueValues in json){
        [clueArray addObject: [[SCSClue alloc] initWithJSON: clueValues]];
    }
    
    return clueArray;
}

- (id)initWithJSON:(NSDictionary *) json
{
    self = [super init];
    if (self) {
        _clueID = [json valueForKey:@"_id"];
        _clueDescription = [json valueForKey:@"description"];
        _type = [json valueForKey:@"type"];
        _pointValue = [json valueForKey:@"pointValue"];
        _latitude = [json valueForKey:@"latitude"];
        _longitude = [json valueForKey:@"longitude"];

        _didSubmit = (_submittedAnswer) ? true :false;
        
        if(_longitude != nil && _latitude != nil)_clueLocation = [[CLLocation alloc]initWithLatitude:[_latitude doubleValue]longitude:[_longitude doubleValue]];

        
    
    }
    return self;
}

@end
