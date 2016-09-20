//
//  TeamCell.h
//  Huntr
//
//  Created by Joy Tao on 4/22/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamAccessoryButton.h"

typedef void (^TeamButtonTappedAction)();

@interface TeamCell : UITableViewCell

@property (nonatomic, weak) UITableView * tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) SCSGame * selectedGame;
@property (nonatomic, weak) SCSTeam * team;
@property (nonatomic, copy) TeamButtonTappedAction teamButtonActionBlock;

@property (nonatomic , strong) IBOutlet TeamAccessoryButton * accessoryButton;

@end
