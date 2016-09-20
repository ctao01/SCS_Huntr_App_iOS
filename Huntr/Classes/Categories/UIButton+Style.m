//
//  UIButton+Style.m
//  Huntr
//
//  Created by Joy Tao on 4/22/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "UIButton+Style.h"

@implementation UIButton (Style)

+ (id) setupJoinedStyle
{
    UIButton * buttton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 30.0f)];
    
    [buttton setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:173.0f /255.0f  blue:239.0f /255.0f  alpha:1]];
    [buttton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttton setTitle:@"Joined" forState:UIControlStateNormal];
    
    buttton.clipsToBounds = YES;
    buttton.layer.cornerRadius = 4.0f;
    buttton.layer.borderWidth = 1.0f;
    buttton.layer.borderColor = [UIColor whiteColor].CGColor ;
    
    return buttton;
    
}

+ (id) setupNormalStyle
{
    UIButton * buttton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 30.0f)];
    
    UIColor * lightBlueColor = [UIColor colorWithRed:0.0f/255.0f green:173.0f /255.0f  blue:239.0f /255.0f  alpha:1];
    
    [buttton setBackgroundColor:[UIColor whiteColor]];
    [buttton setTitleColor:lightBlueColor forState:UIControlStateNormal];
    [buttton setTitle:@"Join" forState:UIControlStateNormal];
    
    buttton.clipsToBounds = YES;
    buttton.layer.cornerRadius = 4.0f;
    buttton.layer.borderWidth = 1.0f;
    buttton.layer.borderColor = lightBlueColor.CGColor ;
    
    return buttton;
}

+ (id) setupLightGrayStyle
{
    UIButton * buttton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 30.0f)];
    
    UIColor * lightGrayColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f  blue:204.0f/255.0f alpha:1];
    
    [buttton setBackgroundColor:[UIColor clearColor]];
    [buttton setTitleColor:lightGrayColor forState:UIControlStateNormal];
    [buttton setTitle:@"Join" forState:UIControlStateNormal];
    
    buttton.clipsToBounds = YES;
    buttton.layer.cornerRadius = 4.0f;
    buttton.layer.borderWidth = 1.0f;
    buttton.layer.borderColor = lightGrayColor.CGColor ;
    
    return buttton;
}
@end
