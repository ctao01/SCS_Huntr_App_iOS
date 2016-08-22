//
//  NSDate+SCSHuntrHelpers.m
//  Huntr
//
//  Created by Justin Leger on 8/21/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "NSDate+SCSHuntrHelpers.h"

@implementation NSDate (SCSHuntrHelpers)


- (NSString *) prettyTimeRemaining
{
    NSInteger ti = ((NSInteger)[self timeIntervalSinceNow]);
    if (ti > 0)
    {
        int seconds = ti % 60;
        int minutes = (ti / 60) % 60;
        int hours = (ti / 3600) % 24;
        
        return [NSString stringWithFormat:@"%dh %dm %ds", hours, minutes, seconds];
    }
    
    return [NSString stringWithFormat:@"%dh %dm %ds", 0, 0, 0];
}

- (NSString *) prettyStartDateAndDurationFromEndDate:(NSDate *)endDate
{
    NSInteger ti = ((NSInteger)[self timeIntervalSinceDate:endDate]);
    if (ti < 0) ti = ti * -1;
    
    int seconds = ti % 60;
    int minutes = (ti / 60) % 60;
    int hours = (ti / 3600) % 24;
    
    NSString * duration = [NSString stringWithFormat:@"%dh %dm %ds", hours, minutes, seconds];
    
    NSDateFormatter *prettyFormater = [[NSDateFormatter alloc] init];
    [prettyFormater setDateFormat:@"MMMM d, yyyy"];
    NSString * prettyDate = [prettyFormater stringFromDate:self];
    
    return [NSString stringWithFormat:@"%@ %@", prettyDate, duration];
}

@end
