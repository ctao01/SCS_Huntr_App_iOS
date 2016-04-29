//
//  TeamAccessoryButton.m
//  Huntr
//
//  Created by Joy Tao on 4/26/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "TeamAccessoryButton.h"

@implementation TeamAccessoryButton

+ (id) initalizeButtonWithType:(UIButtonType)type andFrame:(CGRect)frame
{
    UIButton * buttton = [UIButton buttonWithType:type];
    [buttton setFrame:frame];
    
    buttton.clipsToBounds = YES;
    buttton.layer.cornerRadius = 4.0f;
    buttton.layer.borderWidth = 2.0f;
    
    return buttton;
    
}


+ (id) setupJoinedStyle
{
    UIButton * buttton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttton setFrame:CGRectMake(0.0f, 0.0f, 48.0f, 30.0f)];
    
    [buttton setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:173.0f /255.0f  blue:239.0f /255.0f  alpha:1]];
    [buttton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttton setTitle:@"Joined" forState:UIControlStateNormal];
    
    buttton.clipsToBounds = YES;
    buttton.layer.cornerRadius = 4.0f;
    buttton.layer.borderWidth = 2.0f;
    buttton.layer.borderColor = [UIColor whiteColor].CGColor ;
    
    return buttton;

}

+ (id) setupNormalStyle
{
    UIButton * buttton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttton setFrame:CGRectMake(0.0f, 0.0f, 48.0f, 30.0f)];
    
    [buttton setBackgroundColor:[UIColor whiteColor]];
    [buttton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:173.0f /255.0f  blue:239.0f /255.0f  alpha:1] forState:UIControlStateNormal];
    [buttton setTitle:@"Join" forState:UIControlStateNormal];
    
    buttton.clipsToBounds = YES;
    buttton.layer.cornerRadius = 4.0f;
    buttton.layer.borderWidth = 2.0f;
    buttton.layer.borderColor = [UIColor colorWithRed:0.0f/255.0f green:173.0f /255.0f  blue:239.0f /255.0f  alpha:1].CGColor ;
    
    return buttton;
}

@end
