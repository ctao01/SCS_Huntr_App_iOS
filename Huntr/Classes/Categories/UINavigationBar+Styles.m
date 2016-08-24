//
//  UINavigationBar+Styles.m
//  Huntr
//
//  Created by Joy Tao on 8/24/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "UINavigationBar+Styles.h"

@implementation UINavigationBar (Styles)

- (void) setTransparentStyle
{
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.shadowImage = [UIImage new];
    self.translucent = true;
}


@end
