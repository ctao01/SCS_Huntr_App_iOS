//
//  NSString+UUID.h
//  Huntr
//
//  Created by Justin Leger on 6/10/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UUID)

+ (NSString *)uuid;
+ (NSString *)stringWithNewUUID;

@end
