//
//  SCSAnswer.h
//  Huntr
//
//  Created by Joy Tao on 4/26/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSEntity.h"

typedef NS_ENUM(NSInteger, SCSAnswerState) {
    SCSAnswerStateUnknown,
    SCSAnswerStatePending,
    SCSAnswerStateAccepted,
    SCSAnswerStateRejected
};

@interface SCSAnswer : SCSEntity

@property (nonatomic, readonly) SCSAnswerState answerState;

@property (nonatomic, readonly) BOOL isCorrect;
@property (nonatomic, readonly) BOOL isPending;

@property (nonatomic , strong) NSString * teamId;
@property (nonatomic , strong) NSString * playerName;
@property (nonatomic , strong) NSString * answerImageUrl;
@property (nonatomic , strong) CLLocation * answerLocation;
@property (nonatomic , strong) NSDate * submittedTime;

- (id)initWithJSON:(NSDictionary *) json;

@end
