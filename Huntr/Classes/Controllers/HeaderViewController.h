//
//  HeaderViewController.h
//
//  Created by Justin Leger on 7/29/16.
//  Copyright © 2016 Dean Brindley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWTButton.h"

@interface HeaderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property (weak, nonatomic) IBOutlet UIView * headerView;

@property (strong, nonatomic) IBOutlet UIImageView * headerBlurImageView;
@property (strong, nonatomic) IBOutlet UIImageView * headerImageView;

@end
