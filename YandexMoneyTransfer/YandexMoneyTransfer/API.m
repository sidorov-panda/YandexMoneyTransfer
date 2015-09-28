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
#import "Keychain.h"

static NSString *const KeychainDomain = @"YandexMoneyTransferKeychainDomain";

static NSString *const APIErrorDomain = @"APIErrorDomain";

NSString *const APIBaseURLString = @"https://m.money.yandex.ru/";
NSString *const APIClientIDString = @"3AEF1CAA163CACC9EE006CC306C2BF210C99B8A80AA61A7DAD43C493EFFD7F3E";
//response keys
static NSString *const APIResponseCodeKey = @"code";
static NSString *const APIResponseGrantTypeKey = @"grant_type";

//request keys
static NSString *const APIRequestClientIdKey = @"client_id";
static NSString *const APIRequestResponseTypeKey = @"response_type";
static NSString *const APIRequestRedirectURIKey = @"redirect_uri";
static NSString *const APIRequestScopeKey = @"scope";


NSURL *NSURLFromAPIMethod(APIMethod method) {
    NSString *methodURLString = @"";
    switch (method) {
        case APIMethodAuthorize:
            methodURLString = @"oauth/authorize/";
            break;
            
        case APIMethodToken:
            methodURLString = @"oauth/token";
            break;

        case APIMethodRequestPayment:
            methodURLString = @"api/request-payment/";
            break;

        case APIMethodProcessPayment:
            methodURLString = @"api/process-payment/";
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

@synthesize token = _token;

+ (instancetype)sharedInstance {
    static API *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[API alloc] init];
        if (sharedInstance.token) {
            [[NetworkLayer sharedInstance] setToken:sharedInstance.token];
        }
    });
    return sharedInstance;
}

#pragma mark - Getters / Setters

- (void)setTemporaryToken:(NSString *)temporaryToken {
    _temporaryToken = temporaryToken;
    
    //get token
    [self tokenForCode:temporaryToken completion:^(BOOL succeed) {}];
}

- (void)setToken:(NSString *)token {
    _token = token;
    
    //save to keychain
    //TODO: move somewhere
    [Keychain save:KeychainDomain data:@{@"token" : token}];
    [[NetworkLayer sharedInstance] setToken:token];
}

- (NSString *)token {
    
    NSDictionary *dict = [Keychain load:KeychainDomain];
    return dict[@"token"] ?: nil;
}

- (void)requestPaymentToRecipient:(NSString *)recipient amount:(double)amount comment:(NSString *)comment codepro:(NSString *)codepro expirePeriod:(NSInteger)days completion:(void (^)(NSNumber *requestId, NSError *error))completion {
    
    if (!self.token) {
        //TODO: rename and change the flow
        [self requestTemporaryToken];
    }
    else {
        //Guys, I spent about hour to figure out, that https.m.money.yandex.ru is incorrect URL..
        [[NetworkLayer sharedInstance] performRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://money.yandex.ru/api/request-payment"]]
                                                      method:NetworkLayerMethodPOST
                                                  parameters:@{@"pattern_id" : @"p2p",
                                                               @"to" : recipient,
                                                               @"amount" : @(amount),
                                                               @"comment" : comment,
                                                               @"codepro" : codepro,
                                                               @"expire_period" : @(days),
                                                               @"test_payment" : @"true",
                                                               @"hold_for_pickup" : @"true",
                                                               @"test_result" : @"success"
                                                               }
                                                  completion:^(NSData *response, NSError *error) {
                                                      if (completion) {
                                                          if (!error && response) {
//@see https://tech.yandex.ru/money/doc/dg/reference/request-payment-docpage/
//It`s no desc for technical_error and empty error_description :(
//{"status":"refused","error":"technical_error","error_description":"","test_payment":"true"}
                                                              NSDictionary *data = [self dataToJSON:response];
                                                              if (data[@"request_id"]) {
                                                                  completion(@([data[@"request_id"] integerValue]), nil);
                                                                  return;
                                                              }
                                                              else {
                                                                  completion(nil, [NSError errorWithDomain:APIErrorDomain code:-1 userInfo:@{}]);
                                                              }
                                                              return;
                                                          }
                                                      }
                                                  }
         ];
    }
}

- (void)processPaymentWithRequestId:(NSNumber *)requestId moneySource:(NSString *)moneySource completion:(void (^)(BOOL succeed))completion {
    [[NetworkLayer sharedInstance] performRequestWithURL:NSURLFromAPIMethod(APIMethodProcessPayment)
                                                  method:NetworkLayerMethodPOST
                                              parameters:@{@"request_id" : requestId,
                                                           @"money_source" : moneySource,
                                                           @"test_payment" : @YES
                                                           }
                                              completion:^(NSData *response, NSError *error) {
                                                  
    }];
}

#pragma mark - JSON

- (id)dataToJSON:(NSData *)data {
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

#pragma mark - API Methods

- (void)tokenForCode:(NSString *)code completion:(void (^)(BOOL succeed))completion {
    
    NSMutableDictionary *params = [[APIRequest defaultRequest] dictionary].mutableCopy;
    params[APIResponseCodeKey] = code;
    params[APIResponseGrantTypeKey] = @"authorization_code";
    [params removeObjectForKey:APIRequestScopeKey];
    [[NetworkLayer sharedInstance] performRequestWithURL:NSURLFromAPIMethod(APIMethodToken) method:NetworkLayerMethodPOST parameters:params.copy completion:^(NSData *response, NSError *error) {
        if (!error) {
            APIResponse *resp = [APIResponse responseWithData:response];
            
            //TODO: Omg, refactor it somehow
            if (resp.responseString && [resp.responseString isKindOfClass:[NSString class]]) {
                NSError *error;
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[resp.responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
                if (json[@"access_token"] && [json[@"access_token"] isKindOfClass:[NSString class]]) {
                    [self setToken:json[@"access_token"]];
                }
            }
            
            if (completion) {
                completion(YES);
            }
        }
    }];
}


- (void)requestTemporaryToken {
    
    id<APIDelegate> delegate = self.delegate;
    if (delegate) {
        if ([delegate respondsToSelector:@selector(APINeedsToPresentAuthorizationWebView:)]) {
            UIWebView *webView = [UIWebView autorizationWebView];
            webView.delegate = self;
            [delegate APINeedsToPresentAuthorizationWebView:webView];
        }
    }
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
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


@end


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
    return [[APIRequest alloc] initWithClientId:APIClientIDString responseType:APIResponseCodeKey redirectURI:@"http://yandex.ru" scope:@"payment-p2p"];
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

@interface APIResponse ()

@property (strong, nonatomic, readwrite) NSString *responseString;

@end


@implementation APIResponse

+ (instancetype)responseWithData:(NSData *)data {
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    APIResponse *response = [[APIResponse alloc] init];
    response.responseString = dataString;
    return response;
}

@end