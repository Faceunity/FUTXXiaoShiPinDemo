//
//  TCRegisterViewController.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCRegisterViewController.h"
#import "UIView+CustomAutoLayout.h"
#import "TCLoginModel.h"

@interface TCRegisterViewController ()

@end

@implementation TCRegisterViewController
{
    UITextField    *_accountTextField;  // 用户名/手机号
    UITextField    *_pwdTextField;      // 密码/验证码
    UITextField    *_pwdTextField2;     // 确认密码（用户名注册）

    UIButton       *_regBtn;            // 注册
    UIView         *_lineView1;
    UIView         *_lineView2;
    UIView         *_lineView3;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickScreen)];
    [self.view addGestureRecognizer:tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)initUI {
    UIImage *image = [UIImage imageNamed:@"loginBG"];
    self.view.layer.contents = (id)image.CGImage;
    
    _accountTextField = [[UITextField alloc] init];
    _accountTextField.font = [UIFont systemFontOfSize:14];
    _accountTextField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _accountTextField.returnKeyType = UIReturnKeyNext;
    _accountTextField.delegate = self;
    
    _pwdTextField = [[UITextField alloc] init];
    _pwdTextField.font = [UIFont systemFontOfSize:14];
    _pwdTextField.textColor = [UIColor colorWithWhite:1 alpha:1];
    _pwdTextField.returnKeyType = UIReturnKeyNext;
    _pwdTextField.delegate = self;
    
    _pwdTextField2 = [[UITextField alloc] init];
    _pwdTextField2.font = [UIFont systemFontOfSize:14];
    _pwdTextField2.textColor = [UIColor colorWithWhite:1 alpha:1];
    _pwdTextField2.secureTextEntry = YES;
    [_pwdTextField2 setPlaceholder:@"确认密码"];
    _pwdTextField2.returnKeyType = UIReturnKeyGo;
    _pwdTextField2.delegate = self;
    
    _lineView1 = [[UIView alloc] init];
    [_lineView1 setBackgroundColor:[UIColor whiteColor]];
    
    _lineView2 = [[UIView alloc] init];
    [_lineView2 setBackgroundColor:[UIColor whiteColor]];
    
    _lineView3 = [[UIView alloc] init];
    [_lineView3 setBackgroundColor:[UIColor whiteColor]];
    
    
    _regBtn = [[UIButton alloc] init];
    _regBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_regBtn setTitle:@"注册" forState:UIControlStateNormal];
    [_regBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_regBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [_regBtn setBackgroundImage:[UIImage imageNamed:@"button_pressed"] forState:UIControlStateSelected];
    [_regBtn addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    
   
    [self.view addSubview:_accountTextField];
    [self.view addSubview:_lineView1];
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_lineView2];
    [self.view addSubview:_pwdTextField2];
    [self.view addSubview:_lineView3];
    [self.view addSubview:_regBtn];
    
    [self relayout];
}

- (void)relayout {
    CGFloat screen_width = self.view.bounds.size.width;
    
    [_accountTextField sizeWith:CGSizeMake(screen_width - 50, 33)];
    [_accountTextField alignParentTopWithMargin:97];
    [_accountTextField alignParentLeftWithMargin:25];
    
    [_lineView1 sizeWith:CGSizeMake(screen_width - 44, 1)];
    [_lineView1 layoutBelow:_accountTextField margin:6];
    [_lineView1 alignParentLeftWithMargin:22];
    
    [_pwdTextField sizeWith:CGSizeMake(screen_width - 50, 33)];

    [_pwdTextField layoutBelow:_lineView1 margin:6];
    [_pwdTextField alignParentLeftWithMargin:25];
    
    [_lineView2 sizeWith:CGSizeMake(screen_width - 44, 1)];
    [_lineView2 layoutBelow:_pwdTextField margin:6];
    [_lineView2 alignParentLeftWithMargin:22];
    

    [_pwdTextField2 sizeWith:CGSizeMake(screen_width - 50, 33)];
    [_pwdTextField2 layoutBelow:_lineView2 margin:6];
    [_pwdTextField2 alignParentLeftWithMargin:25];
    
    [_lineView3 sizeWith:CGSizeMake(screen_width - 44, 1)];
    [_lineView3 layoutBelow:_pwdTextField2 margin:6];
    [_lineView3 alignParentLeftWithMargin:22];
    
    [_regBtn sizeWith:CGSizeMake(screen_width - 44, 35)];
    [_regBtn layoutBelow:_lineView3 margin:36];
    [_regBtn alignParentLeftWithMargin:22];
    
    [_accountTextField setPlaceholder:@"用户名以字母开头，支持字母、数字、下划线"];
    [_accountTextField setText:@""];
    _accountTextField.keyboardType = UIKeyboardTypeDefault;
    [_pwdTextField setPlaceholder:@"用户密码支持字母、数字、下划线"];
    [_pwdTextField setText:@""];
    [_pwdTextField2 setText:@""];
    _pwdTextField.secureTextEntry = YES;
    _pwdTextField2.hidden = NO;
    _lineView3.hidden = NO;
    
    _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
    _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
    _pwdTextField2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_pwdTextField2.placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.5]}];
}

- (void)clickScreen {
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_pwdTextField2 resignFirstResponder];
}

- (void)reg:(UIButton *)button {
    TCLoginModel *loginModel = [TCLoginModel sharedInstance];
    
    NSString *userName = _accountTextField.text;
    NSString *failedReason = nil;
    
    if (![loginModel validateUserName:userName failedReason:&failedReason]) {
        [HUDHelper alertTitle:@"用户名错误" message:failedReason cancel:@"确定"];
        return;
    }
    
    NSString *pwd = _pwdTextField.text;
    if (![loginModel validatePassword:pwd failedReason:&failedReason]) {
        [HUDHelper alertTitle:@"密码错误" message:failedReason cancel:@"确定"];
        return;
    }
   
    NSString *pwd2 = _pwdTextField2.text;
    if ([pwd compare:pwd2] != NSOrderedSame) {
        [HUDHelper alertTitle:@"密码错误" message:@"两次密码不一致" cancel:@"确定"];
        return;
    }
    
    // 用户名密码注册
    __weak typeof(self) weakSelf = self;
    [[HUDHelper sharedInstance] syncLoading];
    [[TCLoginModel sharedInstance] registerWithUsername:userName password:pwd succ:^(NSString *userName, NSString *md5pwd) {
        // 注册成功后直接登录
        [[TCLoginModel sharedInstance] loginWithUsername:userName password:pwd succ:^(NSString* userName, NSString* md5pwd ,NSString *token,NSString *refreshToken,NSInteger expires) {
            [[HUDHelper sharedInstance] syncStopLoading];
            [weakSelf.loginListener loginOK:userName hashedPwd:md5pwd token:token refreshToken:refreshToken expires:expires];
        } fail:^(NSString *userName, int errCode, NSString *errMsg) {
            [[HUDHelper sharedInstance] syncStopLoading];
            [weakSelf.loginListener loginFail:userName code:errCode message:errMsg];
            NSLog(@"%s %d %@", __func__, errCode, errMsg);
        }];
        [TCUtil report:xiaoshipin_register userName:userName code:200 msg:@"注册成功"];
    } fail:^(int errCode, NSString *errMsg) {
        [[HUDHelper sharedInstance] syncStopLoading];
        
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:userName forKey:@"userName"];
        [param setObject:@"register" forKey:@"action"];
        
        if (errCode == 612) {
            [HUDHelper alertTitle:@"提示" message:@"用户ID已经被注册" cancel:@"确定"];
            [TCUtil report:xiaoshipin_register userName:userName code:errCode msg:@"用户ID已经被注册"];
        }else{
            [HUDHelper alertTitle:@"提示" message:[NSString stringWithFormat:@"错误码: %d", errCode] cancel:@"确定"];
            [TCUtil report:xiaoshipin_register userName:userName code:errCode msg:errMsg];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSArray<UITextField *> *chain = @[_accountTextField, _pwdTextField, _pwdTextField2];
    NSInteger index = [chain indexOfObject:textField];
    if (index != NSNotFound) {
        if (index < chain.count - 1) {
            [chain[index + 1] becomeFirstResponder];
        } else {
    [textField resignFirstResponder];
            [self reg:nil];
        }
    }
    return YES;
}

@end
