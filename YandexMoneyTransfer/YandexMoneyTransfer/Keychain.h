//
//  Keychain.h
//  YandexMoneyTransfer
//
//  Created by Alexey Sidorov on 28/09/15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)delete:(NSString *)service;

@end
