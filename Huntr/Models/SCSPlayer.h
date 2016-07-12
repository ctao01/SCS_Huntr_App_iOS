//
//  SCSPlayer.h
//  HuntrGamer
//
//  Created by Andrew.Olson on 6/9/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSEntity.h"
#import "SCSGame.h"
#import "SCSTeam.h"

@interface SCSPlayer : SCSEntity


@property (retain, nonatomic) NSString *playerID;
@property (retain, nonatomic) NSString *playerName;
@property (retain, nonatomic) NSMutableArray *breadcrumbs;

@property (retain, nonatomic) SCSGame * game;
@property (retain, nonatomic) SCSTeam * team;

+ (NSArray *) initWithJSON:(NSArray *) json;
- (id)initWithJSON:(NSDictionary *) json;

@end
