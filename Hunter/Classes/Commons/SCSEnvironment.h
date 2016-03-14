//
//  SCSEnvironment.h
//  Hunter
//
//  Created by Joy Tao on 2/24/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSPlayer.h"

@interface SCSEnvironment : NSObject

@property (nonatomic, strong) SCSPlayer * currentPlayer;

+ (instancetype)sharedInstance;
- (BOOL) hasRegisteredPlayer;
- (BOOL) hasStartedGame;



@end
