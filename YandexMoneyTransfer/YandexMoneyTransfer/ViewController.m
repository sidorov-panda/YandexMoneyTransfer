//
//  ViewController.m
//  YandexMoneyTransfer
//
//  Created by Alex on 27.09.15.
//  Copyright (c) 2015 Yandex Money. All rights reserved.
//

#import "ViewController.h"
#import "API.h"


@interface ViewController ()

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
    
    [API autorizeWithSomething];
    
    
    [self prepareViews];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI

- (void)prepareViews {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.backgroundColor = [UIColor greenColor];
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
    containerView.backgroundColor = [UIColor redColor];
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


@end
