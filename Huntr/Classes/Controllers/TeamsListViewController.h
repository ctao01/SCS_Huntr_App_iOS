//
//  TeamsListTableViewController.h
//  Hunter
//
//  Created by Joy Tao on 3/6/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSGame.h"

@interface TeamsListViewController : UITableViewController
@property (nonatomic , strong) SCSGame * selectedGame;

@property (nonatomic , strong) IBOutlet UIButton * addTeamBtn;
@property (nonatomic , strong) IBOutlet UIButton * updateNameBtn;

@property (nonatomic , strong) IBOutlet UILabel * infoLabel;

@end
