//
//  SCSHuntrRootViewController.m
//  Huntr
//
//  Created by Justin Leger on 7/12/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "SCSHuntrRootViewController.h"
#import "SCSRegisteredPlayer.h"


@interface SCSHuntrRootViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end


@implementation SCSHuntrRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SCSRegisteredPlayer * registeredPlayer = [SCSHuntrEnviromentManager sharedManager].registeredPlayer;
    
    if (registeredPlayer) {
        [self showNavigationComponent];
    }
    else {
        [self showPlayerRegistrationComponent];
    }
}

- (void)showPlayerRegistrationComponent {
    UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerRegistrationComponent"];
    newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self cycleFromViewController:self.currentViewController toViewController:newViewController];
    self.currentViewController = newViewController;
}

- (void)showNavigationComponent {
    UIViewController *newViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HuntrNavigationComponent"];
    newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self cycleFromViewController:self.currentViewController toViewController:newViewController];
    self.currentViewController = newViewController;
}

- (void)cycleFromViewController:(UIViewController*) oldViewController toViewController:(UIViewController*) newViewController {
    
    if (oldViewController) {
    
        [oldViewController willMoveToParentViewController:nil];
        [self addChildViewController:newViewController];
        [self addSubview:newViewController.view toView:self.containerView];
        newViewController.view.alpha = 0;
        [newViewController.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.5
                         animations:^{
                             newViewController.view.alpha = 1;
                             oldViewController.view.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [oldViewController.view removeFromSuperview];
                             [oldViewController removeFromParentViewController];
                             [newViewController didMoveToParentViewController:self];
                         }];
    } else {
        
        [self addChildViewController:newViewController];
        [self addSubview:newViewController.view toView:self.containerView];
        [newViewController.view layoutIfNeeded];
    }
}

- (void)addSubview:(UIView *)subView toView:(UIView*)parentView {
    [parentView addSubview:subView];
    
    NSDictionary * views = @{@"subView" : subView,};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                   options:0
                                                                   metrics:0
                                                                     views:views];
    [parentView addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                          options:0
                                                          metrics:0
                                                            views:views];
    [parentView addConstraints:constraints];
}

@end
