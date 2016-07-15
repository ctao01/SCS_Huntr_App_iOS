//
//  SCSHuntrRootViewController.h
//  Huntr
//
//  Created by Justin Leger on 7/12/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCSHuntrRootViewController : UIViewController

@property (weak, nonatomic) UIViewController *currentViewController;

- (void)showPlayerRegistrationComponent;
- (void)showNavigationComponent;

@end
