//
//  API.h
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

+ (void)autorizeWithSomething;



@end


@interface APIRequest : NSObject


@property (copy, nonatomic) NSString *clientId;

@property (copy, nonatomic) NSString *responseType;

@property (copy, nonatomic) NSString *redirectURI;

@property (copy, nonatomic) NSString *scope;


- (instancetype)initWithClientId:(NSString *)clientId responseType:(NSString *)responseType redirectURI:(NSString *)redirectURI scope:(NSString *)scope;


@end