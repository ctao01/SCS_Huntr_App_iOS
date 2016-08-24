//
//  SCSClueViewController.m
//  Huntr
//
//  Created by Joy Tao on 8/24/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSClueViewController.h"

@implementation SCSClueViewController

- (void) viewDidLoad
{
    [super viewDidLoad];

    [self.navigationController.navigationBar setTransparentStyle];
    self.clueDescTextView.text = self.selectedClue.clueDescription;
    
    self.roundButton.clipsToBounds = YES;
    self.roundButton.layer.cornerRadius = self.roundButton.frame.size.width / 2.0f;
    self.roundButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.roundButton.layer.borderWidth = 2.0f;
    self.roundButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.roundButton.layer.shouldRasterize = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
