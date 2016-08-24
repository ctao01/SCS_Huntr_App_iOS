//
//  SCSVisualEffectView.m
//  Huntr
//
//  Created by Joy Tao on 8/23/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSVisualEffectView.h"

@implementation SCSVisualEffectView

-(void) awakeFromNib
{
    [super awakeFromNib];
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor blackColor].CGColor;
}


@end
