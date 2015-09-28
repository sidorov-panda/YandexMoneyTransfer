//
//  API.m
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import "API.h"
#import "NetworkLayer.h"
#import "UIWebView+API.h"

NSString *const APIBaseURLString = @"https://m.money.yandex.ru/";
NSString *const APIClientIDString = @"3AEF1CAA163CACC9EE006CC306C2BF210C99B8A80AA61A7DAD43C493EFFD7F3E";



NSURL *NSURLFromAPIMethod(APIMethod method) {
    NSString *methodURLString = @"";
    switch (method) {
        case APIMethodAuthorize:
            methodURLString = @"oauth/authorize/";
            break;
            
        default:
            return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", APIBaseURLString, methodURLString]];
};


@interface API ()

@property (nonatomic) BOOL hasToken;

@end

@implementation API

+ (instancetype)sharedInstance {
    static API *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[API alloc] init];
    });
    return sharedInstance;
}

- (void)autorizeWithSomething {
    
    id<APIDelegate> delegate = self.delegate;
    if (delegate) {
        if ([delegate respondsToSelector:@selector(APINeedsToPresentAuthorizationWebView:)]) {
            [delegate APINeedsToPresentAuthorizationWebView:[UIWebView autorizationWebView]];
        }
    }
    
    [[NetworkLayer sharedInstance] performRequestWithURL:NSURLFromAPIMethod(APIMethodAuthorize) method:NetworkLayerMethodPOST parameters:[[APIRequest defaultRequest] dictionary] completion:^(NSData *response, NSError *error) {
        if (!error) {
            [APIResponse responseWithData:response];
        }
    }];
}


@end


static NSString *const APIRequestClientIdKey = @"client_id";
static NSString *const APIRequestResponseTypeKey = @"response_type";
static NSString *const APIRequestRedirectURIKey = @"redirect_uri";
static NSString *const APIRequestScopeKey = @"scope";


@implementation APIRequest

#pragma mark - Initializers

- (instancetype)initWithClientId:(NSString *)clientId responseType:(NSString *)responseType redirectURI:(NSString *)redirectURI scope:(NSString *)scope {
    self = [self init];
    if (self) {
        self.clientId = clientId;
        self.responseType = responseType;
        self.redirectURI = redirectURI;
        self.scope = scope;
    }
    return self;
}

+ (instancetype)defaultRequest {
    return [[APIRequest alloc] initWithClientId:APIClientIDString responseType:@"code" redirectURI:@"http://yandex.ru" scope:@"account-info"];
}

#pragma mark Methods

- (NSDictionary *)dictionary {
    return @{APIRequestClientIdKey : self.clientId,
             APIRequestResponseTypeKey : self.responseType,
             APIRequestRedirectURIKey : self.redirectURI,
             APIRequestScopeKey : self.scope,
             };
}


@end



@implementation APIResponse

+ (instancetype)responseWithData:(NSData *)data {
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    
    return [APIResponse new];
}

@end