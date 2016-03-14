//
//  SCSClue.h
//  HuntrGamer
//
//  Created by Trey Chadwell on 6/8/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSEntity.h"
#import "CoreLocation/Corelocation.h"

@interface SCSClue : SCSEntity 


@property (strong, nonatomic) NSString *clueID;
@property (strong, nonatomic) NSString *clueDescription;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *pointValue;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) CLLocation *clueLocation;
@property (nonatomic) BOOL isCorrect;
@property (strong, nonatomic) NSMutableArray *answerArray;

+ (NSArray *) initWithJSON:(NSArray *) json;
- (id)initWithJSON:(NSDictionary *) json;
@end




