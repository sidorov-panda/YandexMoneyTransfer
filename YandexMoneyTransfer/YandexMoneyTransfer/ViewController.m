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


typedef NS_ENUM(NSUInteger, ViewControllerTextFieldTag) {
    ViewControllerTextFieldTagRecipient = 0,
    ViewControllerTextFieldTagRecipientAmount = 1,
    ViewControllerTextFieldTagComment = 2,
    ViewControllerTextFieldTagAmount = 3,
    ViewControllerTextFieldTagCaptcha = 4,
    ViewControllerTextFieldTagDaysToReceive = 5,
};


@interface ViewController () <UIWebViewDelegate, APIDelegate, UITextFieldDelegate, UITextViewDelegate>


#pragma mark - Properties

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UITextField *recipientTextField;

@property (strong, nonatomic) UITextField *amountTextField;

@property (strong, nonatomic) UITextField *recipientAmountTextField;

@property (strong, nonatomic) UITextView *commentTextView;

@property (strong, nonatomic) UITextField *captchaTextField;

@property (strong, nonatomic) UITextField *daysToReceiveTextField;


//Money transfer form model
@property (copy, nonatomic) NSString *recipient;

@property (nonatomic) CGFloat amount;

@property (nonatomic) CGFloat recipientAmount;

@property (copy, nonatomic) NSString *comment;

@property (copy, nonatomic) NSString *captcha;

@property (nonatomic) NSInteger daysToReceive;



@end


@implementation ViewController


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareViews];
    
    [API sharedInstance].delegate = self;
    
//    [[API sharedInstance] requestTemporaryToken];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Setters / Getters

//MoneyTransferFormModel
- (void)setAmount:(CGFloat)amount {
    _amount = amount;
    
    CGFloat recipientAmount = [self calculateRecipientAmountWithAmount:amount];
    if (recipientAmount != self.recipientAmount) {
        self.recipientAmount = recipientAmount;
        self.recipientAmountTextField.text = [NSString stringWithFormat:@"%f", recipientAmount];
    }
}

- (void)setRecipientAmount:(CGFloat)recipientAmount {
    _recipientAmount = recipientAmount;
    
    CGFloat amount = [self calculateAmountWithRecipientAmount:recipientAmount];
    if (amount != self.amount) {
        self.amount = amount;
        self.amountTextField.text = [NSString stringWithFormat:@"%f", amount];
    }
}

- (CGFloat)calculateRecipientAmountWithAmount:(CGFloat)amount {
    //replace 1.03 with real value
    return amount * 1.03;
}

- (CGFloat)calculateAmountWithRecipientAmount:(CGFloat)amount {
    return amount / 1.03;
}




#pragma mark Actions

- (void)submitButtonTaped {
    NSLog(@"I`m running");
    
    if (
        !self.recipient || !self.amount || !self.comment || !self.captcha || !self.daysToReceive) {
        return;
    }
    
    [[API sharedInstance] requestPaymentToRecipient:self.recipient amount:self.amount comment:self.comment codepro:self.captcha expirePeriod:self.daysToReceive completion:^(NSNumber *requestId, NSError *error) {
        if ([requestId isKindOfClass:[NSNumber class]]) {
            [[API sharedInstance] processPaymentWithRequestId:requestId moneySource:@"wallet" completion:^(BOOL succeed) {
                if (succeed) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ол Райт"
                                                                    message:@"It was nice to work with you"
                                                                   delegate:self
                                                          cancelButtonTitle:@"cancel"
                                                          otherButtonTitles:nil, nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [alert show];
                    });
                }
            }];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"So bad"
                                                            message:error.description
                                                           delegate:self
                                                  cancelButtonTitle:@"cancel"
                                                  otherButtonTitles:nil, nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });

        }
    }];
    
    
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    switch (textField.tag) {
        case ViewControllerTextFieldTagAmount: {
            self.amount = [[textField.text stringByReplacingCharactersInRange:range withString:string] floatValue];
        }
            break;
            
        case ViewControllerTextFieldTagRecipientAmount: {
            self.recipientAmount = [[textField.text stringByReplacingCharactersInRange:range withString:string] floatValue];
        }
            break;
            
        case ViewControllerTextFieldTagDaysToReceive: {
            self.daysToReceive = [[textField.text stringByReplacingCharactersInRange:range withString:string] integerValue];
        }
            break;

        case ViewControllerTextFieldTagCaptcha: {
            self.captcha = [textField.text stringByReplacingCharactersInRange:range withString:string];
        }
            break;

        case ViewControllerTextFieldTagRecipient: {
            self.recipient = [textField.text stringByReplacingCharactersInRange:range withString:string];
        }
            break;
            
            
        default:
            break;
    }
    
    
    return YES;
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.comment = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return YES;
}


#pragma mark - UI

- (void)prepareViews {
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
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
 
    self.recipientTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.recipientTextField.tag = ViewControllerTextFieldTagRecipient;
    self.recipientTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.recipientTextField.placeholder = @"Recipient";
    self.recipientTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.recipientTextField.delegate = self;
    [containerView addSubview:self.recipientTextField];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[recipient]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"recipient" : self.recipientTextField
                                                                                }]
     ];
    
    
    self.amountTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.amountTextField.tag = ViewControllerTextFieldTagAmount;
    self.amountTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.amountTextField.placeholder = @"Amount";
    self.amountTextField.delegate = self;
    self.amountTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.amountTextField];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[amount]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"amount" : self.amountTextField
                                                                                    }]
     ];
    
    self.recipientAmountTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.recipientAmountTextField.tag = ViewControllerTextFieldTagRecipientAmount;
    self.recipientAmountTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.recipientAmountTextField.placeholder = @"Recipient Amount";
    self.recipientAmountTextField.delegate = self;
    self.recipientAmountTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.recipientAmountTextField];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[recipientAmountTextField]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"recipientAmountTextField" : self.recipientAmountTextField
                                                                                    }]
     ];
    
    self.commentTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.commentTextView.tag = ViewControllerTextFieldTagComment;
    self.commentTextView.text = @"I`m commentTextView";
    self.commentTextView.delegate = self;
    self.commentTextView.backgroundColor = [UIColor yellowColor];
    self.commentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.commentTextView];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[commentTextView]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"commentTextView" : self.commentTextView
                                                                                    }]
     ];
    
    self.captchaTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.captchaTextField.tag = ViewControllerTextFieldTagCaptcha;
    self.captchaTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.captchaTextField.placeholder = @"Protection";
    self.captchaTextField.delegate = self;
    self.captchaTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.captchaTextField];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[captchaTextField]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"captchaTextField" : self.captchaTextField
                                                                                    }]
     ];
    

    self.daysToReceiveTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.daysToReceiveTextField.tag = ViewControllerTextFieldTagDaysToReceive;
    self.daysToReceiveTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.daysToReceiveTextField.placeholder = @"Days To Receive";
    self.daysToReceiveTextField.delegate = self;
    self.daysToReceiveTextField.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.daysToReceiveTextField];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[daysToReceiveTextField]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"daysToReceiveTextField" : self.daysToReceiveTextField
                                                                                    }]
     ];
    
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectZero];
    submitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonTaped) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:submitButton];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[submitButton]-10-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"submitButton" : submitButton
                                                                                    }]
     ];
    
    
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[recipient(30)]-10-[amount(==recipient)]-10-[recipientAmountTextField(==recipient)]-10-[commentTextView(==50)]-10-[captchaTextField(==recipient)]-10-[daysToReceiveTextField(==recipient)]-10-[submitButton(20)]"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"amount" : self.amountTextField,
                                                                                    @"recipient" : self.recipientTextField,
                                                                                    @"recipientAmountTextField" : self.recipientAmountTextField,
                                                                                    @"commentTextView" : self.commentTextView,
                                                                                    @"captchaTextField" : self.captchaTextField,
                                                                                    @"daysToReceiveTextField" : self.daysToReceiveTextField,
                                                                                    @"submitButton" : submitButton
                                                                                    }]
     ];
    
    
    
    
    
}


#pragma mark APIDelegate

- (void)APINeedsToPresentAuthorizationWebView:(UIWebView *)webView {
    webView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    webView.alpha = 1.0;
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
        webView.alpha = 0.0;
    }
}



@end
