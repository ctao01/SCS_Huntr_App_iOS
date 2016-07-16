//
//  GameCell.m
//  Hunter
//
//  Created by Joy Tao on 3/4/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GameCell.h"
@interface GameCell() 

@property (nonatomic, strong) NSTimer * gameTimer;

@end

@implementation GameCell

- (void) dealloc {
    [self.gameTimer invalidate];
}

- (void) invalidteGameTime
{
    if (self.gameTimer) {
        [self.gameTimer invalidate];
        self.gameTimer = nil;
    }
}

- (void) setTheGame:(SCSGame *)theGame
{
    if (_theGame != theGame) {
        _theGame = theGame;
        [self configureView];
    }
}

- (void) configureView
{
    self.titleLabel.text = self.theGame.gameName;
    self.stateLabel.text = self.theGame.gameStatus;
    self.durationLabel.hidden = (self.theGame.status == SCSGameStatusInProgress) ? NO: YES;
    
    if ([self.stateLabel.text isEqualToString:@"In Progress"])
    {
        [self.gameTimer invalidate];
        
        NSInteger ti = ((NSInteger)[self.theGame.endDate timeIntervalSinceNow]);
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
    else {
        [self.gameTimer invalidate];
    }
}

-(void)updateTimer
{
    //Get the time left until the specified date
    NSInteger ti = ((NSInteger)[self.theGame.endDate timeIntervalSinceNow]);
    if (ti > 0)
    {
        int seconds = ti % 60;
        int minutes = (ti / 60) % 60;
        int hours = (ti / 3600) % 24;
        
        self.durationLabel.text = [NSString stringWithFormat:@"%dh %dm %ds", hours, minutes, seconds];
    }
}



@end
