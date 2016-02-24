//
//  SCSHuntrClient.h
//  Huntr
//
//  Created by Andrew Olson on 6/4/14.
//  Copyright (c) 2013 SunGard Consulting Services. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HTTPStatusCodeSuccess = 200,
    HTTPStatusCodeBadRequest = 400,
    HTTPStatusCodeUnauthorized = 401,
    HTTPStatusCodeForbidden = 403,
    HTTPStatusCodeNotFound = 404,
    HTTPStatusCodeServerError = 500,
    HTTPStatusCodeUnknown = 0
} HTTPStatusCode;


typedef void (^SCSHuntrClientSuccessBlock)(id JSON);
typedef void (^SCSHuntrClientFailureBlock)(NSString * errorString);

@interface SCSHuntrClient : NSObject 

+ (SCSHuntrClient *)sharedClient;

@property (retain, nonatomic) NSString * pushToken;


- (void) callApiGetFunction: (NSString *) apiURL success: (SCSHuntrClientSuccessBlock) successBlock failure:(SCSHuntrClientFailureBlock) failureBlock;
- (void) callApiPostFunction: (NSString *) apiURL postParameters: (NSDictionary *) parameterList success: (SCSHuntrClientSuccessBlock) successBlock failure:(SCSHuntrClientFailureBlock) failureBlock;
- (void) callApiPostImageFunction: (NSString *) apiURL postParameters: (UIImage *) image success: (SCSHuntrClientSuccessBlock) successBlock failure:(SCSHuntrClientFailureBlock) failureBlock;
@end
