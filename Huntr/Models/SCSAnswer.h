//
//  SCSAnswer.h
//  Huntr
//
//  Created by Joy Tao on 4/26/16.
//  Copyright © 2016 SCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSEntity.h"

@interface SCSAnswer : SCSEntity

@property (nonatomic) BOOL isCorrect;
@property (nonatomic) BOOL isPending;
@property (nonatomic , strong) NSString * teamId;
@property (nonatomic , strong) NSString * playerName;
@property (nonatomic , strong) NSString * answerImageUrl;
@property (nonatomic , strong) CLLocation * answerLocation;
@property (nonatomic , strong) NSDate * submittedTime;

- (id)initWithJSON:(NSDictionary *) json;


@end
