//
//  SCSTeam.h
//  HuntrGamer
//
//  Created by Andrew.Olson on 6/8/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSEntity.h"

@interface SCSTeam : SCSEntity

@property (retain, nonatomic) NSString *teamID;
@property (retain, nonatomic) NSString *teamName;
@property (retain, nonatomic) NSNumber *ranking;
@property (retain, nonatomic) NSNumber *score;
//@property (retain, nonatomic) NSArray *playerList;

+ (NSArray *) initWithJSON:(NSArray *) json;
- (id)initWithJSON:(NSDictionary *) json;
@end
