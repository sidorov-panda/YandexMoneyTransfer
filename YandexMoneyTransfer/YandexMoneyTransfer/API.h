//
//  API.h
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIWebView;

//API Methods
typedef NS_ENUM(NSUInteger, APIMethod) {
    APIMethodAuthorize,
    APIMethodToken,
};

extern NSString *const APIBaseURLString;
extern NSString *const APIClientIDString;
extern NSURL *NSURLFromAPIMethod(APIMethod method);


@protocol APIDelegate <NSObject>

- (void)APINeedsToPresentAuthorizationWebView:(UIWebView *)webView;

- (void)APIDismissWebView:(UIWebView *)webView;



@end


@interface API : NSObject

@property (weak, nonatomic) id<APIDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)autorizeWithSomething;


@end




@interface APIRequest : NSObject

@property (copy, nonatomic) NSString *clientId;

@property (copy, nonatomic) NSString *responseType;

@property (copy, nonatomic) NSString *redirectURI;

@property (copy, nonatomic) NSString *scope;


- (instancetype)initWithClientId:(NSString *)clientId responseType:(NSString *)responseType redirectURI:(NSString *)redirectURI scope:(NSString *)scope;

+ (instancetype)defaultRequest;

- (NSDictionary *)dictionary;


@end


@interface APIResponse : NSObject

@property (strong, nonatomic, readonly) NSString *responseString;

+ (instancetype)responseWithData:(NSData *)data;

@end