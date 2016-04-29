//
//  PictureClueCell.h
//  Hunter
//
//  Created by Joy Tao on 3/7/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSClue.h"

@interface GameClueCell : UITableViewCell

//@property (nonatomic, strong) SCSClue * theClue;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *pointLabel;
@property (nonatomic, strong) IBOutlet UIImageView *typeImageView;
@property (nonatomic, strong) IBOutlet UIImageView *checkImageView;

@end
