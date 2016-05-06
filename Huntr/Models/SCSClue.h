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

@class SCSAnswer;

typedef enum {
    ClueTypeLocation = 0,
    ClueTypePicture = 1,
    ClueTypeUnknown = 99
}ClueType;


@interface SCSClue : SCSEntity 

@property (strong, nonatomic) NSString *clueID;
@property (strong, nonatomic) NSString *clueDescription;
@property (strong, nonatomic) NSString *type;
@property (assign, nonatomic) ClueType clueType;
@property (strong, nonatomic) NSNumber *pointValue;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) CLLocation *clueLocation;
@property (nonatomic) BOOL didSubmit;

@property (nonatomic, strong) SCSAnswer * submittedAnswer;

+ (NSArray *) initWithJSON:(NSArray *) json;
- (id)initWithJSON:(NSDictionary *) json;
@end




