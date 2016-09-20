//
//  LeaderboardCell.m
//  Hunter
//
//  Created by Joy Tao on 3/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "LeaderboardCell.h"

@implementation LeaderboardCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

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
