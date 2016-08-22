//
//  TWTButton.m
//  Huntr
//
//  Created by Justin Leger on 8/16/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "TWTButton.h"

@implementation TWTButton

-(void) awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 5.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = self.titleLabel.textColor.CGColor;
//    self.layer.borderColor = [UIColor colorWithRed:85.0/255.0 green: 172.0/255.0 blue:238.0/255.0 alpha:1.0].CGColor;
}

@end
