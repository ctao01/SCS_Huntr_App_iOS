//
//  DismissSegue.m
//  Huntr
//
//  Created by Joy Tao on 4/21/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "DismissSegue.h"

@implementation DismissSegue

- (void)perform
{
    UIViewController *controller = self.sourceViewController;
    [controller.parentViewController dismissViewControllerAnimated:YES
                                                        completion:nil];
}

@end
