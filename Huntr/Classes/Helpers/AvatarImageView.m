//
//  AvatarImageView.m
//  Huntr
//
//  Created by Justin Leger on 8/16/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "AvatarImageView.h"

@implementation AvatarImageView

-(void) awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 3.0;
}

@end
