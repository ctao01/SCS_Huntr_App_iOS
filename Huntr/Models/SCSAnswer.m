//
//  SCSAnswer.m
//  Huntr
//
//  Created by Joy Tao on 4/26/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSAnswer.h"

@implementation SCSAnswer

- (id)initWithJSON:(NSDictionary *) json
{
    
    self = [super init];
    if (self) {
        self.isPending = [json objectForKey:@"pending"];
        self.isCorrect = [json objectForKey:@"correctFlag"];
        self.teamId = [json objectForKey:@"teamID"];
        
        CLLocationDegrees longitude = (CLLocationDegrees)[[json objectForKey:@"longitude"] doubleValue];
        CLLocationDegrees latitude = (CLLocationDegrees)[[json objectForKey:@"latitude"] doubleValue];
        self.answerLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        self.answerImageUrl = [json objectForKey:@"picture"];
        self.playerName = [json objectForKey:@"playerName"];
        
    }
    return  self;
}


@end
