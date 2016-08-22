//
//  GameViewController.m
//  Hunter
//
//  Created by Joy Tao on 3/7/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "GameViewController.h"
#import "CluesListViewController.h"

@interface GameViewController ()
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedIndex = 0;
    
//    self.tabBar.items
    
    CluesListViewController * vcClue = [((UINavigationController*)[self.viewControllers objectAtIndex:1]).viewControllers objectAtIndex:0];
    vcClue.selectedGame = self.selectedGame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
