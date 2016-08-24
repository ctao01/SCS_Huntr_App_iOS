//
//  SCSClue.m
//  HuntrGamer
//
//  Created by Trey Chadwell on 6/8/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import "SCSClue.h"

@implementation SCSClue


+ (NSArray *) initWithJSON:(NSArray *) json {
    NSMutableArray * clueArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary * clueValues in json) {
        [clueArray addObject: [[SCSClue alloc] initWithJSON: clueValues]];
    }
    
    return clueArray;
}

- (id)initWithJSON:(NSDictionary *) json
{
    self = [super init];
    if (self) {
        self.clueID = [json objectForKey:@"_id"];
        self.clueDescription = [json objectForKey:@"description"];
        self.type = [json objectForKey:@"type"];
        self.clueType = [(NSString*)[json valueForKey:@"type"] clueTypeFromString];
        self.pointValue = [json objectForKey:@"pointValue"];
        
        if ([json objectForKey:@"answers"] != nil) {
            [[json objectForKey:@"answers"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                
                SCSAnswer * answer = [[SCSAnswer alloc] initWithJSON:obj];
                NSString * activeTeamID = [SCSHuntrEnviromentManager sharedManager].activeTeamID;
                
                if ([answer.teamId isEqualToString:activeTeamID])
                {
                    self.submittedAnswer = answer;
                    self.didSubmit = YES;
                    *stop = YES;
                }
            }];
        }
        self.clueLocation = [[CLLocation alloc] initWithLatitude:[[json objectForKey:@"latitude"] doubleValue] longitude:[[json objectForKey:@"longitude"] doubleValue]]; 
    
    }
    return self;
}

-(SCSClueState)clueState
{
    if (self.submittedAnswer == nil) return SCSClueStateUnawswered;
    
    if (self.submittedAnswer.answerState == SCSAnswerStatePending) return SCSClueStateAnswerPendingReview;
    if (self.submittedAnswer.answerState == SCSAnswerStateAccepted) return SCSClueStateAnswerAccepted;
    if (self.submittedAnswer.answerState == SCSAnswerStateRejected) return SCSClueStateAnswerRejected;
    
    return SCSClueStateUnknown;
}

@end
