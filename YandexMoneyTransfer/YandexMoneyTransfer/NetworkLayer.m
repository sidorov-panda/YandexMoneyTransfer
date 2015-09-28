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

typedef NS_ENUM(NSUInteger, NetworkLayerError) {
    NetworkLayerErrorTransport = 1,
    //more errors here
};

static NSString *const NetworkLayerErrorDomain = @"NetworkLayerErrorDomain";

@interface NetworkLayer () <NSURLSessionDelegate>

@end


@implementation NetworkLayer


+ (instancetype)sharedInstance {
    static NetworkLayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkLayer alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init {
    self = [super init];
    
    return self;
}


- (void)performRequestWithURL:(NSURL *)url method:(NetworkLayerMethod)method parameters:(NSDictionary *)params completion:(void (^)(NSData *response, NSError *error))completion {

    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:[NetworkLayer sharedInstance] delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:NSStringFromNetworkLayerMethod(method)];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    [request setHTTPBody:postData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(data, [NSError errorWithDomain:NetworkLayerErrorDomain code:NetworkLayerErrorTransport userInfo:@{}]);
            return;
        }
        completion(data, nil);
    }];
    [postDataTask resume];
}




@end
