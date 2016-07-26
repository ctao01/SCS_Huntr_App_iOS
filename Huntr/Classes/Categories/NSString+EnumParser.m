//
//  NSString+EnumParser.m
//  Huntr
//
//  Created by Joy Tao on 4/22/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import "NSString+EnumParser.h"

@implementation NSString (EnumParser)

//- (SCSGameStatus) statusEnumFromString
//{
//    NSDictionary<NSString*,NSNumber*> *status = @{
//                                                    @"unknown": @(SCSGameStatusUnknown),
//                                                    @"not started": @(SCSGameStatusNotStarted),
//                                                    @"in progress": @(SCSGameStatusInProgress),
//                                                    @"completed": @(SCSGameStatusCompleted),
//                                                 };
//    return (SCSGameStatus)status[self.lowercaseString].integerValue;
//}

- (SCSClueType) clueTypeFromString
{
    NSDictionary<NSString*,NSNumber*> *type = @{
                                                    @"unknown": @(SCSClueTypeUnknown),
                                                    @"location": @(SCSClueTypeLocation),
                                                    @"picture": @(SCSClueTypePicture),
                                               };
    
    return (SCSClueType)type[self.lowercaseString].integerValue;
}

@end
