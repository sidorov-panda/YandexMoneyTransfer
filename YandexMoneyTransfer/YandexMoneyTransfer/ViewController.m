//
//  ViewController.m
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright (c) 2015 Yandex Money. All rights reserved.
//

#import "ViewController.h"
#import "WebView.h"
#import "API.h"


//455BC78DAA7131ED2EB11CD308BA0028970998311EEA7FE2E857686A86087B0515231FD31D3DE191FE2CDA50BA879164B5EE7E413EE335BBB238056B93221AECCCAA30F0F18276D651108D8A897F124973B2A4CE9B01D56A5C52B217A824926891BA3EEE15F9C2E58DF1FF34CD449EA4B82C982F167F9F6BB9D901B03728A730


@interface ViewController () <UIWebViewDelegate, APIDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *recipientTextField;

@property (strong, nonatomic) UITextField *amountTextField;

@property (strong, nonatomic) UITextField *recipientAmountTextField;

@property (strong, nonatomic) UITextView *commentTextView;

@property (strong, nonatomic) UITextField *captchaTextField;

@property (strong, nonatomic) UITextField *daysToReceiveTextField;

@end


@implementation ViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareViews];
    
    [API sharedInstance].delegate = self;
    [[API sharedInstance] autorizeWithSomething];
    
    
//    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI

- (void)prepareViews {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
//    self.scrollView.backgroundColor = [UIColor greenColor];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"scrollView" : self.scrollView,
                                                                                @"view" : self.view
                                                                                }]
     ];
                                                                        

                               
   [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:@{@"scrollView" : self.scrollView,
                                                                               @"view" : self.view
                                                                               }]
    ];
    
    
    UIView *containerView = [[UIView alloc] init];
//    containerView.backgroundColor = [UIColor redColor];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:containerView];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[container]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"container" : containerView,
                                                                                @"view" : self.view
                                                                                }]
     ];
                              

    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[container]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"container" : containerView,
                                                                                @"view" : self.view
                                                                                }]
     ];
    //(==view) doesn`t work for some reason
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
 
    
    
    
    
    
}


#pragma mark APIDelegate

- (void)APINeedsToPresentAuthorizationWebView:(UIWebView *)webView {
    webView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [self.view insertSubview:webView aboveSubview:self.scrollView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webView" : webView
                                                                                }]
     ];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webView]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"webView" : webView
                                                                                }]
     ];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
}

- (void)APIDismissWebView:(UIWebView *)webView {
    if (webView) {
        [webView removeFromSuperview];
    }
}



@end
