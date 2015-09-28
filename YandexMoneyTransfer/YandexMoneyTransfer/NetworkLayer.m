//
//  NetworkLayer.m
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import "NetworkLayer.h"


NSString *NSStringFromNetworkLayerMethod(NetworkLayerMethod method) {
    switch (method) {
        case NetworkLayerMethodGET:
            return @"GET";
            
        case NetworkLayerMethodPOST:
            return @"POST";
            
        default:
            NSLog(@"NetworkLayerMethod unknown method %lu, using GET instead", (unsigned long)method);
            return @"GET";
    }
};

@interface NetworkLayer () <NSURLSessionDelegate>

@end


@implementation NetworkLayer


- (instancetype)init {
    self = [super init];
    
    return self;
}


+ (void)performRequestWithURL:(NSURL *)url method:(NetworkLayerMethod)method parameters:(NSDictionary *)params completion:(void (^)(NSData *response, NSError *error))completion {

    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:NSStringFromNetworkLayerMethod(method)];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
    }];
    
    [postDataTask resume];
    
    
}




@end
