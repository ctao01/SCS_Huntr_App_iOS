//
//  AppDelegate.h
//  Hunter
//
//  Created by Joy Tao on 2/9/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void) requestUserToRegisterWithPushNotifications;

@end

