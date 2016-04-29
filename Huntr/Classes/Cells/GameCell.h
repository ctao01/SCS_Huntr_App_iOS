//
//  GameCell.h
//  Hunter
//
//  Created by Joy Tao on 3/4/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSGame.h"

@interface GameCell : UITableViewCell

@property (nonatomic , strong) SCSGame * theGame;
@property (nonatomic , strong) IBOutlet UILabel * titleLabel;
@property (nonatomic , strong) IBOutlet UILabel * stateLabel;
@property (nonatomic , strong) IBOutlet UILabel * durationLabel;
@end
