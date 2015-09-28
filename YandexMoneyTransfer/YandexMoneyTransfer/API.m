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

static NSString *const APIResponseCodeKey = @"code";


NSURL *NSURLFromAPIMethod(APIMethod method) {
    NSString *methodURLString = @"";
    switch (method) {
        case APIMethodAuthorize:
            methodURLString = @"oauth/authorize/";
            break;
            
        case APIMethodToken:
            methodURLString = @"oauth/token";
            break;
            
        default:
            return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", APIBaseURLString, methodURLString]];
};


@interface API () <UIWebViewDelegate>

@property (nonatomic) BOOL hasToken;

@property (strong, nonatomic) NSString *temporaryToken;

@property (strong, nonatomic) NSString *token;

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

#pragma mark - Getters / Setters

- (void)setTemporaryToken:(NSString *)temporaryToken {
    _temporaryToken = temporaryToken;
    
    //get token
    [self tokenForCode:temporaryToken completion:^(BOOL succeed) {
        
    }];
}

- (void)setToken:(NSString *)token {
    _token = token;
    
    
    //save to keychain
}

#pragma mark - API Methods

- (void)tokenForCode:(NSString *)code completion:(void (^)(BOOL succeed))completion {
    
    NSMutableDictionary *params = [[APIRequest defaultRequest] dictionary].mutableCopy;
    params[APIResponseCodeKey] = code;
    [[NetworkLayer sharedInstance] performRequestWithURL:NSURLFromAPIMethod(APIMethodToken) method:NetworkLayerMethodPOST parameters:params.copy completion:^(NSData *response, NSError *error) {
        if (!error) {
            APIResponse *resp = [APIResponse responseWithData:response];
            
            if (completion) {
                completion(YES);
            }
        }
    }];
}


- (void)autorizeWithSomething {
    
    id<APIDelegate> delegate = self.delegate;
    if (delegate) {
        if ([delegate respondsToSelector:@selector(APINeedsToPresentAuthorizationWebView:)]) {
            UIWebView *webView = [UIWebView autorizationWebView];
            webView.delegate = self;
            [delegate APINeedsToPresentAuthorizationWebView:webView];
        }
    }
    
    [[NetworkLayer sharedInstance] performRequestWithURL:NSURLFromAPIMethod(APIMethodAuthorize) method:NetworkLayerMethodPOST parameters:[[APIRequest defaultRequest] dictionary] completion:^(NSData *response, NSError *error) {
        if (!error) {
            APIResponse *resp = [APIResponse responseWithData:response];
            
        }
    }];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"request %@", request.URL);
    NSLog(@"request %@", request.URL.query);
    
    NSURLComponents *components = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:YES];
    
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSURLQueryItem class]]) {
            if ([[(NSURLQueryItem *)obj name] isEqualToString:APIResponseCodeKey]) {
                self.temporaryToken = [(NSURLQueryItem *)obj value].copy;
                
                id<APIDelegate> delegate = self.delegate;
                if (delegate) {
                    if ([delegate respondsToSelector:@selector(APIDismissWebView:)]) {
                        [delegate APIDismissWebView:webView];
                    }
                }
            }
        }
    }];
    
    return YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
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
    return [[APIRequest alloc] initWithClientId:APIClientIDString responseType:APIResponseCodeKey redirectURI:@"http://yandex.ru" scope:@"account-info"];
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