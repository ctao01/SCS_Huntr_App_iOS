//
//  NSString+EnumParser.m
//  Huntr
//
//  Created by Joy Tao on 4/22/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "NSString+EnumParser.h"

@implementation NSString (EnumParser)

- (GameStatus) statusEnumFromString
{
    NSDictionary<NSString*,NSNumber*> *status = @{
                                                  @"Not Started": @(NotStarted),
                                                  @"In Progress": @(InProgress),
                                                  @"Completed": @(Completed),
                                                  };
    return status[self].integerValue;
}
@end
