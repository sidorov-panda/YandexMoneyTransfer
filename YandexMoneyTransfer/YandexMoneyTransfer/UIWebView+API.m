//
//  UIWebView+API.m
//  YandexMoneyTransfer
//
//  Created by Alexey Sidorov on 28/09/15.
//  Copyright © 2015 Yandex Money. All rights reserved.
//

#import "UIWebView+API.h"
#import "API.h"
#import "NSDictionary+UrlEncoding.h"

@implementation UIWebView (API)

+ (instancetype)autorizationWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:[NSURLFromAPIMethod(APIMethodAuthorize) absoluteString]];
    urlComponents.query = [[[APIRequest defaultRequest] dictionary] urlEncodedString];
    NSMutableURLRequest *req = [NSURLRequest requestWithURL:[urlComponents URL]].mutableCopy;
    [req setHTTPMethod:@"POST"];
    
    [webView loadRequest:req.copy];
    return webView;
}

@end
