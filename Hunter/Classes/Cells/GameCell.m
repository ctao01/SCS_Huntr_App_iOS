//
//  GameCell.m
//  Hunter
//
//  Created by Joy Tao on 3/4/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GameCell.h"
@interface GameCell() {
    NSDate * tempDisplyDate;
}
@end
@implementation GameCell


- (void) setTheGame:(SCSGame *)theGame
{
    self.titleLabel.text = theGame.gameName;
    self.stateLabel.text = theGame.gameStatus;
    self.durationLabel.hidden = ([self.stateLabel.text isEqualToString:@"In Progress"]) ? false: true;
    if ([self.stateLabel.text isEqualToString:@"In Progress"])
    {
        //For Test:
        tempDisplyDate = [[NSDate date] dateByAddingTimeInterval:60 * 60 * 22];
        
        NSInteger ti = ((NSInteger)[tempDisplyDate timeIntervalSinceNow]);
        int seconds = ti % 60;
        int minutes = (ti / 60) % 60;
        int hours = (ti / 3600) % 24;
        
        self.durationLabel.text = [NSString stringWithFormat:@"%dh %dm %ds", hours, minutes, seconds];

        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(updateTimer)
                                               userInfo:nil
                                                repeats:YES];
    }

    
}

-(void)updateTimer
{
    //Get the time left until the specified date
    NSInteger ti = ((NSInteger)[tempDisplyDate timeIntervalSinceNow]);
    if (ti > 0)
    {
        int seconds = ti % 60;
        int minutes = (ti / 60) % 60;
        int hours = (ti / 3600) % 24;
        
        self.durationLabel.text = [NSString stringWithFormat:@"%dh %dm %ds", hours, minutes, seconds];

    }
    
}



@end
