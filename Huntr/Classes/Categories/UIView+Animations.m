//
//  UIView+Animations.m
//  Huntr
//
//  Created by Joy Tao on 8/23/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "UIView+Animations.h"

@implementation UIView (Animations)

- (void) addBounceAnimation
{
    CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    theAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    theAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:theAnimation.values.count];
    for (NSUInteger i = 0; i < theAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [theAnimation setTimingFunctions:timingFunctions.copy];
    theAnimation.removedOnCompletion = YES;
    
    [self.layer addAnimation:theAnimation forKey:@"com.huntr.view.bounceAnimation"];
}

- (void) addMovingAnimationOnMapFrom:(CGPoint)fromPos to:(CGPoint)toPos
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    animation.fromValue = [NSValue valueWithCGPoint:fromPos];
    animation.toValue = [NSValue valueWithCGPoint:toPos];
    animation.duration = 0.8;
    animation.delegate = self;
    animation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:animation  forKey:@"com.huntr.mapview.movingAnimation"];

}

@end
