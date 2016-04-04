//
//  RegisterUserViewController.h
//  Hunter
//
//  Created by Joy Tao on 3/3/16.
//  Copyright © 2016 SCS. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum SCSCreateObjectType : NSInteger {
    SCSCreateObjectTypeUser = 1,
    SCSCreateObjectTypeTeam = 2,
    SCSCreateObjectTypeUnknown = 99
} SCSCreateObjectType;

@protocol NewEntityControllerDelegate;

@interface NewEntityViewController : UIViewController
@property (nonatomic , strong) IBOutlet UITextField * nameField;
@property (nonatomic , strong) IBOutlet UILabel * descriptionLabel;
@property (nonatomic, weak) id<NewEntityControllerDelegate> delegate;
@property (nonatomic, assign) SCSCreateObjectType objectType;
@end

@protocol NewEntityControllerDelegate <NSObject>
@optional
- (void) didRegisterUser;
- (void) willValidateNewTeam:(NSString*)teamName completion:(void (^)(bool isExisting))completion;
- (void) willCreateNewTeam:(NSString*)teamName;
@end
