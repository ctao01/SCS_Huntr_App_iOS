//
//  SCSEntity.m
//  HuntrGamer
//
//  Created by Andrew.Olson on 6/8/14.
//  Copyright (c) 2014 SunGard. All rights reserved.
//

#import "SCSEntity.h"


@implementation SCSEntity {
    NSDateFormatter * dateFormatter;
}

- (id)init {
    self = [super init];
    if (self) {
        dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    return self;
}

- (NSDate *)dateForApiTimeString:(NSString *) apiTimeString {
    return [dateFormatter dateFromString:apiTimeString];
}


@end
