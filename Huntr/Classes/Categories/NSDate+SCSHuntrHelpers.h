//
//  NSDate+SCSHuntrHelpers.h
//  Huntr
//
//  Created by Justin Leger on 8/21/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SCSHuntrHelpers)

- (NSString *) prettyTimeRemaining;

- (NSString *) prettyStartDateAndDurationFromEndDate:(NSDate *)endDate;

@end
