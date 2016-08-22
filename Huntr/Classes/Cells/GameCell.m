//
//  GameCell.m
//  Hunter
//
//  Created by Joy Tao on 3/4/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GameCell.h"
#import "NSDate+SCSHuntrHelpers.h"

@interface GameCell() 

@property (nonatomic, strong) NSTimer * gameTimer;

@end

@implementation GameCell

- (void) dealloc {
    [self invalidteGameTimer];
}

- (void) invalidteGameTimer
{
    if (self.gameTimer) {
        [self.gameTimer invalidate];
        self.gameTimer = nil;
    }
}

-(void)updateGameTimer
{
    //Get the time left until the specified date
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.durationLabel.text = [self.selectedGame.endDate prettyTimeRemaining];
    });
}

- (void) setSelectedGame:(SCSGame *)selectedGame
{
    if (_selectedGame != selectedGame) {
        _selectedGame = selectedGame;
        [self configureView];
    }
}

- (void) configureView
{
    self.titleLabel.text = self.selectedGame.gameName;
    self.stateLabel.text = self.selectedGame.statusText;
    self.durationLabel.hidden = (self.selectedGame.status == SCSGameStatusInProgress) ? NO: YES;
    
    [self invalidteGameTimer];
    
    if (self.selectedGame.status == SCSGameStatusInProgress)
    {
        [self updateGameTimer];
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateGameTimer)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}



@end
