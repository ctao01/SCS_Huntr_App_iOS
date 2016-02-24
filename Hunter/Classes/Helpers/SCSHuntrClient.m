//
//  SCSHuntrClient.m
//  Huntr
//
//  Created by Andrew Olson on 6/4/14.
//  Copyright (c) 2013 SunGard Consulting Services. All rights reserved.
//

#import "SCSHuntrClient.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFHTTPRequestOperationManager.h"

//TODO: Add Prod/Dev schemes
static NSString * const kSCSHuntrAPIBaseURLString = @"http://uzhome.no-ip.org:3000/";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://huntr-api.herokuapp.com/";
//static NSString * const kSCSHuntrAPIBaseURLString = @"http://BAPKAG.local:3000/";

@implementation SCSHuntrClient {
    __weak SCSHuntrClient * weakSelf;
    NSURLSessionConfiguration * sessionConfig;
    NSURLSession * session;
}

#pragma mark - 
#pragma mark - init
+ (SCSHuntrClient *)sharedClient {
    static SCSHuntrClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SCSHuntrClient alloc] init];
    });
    
    return _sharedClient;
}

- (id) init{
    self = [super init];
    if (self) {
        weakSelf = self;
        sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfig setHTTPAdditionalHeaders: @{@"Accept": @"application/json"}];
        session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }
    
    return self;
}


- (void) callApiGetFunction: (NSString *) apiURL success: (SCSHuntrClientSuccessBlock) successBlock failure:(SCSHuntrClientFailureBlock) failureBlock{
    NSString * urlString = [[NSString stringWithFormat: @"%@%@", kSCSHuntrAPIBaseURLString, apiURL] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"Calling function %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlString]];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                if (httpResponse.statusCode == HTTPStatusCode.) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        //[self handleSearchResults:data];
                                                        NSError *jsonError;
                                                        id responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:&jsonError];
                                                        if(responseData){
                                                            // NSLog(@"API Response Data: %@", responseData);
                                                            
                                                            successBlock(responseData);
                                                        }
                                                        else{
                                                            failureBlock([NSString stringWithFormat: @"%@", jsonError]);
                                                        }
                                                    });
                                                } else {
                                                    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                    NSLog(@"Received HTTP %ld: %@", (long)httpResponse.statusCode, body);
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
                                                    });
                                                }
                                                
                                            }];
    
    [task resume];
}

- (void) callApiPostFunction: (NSString *) apiURL postParameters: (NSDictionary *) parameterList success: (SCSHuntrClientSuccessBlock) successBlock failure:(SCSHuntrClientFailureBlock) failureBlock{
    NSString * urlString = [[NSString stringWithFormat: @"%@%@", kSCSHuntrAPIBaseURLString, apiURL] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"Calling function %@", urlString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlString]];
    request.HTTPMethod = @"POST";
    
    
    NSString *postDataString = @"";
    for(id key in parameterList) {
        NSString * value = [parameterList objectForKey:key];
        postDataString = [NSString stringWithFormat:@"%@%@=%@&", postDataString, key, value];
    }
    request.HTTPBody = [postDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Post Body = %@", postDataString);
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                if (httpResponse.statusCode ==200) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        //[self handleSearchResults:data];
                                                        NSError *jsonError;
                                                        id responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves error:&jsonError];
                                                        if(responseData){
                                                            //  NSLog(@"API Response Data: %@", responseData);
                                                            
                                                            successBlock(responseData);
                                                        }
                                                        else{
                                                            failureBlock([NSString stringWithFormat: @"%@", jsonError]);
                                                        }
                                                    });
                                                } else {
                                                    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                    NSLog(@"Received HTTP %ld: %@", (long)httpResponse.statusCode, body);
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        failureBlock([NSString stringWithFormat: @"Received HTTP %ld", (long)httpResponse.statusCode]);
                                                    });
                                                }
                                                
                                            }];
    
    [task resume];
}

- (void) callApiPostImageFunction: (NSString *) apiURL postParameters: (UIImage *) image success: (SCSHuntrClientSuccessBlock) successBlock failure:(SCSHuntrClientFailureBlock) failureBlock{
    NSString * urlString = [[NSString stringWithFormat: @"%@%@", kSCSHuntrAPIBaseURLString, apiURL] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"Calling function %@", image.description);
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kSCSHuntrAPIBaseURLString]];
    NSDictionary *parameters = @{@"foo": @"bar"};
    
    AFHTTPRequestOperation *requestOperation = [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"photoAnswer" fileName:@"answer.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
        NSLog(@"Success: %@ ***** %@", operation.responseString, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failureBlock(operation.responseString);
        NSLog(@"Error: %@ ***** %@", operation.responseString, error);
    }];
    
    [requestOperation start];
}


@end
