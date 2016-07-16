//
//  SCSAnswer.m
//  Huntr
//
//  Created by Joy Tao on 4/26/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSAnswer.h"

@interface SCSAnswer()

@property (nonatomic , strong) NSString * answerStateString;

@end

@implementation SCSAnswer

- (id)initWithJSON:(NSDictionary *) json
{
    
    self = [super init];
    if (self) {
        self.answerStateString = [json objectForKey:@"answerState"];
        self.teamId = [json objectForKey:@"teamID"];
        
        CLLocationDegrees longitude = (CLLocationDegrees)[[json objectForKey:@"longitude"] doubleValue];
        CLLocationDegrees latitude = (CLLocationDegrees)[[json objectForKey:@"latitude"] doubleValue];
        self.answerLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        self.answerImageUrl = [json objectForKey:@"picture"];
        self.playerName = [json objectForKey:@"playerName"];
        
    }
    return  self;
}

-(SCSAnswerState)answerState
{
    if ([self.answerStateString isEqualToString:@"pending"]) return SCSAnswerStatePending;
    if ([self.answerStateString isEqualToString:@"accepted"]) return SCSAnswerStateAccepted;
    if ([self.answerStateString isEqualToString:@"rejected"]) return SCSAnswerStateRejected;
    
    return SCSAnswerStateUnknown;
}

-(BOOL) isCorrect
{
    return self.answerState == SCSAnswerStateAccepted;
}

-(BOOL) isPending
{
    return self.answerState == SCSAnswerStatePending;
}


@end
