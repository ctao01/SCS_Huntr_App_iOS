//
//  LeaderboardCell.m
//  Hunter
//
//  Created by Joy Tao on 3/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "LeaderboardCell.h"

@implementation LeaderboardCell

- (void) setTheTeam:(SCSTeam *)theTeam
{
    if (_theTeam != theTeam) {
        _theTeam = theTeam;
        [self configureView];
    }
}

- (void) configureView
{
    if (self.theTeam) {
        self.rankLabel.text = ([self.theTeam.ranking integerValue]!= 0) ? [NSString stringWithFormat:@"%i",[self.theTeam.ranking intValue]]: @"1";
        self.teamLabel.text = self.theTeam.teamName;
        self.scoreLabel.text = [NSString stringWithFormat:@"%i",[self.theTeam.score intValue]];
    }
}

@end
