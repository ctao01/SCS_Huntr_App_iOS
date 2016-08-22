//
//  PictureClueCell.h
//  Hunter
//
//  Created by Joy Tao on 3/7/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSGame.h"
#import "SCSClue.h"

@interface GameClueCell : UITableViewCell

@property (nonatomic, weak) SCSGame * selectedGame;
@property (nonatomic, weak) SCSClue * theClue;

@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *pointLabel;
@property (nonatomic, strong) IBOutlet UIImageView *typeImageView;
@property (nonatomic, strong) IBOutlet UIImageView *statusImageView;
@property (nonatomic, strong) IBOutlet UILabel *pendingStatusLabel;

@end
