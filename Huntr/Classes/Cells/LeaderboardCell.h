//
//  LeaderboardCell.h
//  Hunter
//
//  Created by Joy Tao on 3/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSTeam.h"

@interface LeaderboardCell : UITableViewCell

@property (nonatomic, strong) SCSTeam * theTeam;

@property (nonatomic, strong) IBOutlet UILabel *rankLabel;
@property (nonatomic, strong) IBOutlet UILabel *teamLabel;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;

@end
