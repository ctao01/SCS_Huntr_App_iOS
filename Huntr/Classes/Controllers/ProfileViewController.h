//
//  GameProfileViewController.h
//  Twitter User Interface
//
//  Created by Justin Leger on 7/29/16.
//  Copyright © 2016 Dean Brindley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWTButton.h"

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIView * headerView;
@property (weak, nonatomic) IBOutlet UIView * profileView;
@property (weak, nonatomic) IBOutlet UIView * segmentedView;

@property (weak, nonatomic) IBOutlet UIImageView * avatarImage;

@property (weak, nonatomic) IBOutlet UILabel * titleLabel;
@property (weak, nonatomic) IBOutlet UILabel * headerTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel * subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel * subSubtitleLabel;

@property (strong, nonatomic) IBOutlet UIImageView * headerBlurImageView;
@property (strong, nonatomic) IBOutlet UIImageView * headerImageView;

@end
