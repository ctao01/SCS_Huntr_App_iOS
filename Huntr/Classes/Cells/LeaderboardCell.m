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
    self.rankLabel.text = [NSString stringWithFormat:@"%i",[theTeam.ranking intValue]];
    self.teamLabel.text = theTeam.teamName;
    self.scoreLabel.text = [NSString stringWithFormat:@"%i",[theTeam.score intValue]];
}

@end