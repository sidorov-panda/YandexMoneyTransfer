//
//  NetworkLayer.h
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import <Foundation/Foundation.h>

//@protocol NetworkLayerProtocol <NSObject>
//
//@required
//
//
//@end

typedef NS_ENUM(NSUInteger, NetworkLayerMethod) {
    NetworkLayerMethodPOST,
    NetworkLayerMethodGET,
};

extern NSString *NSStringFromNetworkLayerMethod(NetworkLayerMethod method);


@interface NetworkLayer : NSObject

+ (instancetype)sharedInstance;

- (void)performRequestWithURL:(NSURL *)url method:(NetworkLayerMethod)method parameters:(NSDictionary *)params completion:(void (^)(NSData *response, NSError *error))completion;

- (void)setToken:(NSString *)token;

@end
