//
//  API.m
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import "API.h"
#import "NetworkLayer.h"

static NSString *const ApiBaseURLString = @"https://m.money.yandex.ru/";

@implementation API


+ (void)autorizeWithSomething {

    const NSString *authURLString = @"oauth/authorize/";
    
    [NetworkLayer performRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", ApiBaseURLString, authURLString]] completion:^(NSData *response, NSError *error) {
        
    }];
    

}


@end


@implementation APIRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}


- (instancetype)initWithClientId:(NSString *)clientId responseType:(NSString *)responseType redirectURI:(NSString *)redirectURI scope:(NSString *)scope {
    self = [self init];
    if (self) {
    
    }
    return self;
}

@end





@interface APIResponse : NSObject

@end

@implementation APIResponse



@end