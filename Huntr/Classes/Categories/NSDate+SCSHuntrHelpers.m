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
//        int seconds = ti % 60;
//        int minutes = (ti / 60) % 60;
//        int hours = (ti / 3600) % 24;

        long seconds = ti % 60;   // remainder is seconds
        ti /= 60;                 // total number of mins
        long minutes = ti % 60;   // remainder is minutes
        long hours = ti / 60;      // number of hours
        return [NSString stringWithFormat:@"%ldh %02ldm %02lds", hours, minutes, seconds];
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
