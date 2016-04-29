//
//  SCSGame.h
//  HuntrGamer
//
//  Created by Andrew.Olson on 6/7/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SCSEntity.h"
#import "SCSTeam.h"
#import "SCSClue.h"

typedef enum {
    NotStarted = 0,
    InProgress = 1,
    Completed = 2,
    Unknown = 99,
} GameStatus;

@interface SCSGame : SCSEntity

@property (retain, nonatomic) NSString *    gameName;
@property (retain, nonatomic) NSString *    gameID;
@property (retain, nonatomic) NSString *    gameStatus;
@property (assign, nonatomic) GameStatus  status;
@property (retain, nonatomic) SCSTeam *     myTeam;
@property (retain, nonatomic) NSString *    myPlayerName;

@property (retain, nonatomic) NSDate *      startDate;
@property (retain, nonatomic) NSDate *      endDate;
@property (retain, nonatomic) NSArray *     teamList;
@property (retain, nonatomic) NSArray *     clueList;

- (id) initWithJSON:(NSDictionary *) json;

@end
