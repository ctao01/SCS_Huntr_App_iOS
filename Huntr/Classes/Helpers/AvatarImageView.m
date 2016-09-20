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
    self.layer.borderColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f  blue:51.0f/255.0f alpha:1].CGColor;
    self.layer.borderWidth = 3.0;
}

@end
