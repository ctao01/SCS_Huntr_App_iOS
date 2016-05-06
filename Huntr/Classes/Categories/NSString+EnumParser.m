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
                                                  @"Not Started": @(GameStatusNotStarted),
                                                  @"In Progress": @(GameStatusInProgress),
                                                  @"Completed": @(GameStatusCompleted),
                                                  };
    return (GameStatus)status[self].integerValue;
}

- (ClueType) clueTypeFromString
{
    NSDictionary<NSString*,NSNumber*> *type = @{
                                                  @"Location": @(ClueTypeLocation),
                                                  @"Picture": @(ClueTypePicture)
                                                  };
    
    return (ClueType)type[self].integerValue;
}

@end
