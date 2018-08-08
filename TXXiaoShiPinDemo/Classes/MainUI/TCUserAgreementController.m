//
//  TCUserAgreementController.m
//  TCLVBIMDemo
//
//  Created by zhangxiang on 16/9/14.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCUserAgreementController.h"
#import "UIView+Additions.h"
#import "AppDelegate.h"
#import "TCLoginModel.h"

@implementation TCUserAgreementController
{
    UIWebView *_webView;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"用户协议";
    CGFloat bottom = self.view.height;

    BOOL hasBottomInsets = NO;
    if (@available(iOS 11, *)) {
        CGFloat bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        bottom -= bottomInset;
        hasBottomInsets = bottomInset > 0;
    }

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, bottom - 50)];
    [self.view addSubview:_webView];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"UserProtocol"
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    [_webView loadHTMLString:htmlCont baseURL:baseURL];

    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, bottom - 50, self.view.width, 0.5)];
    lineView1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(self.view.width/2,lineView1.bottom, 0.5, 49)];
    lineView2.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView2];

    if (hasBottomInsets) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, self.view.width, 0.5)];
        lineView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:lineView];
    }

    //同意
    UIButton *unAgreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unAgreeBtn.frame = CGRectMake(0,lineView1.bottom, self.view.width/2, 49);
    [unAgreeBtn setTitle:@"不同意" forState:UIControlStateNormal];
    [unAgreeBtn setTitleColor:RGB(237, 100, 85) forState:UIControlStateNormal];
    [unAgreeBtn addTarget:self action:@selector(unAgreeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unAgreeBtn];
    
    //不同意
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.frame = CGRectMake(self.view.width/2 + 1, lineView1.bottom, self.view.width/2, 49);
    [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
    [agreeBtn setTitleColor:RGB(237, 100, 85) forState:UIControlStateNormal];
    [agreeBtn addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreeBtn];
}

-(void)unAgreeClick{
    if(_agree) _agree(NO);
//    AppDelegate *app = [UIApplication sharedApplication].delegate;
//    [[TCLoginModel sharedInstance] logout:^{
//        [app enterLoginUI];
//    }];
}

-(void)agreeClick{
    if(_agree) _agree(YES);
//  [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:hasAgreeUserAgreement];
//  [[AppDelegate sharedAppDelegate] enterMainUI];
}
@end
